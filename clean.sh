#!/bin/bash

# set -euo pipefail

kubectl delete -f load-tester/loader-pod.yaml

helm uninstall -n vector        	vector

sleep 10
kubectl delete -f ./data-plane/

sleep 10
helm uninstall -n kube-metric metrics-server

