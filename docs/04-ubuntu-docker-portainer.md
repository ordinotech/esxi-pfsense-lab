# Étape 4 : Ubuntu, Docker, Portainer et PairDrop

[← Étape précédente](03-pfsense.md) · [Étape suivante →](05-dns-et-client-windows.md)

## Objectif

Héberger un service dans un conteneur, administré depuis une interface web, avec des **données persistantes** (volume nommé, pas de bind mount) et un **réseau Docker dédié**. PairDrop, que je faisais déjà tourner avec un simple compose, est migré vers un stack Portainer.

## 4.1 La VM Ubuntu

Ubuntu Server (dernière LTS) sur `pg_LAN`. Elle obtient son adresse du DHCP de pfSense (`192.168.1.11`).

![Paramètres de la VM](../images/04-ubuntu-docker-portainer/01-vm-ubuntu-parametres.png)
![Réseau de l'installateur : adresse DHCP](../images/04-ubuntu-docker-portainer/02-installateur-reseau.png)
![Stockage](../images/04-ubuntu-docker-portainer/03-installateur-stockage.png)
![Installation du système](../images/04-ubuntu-docker-portainer/04-installation-systeme.png)

## 4.2 Docker et Docker Compose

```bash
apt install docker-compose-v2 docker.io
systemctl status docker
```

![Installation](../images/04-ubuntu-docker-portainer/05-apt-install-docker.png)
![Docker actif](../images/04-ubuntu-docker-portainer/06-docker-actif.png)

## 4.3 Portainer en ligne de commande

```bash
docker volume create portainer_data

docker run -d -p 8000:8000 -p 9443:9443 \
  --name portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:lts \
  --no-setup-token
```

![docker run](../images/04-ubuntu-docker-portainer/07-portainer-docker-run.png)

L'interface répond sur `https://192.168.1.11:9443`. Le certificat est auto-signé : l'avertissement du navigateur est normal.

![Avertissement de certificat](../images/04-ubuntu-docker-portainer/08-portainer-certificat.png)

Création du compte administrateur (Portainer exige au moins 12 caractères ; le mot de passe n'apparaît pas ici).

![Compte admin](../images/04-ubuntu-docker-portainer/09-portainer-compte-admin.png)

## 4.4 Réseau externe `web` et volume nommé

Dans Portainer, création du réseau `web`, puis du volume `pairdrop_data`.

![Réseau web](../images/04-ubuntu-docker-portainer/10-reseau-web.png)
![Création du volume](../images/04-ubuntu-docker-portainer/11-volume-pairdrop-data.png)
![Liste des volumes](../images/04-ubuntu-docker-portainer/12-liste-volumes.png)

## 4.5 Migrer PairDrop vers un stack

1. Arrêter proprement l'ancien conteneur : `docker compose down` depuis son dossier d'origine ([compose d'origine](../configs/pairdrop-compose-origine.yml)).
2. Dans Portainer : *Stacks → Add stack*, nom `pairdrop`, éditeur web, avec le [compose du stack](../configs/pairdrop-stack.yml).
   ![Éditeur du stack](../images/04-ubuntu-docker-portainer/13-stack-pairdrop-editeur.png)
3. Déployer, puis vérifier que le conteneur est `running` et membre du réseau `web`, avec le volume `pairdrop_data` monté sur `/data`.
   ![Conteneur running](../images/04-ubuntu-docker-portainer/14-stack-conteneur-running.png)
   ![Volume et réseau du conteneur](../images/04-ubuntu-docker-portainer/15-conteneur-volume-reseau.png)
4. Valider l'accès depuis un navigateur du LAN : `http://192.168.1.11:3000`.
   ![PairDrop en accès LAN](../images/04-ubuntu-docker-portainer/16-pairdrop-acces-lan.png)

## À retenir

- `external: true` indique que le volume et le réseau existent déjà : le stack les utilise sans les créer, ni les supprimer à sa suppression.
- Aucun chemin local dans la section `volumes` du service : les données vivent dans un volume géré par Docker.
- L'adresse `172.18.x.x` visible dans Portainer est celle du réseau Docker interne, pas du lab.
