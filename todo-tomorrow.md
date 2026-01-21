# Cluster Recovery TODO

## Missing Bitwarden Secrets

The following secrets need to be created in Bitwarden Secrets Manager (project ID: `5f98326d-0d11-49eb-a2df-b3d500d05c5e`):

1. **`keycloak-admin-password`** - Admin password for Keycloak web console
2. **`keycloak-db-password`** - Password for the keycloak PostgreSQL database user

## After Creating Bitwarden Secrets

Run these commands to sync the new secrets:

```bash
export KUBECONFIG="C:/Users/taya/Projects/infra/talos/kubeconfig"

# Delete existing ExternalSecrets to trigger re-sync
kubectl delete externalsecret -n keycloak keycloak-admin-credentials keycloak-db-credentials

# Trigger Flux reconciliation
flux reconcile kustomization infrastructure -n flux-system
```

## Other Known Issues

- **Tailscale operator**: Needs ACL configuration to permit `tag:k8s-operator`
- **oauth2-proxy**: Will start working once Keycloak realm is configured
- **weave-gitops**: Check logs after Keycloak is running

## Git Changes Made

- Fixed `keycloak-config-cli` job:
  - Corrected health check port from 8080 to 9000
  - Fixed image tag from `6.1.6-26.0.5` to `6.4.0-26.0.5`
  - Disabled internal availability check (init container handles it)

- Updated `info.md` with new network layout (192.168.0.x)
