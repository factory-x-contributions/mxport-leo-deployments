#!/bin/bash

rm -rf aasx-server

git clone -b main --depth 1 https://github.com/admin-shell-io/aasx-server.git
mkdir aasx-server

cp Dockerfile ./aasx-server
docker-compose build
echo
