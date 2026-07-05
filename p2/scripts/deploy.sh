#!/usr/bin/env bash

# Deploy the Kubernetes resources
# Apply every manifest found in the shared configuration directory.
kubectl apply -f /vagrant/confs/app1.yaml
kubectl apply -f /vagrant/confs/app2.yaml
kubectl apply -f /vagrant/confs/app3.yaml
kubectl apply -f /vagrant/confs/ingress.yaml

# Wait for the applications to become ready
echo "Waiting for all Pods to become Ready..."
kubectl wait \
    --for=condition=Ready \
    pods \
    --all \
    --timeout=180s

# Display the cluster state
echo
echo "---------------------------------------------------------------------------"
echo "                          Current cluster status                           "
echo "---------------------------------------------------------------------------"
echo
sleep 2
echo "Nodes"
kubectl get nodes
echo "Pods"
kubectl get pods -o wide
echo
echo "Services"
kubectl get services
echo
echo "Ingress"
kubectl get ingress

# Display test commands
echo
echo "---------------------------------------------------------------------------"
echo "Deployment completed successfully."
echo
echo "Test the applications with:"
echo
echo 'curl -H "Host: app1.com" http://192.168.56.110'
echo 'curl -H "Host: app2.com" http://192.168.56.110'
echo 'curl http://192.168.56.110'
echo "---------------------------------------------------------------------------"