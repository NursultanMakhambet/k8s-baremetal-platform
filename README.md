# k8s-baremetal-platform

Bare-metal Kubernetes via Kubespray. This repo holds inventory and vars; Kubespray is a submodule.

**Layout**
- `environments/<env>/host` — inventory; `group_vars/` for that env.
- `kubespray/` — submodule (don’t edit; override in env group_vars).
- `playbooks/cluster.yml` — runs Kubespray with our inventory.
- Kubespray expects groups like `k8s_cluster`, `kube_control_plane`, `kube_node`, `etcd`; we map from `k8s_master` / `k8s_worker` in `host`.

**Setup**
```bash
git clone --recurse-submodules <repo>
./bootstrap
./make cluster   # or: make cluster (on Windows Git Bash use ./make)
```
Requires Python 3 and SSH to the hosts. Edit `environments/local/group_vars/k8s_cluster/k8s-cluster.yml` for Kubespray settings.

**Kubespray version**  
Set `kubespray_version` in `group_vars/all.yml` or env `group_vars`, then `./make kubespray-pin` and commit.

**Note**  
Ansible control node is not supported on native Windows (run playbooks from WSL or Linux). Bootstrap on Windows still prepares the venv for use under WSL or from another machine.
