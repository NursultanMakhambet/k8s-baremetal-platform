.PHONY: build buildrpm clean
.DEFAULT_GOAL := buildrpm

MAKEFILE_PATH := $(realpath .)
RPM_DIR := $(CURDIR)/RPM
BUILD_DIR := $(CURDIR)/.build
NFPM_BIN ?= $(shell which nfpm)
NFPM_CONFIG := $(MAKEFILE_PATH)/nfpm.yaml
PRODUCT_TITLE := grafana
PRODUCT_VERSION ?= 12.0.1
DOWNLOAD_URL := https://dl.grafana.com/oss/release/$(PRODUCT_TITLE)-$(PRODUCT_VERSION).linux-amd64.tar.gz
EXTRACT_DIR := $(BUILD_DIR)/$(PRODUCT_TITLE)-v$(PRODUCT_VERSION)

build:
	mkdir -p $(BUILD_DIR)
	wget -q -O $(BUILD_DIR)/$(PRODUCT_TITLE).tar.gz $(DOWNLOAD_URL)
	tar -C $(BUILD_DIR) -xzf $(BUILD_DIR)/$(PRODUCT_TITLE).tar.gz
	[ -d $(BUILD_DIR)/$(PRODUCT_TITLE)-$(PRODUCT_VERSION) ] && mv $(BUILD_DIR)/$(PRODUCT_TITLE)-$(PRODUCT_VERSION) $(BUILD_DIR)/$(PRODUCT_TITLE)-v$(PRODUCT_VERSION); true
	cp -r $(CURDIR)/extra/* $(BUILD_DIR)

buildrpm: build
	mkdir -p $(RPM_DIR)
	sed 's/12.0.1/$(PRODUCT_VERSION)/g' $(NFPM_CONFIG) > $(BUILD_DIR)/nfpm.yaml
	$(NFPM_BIN) pkg -f $(BUILD_DIR)/nfpm.yaml --packager rpm --target $(RPM_DIR)

clean:
	rm -rf $(BUILD_DIR) $(RPM_DIR)
