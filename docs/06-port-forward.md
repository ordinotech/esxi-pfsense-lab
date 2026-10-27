# Étape 6 : redirection de port et accès depuis le WAN

[← Étape précédente](05-dns-et-client-windows.md) · [Difficultés →](07-difficultes.md)

## Objectif

Rendre PairDrop joignable **depuis l'extérieur du LAN** : une machine d'un autre segment du réseau, qui ne connaît que l'adresse WAN de pfSense, doit atteindre le conteneur.

## Principe

```mermaid
sequenceDiagram
    participant C as Poste externe
    participant W as pfSense (WAN)
    participant U as Ubuntu 192.168.1.11
    C->>W: TCP :3000 vers l'adresse WAN
    Note over W: Règle NAT (port forward)<br/>+ règle de filtrage associée
    W->>U: TCP :3000 (destination réécrite)
    U-->>W: Réponse PairDrop
    W-->>C: Réponse
```

## Configuration

*Firewall → NAT → Port Forward → Add*, interface **WAN** :

| Champ | Valeur |
|---|---|
| Protocole | TCP |
| Destination | WAN address |
| Port de destination | 3000 |
| Redirect target IP | 192.168.1.11 |
| Redirect target port | 3000 |
| Filter rule association | Add associated filter rule |

![Règle NAT, partie 1](../images/06-port-forward/01-regle-nat-partie-1.png)
![Règle NAT, partie 2](../images/06-port-forward/02-regle-nat-partie-2.png)

Après enregistrement, appliquer les changements. La règle apparaît dans la liste avec le symbole de règle liée.

![Liste des port forwards](../images/06-port-forward/03-liste-port-forward.png)

## Validation

Depuis un poste d'un autre segment, ouvrir `http://<adresse WAN de pfSense>:3000` : l'interface PairDrop doit s'afficher.

Le premier essai a expiré (`ERR_CONNECTION_TIMED_OUT`) à cause du blocage des réseaux privés et bogons sur l'interface WAN : voir [Difficultés](07-difficultes.md#5-accès-refusé-depuis-un-autre-segment).

> **Capture de preuve non incluse.** La capture montrant l'accès réussi depuis le segment externe affiche l'adresse WAN réelle du réseau amont ; elle n'est donc pas publiée.
