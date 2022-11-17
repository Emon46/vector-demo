#!/bin/bash

set -euo pipefail

helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm upgrade -i obsv-metrics-server metrics-server/metrics-server --devel --set args[0]=--kubelet-insecure-tls --create-namespace  --namespace obsv-metrics-server

sleep 10
helm repo add vector https://helm.vector.dev
helm upgrade --install obsv-telemetry-agent vector/vector-agent --devel --values telemetry-agent/config.yaml --create-namespace --namespace obsv-telemetry-agent

sleep 10
helm upgrade  --install obsv-data-plane deploy/helm/data-plane --devel --create-namespace  --namespace obsv-data-plane


sleep 20
kubectl apply -f load-test/loader-gen.yaml