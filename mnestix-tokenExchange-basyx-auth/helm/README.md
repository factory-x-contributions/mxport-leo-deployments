<!-- SPDX-License-Identifier: MIT -->
<!-- Copyright (c) 2025 XITASO GmbH -->
# Helm Deployment

This folder contains the Helm chart for deploying the Mnestix Token Exchange stack on Kubernetes.

## Components

| Component | Image | Description |
|-----------|-------|-------------|
| Mnestix Browser | `mnestix/mnestix-browser:2.0.0` | AAS web UI |
| Mnestix Proxy | `mnestix/mnestix-proxy:1.0.0-fx` | Reverse proxy with token exchange |
| Keycloak | `mnestix/keycloak-fx:24.0.4` | Identity provider |
| MongoDB | `mongo:8` | Database backend for BaSyx |
| BaSyx AAS Environment | `eclipsebasyx/aas-environment:2.0.0-milestone-06` | AAS repository |

## Prerequisites

- Kubernetes cluster (tested with [kind](https://kind.sigs.k8s.io/))
- [Helm 3.x](https://helm.sh/docs/intro/install/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- Docker (to build the Keycloak image)

## Local Test with kind

The following steps set up a fully working local environment from scratch:

```bash
# 1. Install kind (if not already installed)
brew install kind    # macOS
# or: go install sigs.k8s.io/kind@latest

# 2. Create a local cluster
kind create cluster --name mnestix-test

# 3. Build and load the Keycloak image
#    (the image is built from the docker-compose/keycloak folder)
cd ../docker-compose
docker build -t mnestix/keycloak-fx:24.0.4 ./keycloak
kind load docker-image mnestix/keycloak-fx:24.0.4 --name mnestix-test
cd ../helm

# 4. Install the chart
helm upgrade --install mnestix . --namespace mnestix --create-namespace

# 5. Wait for all pods to become ready
#    (first run takes several minutes due to image pulls)
kubectl wait --for=condition=Ready pod --all -n mnestix --timeout=300s

# 6. Verify everything is running
kubectl get pods -n mnestix
```

All 5 pods should show `Running` and `READY 1/1`.

## Access Services Locally

Start port-forwards in the background:

```bash
kubectl -n mnestix port-forward svc/mnestix-mnestix-tokenexchange-basyx-auth-mnestix-browser 3000:3000 &
kubectl -n mnestix port-forward svc/mnestix-mnestix-tokenexchange-basyx-auth-mnestix-proxy 5065:5065 &
kubectl -n mnestix port-forward svc/mnestix-mnestix-tokenexchange-basyx-auth-keycloak 8080:8080 &
```

| Service | Local URL | Notes |
|---------|-----------|-------|
| Mnestix Browser | http://localhost:3000 | AAS web UI |
| Mnestix Proxy | http://localhost:5065 | Token exchange proxy |
| Keycloak | http://localhost:8080 | Admin: `admin` / `admin` |

## Test in the Browser

1. Open http://localhost:3000
2. Click **"GO TO AAS LIST"**
3. You will see "Authentication needed" (proxy returns 401 without token)
4. Click **"Login"** - redirects to Keycloak
5. Sign in with the demo credentials:
   - **Username:** `aorzelski@phoenixcontact.com`
   - **Password:** `aorzelski@phoenixcontact.com-secret`
6. After login, all AAS entries from plugfest5 are displayed, including protected submodels

## Quick Verification via curl

```bash
# Proxy without auth (expect 401)
curl -i http://localhost:5065/plugfest5/shells

# Keycloak OpenID config (expect 200)
curl http://localhost:8080/realms/Mnestix/.well-known/openid-configuration
```

## Install on an Existing Cluster

If you already have a cluster with access to a container registry:

```bash
# Push the keycloak image to your registry
docker build -t your-registry/keycloak-fx:24.0.4 ../docker-compose/keycloak
docker push your-registry/keycloak-fx:24.0.4

# Install with custom image
helm upgrade --install mnestix . \
  --set keycloak.image.repository=your-registry/keycloak-fx \
  --namespace mnestix --create-namespace
```

All default values are configured for a working demo setup. See `values.yaml` for all customization options.

## Uninstall

```bash
helm uninstall mnestix -n mnestix
```

## Cleanup Local Cluster

```bash
kind delete cluster --name mnestix-test
```

## Lint Chart

```bash
helm lint .
# or without local Helm:
docker run --rm -v "$PWD":/chart -w /chart alpine/helm:3.17.2 lint .
```
