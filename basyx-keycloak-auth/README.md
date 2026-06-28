# BaSyx Keycloak Auth

Exemplary Helm deployment of the Eclipse BaSyx Asset Administration Shell (AAS) components secured directly by a bundled Keycloak instance.

```
.
├── README.md                       # this file
├── Chart.yaml                      # umbrella chart, depends on aas-basyx-v2-full
├── values.yaml                     # all configuration, Vault placeholders included
├── config/
│   └── test-realm.json             # Keycloak realm imported on first start
└── templates/
    └── configmap-test-realm.yaml   # mounts test-realm.json into Keycloak
```

The deployment provides four services: Keycloak (identity provider with a PostgreSQL backend), the BaSyx AAS Registry, the BaSyx AAS Discovery Service, and the BaSyx AAS Environment. Each AAS service is protected via RBAC enforced with JWT bearer tokens issued by Keycloak.

Clients authenticate directly against Keycloak and pass the resulting JWT to the AAS endpoints.

## Components

| Component | Image | Notes |
|---|---|---|
| Keycloak | `bitnamilegacy/keycloak:26.3.3` | PostgreSQL backend |
| AAS Registry | `eclipsebasyx/aas-registry-log-mem:2.0.0-SNAPSHOT` | In-memory backend, CORS enabled |
| AAS Discovery | `eclipsebasyx/aas-discovery-service:2.0.0-SNAPSHOT` | RBAC via `BaSyx` realm JWT, in-memory |
| AAS Environment | `eclipsebasyx/aas-environment:2.0.0-SNAPSHOT` | RBAC via `test` realm JWT, in-memory |

## Prerequisites

- A Kubernetes cluster with an `nginx` IngressClass and `cert-manager` configured with a `letsencrypt-prod` ClusterIssuer (or adjust the ingress annotations in `values.yaml` to match your setup)
- Helm 3
- DNS records pointing all four hostnames at your cluster's ingress
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
| `basyx-reg-url` | Public hostname for the AAS Registry |
| `basyx-disco-url` | Public hostname for the AAS Discovery Service |
| `basyx-env-url` | Public hostname for the AAS Environment |

All secrets are read from the Vault path `factory-x-ci-cd/data/mx-leo-deployments`.

## RBAC

RBAC rules are defined inline in `values.yaml` under `aas-basyx-v2-full.aas-environment.rbac.rules`. The following roles are pre-configured:

| Role | Permissions |
|---|---|
| `admin` | Full CRUD and execute on all AAS, submodels, and concept descriptions |
| `basyx-reader` | READ on all submodels |
| `basyx-reader-two` | READ on a specific submodel |
| `basyx-sme-reader` | READ on specific submodel elements |
| `basyx-updater` | UPDATE on specific submodel elements |
| `basyx-deleter` | DELETE on specific resources |
| `basyx-executor` | EXECUTE on specific operations |

Roles are assigned to Keycloak clients or users within the `test` realm. Adjust the `rbac.rules` block in `values.yaml` to match your access requirements.

The AAS Discovery Service is secured against the `BaSyx` realm; the AAS Environment uses the `test` realm. Both realms are imported from ConfigMaps on Keycloak's first start. To add users, roles, or additional clients, edit `config/test-realm.json` before the first deploy.

## Deploy

This chart vendors its dependency (`aas-basyx-v2-full`) as a `.tgz` archive in `charts/`, so no `helm dependency build` is needed.

```sh
helm upgrade --install basyx-keycloak-auth . \
  -n basyx-keycloak-auth --create-namespace
```

For a local deploy without Vault, supply concrete values via an override file:

```sh
helm upgrade --install basyx-keycloak-auth . \
  -n basyx-keycloak-auth --create-namespace \
  -f my-overrides.yaml
```

where `my-overrides.yaml` replaces all `<path:...>` placeholders with literal values.

Keycloak imports `config/test-realm.json` on first start via a ConfigMap. The realm contains a single confidential client with service accounts enabled.

## Verify

Once all pods are ready, confirm the AAS Environment returns a token-protected response:

```sh
# 1. Obtain a token from Keycloak (test realm, test-client)
TOKEN=$(curl -s -X POST \
  https://<keycloak-url>/realms/test/protocol/openid-connect/token \
  -d grant_type=client_credentials \
  -d client_id=test-client \
  -d client_secret=<client-secret> | jq -r .access_token)

# 2. Call the AAS Environment shells endpoint
curl -H "Authorization: Bearer $TOKEN" \
  https://<basyx-env-url>/shells
# Expect HTTP 200 with an empty or populated shells list
```

## Troubleshooting

- **Keycloak pod stuck in init** — confirm the PostgreSQL credentials are correct and the PostgreSQL pod is fully ready before Keycloak starts.
- **Realm not imported** — check Keycloak pod logs for import errors; the realm JSON must be valid and the ConfigMap must mount correctly (see `templates/configmap-test-realm.yaml`).
- **401 from AAS Discovery or AAS Environment** — verify that the `keycloak.issuer` URL in `values.yaml` matches the actual public Keycloak hostname and that the correct realm name is used (`BaSyx` for Discovery, `test` for Environment).
- **403 from AAS Environment** — the token was accepted but the client lacks the required RBAC role. Check `rbac.rules` in `values.yaml` and ensure the role is assigned to the client in the Keycloak `test` realm.
- **Ingress 502 / service unreachable** — confirm DNS resolves all four hostnames to the cluster ingress and that cert-manager has successfully issued TLS certificates for each host.
