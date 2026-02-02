# How to run

Use either **make** (recommended) or **ansible-playbook** directly. Both support environment and tags.

**Environment** — Set which env to use: `localVM`, `dev`, `prod`, etc. Inventory path is `environments/<env>/hosts`. Default is `localVM` when using make.

**Tags** — Limit what runs: e.g. only firewall for Kubernetes, or only Postgres firewall, or only platform namespaces.

---

## Via make

Activate the venv first (or use the project’s `./bootstrap` once). From the repo root:

| Goal | Command | Notes |
|------|----------|--------|
| Full stack | `make full` | prepare → cluster → platform (all namespaces). Optional: `make full TAGS=k8s` (only k8s firewall in prepare), `make full EXTRA_ARGS="-e platform_install_argocd=true"` |
| Prepare nodes | `make prepare` | Firewall for k8s and db. Use `TAGS=k8s` or `TAGS=postgres` or `TAGS=firewall` to run only those parts. |
| Cluster (Kubespray) | `make cluster` | Deploys Kubernetes. |
| Platform (namespaces, Argo CD) | `make platform` | Creates namespaces; use `EXTRA_ARGS="-e platform_install_argocd=true"` to install Argo CD. Use `TAGS=namespaces` or `TAGS=argocd` to run only one part. |

**Different environment:**

```bash
make prepare ENV=prod
make cluster ENV=prod
make platform ENV=prod
# or with tags
make prepare ENV=prod TAGS=k8s
make platform ENV=prod TAGS=namespaces EXTRA_ARGS="-e platform_install_argocd=true"
```

---

## Via ansible-playbook

Use `-i environments/<env>/hosts` and optional `--tags`.

**Prepare (firewall for k8s and/or postgres):**

```bash
ansible-playbook -i environments/localVM/hosts playbooks/prepare.yml
ansible-playbook -i environments/localVM/hosts playbooks/prepare.yml --tags k8s
ansible-playbook -i environments/localVM/hosts playbooks/prepare.yml --tags postgres
ansible-playbook -i environments/localVM/hosts playbooks/prepare.yml --tags firewall
```

**Cluster (Kubespray):**

```bash
ansible-playbook -i environments/localVM/hosts playbooks/cluster.yml
```

**Platform (namespaces, optional Argo CD):**

```bash
ansible-playbook -i environments/localVM/hosts playbooks/platform.yml
ansible-playbook -i environments/localVM/hosts playbooks/platform.yml --tags namespaces
ansible-playbook -i environments/localVM/hosts playbooks/platform.yml --tags argocd -e platform_install_argocd=true
```

Replace `localVM` with your env (`dev`, `prod`, etc.) if different. Platform playbook runs on localhost and needs `kubectl` and `KUBECONFIG` set; Argo CD install also needs `helm` in PATH.

---

## Tags reference

| Playbook | Tag | What runs |
|----------|-----|-----------|
| prepare | `k8s` | Firewall: open Kubernetes/etcd ports on hosts in group `k8s`. |
| prepare | `postgres` | Firewall: open Postgres ports on hosts in group `db`. |
| prepare | `firewall` | Both k8s and postgres firewall (all prepare firewall tasks). |
| platform | `namespaces` | Create monitoring, argocd, vault, platform namespaces. |
| platform | `argocd` | Install Argo CD via Helm (only if `platform_install_argocd` is true). |

No tags = run everything in that playbook.
