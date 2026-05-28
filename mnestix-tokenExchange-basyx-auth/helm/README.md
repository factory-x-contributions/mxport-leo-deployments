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

- Kubernetes cluster (tested with kind)
- Helm 3.x
- The Keycloak image must be available to your cluster. Build and push it from the `docker-compose/` folder:

```bash
cd ../docker-compose
docker build -t mnestix/keycloak-fx:24.0.4 ./keycloak
docker push mnestix/keycloak-fx:24.0.4
```

## Install

```bash
helm upgrade --install mnestix . \
  --namespace mnestix --create-namespace
```

All default values are configured for a working demo setup. See `values.yaml` for customization options.

## Verify Deployment

```bash
helm status mnestix -n mnestix
kubectl get deploy,pods,svc -n mnestix
kubectl wait --for=condition=Available deployment --all -n mnestix --timeout=120s
```

## Access Services

Port-forward to access the services locally:

```bash
# Mnestix Browser
kubectl -n mnestix port-forward svc/mnestix-mnestix-tokenexchange-basyx-auth-mnestix-browser 3000:3000

# Mnestix Proxy
kubectl -n mnestix port-forward svc/mnestix-mnestix-tokenexchange-basyx-auth-mnestix-proxy 5065:5065

# Keycloak
kubectl -n mnestix port-forward svc/mnestix-mnestix-tokenexchange-basyx-auth-keycloak 8080:8080
```

| Service | Local URL | Notes |
|---------|-----------|-------|
| Mnestix Browser | http://localhost:3000 | AAS web UI |
| Mnestix Proxy | http://localhost:5065 | Token exchange proxy |
| Keycloak | http://localhost:8080 | Admin: `admin` / `admin` |

## Demo Credentials

Keycloak demo user (allowed to see all submodels):
- Username: `aorzelski@phoenixcontact.com`
- Password: `aorzelski@phoenixcontact.com-secret`

## Uninstall

```bash
helm uninstall mnestix -n mnestix
```

## Lint Chart

```bash
helm lint .
# or without local Helm:
docker run --rm -v "$PWD":/chart -w /chart alpine/helm:3.17.2 lint .
```
