<!-- SPDX-License-Identifier: MIT -->
<!-- Copyright (c) 2025 XITASO GmbH -->
<h1 style="text-align: center">Mnestix Proxy</h1>

[![Made by XITASO](https://img.shields.io/badge/Made_by_XITASO-005962?style=flat-square)](https://xitaso.com/)
[![MIT License](https://img.shields.io/badge/License-MIT-005962.svg?style=flat-square)](https://choosealicense.com/licenses/mit/)
[![Join our Community](https://img.shields.io/badge/Join_our_Community-005962?style=flat-square)](https://xitaso.com/kompetenzen/mnestix/#support)

### This is a fork for Factory-X ###
Original repository: https://github.com/eclipse-mnestix/mnestix-proxy

This proxy is used to handle the token exchange as described here: https://factory-x.atlassian.net/wiki/spaces/TP4/pages/587104261/Increment+2+Trusted+List

The proxy sits between the client and the AAS repository. Testing was performed using Eclipse Mnestix Browser as the AAS client and the AAS Package Explorer Server as AAS repository.

![](./wiki/FX-Specifics/FX-Mnestix-Proxy.png)

### Quick Start ###

**Prerequisites:** [Docker](https://docs.docker.com/get-docker/) with the Compose plugin (included in Docker Desktop).

Start the entire stack with a single command:

```bash
docker compose up -d
```

This will build and start all services. The first start may take a few minutes due to the Keycloak image build (Maven compilation).

### Available Services ###

| Service | URL | Description |
|---------|-----|-------------|
| Mnestix Browser | http://localhost:3000 | AAS web UI |
| Mnestix Proxy | http://localhost:5065 | Reverse proxy with token exchange |
| Keycloak | http://localhost:8080 | Identity provider (Admin: `admin` / `admin`) |
| Keycloak (HTTPS) | https://localhost:8443 | Keycloak HTTPS endpoint |
| MongoDB | (internal only) | Database backend for BaSyx |
| BaSyx AAS Environment | (internal only) | AAS repository |

### Demo Walkthrough ###

- After starting up the proxy, you can test it via your browser:
  - get all shells from [plugfest5](https://plugfest5.aas-voyager.com/api/v3.0/) by calling: http://localhost:5065/plugfest5/shells
  - get all submodels from [plugfest5](https://plugfest5.aas-voyager.com/api/v3.0/) by calling: http://localhost:5065/plugfest5/submodels
  - HINT: try calling https://plugfest5.aas-voyager.com/api/v3.0/submodels directly and you will not get e.g. the HandoverDocumentation submodels because of missing credentials.
- Open your browser and navigate to http://localhost:3000
    - Click "GO TO AAS LIST".
    - If you do not have a Authorization header in the request, the proxy will return HTTP Status "401 - not authenticated" (This is for demo and testing purposes.)
      - You get a hint in the Mnestix Browser: "Authentication needed"
      - click "Login" to get forwarded to Keycloak (running at http://localhost:8080)
      - Authenticate in keycloak with these credentials (this user is allowed to see all submodels of plugfest5)
        - Username: aorzelski@phoenixcontact.com
        - Password: aorzelski@phoenixcontact.com-secret
      - You get your token in the Authorization header
      - You will get a nice visualization of all the AASs from plugfest5 via the Mnestix-Proxy.
    - You can click an AAS and see all the details including all submodels.

### Stop ###

```bash
docker compose down
```

### For Developers ###

The token exchange implementation is part of the [Mnestix Proxy](https://github.com/eclipse-mnestix/mnestix-proxy) (Factory-X fork). The proxy intercepts requests to the AAS repository and exchanges the user's token via a Security Token Service (STS) to obtain credentials for the target system.

Key configuration in the proxy image:
- **Reverse Proxy Routes**: The proxy routes requests from `/plugfest5/*` to `https://plugfest5.aas-voyager.com/api/v3.0/`
- **Token Exchange**: Configured via the `TokenExchange` settings to call the STS endpoint

### Kubernetes Deployment (Helm)

See the dedicated Helm chart documentation in [`../helm/README.md`](../helm/README.md).
