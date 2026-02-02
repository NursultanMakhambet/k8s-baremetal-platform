# k8s-baremetal-platform

Bare-metal Kubernetes with Kubespray. This repo holds inventory and overrides; Kubespray is included as a submodule.

## Layout

- **environments/** — One directory per environment (`local`, `dev`, `prod`, etc.). Each has `hosts` (inventory) and `group_vars/`.
- **kubespray/** — Submodule. Do not edit; override behaviour via environment group_vars.
- **playbooks/** — `cluster.yml` runs Kubespray; `platform.yml` creates platform namespaces and can install Argo CD; `prepare.yml` prepares nodes (e.g. firewall).

Kubespray expects groups such as `k8s_cluster`, `kube_control_plane`, `kube_node`, `etcd`. Map your inventory groups (e.g. `k8s_master`, `k8s_worker`) in `hosts` accordingly.

## Setup (Linux)

```bash
git clone --recurse-submodules <repo-url>
./bootstrap
make cluster
```

You need Python 3.11 or 3.12 and SSH access to all inventory hosts. Ensure your inventory hostnames or IPs are reachable (e.g. via `~/.ssh/config` or your network).

Tune Kubespray via `environments/<env>/group_vars/`. Pin the Kubespray version with `kubespray_version` in group_vars, then run `make kubespray-pin` and commit.

## After the cluster is up

Run `make platform` to create namespaces (monitoring, argocd, vault, platform). See **docs/platform-namespaces.md** for the runbook and optional Argo CD install.
