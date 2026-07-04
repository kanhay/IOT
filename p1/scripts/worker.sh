#!/bin/bash

IP="192.168.56.111"
SERVER_IP="192.168.56.110"
TOKEN_FILE="/vagrant/confs/node-token"

# Update package lists and install curl
apt-get update -y
apt-get install -y curl

# Wait until the token is available before attempting to join
while [ ! -f "$TOKEN_FILE" ]
do
    sleep 2
done

# Read the join token from the file
TOKEN=$(cat "$TOKEN_FILE")

# Install and start the K3s agent as a worker node, joining the cluster using the server's IP and the join token
curl -sfL https://get.k3s.io | \
K3S_URL="https://$SERVER_IP:6443" \
K3S_TOKEN="$TOKEN" \
sh -s - agent \
    --node-ip="$IP" 