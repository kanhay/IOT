#!/usr/bin/env bash
set -eu

IP="$1"
IFACE=$(ip -4 -o addr show | awk -v ip="$IP" '$4 ~ ip {print $2}') #Finding the interface

# export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y curl

curl -sfL https://get.k3s.io | sh -s - server \
    --node-ip="$IP" \
    --flannel-iface="$IFACE" \
    --write-kubeconfig-mode=644

mkdir -p /home/vagrant/.kube
cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
sed -i "s/127.0.0.1/$IP/" /home/vagrant/.kube/config #Replacing localhost
chown -R vagrant:vagrant /home/vagrant/.kube
echo "export KUBECONFIG=/home/vagrant/.kube/config" >> /home/vagrant/.bashrc

# K3s auto-applies anything dropped here, and keeps it in sync
mkdir -p /var/lib/rancher/k3s/server/manifests
cp /vagrant/confs/*.yaml /var/lib/rancher/k3s/server/manifests/

echo "Waiting for node to become Ready..."
until kubectl --kubeconfig=/etc/rancher/k3s/k3s.yaml get nodes | grep -q " Ready"; do
    sleep 2
done