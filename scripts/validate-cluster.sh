#!/bin/bash

echo "Checking nodes..."
kubectl get nodes || exit 1

echo "Checking namespaces..."
kubectl get ns | grep -E "dev|staging|prod" || exit 1

echo "Checking system pods..."
kubectl get pods -n kube-system || exit 1

echo "Platform foundation looks good ✅"
