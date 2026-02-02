**Role structure.**  
Every role follows the same pattern: **`tasks/main.yml`** contains only `include_tasks` calls; all real work lives in **named task files** in the same `tasks/` directory (e.g. `firewall_k8s.yml`, `firewall_postgres.yml`). That keeps main.yml as an index and makes it clear what each role does.

| Role | Task files (in `roles/<role>/tasks/`) |
|------|---------------------------------------|
| **firewall** | `firewall_install.yml`, `firewall_ports.yml` |
| **k8s** | `firewall_k8s.yml` |
| **postgres** | `firewall_postgres.yml` |
| **namespaces** | `namespaces_create.yml` |
| **argocd** | `argocd_helm.yml` |

To add a new role: create `tasks/main.yml` with includes only, add one or more named task files, then wire the role into the right playbook. See **docs/ansible-playbooks.md**.
