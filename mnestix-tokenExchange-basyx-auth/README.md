<!-- SPDX-License-Identifier: MIT -->
<!-- Copyright (c) 2025 XITASO GmbH -->
# Mnestix Token Exchange - Deployment Setup

[![Made by XITASO](https://img.shields.io/badge/Made_by_XITASO-005962?style=flat-square)](https://xitaso.com/)
[![MIT License](https://img.shields.io/badge/License-MIT-005962.svg?style=flat-square)](https://choosealicense.com/licenses/mit/)

This repository provides deployment configurations for the Mnestix Token Exchange stack, demonstrating secure AAS (Asset Administration Shell) access via token exchange in the Factory-X ecosystem.

The proxy sits between the client and the AAS repository, performing token exchange via a Security Token Service (STS) to access protected submodels.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) (Docker Desktop or Docker Engine with Compose plugin)
- For Helm deployment: [kubectl](https://kubernetes.io/docs/tasks/tools/), [Helm 3.x](https://helm.sh/docs/intro/install/), [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)

## Quick Start (Docker Compose)

```bash
cd docker-compose
docker compose up -d
```

The first start takes a few minutes (Keycloak image is built from source). Once running:

| Service | URL | Description |
|---------|-----|-------------|
| Mnestix Browser | http://localhost:3000 | AAS web UI |
| Mnestix Proxy | http://localhost:5065 | Reverse proxy with token exchange |
| Keycloak | http://localhost:8080 | Identity provider (Admin: `admin` / `admin`) |

### Test in the Browser

1. Open http://localhost:3000
2. Click **"GO TO AAS LIST"**
3. You will see "Authentication needed" (the proxy returns 401 without a token)
4. Click **"Login"** - you are redirected to Keycloak
5. Sign in with the demo credentials:
   - **Username:** `aorzelski@phoenixcontact.com`
   - **Password:** `aorzelski@phoenixcontact.com-secret`
6. After login, you will see all AAS entries from plugfest5, including protected submodels (e.g. HandoverDocumentation)

### Stop

```bash
docker compose down
```

## Helm Deployment (Kubernetes)

For deploying on a Kubernetes cluster. See [helm/README.md](helm/README.md) for full details.

### Local Test with kind

```bash
# 1. Create a local Kubernetes cluster
kind create cluster --name mnestix-test

# 2. Build and load the Keycloak image into the cluster
cd docker-compose
docker build -t mnestix/keycloak-fx:24.0.4 ./keycloak
kind load docker-image mnestix/keycloak-fx:24.0.4 --name mnestix-test

# 3. Install the Helm chart
cd ../helm
helm upgrade --install mnestix . --namespace mnestix --create-namespace

# 4. Wait for all pods to be ready (may take a few minutes for image pulls)
kubectl wait --for=condition=Ready pod --all -n mnestix --timeout=300s

# 5. Start port-forwards to access services locally
kubectl -n mnestix port-forward svc/mnestix-mnestix-tokenexchange-basyx-auth-mnestix-browser 3000:3000 &
kubectl -n mnestix port-forward svc/mnestix-mnestix-tokenexchange-basyx-auth-mnestix-proxy 5065:5065 &
kubectl -n mnestix port-forward svc/mnestix-mnestix-tokenexchange-basyx-auth-keycloak 8080:8080 &
```

Then open http://localhost:3000 and follow the same test steps as above.

### Cleanup

```bash
helm uninstall mnestix -n mnestix
kind delete cluster --name mnestix-test
```

## Repository Structure

```
├── docker-compose/          # Docker Compose setup (local development/demo)
│   ├── compose.yml          # Service definitions
│   ├── keycloak/            # Keycloak Dockerfile + realm config
│   └── README.md            # Detailed Docker Compose documentation
├── helm/                    # Helm chart (Kubernetes deployment)
│   ├── Chart.yaml
│   ├── values.yaml          # Configurable values
│   ├── templates/           # Kubernetes resource templates
│   └── README.md            # Detailed Helm documentation
└── LICENSE                  # MIT License
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
