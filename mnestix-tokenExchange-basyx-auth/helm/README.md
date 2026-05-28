<!-- SPDX-License-Identifier: MIT -->
<!-- Copyright (c) 2025 XITASO GmbH -->
# Helm Deployment

This folder contains the Helm chart for deploying the complete stack:

- Mnestix Browser
- Mnestix Proxy
- Keycloak
- MongoDB
- BaSyx AAS Environment

## Prerequisites

1. Verify that the proxy image is available:

```bash
docker pull mnestix/mnestix-proxy:1.0.0-fx
```

2. Ensure the keycloak image is available to your cluster.

```bash
docker pull mnestix/mnestix-keycloak-fx:24.0.4
```

3. If you need your own keycloak image variant, build and push it.

```bash
# Run from docker-compose folder
cd ../docker-compose

docker build -t mnestix/mnestix-keycloak-fx:24.0.4 ./keycloak

docker push mnestix/mnestix-keycloak-fx:24.0.4
```

## Install / Upgrade

```bash
# Run from helm folder
helm upgrade --install mnestix . \
  --set mnestixProxy.image.repository=mnestix/mnestix-proxy \
  --set mnestixProxy.image.tag=1.0.0-fx \
  --set keycloak.image.repository=mnestix/mnestix-keycloak-fx \
  --set keycloak.image.tag=24.0.4 \
  --namespace mnestix --create-namespace
```

If you built your own keycloak image, replace `keycloak.image.repository` with your registry path.

## Validate Deployment In kind

1. Check release and rollout status.

```bash
helm status mnestix -n mnestix
kubectl get deploy,pods,svc,endpoints -n mnestix
kubectl wait --for=condition=Available deployment --all -n mnestix --timeout=120s
```

2. Test browser locally.

```bash
kubectl -n mnestix port-forward svc/mnestix-mnestix-tokenexchange-basyx-auth-mnestix-browser 3000:3000
```

In a second terminal:

```bash
curl -I http://127.0.0.1:3000
```

Expected: `200` or `307`.

3. Test proxy locally.

```bash
kubectl -n mnestix port-forward svc/mnestix-mnestix-tokenexchange-basyx-auth-mnestix-proxy 5065:5065
```

In a second terminal:

```bash
curl -i http://127.0.0.1:5065/plugfest5/shells
```

Expected without auth token: `401 Unauthorized`.

4. Test keycloak locally.

```bash
kubectl -n mnestix port-forward svc/mnestix-mnestix-tokenexchange-basyx-auth-keycloak 8080:8080
```

In a second terminal:

```bash
curl -I http://127.0.0.1:8080/realms/Mnestix/.well-known/openid-configuration
```

Expected: `200 OK`.

5. Test AAS health locally.

```bash
kubectl -n mnestix port-forward svc/mnestix-mnestix-tokenexchange-basyx-auth-aas-environment 8081:8081
```

In a second terminal:

```bash
curl -i http://127.0.0.1:8081/actuator/health
```

Expected: `{"status":"UP"}`.

## Validate Chart

If `helm` is not installed locally, you can lint with Docker:

```bash
docker run --rm -v "$PWD":/chart -w /chart alpine/helm:3.17.2 lint .
```
