#!/bin/bash

# Exit immediately if any command fails.
# This prevents the script from continuing in an inconsistent state.
set -ex

###############################################################################
# Configuration
###############################################################################

IP="192.168.56.110"
TOKEN="/var/lib/rancher/k3s/server/node-token"
# CONFIG="/etc/rancher/k3s/k3s.yaml"
# KUBECONFIG="/home/vagrant/.kube/config"

###############################################################################
# Detect the private network interface
###############################################################################

# Find the interface that owns the server's private IP.
# K3s will use this interface for the overlay network (Flannel).
# IFACE=$(ip -4 -o addr show | awk -v ip="$IP" '$4 ~ ip {print $2}')

# if [ -z "$IFACE" ]; then
#     echo "Could not determine the network interface for $IP"
#     exit 1
# fi

###############################################################################
# Install required packages
###############################################################################

apt-get update -y
apt-get install -y curl

###############################################################################
# Install and start the K3s server
###############################################################################

curl -sfL https://get.k3s.io | sh -s - server \
    --node-ip="$IP" \
    --write-kubeconfig-mode=644
    # --flannel-iface="$IFACE" \
    # --bind-address="$IP" \

# Wait until the API server responds.
until kubectl get nodes >/dev/null 2>&1
do
    sleep 2
done

###############################################################################
# Export files needed by the worker and the vagrant user
###############################################################################

# Share the worker join token through the synced folder so that the worker VM
# can join the cluster.
mkdir -p /vagrant/confs
cp "$TOKEN" /vagrant/confs/node-token

# Copy the kubeconfig for the vagrant user.
# mkdir -p /home/vagrant/.kube
# cp "$CONFIG" "$KUBECONFIG"

# Replace localhost with the server IP so kubectl works from outside localhost.
# sed -i "s/127.0.0.1/$IP/g" "$KUBECONFIG"

# Give ownership to the vagrant user.
# chown -R vagrant:vagrant /home/vagrant/.kube
