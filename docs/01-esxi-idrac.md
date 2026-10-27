# Étape 1 : installer ESXi à distance avec l'iDRAC

[← Retour au sommaire](../README.md) · [Étape suivante →](02-datastore-et-hote.md)

## Objectif

Installer VMware ESXi sur un serveur sans y toucher physiquement. L'**iDRAC** (le contrôleur de gestion intégré de Dell) fournit une console virtuelle (écran, clavier, souris) et permet de **monter une ISO** comme si c'était un lecteur optique branché sur le serveur.

## Déroulé

1. **Connexion à l'iDRAC** par son interface web (HTTPS, adresse du réseau de gestion) avec le compte administrateur.
   ![Connexion iDRAC](../images/01-esxi-idrac/01-idrac-login.png)
   ![Identifiants saisis, mot de passe masqué](../images/01-esxi-idrac/02-idrac-identifiants.png)

2. **Vérifier le serveur** dans *System Summary* : modèle R730xd, état général, aperçu de la console.
   ![Résumé système](../images/01-esxi-idrac/03-idrac-system-summary.png)

3. **Ouvrir la console virtuelle.** Le serveur n'a aucun système installé et boucle sur « No boot device available ».
   ![Console virtuelle](../images/01-esxi-idrac/04-console-virtuelle.png)

4. **Monter l'ISO d'ESXi** via *Virtual Media* : choisir le fichier, puis *Map Device*.
   ![Dialogue Virtual Media](../images/01-esxi-idrac/05-virtual-media-dialogue.png)
   ![ISO sélectionnée](../images/01-esxi-idrac/06-iso-selectionnee.png)
   ![ISO mappée sur le lecteur CD/DVD](../images/01-esxi-idrac/07-iso-mappee.png)
   ![Statut : média connecté, 1 périphérique mappé](../images/01-esxi-idrac/08-statut-media-connecte.png)

   > Le périphérique doit rester mappé jusqu'au démarrage, sinon il n'apparaît pas dans la liste de boot.

5. **Redémarrer** avec la macro *Ctrl-Alt-Del* (Console Controls).
   ![Ctrl-Alt-Del](../images/01-esxi-idrac/09-ctrl-alt-del.png)

6. **F11 : Boot Manager**, puis *One-shot boot* sur **Virtual Optical Drive**. On ne modifie donc pas l'ordre de boot permanent.
   ![POST, F11](../images/01-esxi-idrac/10-post-f11-boot-manager.png)
   ![Boot Manager, lecteur optique virtuel](../images/01-esxi-idrac/11-boot-manager-optical.png)

7. **L'installateur ESXi démarre** depuis l'ISO.
   ![Chargement de l'installateur](../images/01-esxi-idrac/12-installateur-esxi-chargement.png)
   ![Démarrage d'ESXi 8.0.3](../images/01-esxi-idrac/13-esxi-demarrage.png)

8. **Choisir le disque** d'installation (volume RAID du contrôleur PERC, 7,28 TiB), puis suivre l'assistant (clavier, mot de passe root, confirmation).
   ![Sélection du disque](../images/01-esxi-idrac/14-selection-disque.png)

9. **Premier démarrage** : l'écran DCUI affiche l'URL de gestion. L'hôte a obtenu son adresse en DHCP.
   ![Console ESXi, URL de gestion masquée](../images/01-esxi-idrac/15-console-esxi-url-gestion.png)

10. **Ouvrir le Host Client** dans un navigateur : l'hôte est opérationnel (ESXi 8.0 U3, mode évaluation).
    ![ESXi Host Client](../images/01-esxi-idrac/16-esxi-host-client.png)

## À retenir

- L'ISO montée à distance remplace la clé USB : indispensable quand le serveur est dans une salle technique.
- Le **one-shot boot** évite de toucher au BIOS.
- ESXi tourne ici avec une seule carte réseau physique (`vmnic0`), contrainte qui structure toute la suite.
