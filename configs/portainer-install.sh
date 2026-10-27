#!/usr/bin/env bash
# Installation de Portainer CE (LTS) en ligne de commande
set -euo pipefail

docker volume create portainer_data

docker run -d -p 8000:8000 -p 9443:9443 \
  --name portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:lts \
  --no-setup-token

# Préparer le réseau et le volume attendus par le stack PairDrop
docker network create web
docker volume create pairdrop_data
