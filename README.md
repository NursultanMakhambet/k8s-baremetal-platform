# k8s-baremetal-platform

Bare-metal Kubernetes with Kubespray. This repo holds inventory and overrides; Kubespray is a submodule. Use it to prepare nodes (firewall), deploy the cluster, and bootstrap platform (namespaces, optional Argo CD). Deploy monitoring, Vault, and other apps via Argo CD or Helm from your machine.
Prefer kubectl + kubeconfig on the machine where you run Ansible; then run platform and helm from there.

**Prep (short).**  
- **kubectl on your machine** — Your machine is a client, not another master. Install kubectl and put a kubeconfig there (e.g. copy `admin.conf` from a master). Then you can run platform playbook and helm from that machine.  
- **Ansible** — One-time bootstrap: prepare nodes, cluster, namespaces, optional Argo CD.  
- **Argo CD / Helm** — Use them for day-to-day app deployments (monitoring, Vault, etc.) from Git or from your machine.

**Layout.**  
- **environments/** — One per env (default `localVM`). Each has `hosts` and `group_vars/`.  
- **playbooks/** — `prepare.yml`, `cluster.yml` (Kubespray), `platform.yml`, `kubectl_config.yml`, `full.yml` (all three; use tags to run only part).  
- **roles/** — Separated by purpose (see Role structure below).

---

## How to run

**Make (default env `localVM`):**

```bash
./bootstrap   # once: venv + deps
make prepare [ENV=localVM] [TAGS=k8s|postgres|firewall]
make cluster  [ENV=localVM]
make kubectl-config [ENV=localVM]   # after cluster: install kubectl and copy kubeconfig from first master
make platform [ENV=localVM] [TAGS=namespaces|argocd] [EXTRA_ARGS="-e platform_install_argocd=true"]
make full     [ENV=localVM] [TAGS=prepare|cluster|platform] [EXTRA_ARGS="..."]
```

**One playbook (full stack with tags):**

```bash
ansible-playbook -i environments/localVM/hosts playbooks/full.yml
ansible-playbook -i environments/localVM/hosts playbooks/full.yml --tags prepare
ansible-playbook -i environments/localVM/hosts playbooks/full.yml --tags cluster
ansible-playbook -i environments/localVM/hosts playbooks/full.yml --tags platform
```

Replace `localVM` with your env. Run `make kubectl-config` after the cluster is up to install kubectl on the control host and copy kubeconfig from the first master (SSH to master required; fetch uses sudo on the master to read the config—if sudo needs a password, run `make kubectl-config EXTRA_ARGS="-K"`). Default config path on master is `/root/.kube/config`; override with `kubectl_config_src` in group_vars if different. Kubectl is installed to `~/.local/bin` (no sudo); ensure that dir is in PATH. Platform runs on localhost and needs kubectl and KUBECONFIG; for Argo CD install, helm must be in PATH.

**Multiple envs.** Kubeconfig is saved per env: `~/.kube/config-<ENV>` (e.g. `~/.kube/config-localVM`, `~/.kube/config-prod`). Run `make kubectl-config ENV=prod` to fetch config for that env. Use the one you need: `export KUBECONFIG=~/.kube/config-localVM` or `export KUBECONFIG=~/.kube/config-prod`.

**Tags.**

| Playbook / full | Tag | What runs |
|-----------------|-----|-----------|
| prepare | `k8s` | Firewall: Kubernetes ports on hosts in group `k8s`. |
| prepare | `postgres` | Firewall: Postgres ports on hosts in group `db`. |
| prepare | `firewall` | Both. |
| full | `prepare` | prepare.yml only. |
| full | `cluster` | cluster.yml (Kubespray) only. |
| full | `platform` | platform.yml only (namespaces, optional Argo CD). |
| kubectl_config | `kubectl_config` | Install kubectl and copy kubeconfig from first master. |

No tags = run everything in that playbook.

---

**Docs.**  
- **docs/platform-namespaces.md** — Namespace table.  
- **docs/ansible-playbooks.md** — How to use playbooks, how to add a new role.  
- **docs/ansible-tags.md** — Tags layout, how to add tags.
