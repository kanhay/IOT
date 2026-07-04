#!/usr/bin/env bash

###############################################################################
# Configuration
###############################################################################

IP="$1"

# Find the network interface that owns the server's private IP.
# K3s will use this interface for the overlay network (Flannel).
# IFACE=$(ip -4 -o addr show | awk -v ip="$IP" '$4 ~ ip {print $2}')

# if [ -z "$IFACE" ]; then
#     echo "Could not determine the network interface for $IP"
#     exit 1
# fi


apt-get update
apt-get install -y curl

# Install K3s server
curl -sfL https://get.k3s.io | sh -s - server \
    --node-ip="$IP" \
    --write-kubeconfig-mode=644
    # --flannel-iface="$IFACE" \

# Wait until the control plane is ready
echo "Waiting for the K3s server to become Ready..."
kubectl wait \
    --for=condition=Ready \
    node \
    --all \
    --timeout=180s

echo
echo "K3s server is ready."
kubectl get nodes