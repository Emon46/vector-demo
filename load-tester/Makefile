REGISTRY ?= hremon331046
# Image URL to use all building/pushing image targets
TAG      ?= $(shell git describe --exact-match --abbrev=0 2>/dev/null || echo "latest")
IMG ?= $(REGISTRY)/load-tester:$(TAG)
# ENVTEST_K8S_VERSION refers to the versi

.PHONY: build
build:  ## Build docker image with the manager.
	docker build -t ${IMG} .

.PHONY: push
push: build ## Push docker image with the manager.
	docker push ${IMG}

.PHONY: push-to-kind
push-to-kind: build
	@echo "Loading docker image into kind cluster...."
	@kind load docker-image $(IMG)
	@echo "Image has been pushed successfully into kind cluster."
