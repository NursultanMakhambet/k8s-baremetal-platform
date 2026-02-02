# Ansible tags

**How to use:** See README (Tags table). Use `--tags <tag>` or `TAGS=<tag>` with make to run only part of a playbook.

**Tag layout:**
- **prepare** playbook: `k8s`, `postgres`, `firewall` (task-level tags in roles k8s, postgres, firewall).
- **platform** playbook: `namespaces`, `argocd`.
- **full** playbook: `prepare`, `cluster`, `platform` (playbook-level); plus task tags when that part runs.

**How to add tags:** In a role, add `tags: [tagname]` to the `include_tasks` in `main.yml` and to tasks inside the included file so that `--tags tagname` runs only that part.
