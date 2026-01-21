# Cluster Docs

# Physical Network Topology

Internet
└─ Init7 (Our ISP)
  └─ TP-Link Archer AX55 (Router) 192.168.0.1
      ├─ [Other Devices]
      ├─ TOPAZ (My Workstation PC) 192.168.0.93
      └─ Netgear GS108GE (Unmanaged Switch)
          ├─ Node-01 (ThinkCentre M920q Tiny) 8C:16:45:C1:E3:DA 192.168.0.101
          ├─ Node-02 (ThinkCentre M920q Tiny) E8:6A:64:F5:05:11 192.168.0.102
          ├─ Node-03 (ThinkCentre M920q Tiny) E8:6A:64:F8:B8:86 192.168.0.103
          └─ Node-04 (ThinkCentre M920q Tiny) E8:6A:64:F8:AD:B3 192.168.0.104

# TP-Link Archer AX55
Is the network gateway and DHCP server.
It has the local IP address `192.168.0.1`.
The DHCP server hands out IP addresses in the `192.168.0.x` range.
The cluster nodes are connected via a switch directly to the router.

## Static IP Reservations (DHCP by MAC):
- Node-01: `192.168.0.101` (MAC: 8C:16:45:C1:E3:DA)
- Node-02: `192.168.0.102` (MAC: E8:6A:64:F5:05:11)
- Node-03: `192.168.0.103` (MAC: E8:6A:64:F8:B8:86)
- Node-04: `192.168.0.104` (MAC: E8:6A:64:F8:AD:B3)

# ThinkCentre M920q Tiny Nodes
Each node is a Lenovo ThinkCentre M920q Tiny.
They are connected to the network via a Netgear GS108GE unmanaged switch.
They have the following specifications:
- CPU: Intel Core i7-8700T @ 2.40GHz
- RAM: 32GB DDR4 (2x 16GB)
- Storage:
  - 512GB NVMe SSD /dev/nvme0n1
  - 5TB HDD /dev/sda
- Network: Intel Gigabit Ethernet
- BIOS: Lenovo M1UKT77A released 2024-04-10