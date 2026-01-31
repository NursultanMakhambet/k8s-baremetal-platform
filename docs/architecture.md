# Architecture

Bare-metal K8s, production-style. Not a lab or tutorial.

Decisions:

1. **Bootstrap** - Kubespray. We use it as a submodule, no patches. Config via inventory and group_vars only.

2. **Split** - Kubespray installs the cluster. This repo does inventory, envs, platform, GitOps.

3. **Layout** - kubespray/ (submodule), environments/ (inventory + vars), playbooks/ (thin wrappers), kubernetes/ later for ingress/GitOps/monitoring, scripts/, diagrams/ optional.

4. **Windows** - Don't use filenames like aux, con, nul. Use e.g. infra_aux.yml. If checkout fails: `git config --global core.longpaths true`.

5. **Makefile** - Minimal. Bootstrap, help, ENV, kubespray-init/pin. No product build stuff.

What it is: long-lived bare-metal K8s, portfolio-grade. What it isn't: tutorial, kubeadm-from-scratch, monolith, cloud-specific.

Optional next: CI (ansible-lint), vault for secrets, new env = copy environments/local and edit, kubernetes/ for manifests, diagrams/ for pics.
