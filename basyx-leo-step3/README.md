# MX-Port Leo BaSyx-Gateway Demo

Exemplary Helm deployments for a Factory-X data **consumer** and data **provider** using BaSyx as the AAS backend, an STS-based token exchange, and gateways on both sides.

```
.
├── README.md                       # this file
├── charts/
│   ├── consumer-deployment/        # Keycloak (local IdP) + consumer STS + consumer gateway
│   ├── provider-deployment/        # BaSyx (AAS env + registry) + provider STS + provider gateway
│   └── sts-chart/                  # shared dependency used by both umbrellas
└── bruno-basyx-leo-collection/     # Bruno collection for testing the full flow
```

The client sends a single request to the **consumer gateway** with its local Keycloak token. The consumer gateway exchanges that token at the consumer STS for a Factory-X token and forwards the request to the provider gateway. The provider gateway exchanges the FX token at the provider STS for a BaSyx-scoped token and forwards the request to BaSyx.

## Prerequisites

- A Kubernetes cluster with an `nginx` IngressClass and `cert-manager` configured with a `letsencrypt-prod` ClusterIssuer (or adjust the ingress annotations in both `values.yaml` files to match your setup)
- Helm 3
- Access to `ghcr.io/factory-x-contributions/*` for the STS and gateway images
- DNS records pointing the hostnames you choose at your cluster's ingress

## values.yaml

Both `values.yaml` files contain `<path:factory-x-ci-cd/data/...>` placeholders. These are resolved by a Vault-based secret injector in our reference deployment — for a local deploy, replace each placeholder with a concrete value (either inline in `values.yaml`, via `-f my-values.yaml`, or via `--set`).

**Consumer (`charts/consumer-deployment/values.yaml`)**

| Placeholder | Replace with |
|---|---|
| `keycloak-host` | public hostname for Keycloak |
| `keycloak-admin-user`, `keycloak-admin-password` | Keycloak admin credentials |
| `keycloak-db-user`, `keycloak-db-password`, `keycloak-db-name` | credentials for the bundled Postgres |
| `keycloak-realm-name`, `keycloak-client-id`, `keycloak-client-secret` | realm/client imported on first start from `config/consumer-realm.json` |
| `sts-host` | public hostname for the consumer STS |
| `gateway-host` | public hostname for the consumer gateway (the entry point clients will hit) |
| `dockerconfigjson` | base64 Docker config for pulling from GHCR (or drop the pull secret and use a public image) |

**Provider (`charts/provider-deployment/values.yaml`)**

| Placeholder | Replace with |
|---|---|
| `gateway-host` | public hostname for the provider gateway |
| `sts-host` | public hostname for the provider STS |
| `aas-registry-url`, `basyx-env-url` | hostnames for the BaSyx registry and AAS environment |
| `keystore-password`, `key-password` | password(s) for the provider STS signing keystore |
| `dockerconfigjson` | base64 Docker config for pulling from GHCR |

## Deploy

Both umbrella charts use a `file://` dependency on `sts-chart`, so dependencies need to be built first.

```sh
# Provider
helm dependency build charts/provider-deployment
helm upgrade --install basyx-leo-provider charts/provider-deployment \
  -n basyx-leo-provider --create-namespace

# Consumer
helm dependency build charts/consumer-deployment
helm upgrade --install basyx-leo-consumer charts/consumer-deployment \
  -n basyx-leo-consumer --create-namespace
```

The consumer STS trusts the provider STS via the hostnames in values (and vice versa), so both deployments need to be reachable from each other for the full flow to work.

The consumer's Keycloak realm is imported on first start from a ConfigMap (`consumer-realm.json`). It contains a single confidential client with `client_credentials` and service accounts enabled — adjust the JSON for additional clients, users, or roles.

## Test

A Bruno collection (`bruno-basyx-leo-collection`) is provided alongside this directory. Its `local.bru` environment is pre-configured to point at the currently running ArgoCD deployment of consumer and provider, so you can try the flow end-to-end without deploying anything yourself — use client secret `democlient-secret-28g2g458ko` for the `democlient` in the `consumer-realm`.

The collection runs a two-step flow:

1. **Keycloak Token** — `POST {keycloak_base}/realms/{realm}/protocol/openid-connect/token` with `grant_type=client_credentials` → stores the access token
2. **Consumer Gateway** — `GET {consumer_gateway}/external/{provider_host}/shells` with the Keycloak token as bearer → the gateway exchanges the token and forwards to BaSyx, expect `< 400`

To run the collection against your own deployment instead, edit `bruno-basyx-leo-collection/environments/local.bru`:

```
keycloak_base:      https://<keycloak-host>
consumer_gateway:   https://<consumer gateway-host>
realm:              <keycloak-realm-name>
client_id:          <keycloak-client-id>
```

Set `client_secret` in the secret vars (matches the client secret from the realm). Then run the collection in the Bruno UI or via `bru run`.

A successful step 2 (any 2xx/3xx) confirms the full chain: Keycloak → consumer gateway → consumer STS → provider gateway → provider STS → BaSyx.

## Troubleshooting

- **401 at step 2 (from consumer gateway)** — the consumer STS could not verify the Keycloak token. Check that `serverConfig.issuerSpecificConfiguration[].issuer` and `jwksUri` in `consumer-deployment/values.yaml` resolve to the deployed Keycloak realm.
- **401 at step 2 (from provider gateway)** — the provider STS rejected the FX token. Verify the consumer STS host is reachable from the provider cluster (the provider fetches the consumer's JWKS at `https://<consumer sts-host>/sts/jwks`) and that the token audience matches on both sides.
- **403 from provider gateway** — the provider hostname is not in the consumer gateway's allowlist. Check `gateway-sts.config` in `consumer-deployment/values.yaml`.
- **403 from BaSyx** — token reached BaSyx but the subject lacks the required RBAC role. Roles are defined in `provider-deployment/values.yaml` under `aas-basyx-v2-full.aas-environment.rbac.rules`; map them onto your Keycloak client/users as needed.
- **`ImagePullBackOff`** — the `dockerconfigjson` value is missing or not base64-encoded.
