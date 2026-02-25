# Scripts and automation

## bootstrap

One-time setup script at the repo root. Run **once** before using the project:

```bash
./bootstrap
```

**What it does:**

1. **make** — Ensures `make` is installed (tries apt-get, dnf, yum, apk, zypper).
2. **Venv check** — If `.venv` already exists and has `ansible-playbook`, it exits with “Venv exists. Run: make cluster”.
3. **Python** — On Debian/Ubuntu (apt-get), installs Python 3.11 or 3.12 and venv/dev packages (avoids 3.13 for ruamel.yaml.clib compatibility). Otherwise uses system `python3`.
4. **make bootstrap** — Creates `.venv`, installs Kubespray requirements and Ansible/ansible-lint.

After it finishes, use the Makefile (e.g. `make prepare`, `make cluster`). See **README** and **docs/ansible-playbooks.md**.

---

## Makefile (root)

All targets use **ENV** (default `localVM`) for inventory: `-i environments/$(ENV)/hosts`. Optional **TAGS** and **EXTRA_ARGS** are documented in the README.

| Target | Purpose |
|--------|--------|
| **help** | List targets with descriptions (`make` or `make help`). |
| **kubespray-init** | `git submodule update --init --recursive` for Kubespray. |
| **kubespray-update** | Update Kubespray submodule to latest, then **kubespray-pin**. |
| **kubespray-pin** | Checkout Kubespray tag from `kubespray_version` in group_vars. |
| **bootstrap** | Create `.venv`, install Kubespray deps + ansible-core + ansible-lint. Depends on **kubespray-init**. |
| **prepare** | Run `playbooks/prepare.yml` (firewall, etc.). Use **TAGS** = `k8s` \| `postgres` \| `firewall`. |
| **cluster** | Run Kubespray `playbooks/cluster.yml`. |
| **platform** | Run `playbooks/platform.yml` (namespaces, optional Argo CD). Use **TAGS** and **EXTRA_ARGS**. |
| **kubectl-config** | Install kubectl on control host and copy kubeconfig from first master; saves to `~/.kube/config-<ENV>`. |
| **full** | Run `playbooks/full.yml`; use **TAGS** = `prepare` \| `cluster` \| `platform` to run only part. |
| **lint** | Run ansible-lint on `playbooks/`. |
| **grafana-pkg** | Build Grafana RPM (see **docs/pkgs.md**). |
| **clean** | Remove `.venv`. |

Example: `make prepare ENV=prod TAGS=firewall`, `make kubectl-config ENV=localVM EXTRA_ARGS="-K"`.
