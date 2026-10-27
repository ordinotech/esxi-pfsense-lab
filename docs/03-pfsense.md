# Étape 3 : pfSense, le pare-feu entre deux réseaux

[← Étape précédente](02-datastore-et-hote.md) · [Étape suivante →](04-ubuntu-docker-portainer.md)

## Objectif

Créer un réseau interne **sans connexion physique** et placer un pare-feu pfSense entre ce réseau (LAN) et le réseau amont (WAN). Tout ce qui sort du LAN passe par pfSense.

```mermaid
flowchart LR
    NET["Réseau amont"] --- U["vmnic0"] --- VS0["vSwitch0<br/>VM Network"] --- WAN["pfSense WAN<br/>(vmx0, DHCP)"]
    WAN --- FW(("pfSense"))
    FW --- LAN["pfSense LAN<br/>(vmx1) 192.168.1.1/24"] --- PG["pg_LAN<br/>vSwitch_LAN, sans uplink"]
    PG --- C1["Ubuntu / Docker"]
    PG --- C2["Client Windows"]
```

## 3.1 Préparer ESXi

1. **Téléverser les ISO** (pfSense, Ubuntu Server, Windows 10) dans un dossier `ISO/` du datastore.
   ![ISO dans le datastore](../images/03-pfsense/01-iso-dans-datastore.png)
2. **Créer `vSwitch_LAN` sans uplink** : aucun adaptateur physique, donc réseau fermé.
   ![vSwitch sans uplink](../images/03-pfsense/02-vswitch-lan-sans-uplink.png)
3. **Créer le port group `pg_LAN`** rattaché à ce vSwitch (VLAN 0).
   ![Port group pg_LAN](../images/03-pfsense/03-portgroup-pg-lan.png)

## 3.2 Créer la VM pfSense

Deux cartes **VMXNET 3** : la première sur `VM Network` (WAN), la seconde sur `pg_LAN` (LAN). Guide de référence : [documentation Netgate, pfSense sous ESXi](https://docs.netgate.com/pfsense/en/latest/recipes/virtualize-esxi.html).

![Deux adaptateurs réseau](../images/03-pfsense/04-vm-pfsense-adaptateurs.png)
![Récapitulatif](../images/03-pfsense/05-vm-pfsense-recapitulatif.png)

## 3.3 Installer pfSense

1. Démarrer sur l'ISO et accepter le partitionnement proposé (ZFS).
   ![Installateur ZFS](../images/03-pfsense/06-installateur-zfs.png)
   ![Installation terminée](../images/03-pfsense/07-installation-terminee.png)
2. **Assigner les interfaces** : `vmx0` devient le WAN, `vmx1` le LAN. On vérifie que les adresses MAC correspondent bien aux cartes de la VM.
   ![Assignation](../images/03-pfsense/08-assignation-interfaces.png)

## 3.4 Configurer WAN et LAN

1. **WAN** : pfSense reçoit une adresse inattendue (`192.168.1.137/24`) au lieu d'une adresse du réseau amont. Voir [Difficultés](07-difficultes.md#1-adresse-wan-inattendue).
   ![WAN inattendu](../images/03-pfsense/09-wan-ip-inattendue.png)
2. Relancer la configuration **WAN en DHCP** (option 2 de la console).
   ![WAN en DHCP](../images/03-pfsense/10-wan-dhcp.png)
3. **LAN** : `192.168.1.1/24`, serveur DHCP activé sur `192.168.1.5` à `192.168.1.10`.
   ![LAN et DHCP](../images/03-pfsense/11-lan-dhcp-console.png)
   ![Menu WAN/LAN](../images/03-pfsense/12-menu-wan-lan.png)
4. **Test de connectivité** depuis la console : `ping 8.8.8.8` répond, le WAN sort bien vers l'extérieur.
   ![Ping 8.8.8.8](../images/03-pfsense/13-test-ping-externe.png)

## 3.5 Un client Windows sur le LAN

pfSense s'administre depuis le LAN : on crée une VM Windows 10 **dans `pg_LAN`**.

![Paramètres de la VM Windows](../images/03-pfsense/14-vm-windows-parametres.png)
![Topologie de vSwitch_LAN](../images/03-pfsense/15-topologie-vswitch-lan.png)
![Installation de Windows](../images/03-pfsense/16-installation-windows.png)
![Préparation](../images/03-pfsense/17-preparation-windows.png)
![Installer les VMware Tools : menu](../images/03-pfsense/18-vmware-tools-menu.png)
![Installer les VMware Tools : assistant](../images/03-pfsense/19-vmware-tools-assistant.png)

Le client reçoit `192.168.1.10` en DHCP, passerelle et DNS sur `192.168.1.1`.

![ipconfig du client](../images/03-pfsense/20-ipconfig-client.png)

## 3.6 Interface web et assistant de configuration

1. Ouvrir `http://192.168.1.1` depuis le client Windows.
   ![Connexion web](../images/03-pfsense/21-webgui-connexion.png)
2. **Trois mauvais mots de passe** de suite déclenchent un bannissement temporaire ; les échecs apparaissent dans les journaux. Voir [Difficultés](07-difficultes.md#2-bannissement-temporaire).
   ![Journal des échecs](../images/03-pfsense/22-journal-echecs-authentification.png)
   ![Interface injoignable](../images/03-pfsense/23-webgui-injoignable.png)
3. L'assistant de configuration initiale : fuseau horaire, nom d'hôte, mot de passe administrateur.
   ![Assistant](../images/03-pfsense/24-assistant-configuration.png)
   ![Paramètres système](../images/03-pfsense/25-parametres-systeme.png)
4. Vérification de l'heure depuis le shell.
   ![Date](../images/03-pfsense/26-shell-date.png)

## À retenir

- `vSwitch_LAN` sans uplink = réseau étanche : le seul chemin vers l'extérieur est pfSense.
- Les interfaces se nomment `vmx0` / `vmx1` avec VMXNET 3 (et non `em0` / `em1`).
- Changer le mot de passe par défaut dès l'assistant (pfSense le rappelle en bandeau).
