# k8s-baremetal-platform

Bare-metal Kubernetes with Kubespray. This repo holds inventory and overrides; Kubespray is a submodule. Use it to prepare nodes (firewall), deploy the cluster, and bootstrap platform (namespaces, optional Argo CD). Deploy monitoring, Vault, and other apps via Argo CD or Helm from your machine.
Prefer kubectl + kubeconfig on the machine where you run Ansible; then run platform and helm from there.

**Prep (short).**  
- **kubectl on your machine** — Your machine is a client, not another master. Install kubectl and put a kubeconfig there (e.g. copy `admin.conf` from a master). Then you can run platform playbook and helm from that machine.  
- **Ansible** — One-time bootstrap: prepare nodes, cluster, namespaces, optional Argo CD.  
- **Argo CD / Helm** — Use them for day-to-day app deployments (monitoring, Vault, etc.) from Git or from your machine.

**Layout.**  
- **environments/** — One per env (default `localVM`). Each has `hosts` and `group_vars/`.  
- **playbooks/** — `prepare.yml`, `cluster.yml` (Kubespray), `platform.yml`, `controlhost_kubectl_config.yml`, `full.yml` (use tags to run only part).  
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

Replace `localVM` with your env. Run `make kubectl-config` after the cluster is up to install kubectl on the control host and copy kubeconfig from the first master (SSH to master required; fetch uses sudo on the master to read the config—if sudo needs a password, run `make kubectl-config EXTRA_ARGS="-K"`). Default config path on master is `/root/.kube/config`; override with `kubectl_config_src` in group_vars if different. Kubectl is installed to `~/.local/bin` (no sudo); ensure that dir is in PATH. Platform and kubectl-config run on the **control host** (Ansible host); inventory must define group `controlhost` with a host using `ansible_connection=local` (e.g. `localhost` in group `controlhost`). That machine needs kubectl and KUBECONFIG; for Argo CD install, helm must be in PATH.

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
| controlhost_kubectl_config | `kubectl_config` | Install kubectl on control host and copy kubeconfig from first master. |

No tags = run everything in that playbook.

---

**Connect to Argo CD.**  
Argo CD server is a ClusterIP service. From a machine with `kubectl` and kubeconfig:

1. Port-forward the server (e.g. to local port 8443):
   ```bash
   kubectl port-forward svc/argocd-server -n argocd 8443:443
   ```
2. Open **https://localhost:8443** in a browser (accept the self-signed cert).
3. Login: username **admin**. Password:
   - If you installed Argo CD via this repo’s platform role with `argocd_admin_password` set (and htpasswd available), use that value (default **admin**).
   - Otherwise:  
     `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`

---

**Docs.**  
- **docs/platform-namespaces.md** — Namespace table.  
- **docs/ansible-playbooks.md** — How to use playbooks, how to add a new role.  
- **docs/ansible-tags.md** — Tags layout, how to add tags.  
- **docs/scripts.md** — Bootstrap script and Makefile targets.  
- **docs/pkgs.md** — Custom packages (e.g. Grafana RPM build).

---

## GitOps (Argo CD + Helm)

After the cluster and Argo CD are running, deploy all platform apps via the App-of-Apps pattern.

**Structure.**

```
argocd/
  root-app.yaml            # App-of-Apps — apply this once
  applications/
    monitoring/
      prometheus.yaml       # kube-prometheus-stack
      grafana.yaml          # standalone Grafana
    vault/
      vault.yaml            # HashiCorp Vault (HA / Raft)
    exporters/
      node-exporter.yaml    # prometheus-node-exporter
helm-values/
  prometheus/values.yaml
  grafana/values.yaml
  vault/values.yaml
```

**Bootstrap (one-time).**

```bash
kubectl apply -f argocd/root-app.yaml
```

Argo CD will discover every Application YAML under `argocd/applications/` and deploy the corresponding Helm charts. All apps have automated sync with prune and self-heal enabled.

**Adding a new app.** Create an `Application` manifest in `argocd/applications/<category>/`, add a values file in `helm-values/<app>/values.yaml`, commit, and push. The root app picks it up automatically.

**Grafana admin secret.** The Grafana chart expects a pre-existing secret. Create it before the first sync:

```bash
kubectl -n monitoring create secret generic grafana-admin-credentials \
  --from-literal=admin-user=admin \
  --from-literal=admin-password='<your-password>'
```

**Vault initialization.** Vault pods start sealed. After the first sync, initialize and unseal:

```bash
kubectl -n vault exec vault-0 -- vault operator init
kubectl -n vault exec vault-0 -- vault operator unseal  # repeat with 3 unseal keys
kubectl -n vault exec vault-1 -- vault operator unseal
kubectl -n vault exec vault-2 -- vault operator unseal
```
