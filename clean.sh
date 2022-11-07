#!/bin/bash

set -euo pipefail

kubectl delete -f ./tel-agent/

sleep 30

helm uninstall -n kube-metric metrics-server

helm uninstall -n vector        	vector


sleep 50

kubectl delete -f load-tester/loader-pod.yaml