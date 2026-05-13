# Blueprint: Keycloak + AASPE (docker-compose)

## Voraussetzungen
- Docker
- Docker Compose v2

## Einmalige Vorbereitung
```bash
docker network create blueprint-net

## Startreihenfolge

cd keycloak && docker compose up -d
cd ../aaspe && docker compose up -d

Services

Keycloak: http://localhost:8080
AASPE: http://localhost:8081

Stoppen
docker compose down

AASPE Packager Explorer (Desktop app)
powershell -File .aaspe package explorer\install_and_run-aasx-package-explorer.ps1