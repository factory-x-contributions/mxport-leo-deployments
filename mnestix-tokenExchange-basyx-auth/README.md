<!-- SPDX-License-Identifier: MIT -->
<!-- Copyright (c) 2025 XITASO GmbH -->
# Mnestix Token Exchange - Deployment Setup

This repository is split into two independent setup folders:

- `docker-compose/`: Local setup with Docker Compose
- `helm/`: Kubernetes setup with Helm chart

## Docker Compose

Use this for local development or demos.

```bash
cd docker-compose
docker compose up -d
```

Details: `docker-compose/README.md`

## Helm

Use this for Kubernetes deployments.

```bash
cd helm
helm upgrade --install mnestix .
```

Details: `helm/README.md`
