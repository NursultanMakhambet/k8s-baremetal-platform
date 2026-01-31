.PHONY: help bootstrap cluster platform lint clean kubespray-init kubespray-update kubespray-pin grafana-pkg
.DEFAULT_GOAL := help

ENV ?= local
VENV := .venv
ifeq ($(OS),Windows_NT)
VENV_BIN := $(VENV)/Scripts
PYTHON ?= python
else
VENV_BIN := $(VENV)/bin
PYTHON ?= python3
endif
ANSIBLE_PLAYBOOK := $(VENV_BIN)/ansible-playbook
INVENTORY := environments/$(ENV)/hosts
ENV_GROUP_VARS := environments/$(ENV)/group_vars/all.yml
ROOT_GROUP_VARS := group_vars/all.yml
KUBESPRAY_VERSION := $(shell (test -f $(ENV_GROUP_VARS) && grep 'kubespray_version' $(ENV_GROUP_VARS) || grep 'kubespray_version' $(ROOT_GROUP_VARS)) 2>/dev/null | head -1 | sed 's/.*: *//' | tr -d ' "')
GRAFANA_VERSION := $(shell (test -f $(ENV_GROUP_VARS) && grep 'grafana_version' $(ENV_GROUP_VARS) || grep 'grafana_version' $(ROOT_GROUP_VARS)) 2>/dev/null | head -1 | sed 's/.*: *//' | tr -d ' "')

help:
	@grep -E '^[a-zA-Z_-]+:.*?##' $(MAKEFILE_LIST) | column -t -s '##'

kubespray-init: ## Init Kubespray submodule
	git submodule update --init --recursive

kubespray-update: ## Update submodule, then pin to kubespray_version
	git submodule update --remote kubespray
	$(MAKE) kubespray-pin

kubespray-pin: ## Checkout tag from kubespray_version in group_vars
	@[ -n "$(KUBESPRAY_VERSION)" ] || (echo "kubespray_version not set" && exit 1)
	cd kubespray && git fetch --tags && git checkout $(KUBESPRAY_VERSION) && cd ..
	git add kubespray
	@echo "git commit -m \"Pin Kubespray $(KUBESPRAY_VERSION)\""

bootstrap: $(VENV_BIN)/activate ## Venv + Kubespray deps + ansible-lint
$(VENV_BIN)/activate:
	$(PYTHON) -m venv $(VENV)
	$(VENV_BIN)/pip install --upgrade pip
	$(VENV_BIN)/pip install -r kubespray/requirements.txt
	$(VENV_BIN)/pip install 'ansible-lint>=24,<25'

cluster: ## Deploy cluster (Kubespray)
	$(ANSIBLE_PLAYBOOK) -i $(INVENTORY) playbooks/cluster.yml

platform: ## Deploy platform (GitOps, ingress, monitoring)
	$(ANSIBLE_PLAYBOOK) -i $(INVENTORY) playbooks/platform.yml

lint: ## ansible-lint
	$(VENV_BIN)/ansible-lint playbooks

grafana-pkg: ## Build Grafana RPM (version from group_vars grafana_version)
	@[ -n "$(GRAFANA_VERSION)" ] || (echo "grafana_version not set in group_vars" && exit 1)
	$(MAKE) -C pkgs/grafana buildrpm PRODUCT_VERSION=$(GRAFANA_VERSION)

clean:
	rm -rf $(VENV)
