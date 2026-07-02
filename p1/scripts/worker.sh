#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq curl >/dev/null

# we make the worker wait until the server has finished creating the cluster and the node token is available
while [ ! -f /vagrant/confs/node-token ]
do
    sleep 2
done

TOKEN=$(cat /vagrant/confs/node-token)
IFACE=$(ip -4 -o addr show | awk '/192\.168\.56\./{print $2}')

curl -sfL https://get.k3s.io | \
K3S_URL=https://192.168.56.110:6443 \
K3S_TOKEN=$TOKEN \
sh -s - agent \
  --node-ip=192.168.56.111 \
  --flannel-iface="$IFACE"