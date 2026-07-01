#!/bin/bash

set -e 
# set -e is used to make the script exit immediately if any command exits with a non-zero status. This is useful for catching errors early and preventing the script from continuing in an unexpected state.

# Install K3s Server
curl -sfL https://get.k3s.io | sh -

until   kubectl get nodes >/dev/null 2>&1
do
    sleep 2
done

mkdir -p /vagrant/confs

cp /var/lib/rancher/k3s/server/node-token \
/vagrant/confs/node-token

cp /etc/rancher/k3s/k3s.yaml \
/home/vagrant/.kubeconfig


chown vagrant:vagrant /home/vagrant/.kubeconfig

echo 'export KUBECONFIG=/home/vagrant/.kubeconfig' \
>> /home/vagrant/.bashrc