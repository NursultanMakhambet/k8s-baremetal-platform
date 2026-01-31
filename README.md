# k8s-baremetal-platform

Bare-metal Kubernetes with Kubespray (submodule). Inventory and vars live here.

Layout:
- `group_vars/all.yml` - shared vars like kubespray_version. Env overrides in `environments/<env>/group_vars/`.
- `environments/local/` - inventory file `host`, group_vars per group.
- `kubespray/` - submodule, upstream only. We don't edit it. Overrides in env group_vars.
- `playbooks/cluster.yml` - runs Kubespray cluster.yml with our inventory.
- `ansible.cfg` - default inventory, roles_path includes kubespray/roles.

Kubespray expects k8s_cluster, kube_control_plane, kube_node, etcd. We map those from k8s_master and k8s_worker in `environments/<env>/host`.

Clone:
```bash
git clone --recurse-submodules <repo-url>
# or: git submodule update --init --recursive
# or: make kubespray-init
```

Run (local):
```bash
pip install -r kubespray/requirements.txt
ansible-playbook -i environments/local/host playbooks/cluster.yml
```
Needs Ansible 2.14+, SSH to hosts. Tweak Kubespray in `environments/local/group_vars/k8s_cluster/k8s-cluster.yml`.

Bump Kubespray: set `kubespray_version` in root or env group_vars/all.yml, then `make kubespray-pin` and commit.

Roles go in `roles/`, use them in your playbooks.
