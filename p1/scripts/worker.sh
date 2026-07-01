
#!/bin/bash
set -e

# we make the worker wait until the server has finished creating the cluster and the node token is available
while [ ! -f /vagrant/confs/node-token ]
do
    sleep 2
done

TOKEN=$(cat /vagrant/confs/node-token)

curl -sfL https://get.k3s.io | \
K3S_URL=https://192.168.56.110:6443 \
K3S_TOKEN=$TOKEN \
sh -