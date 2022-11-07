#!/bin/bash

set -euo pipefail

kubectl delete -f load-tester/loader-pod.yaml
kubectl delete -f ./tel-agent/

sleep 10

helm uninstall -n kube-metric metrics-server

helm uninstall -n vector        	vector