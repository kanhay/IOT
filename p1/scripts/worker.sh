#!/bin/bash

# Exit immediately if any command fails.
# This prevents the script from continuing in an inconsistent state.
set -ex

###############################################################################
# Configuration
###############################################################################

IP="192.168.56.111"
SERVER_IP="192.168.56.110"
TOKEN_FILE="/vagrant/confs/node-token"

###############################################################################
# Install required packages
###############################################################################

apt-get update -y
apt-get install -y curl

###############################################################################
# Wait for the server to finish initializing
###############################################################################

# The server generates a join token after creating the cluster.
# Wait until the token is available before attempting to join.
while [ ! -f "$TOKEN_FILE" ]
do
    sleep 2
done

TOKEN=$(cat "$TOKEN_FILE")

###############################################################################
# Detect the private network interface
###############################################################################

# Find the interface that owns the worker's private IP.
# K3s will use this interface for the overlay network (Flannel).
# IFACE=$(ip -4 -o addr show | awk -v ip="$IP" '$4 ~ ip {print $2}')

# if [ -z "$IFACE" ]; then
#     echo "Could not determine the network interface for $IP"
#     exit 1
# fi

###############################################################################
# Install and start the K3s agent
###############################################################################

curl -sfL https://get.k3s.io | \
K3S_URL="https://$SERVER_IP:6443" \
K3S_TOKEN="$TOKEN" \
sh -s - agent \
    --node-ip="$IP" \
    # --flannel-iface="$IFACE"