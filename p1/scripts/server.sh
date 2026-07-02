#!/bin/bash

set -e 
# set -e is used to make the script exit immediately if any command exits with a non-zero status. This is useful for catching errors early and preventing the script from continuing in an unexpected state.

export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq curl >/dev/null

# Detect the private-network interface (the one with the 192.168.56.x address)
IFACE=$(ip -4 -o addr show | awk '/192\.168\.56\./ {print $2}')

# Install K3s Server
curl -sfL https://get.k3s.io | sh -s - server \
  --node-ip=192.168.56.110 \
  --flannel-iface="$IFACE" \
  --bind-address=192.168.56.110

until   kubectl get nodes >/dev/null 2>&1
do
    sleep 2
done

mkdir -p /vagrant/confs
cp /var/lib/rancher/k3s/server/node-token \
/vagrant/confs/node-token
cp /etc/rancher/k3s/k3s.yaml \
/home/vagrant/.kubeconfig
# kubectl on the server VM points to 192.168.56.110
sed -i "s/127.0.0.1/192.168.56.110/g" \
/home/vagrant/.kubeconfig
chown vagrant:vagrant /home/vagrant/.kubeconfig
echo 'export KUBECONFIG=/home/vagrant/.kubeconfig' \
>> /home/vagrant/.bashrc