Things that arent automated/declarative yet:

- talos config patches
  - allowSchedulingOnControlPlanes: true
  - disable default CNI & kube-proxy

TODO:
- disk layout of the main ssd? (use of the hdds?)
- flux operator? with mcp?

DONE:
- secrets management with ESO with bitwarden secrets management
- cloudflare tunnel (managed via Cloudflare dashboard, routes to cilium-ingress.kube-system.svc.cluster.local)