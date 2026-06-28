# FA³ST Keycloak Auth

Exemplary Helm deployment of the FA³ST Service (Fraunhofer Asset Administration Shell Technology) secured by a bundled Keycloak instance, with MongoDB as the AAS persistence backend.

```
.
├── README.md                           # this file
├── Chart.yaml                          # umbrella chart, depends on faaast-service, keycloak, mongodb
├── values.yaml                         # all configuration, Vault placeholders included
├── config/
│   ├── test-realm.json                 # Keycloak realm imported on first start
│   ├── acl/
│   │   └── client_id-acl.json          # FA³ST ACL rules (client_id-based)
│   └── example-aas/
│       ├── config.json                 # FA³ST runtime configuration
│       └── model.json                  # example AAS model loaded on startup
└── templates/
    ├── configmap-test-realm.yaml       # mounts test-realm.json into Keycloak
    ├── configmap-example-config.yaml   # mounts FA³ST config.json
    ├── configmap-example-model.yaml    # mounts example AAS model
    └── configmap-acl-folder.yaml       # mounts ACL rules into FA³ST
```

The deployment provides three services: Keycloak (identity provider with a PostgreSQL backend), FA³ST Service (AAS runtime with an HTTP endpoint), and MongoDB (persistent AAS storage). Clients authenticate against Keycloak and pass the resulting JWT to the FA³ST HTTP endpoint, where ACL rules control access per `client_id`.

## Components

| Component | Image | Notes |
|---|---|---|
| Keycloak | `bitnamilegacy/keycloak:latest` | PostgreSQL backend |
| FA³ST Service | `ghcr.io/factory-x-contributions/fa3st-service:security` | HTTP endpoint on port 8080, JWT validation via Keycloak JWKS |
| MongoDB | `bitnami/mongodb:latest` | Standalone, 10 Gi persistent volume |

## Prerequisites

- A Kubernetes cluster with an `nginx` IngressClass and `cert-manager` configured with a `letsencrypt-prod` ClusterIssuer (or adjust the ingress annotations in `values.yaml` to match your setup)
- Helm 3
- Access to `ghcr.io/factory-x-contributions/fa3st-service:security` (requires GHCR credentials if the image is private)
- DNS records pointing the FA³ST and Keycloak hostnames at your cluster's ingress
- HashiCorp Vault with the secrets listed below populated (or replace the `<path:...>` placeholders with concrete values for a local deploy)

## values.yaml

`values.yaml` contains `<path:factory-x-ci-cd/data/mx-leo-deployments#...>` placeholders. These are resolved by a Vault-based secret injector in the reference ArgoCD deployment. For a local deploy, replace each placeholder with a concrete value — either inline in `values.yaml`, via `-f my-values.yaml`, or via `--set`.

| Placeholder key | Replace with |
|---|---|
| `kc-pg-user` | Keycloak PostgreSQL username |
| `kc-pg-pw` | Keycloak PostgreSQL password |
| `kc-pg-db` | Keycloak PostgreSQL database name |
| `keycloak-url` | Public hostname for Keycloak (no scheme) |
| `keycloak-user` | Keycloak admin username |
| `keycloak-pw` | Keycloak admin password |
| `mongodb-admin-user` | MongoDB root username |
| `mongodb-admin-pw` | MongoDB root password |

All secrets are read from the Vault path `factory-x-ci-cd/data/mx-leo-deployments`.

## Access Control

FA³ST uses a file-based ACL evaluated against JWT claims. The ACL configuration is in `config/acl/client_id-acl.json` and is mounted into the FA³ST pod via a ConfigMap. The pre-configured rule grants READ access to `test-client` on all routes (`*`):

```json
{
  "claimName": "client_id",
  "rules": [
    { "clientId": "test-client", "permissions": ["READ"], "routes": ["*"] }
  ]
}
```

Adjust this file to add roles, restrict routes, or map additional Keycloak clients before deploying. The ACL glob pattern (`*`) covers all AAS endpoints.

JWT validation is configured to use the Keycloak JWKS endpoint:

```
http://<keycloak-url>/realms/test-realm/protocol/openid-connect/certs
```

This URL is set in `values.yaml` under `faaast-service.config.security.jwkProviderUrl` and must match the deployed Keycloak hostname and realm name.

## Keycloak Realm

`config/test-realm.json` is imported on Keycloak's first start via a ConfigMap. It defines the `test-realm` realm with two pre-configured clients:

| Client | Service Account | Notes |
|---|---|---|
| `test-client` | enabled | Matched by the pre-configured ACL rule |
| `fake-client` | enabled | Available for testing negative ACL cases |

To add users, additional clients, or modify realm settings, edit `config/test-realm.json` before the first deploy.

## MongoDB Connection

FA³ST connects to MongoDB using the connection string configured in `config/example-aas/config.json`:

```
mongodb://<mongodb-admin-user>:<mongodb-admin-pw>@mongodb:27017
```

The Helm chart resolves this at render time from the Vault secrets. MongoDB is deployed in standalone mode with a 10 Gi persistent volume and `override: true` set, meaning FA³ST will overwrite existing data in MongoDB with the bundled example model on each startup.

## Deploy

```sh
helm dependency build .
helm upgrade --install faaast-keycloak-auth . \
  -n faaast-keycloak-auth --create-namespace
```

For a local deploy without Vault, supply concrete values via an override file:

```sh
helm dependency build .
helm upgrade --install faaast-keycloak-auth . \
  -n faaast-keycloak-auth --create-namespace \
  -f my-overrides.yaml
```

where `my-overrides.yaml` replaces all `<path:...>` placeholders with literal values.

`helm dependency build` is required because the `faaast-service` subchart is vendored as a local `file://` dependency in `charts/`.

## Verify

Once all pods are ready, confirm FA³ST returns a JWT-protected response:

```sh
# 1. Obtain a token from Keycloak (test-realm, test-client)
TOKEN=$(curl -s -X POST \
  https://<keycloak-url>/realms/test-realm/protocol/openid-connect/token \
  -d grant_type=client_credentials \
  -d client_id=test-client \
  -d client_secret=<client-secret> | jq -r .access_token)

# 2. Call the FA³ST shells endpoint
curl -H "Authorization: Bearer $TOKEN" \
  https://<faaast-url>/api/v3.0/shells
# Expect HTTP 200 with the example AAS model
```

## Troubleshooting

- **Keycloak pod stuck in init** — confirm the PostgreSQL credentials are correct and the PostgreSQL pod is fully ready before Keycloak starts.
- **Realm not imported** — check Keycloak pod logs for import errors; the realm JSON must be valid and the ConfigMap must mount correctly (see `templates/configmap-test-realm.yaml`).
- **FA³ST pod crash-loops** — check that MongoDB is ready and reachable at `mongodb:27017` from within the FA³ST pod. Verify the MongoDB credentials match between `values.yaml` and `config/example-aas/config.json`.
- **401 from FA³ST** — JWT validation failed. Verify that `faaast-service.config.security.jwkProviderUrl` in `values.yaml` resolves to the correct Keycloak JWKS endpoint and that the realm name is `test-realm`.
- **403 from FA³ST** — the token was accepted but the `client_id` claim is not matched by any ACL rule. Check `config/acl/client_id-acl.json` and confirm the client used to obtain the token is listed there.
- **Ingress 502 / service unreachable** — confirm DNS resolves both hostnames to the cluster ingress and that cert-manager has issued TLS certificates for each host.
