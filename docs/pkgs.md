# Packages (pkgs)

This directory holds **custom package builds** (e.g. RPMs) used or deployable on the platform. Built artifacts are for use in your pipeline or on nodes; the main Ansible playbooks do not build them by default.

---

## Grafana (pkgs/grafana)

Builds a **Grafana RPM** for Linux (amd64) using [nfpm](https://nfpm.goreleaser.com/).

**Requirements:** `nfpm` in PATH, `wget`, `tar`. Version is taken from **group_vars** (`grafana_version`, e.g. in `group_vars/all.yml` or `environments/<env>/group_vars/all.yml`).

**From repo root:**

```bash
make grafana-pkg   # uses grafana_version from group_vars
```

**From pkgs/grafana:**

```bash
make buildrpm PRODUCT_VERSION=12.0.1
```

**Layout:**

| Path | Purpose |
|------|--------|
| **Makefile** | Downloads Grafana tarball, extracts, copies `extra/`, runs nfpm to produce RPM. |
| **nfpm.yaml** | nfpm package config (name, version placeholder, files, init script). |
| **extra/** | Files merged into the package: `grafana-server`, `grafana-server.service`, `grafana-server.sh`, `preinstall.sh`. |
| **RPM/** | Output directory for the built RPM (created by build). |
| **.build/** | Temporary download and extract dir (cleaned by `make clean`). |

**Root Makefile:** The `grafana-pkg` target reads `grafana_version` from group_vars and calls `make -C pkgs/grafana buildrpm PRODUCT_VERSION=$(GRAFANA_VERSION)`.
