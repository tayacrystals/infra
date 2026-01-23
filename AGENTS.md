# AGENTS.md

This file provides guidance to AI Agents when working with code in this repository.

## Overview

GitOps repository for a 4-node Talos Kubernetes cluster (`tayacluster`). Manages infrastructure and applications using Flux CD for continuous delivery.

**Stack**: Talos OS, Kubernetes 1.35, Flux v2.7.5, Cilium (CNI + ingress), Longhorn (storage), Cloudflare Tunnel (external access)

## Common Commands

```bash
# Install tools (talosctl, kubectl, flux, helm)
mise install

# Check cluster health
mise run talos-health

# Open Talos dashboard for all nodes
mise run talos-dashboard

# Apply Talos config to all nodes
mise run talos-apply

# Port-forward internal dashboards
kubectl port-forward -n longhorn-system svc/longhorn-frontend 8080:80
kubectl port-forward -n flux-system svc/flux-operator 8081:80
```

## Cluster Nodes

| Node | IP | Role |
|------|-----|------|
| Node-01 | 192.168.0.101 | controlplane |
| Node-02 | 192.168.0.102 | controlplane |
| Node-03 | 192.168.0.103 | controlplane |
| Node-04 | 192.168.0.104 | worker |

## Architecture

### GitOps Deployment Flow

```
Git push → Flux watches main branch → Kustomizations deploy in order:
  1. infrastructure (Cilium, cert-manager, external-secrets, Longhorn, etc.)
  2. infrastructure-config (ClusterSecretStore for Bitwarden)
  3. apps (user applications)
```

### Network Path

```
Internet → Cloudflare Edge → cloudflared (tunnel) → Cilium Ingress → Services
```

### Key Directories

- `talos/` - Talos OS configs and patches. `secrets.yaml`, `talosconfig`, `kubeconfig` are gitignored.
- `clusters/tayacluster/infrastructure/` - Core platform services (Flux sources)
- `clusters/tayacluster/apps/` - User applications

## Adding Applications

1. Create directory: `clusters/tayacluster/apps/<app-name>/`
2. Add manifests (namespace, deployment, service, ingress)
3. Add to `clusters/tayacluster/apps/kustomization.yaml`
4. Commit and push - Flux deploys automatically

## Important Notes

- **Secrets**: Managed via External Secrets Operator syncing from Bitwarden. Never commit secrets to Git.
- **Talos config generation**: Not automated. Requires `talosctl gen config` with patches if regenerating.
- **Storage**: Longhorn provides distributed storage across nodes (NVMe tier + HDD tier).
- **Kustomization dependencies**: Infrastructure must stabilize before apps deploy. Check `dependsOn` fields.
