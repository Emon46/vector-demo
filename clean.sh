#!/bin/bash

set -euo pipefail

kubectl delete -f load-test/load-gen.yaml

helm uninstall -n obsv-telemetry-agent obsv-telemetry-agent

sleep 10
helm uninstall -n obsv-data-plane obsv-data-plane

sleep 10
helm uninstall -n obsv-metrics-server obsv-metrics-server

