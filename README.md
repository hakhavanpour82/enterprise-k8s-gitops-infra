# Enterprise Kubernetes GitOps Infrastructure

A production-style Kubernetes cluster provisioned entirely with **Ansible** (kubeadm-based, not managed K8s), running **Cilium** as CNI and **ArgoCD** for GitOps-driven application delivery — built as a hands-on SRE/DevOps learning project.

## Architecture

```
┌─────────────────────┐
│   1x control-plane   │  kubeadm-initialized, Ansible-provisioned
├─────────────────────┤
│   2x worker nodes     │  Hetzner Cloud VPS, Ubuntu 24.04 LTS
└─────────────────────┘
        │
        ├── Cilium (eBPF-based CNI, pod networking)
        └── ArgoCD (GitOps continuous delivery)
                │
                └── Applications defined declaratively in apps/
                    auto-synced from this repo (prune + self-heal enabled)
```

## Stack

- **Provisioning:** Ansible (roles: `os_hardening`, `k8s_install`, `k8s_cluster_init`, `k8s_cni_cilium`, `gitops_argocd`)
- **Container runtime:** containerd
- **Kubernetes:** v1.30 (kubeadm)
- **CNI:** Cilium 1.16
- **GitOps:** ArgoCD (automated sync, self-heal, prune)
- **Infra:** 3x Hetzner Cloud VPS (1 control-plane, 2 workers)

## Repository layout

```
ansible/
  inventory              # masters / workers groups
  playbooks/k8s/site.yml # entrypoint playbook
  roles/
    os_hardening/         # swap off, sysctl, kernel modules, ulimits
    k8s_install/          # containerd + kubeadm/kubelet/kubectl install
    k8s_cluster_init/     # kubeadm init + join
    k8s_cni_cilium/       # Cilium install via Helm
    gitops_argocd/        # ArgoCD install + expose
apps/
  hello-gitops/           # example app auto-deployed by ArgoCD
```

## What this demonstrates

- Debugging real infrastructure failures: broken apt repository URLs, Ansible idempotency pitfalls, kubeadm state drift across re-runs, and ArgoCD's `kubectl apply` annotation-size limitation (solved via server-side apply).
- End-to-end GitOps: a change pushed to this repo is automatically detected and reconciled onto the live cluster by ArgoCD, with no manual `kubectl apply` involved after initial bootstrap.
- Ansible role design with proper idempotency checks (`stat` + `when`) so re-running the playbook never breaks a healthy cluster.

## Status

Actively evolving — next planned additions: Ingress controller, TLS via cert-manager, and Istio service mesh integration.

## Getting started

```bash
cd ansible
ansible-playbook -i inventory playbooks/k8s/site.yml
```

Requires an `inventory` file defining `masters` and `workers` groups with SSH access, and a private key (kept out of this repo — see `.gitignore`).
