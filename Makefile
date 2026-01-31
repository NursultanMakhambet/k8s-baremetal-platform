
.PHONY: help bootstrap cluster platform lint clean kubespray-init kubespray-update kubespray-pin

.DEFAULT_GOAL := help

ENV ?= local
VENV := .venv
ANSIBLE := $(VENV)/bin/ansible
ANSIBLE_PLAYBOOK := $(VENV)/bin/ansible-playbook
INVENTORY := environments/$(ENV)/host
ENV_GROUP_VARS := environments/$(ENV)/group_vars/all.yml
ROOT_GROUP_VARS := group_vars/all.yml
# kubespray_version from env group_vars, else root group_vars
KUBESPRAY_VERSION := $(shell (test -f $(ENV_GROUP_VARS) && grep 'kubespray_version' $(ENV_GROUP_VARS) || grep 'kubespray_version' $(ROOT_GROUP_VARS)) 2>/dev/null | head -1 | sed 's/.*: *//' | tr -d ' "')

help: ## Show available commands
	@grep -E '^[a-zA-Z_-]+:.*?##' $(MAKEFILE_LIST) | column -t -s '##'

# --- Kubespray submodule ---
kubespray-init: ## Clone and init Kubespray submodule (e.g. after git clone)
	git submodule update --init --recursive

kubespray-update: ## Pull current Kubespray ref, then pin to version from group_vars
	git submodule update --remote kubespray
	$(MAKE) kubespray-pin

kubespray-pin: ## Pin Kubespray to version from group_vars (root or environments/$(ENV))
	@[ -n "$(KUBESPRAY_VERSION)" ] || (echo "kubespray_version not found in $(ENV_GROUP_VARS) or $(ROOT_GROUP_VARS)" && exit 1)
	cd kubespray && git fetch --tags && git checkout $(KUBESPRAY_VERSION) && cd ..
	git add kubespray
	@echo "Run: git commit -m \"Pin Kubespray $(KUBESPRAY_VERSION)\""

# --- Local env & playbooks ---
bootstrap: $(VENV)/bin/activate ## Setup venv and Kubespray deps
$(VENV)/bin/activate:
	python3 -m venv $(VENV)
	$(VENV)/bin/pip install --upgrade pip
	$(VENV)/bin/pip install -r kubespray/requirements.txt
	$(VENV)/bin/pip install ansible-lint

cluster: ## Deploy Kubernetes cluster (Kubespray)
	$(ANSIBLE_PLAYBOOK) -i $(INVENTORY) playbooks/cluster.yml

platform: ## Deploy platform components (GitOps, ingress, monitoring)
	$(ANSIBLE_PLAYBOOK) -i $(INVENTORY) playbooks/platform.yml

lint: ## Run ansible-lint
	$(VENV)/bin/ansible-lint playbooks

clean: ## Remove local artifacts
	rm -rf $(VENV)
