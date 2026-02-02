# Platform namespaces

Standard namespaces for observability, GitOps, and shared platform services.

| Namespace    | Purpose |
|-------------|---------|
| **monitoring** | Grafana, VictoriaMetrics, Alertmanager, exporters (e.g. node-exporter). |
| **argocd**     | Argo CD (GitOps). |
| **vault**      | HashiCorp Vault, if used. |
| **platform**   | cert-manager, ingress, external-secrets, and other shared services. |

## Recommended deployment order

1. Create namespaces (once).
2. Ingress and cert-manager — so other services can use TLS and stable hostnames.
3. Argo CD — then manage the rest via GitOps (Helm charts as Argo Applications).
4. Monitoring — VictoriaMetrics (or Prometheus), Alertmanager, Grafana, exporters in `monitoring`.
5. Vault (optional) — then external-secrets or CSI if you need secrets from Vault.

Ansible creates the namespaces and can optionally install Argo CD. Deploy and upgrade Grafana, VM, Alertmanager, Vault, etc. from a Git repo via Argo CD or Helm for a single source of truth and easy rollbacks.

---

## Runbook

**Prerequisites:** Run from a machine that has `kubectl` and `KUBECONFIG` set for the target cluster. For Argo CD install, `helm` must be in PATH.

1. **Create namespaces**
   ```bash
   make platform
   ```
   Creates `monitoring`, `argocd`, `vault`, `platform`.

2. **Install Argo CD (optional)**
   ```bash
   make platform EXTRA_ARGS="-e platform_install_argocd=true"
   ```
   Or set `platform_install_argocd: true` in your environment `group_vars/all.yml` and run `make platform` once.

3. **Deploy monitoring**  
   Use Argo CD (recommended) or Helm: add an Application pointing at your Git repo with Helm charts for Grafana, VictoriaMetrics, Alertmanager, and exporters in the `monitoring` namespace. Alternatively install each component with Helm in `monitoring`.

4. **Vault and other services**  
   Deploy Vault in `vault`; cert-manager, ingress, external-secrets in `platform` (or dedicated namespaces), again via Argo CD or Helm.
