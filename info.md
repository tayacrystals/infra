# Cluster Docs

# Physical Network Topology

Internet
└─ Init7 (Our ISP)
  └─ FritzBox (Our Router)
      ├─ [Other Devices]
      ├─ TOPAZ (My Workstation PC)
      └─ TP-Link wr1502x (Wifi Client) A8:29:48:9B:FA:C0 192.168.178.59	
        └─ Netgear GS108GE (Unmanaged Switch)
            ├─ Node-01 (ThinkCentre M920q Tiny) 8C:16:45:C1:E3:DA 192.168.178.101
            ├─ Node-02 (ThinkCentre M920q Tiny) E8:6A:64:F5:05:11 192.168.178.102
            ├─ Node-03 (ThinkCentre M920q Tiny) E8:6A:64:F8:B8:86 192.168.178.103
            └─ Node-04 (ThinkCentre M920q Tiny) E8:6A:64:F8:AD:B3 192.168.178.104

# FritzBox
Is the network gateway and DHCP server.
It has the local IP address `192.168.178.1`.
The DHCP server hands out IP addresses: `192.168.178.20-99` (configured for Cozystack)
All downstream devices are connected to it over wifi.

## Static IP Reservations (DHCP by MAC):
- Node-01: `192.168.178.101` (MAC: 8C:16:45:C1:E3:DA)
- Node-02: `192.168.178.102` (MAC: E8:6A:64:F5:05:11)
- Node-03: `192.168.178.103` (MAC: E8:6A:64:F8:B8:86)
- Node-04: `192.168.178.104` (MAC: E8:6A:64:F8:AD:B3)

## Reserved for Cozystack:
- VIP (Kubernetes API): `192.168.178.100`
- MetalLB Pool: `192.168.178.200-250`

# ThinkCentre M920q Tiny Nodes
Each node is a Lenovo ThinkCentre M920q Tiny.
They are connected to the network via a Netgear GS108GE unmanaged switch.
They have the following specifications:
- CPU: Intel Core i7-8700T @ 2.40GHz
- RAM: 32GB DDR4 (2x 16GB)
- Storage:
  - 512GB NVMe SSD
  - 5TB HDD
- Network: Intel Gigabit Ethernet
- BIOS: Lenovo M1UKT77A released 2024-04-10

# Cloudflare Tunnel
A Cloudflare Tunnel is used to route traffic from the internet to the cluster.

**How it works:**
- `cloudflared` runs as a pod inside the Kubernetes cluster
- Creates outbound tunnel connection to Cloudflare's edge (no inbound ports needed)
- Routes traffic to MetalLB ingress IP: `192.168.178.200:80`

# DNS
DNS CNAME records point domains to the Cloudflare Tunnel hostname.

**Configuration:**
```
*.taya-cluster.infra.taya.net  CNAME  [tunnel-id].cfargotunnel.com
```

This covers all cluster services:
- `dashboard.taya-cluster.infra.taya.net`
- `grafana.taya-cluster.infra.taya.net`
- `*.taya-cluster.infra.taya.net` (wildcard for all apps)

I manage the following DNS zones:
- taya.net
- ginco.gg

# PXE Boot Setup
PXE boot configured in `boot/` directory. See `boot/README.md` for instructions.

# Power Control
Intel AMT remote power control: `./power.sh on|off|reset [1-4|all]`
Requires `openwsman-client` package. Credentials in `.env` file (see `.env.example`)

# TODO:
- PXE boot and install TalosOS on all nodes
  - apparently getting dnsmasq to work on windows is a pain
- Setup Kubernetes cluster with TalosOS
