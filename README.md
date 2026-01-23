# tayacluster

GitOps repository for a 4-node Talos Kubernetes cluster.

## Architecture

```
Internet → Cloudflare Edge → cloudflared → Cilium Ingress → Services
```

### Components

| Component | Purpose |
|-----------|---------|
| **Talos OS** | Immutable Kubernetes OS on all nodes |
| **Cilium** | CNI, kube-proxy replacement, ingress controller |
| **Flux Operator** | GitOps continuous delivery (manages Flux lifecycle) |
| **cert-manager** | TLS certificate management |
| **External Secrets** | Secrets sync from Bitwarden |
| **cloudflared** | Cloudflare Tunnel for ingress (no public IP needed) |
| **Longhorn** | Distributed block storage (NVMe + HDD) |
| **Tailscale** | Secure offsite access to K8s API via tailnet |

## Repository Structure

```
├── talos/                      # Talos OS configuration
│   ├── controlplane.yaml       # Generated control plane config
│   ├── worker.yaml             # Generated worker config
│   └── *-patch.yaml            # Patches applied during generation
├── clusters/tayacluster/
│   ├── flux-instance.yaml      # FluxInstance CRD (Flux configuration)
│   ├── infrastructure/         # Core platform services
│   │   ├── flux-operator/      # Flux Operator Helm release
│   │   ├── cilium/
│   │   ├── cert-manager/
│   │   ├── external-secrets/
│   │   ├── cloudflared/
│   │   ├── longhorn/
│   │   └── tailscale/
│   └── apps/                   # User applications
│       └── whoami/             # Demo app
└── info.md                     # Network topology & hardware specs
```

## Prerequisites

Tools managed via [mise](https://mise.jdx.dev/):
- `talosctl` - Talos machine management
- `kubectl` - Kubernetes CLI
- `flux` - GitOps CLI
- `helm` - Package manager

Run `mise install` to install all tools.

## Cluster Bootstrap

See `setup.sh` for initial cluster setup. The script:
1. Generates Talos configs with patches
2. Applies configs to nodes
3. Bootstraps etcd on first control plane
4. Generates kubeconfig

## Adding Applications

1. Create directory under `clusters/tayacluster/apps/<app-name>/`
2. Add Kubernetes manifests (namespace, deployment, service, ingress)
3. Add to `clusters/tayacluster/apps/kustomization.yaml`
4. Commit and push - Flux will deploy automatically

## Exposing Services

Services are exposed via Cloudflare Tunnel:
1. Create an Ingress with `ingressClassName: cilium`
2. Set the hostname (e.g., `app.taya.net`)
3. Configure the route in Cloudflare dashboard

## Offsite Access

The Kubernetes API is accessible from anywhere via Tailscale. This allows `kubectl` access when away from the local network.

**Setup (one-time on your device):**

```bash
# Configure kubectl to use Tailscale
tailscale configure kubeconfig tayacluster-operator
```

**Usage:**

```bash
# Use the Tailscale context
kubectl --context=tailscale-tayacluster-operator get nodes

# Or set as default
kubectl config use-context tailscale-tayacluster-operator
```

Your Tailscale identity maps to Kubernetes RBAC via the operator. Ensure your Tailscale ACLs grant appropriate access.

## Notes

**Not yet automated:**
- Talos config generation (patches must be applied manually via `talosctl gen config`)

**TODO:**
- Flux Operator MCP integration for AI-assisted operations
- Connect other services into the monitoring stack?
- SSO with Keycloak (half set up, but is broken)