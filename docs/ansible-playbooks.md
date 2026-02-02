# Ansible playbooks

**How to use:** See README (How to run). Playbooks: `prepare.yml`, `cluster.yml`, `platform.yml`, `kubectl_config.yml`, `full.yml`. Use `-i environments/<env>/hosts` and optional `--tags`.

**How to add a new role:**
1. Create `roles/<role_name>/tasks/main.yml` with only `include_tasks` calls to named task files (e.g. `include_tasks: my_task.yml`).
2. Add task files under `roles/<role_name>/tasks/` by name (e.g. `firewall_k8s.yml`, `firewall_postgres.yml`).
3. Add the role to the right playbook (e.g. `prepare.yml` or `platform.yml`) with the right `hosts` and `tags`.
4. Add defaults in `roles/<role_name>/defaults/main.yml` if needed.

**Role layout:** Each role has `tasks/main.yml` (includes only); other tasks live in named files in the same `tasks/` dir.
