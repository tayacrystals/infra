#!/usr/bin/env bash
set -euo pipefail

CONTROL_PLANE_IPS=(192.168.178.101 192.168.178.102 192.168.178.103)
WORKER_IPS=(192.168.178.104)
CLUSTER_NAME=tayacluster
DISK_NAME=nvme0n1

continue_prompt() {
    read -p "Press any key to continue..." -n1 -s
    printf "\n"
}

require_tool() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Missing required tool: $1" >&2
        exit 1
    fi
}

require_tool talosctl

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
TALOS_DIR="${BASE_DIR}/talos"
mkdir -p "$TALOS_DIR"
cd "$TALOS_DIR"

# Generate configs only if they do not exist yet
if [[ ! -f talosconfig || ! -f controlplane.yaml || ! -f worker.yaml ]]; then
    talosctl gen config "$CLUSTER_NAME" "https://${CONTROL_PLANE_IPS[0]}:6443" \
        --install-disk "/dev/${DISK_NAME}" \
        --output-dir .
else
    echo "Configuration files already exist, skipping generation."
fi

echo "Ensure all nodes are in maintenance mode before proceeding."
continue_prompt

for ip in "${CONTROL_PLANE_IPS[@]}"; do
    echo "Applying config to control plane node: $ip"
    talosctl apply-config --insecure --nodes "$ip" --file controlplane.yaml
done

for ip in "${WORKER_IPS[@]}"; do
    echo "Applying config to worker node: $ip"
    talosctl apply-config --insecure --nodes "$ip" --file worker.yaml
done

export TALOSCONFIG="$TALOS_DIR/talosconfig"
talosctl config endpoints "${CONTROL_PLANE_IPS[@]}"

continue_prompt

talosctl bootstrap --nodes "${CONTROL_PLANE_IPS[0]}"
continue_prompt

talosctl kubeconfig kubeconfig --nodes ${CONTROL_PLANE_IPS[0]}
export KUBECONFIG="$TALOS_DIR/kubeconfig"

continue_prompt

talosctl --nodes "${CONTROL_PLANE_IPS[0]}" health
continue_prompt

kubectl get nodes