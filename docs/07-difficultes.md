# Difficultés rencontrées et solutions

[← Retour au sommaire](../README.md)

## 1. Adresse WAN inattendue

**Symptôme.** Le WAN de pfSense obtient `192.168.1.137/24` alors que le réseau amont utilise un plan `172.16.X.Y`.

**Analyse.** Le réseau amont est un **/21** (`255.255.248.0`), pas un /24. La plage d'adresses prévue pour le lab appartient au même réseau que l'hôte ESXi. Les deux VM partagent `vSwitch0` avec l'hôte : un autre serveur DHCP du segment répondait avant celui du réseau amont (hypothèse).

**Solution.** Relancer la configuration WAN en DHCP (console, option 2) : pfSense obtient alors une adresse `172.16.X.Y/21` cohérente.

## 2. Bannissement temporaire

**Symptôme.** Après trois mots de passe erronés sur l'interface web, plus aucune réponse de `192.168.1.1`.

**Cause.** Protection anti-brute-force de pfSense : l'adresse du client est bannie temporairement.

**Solution.** Attendre la fin du bannissement (ou le lever depuis la console), puis saisir le bon mot de passe. Les échecs sont visibles dans les journaux.

## 3. PairDrop seulement avec `:3000`

Un enregistrement DNS ne porte pas de port. Voir [étape 5](05-dns-et-client-windows.md#pourquoi-3000-est-indispensable).

## 4. Une seule carte réseau physique

L'hôte n'a qu'une carte (`vmnic0`) pour la gestion d'ESXi **et** le WAN de pfSense. Le LAN étant interne, le LAN n'a pas besoin de carte supplémentaire : un `vSwitch` sans uplink suffit.

## 5. Accès refusé depuis un autre segment

**Symptôme.** Le test de l'étape 6 expire : `ERR_CONNECTION_TIMED_OUT`.

**Cause.** Sur l'interface WAN, les options **Block private networks** et **Block bogon networks** étaient activées. Le trafic venant d'adresses privées (`172.16.x.x`) était rejeté.

**Solution.** *Interfaces → WAN* : décocher les deux options, enregistrer, appliquer. PairDrop devient accessible.

> **Attention.** Ces blocages sont une bonne pratique sur un WAN connecté à Internet. Ils ne sont désactivés ici que parce que le WAN du lab est lui-même un réseau privé.
