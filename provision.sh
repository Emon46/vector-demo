#!/bin/bash

set -euo pipefail

helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/

helm upgrade -i metrics-server metrics-server/metrics-server --devel --set args[0]=--kubelet-insecure-tls --create-namespace  --namespace kube-metric

sleep 30
kubectl apply -f tel-agent/rbac.yaml
kubectl apply -f tel-agent/service.yaml
kubectl apply -f tel-agent/tel-agent-config.yaml
kubectl apply -f tel-agent/vector-ta-sts.yaml

sleep 30

helm repo add vector https://helm.vector.dev

helm upgrade -i vector vector/vector-agent --devel --values config.yaml --create-namespace --namespace vector

sleep 10
kubectl apply -f tel-agent/horizontal-auto-scaling.yaml

sleep 50

kubectl apply -f load-tester/loader-pod.yaml