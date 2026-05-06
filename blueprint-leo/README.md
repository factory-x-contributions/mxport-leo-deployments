# MX Port Leo AAS

This repository is a fork of the Hercules async-aas helm Charts, adapted for the Leo Blueprint Deployment.

1. MongoDB Install

```bash
helm install -n basyx mongodb bitnami/mongodb --version 18.1.1 -f values.mongodb.yaml
```

## Chart Dependencies

This umbrella chart includes the following dependencies:

- **FAAAST Service**: Version 0.1.4 (tag:`fxleo`, fx-fa³st fork)
- **Eclipse BaSyx v2**: Version 2.0.11  
- **MongoDB**: Version 18.1.1 (MongoDB 8.2.1, digest-pinned for stability)
- **RabbitMQ**: Version 16.0.14

## Prerequisites

- Kubernetes cluster
- Helm 3.x
- Docker (for image pulls)

## Quick Start

1. **Update dependencies:**

   ```bash
   helm dependency update
   ```

2. **Install the chart:**

   ```bash
   helm install mxport-leo-aas ./charts/mxport-leo-aas -n <namespace> --create-namespace
   ```

3. **Upgrade existing installation:**

   ```bash
   helm upgrade mxport-leo-aas ./charts/mxport-leo-aas -n <namespace>
   ```

## Service Dependencies

The services have the following startup order dependencies:

1. MongoDB (database)
2. Keycloak (authentication)
3. BaSyx services (AAS registry, discovery, environment)
4. FA3ST Service + Registry
