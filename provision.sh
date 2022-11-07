#!/bin/bash

set -euo pipefail

helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm upgrade -i metrics-server metrics-server/metrics-server --devel --set args[0]=--kubelet-insecure-tls --create-namespace  --namespace kube-metric

sleep 10
helm repo add vector https://helm.vector.dev
helm upgrade -i vector vector/vector-agent --devel --values telemetry-agent/config.yaml --create-namespace --namespace vector

sleep 10
kubectl apply -f data-plane/horizontal-auto-scaling.yaml

sleep 10
kubectl apply -f data-plane/rbac.yaml
kubectl apply -f data-plane/service.yaml
kubectl apply -f data-plane/data-plane-config.yaml
kubectl apply -f data-plane/vector-dp-sts.yaml


sleep 20
kubectl apply -f load-tester/loader-pod.yaml