# Contract — Routes JSON (API interne)

**Date**: 2026-10-20 | **Spec**: FR-013, FR-014 | **Plan**: [plan.md](plan.md)

Deux routes JSON sont exigées par le sujet. Toutes renvoient
`Content-Type: application/json` ; erreurs en JSON
`{"erreur": "<message>"}` avec le statut HTTP adéquat.

## 1. État des sièges d'un voyage

`GET /api/voyages/<int:id_voyage>/sieges`

Alimente le plan des sièges (appelé par `static/js/sieges.js` via
`fetch`). Lecture seule.

**Réponse 200** :

```json
{
  "voyage": 12,
  "total_places": 45,
  "prix": 5000,
  "sieges": [
    {"numero": 1, "pris": false},
    {"numero": 2, "pris": true},
    {"numero": 3, "pris": false}
  ]
}
```

- `prix` : prix appliqué à ce voyage (type du bus × tarif du trajet).
- `sieges` : liste complète de 1 à `total_places`, triée par numéro ;
  `pris: true` ⇔ un billet existe pour `(voyage, numero)`.

**Erreurs** :

| Cas | Statut | Corps |
|---|---|---|
| Voyage inexistant | 404 | `{"erreur": "Voyage introuvable"}` |

## 2. Statistiques d'exploitation

`GET /api/statistiques`

Calculées sur l'ensemble de la base (jeu de test). Valeurs monétaires en
FCFA (entiers).

**Réponse 200** :

```json
{
  "remplissage_par_trajet": [
    {"trajet": "Douala → Yaoundé", "taux": 0.72}
  ],
  "recette_par_trajet_semaine": [
    {"trajet": "Douala → Yaoundé", "semaine": "41", "recette": 185000}
  ],
  "heures_demandees": [
    {"heure": "08:00", "nb_billets": 34}
  ],
  "billets_14_jours": [
    {"date": "2026-10-19", "nb_billets": 12}
  ]
}
```

- `taux` : billets vendus ÷ capacité cumulée des voyages du trajet
  (0.0–1.0).
- `semaine` : numéro de semaine ISO (`%W` de SQLite), année courante.
- `billets_14_jours` : une entrée par jour des 14 derniers jours, jours
  sans vente inclus (nb 0).

**Erreurs** : aucune attendue (calcul toujours possible, base vide →
listes vides ou taux 0).

## Contrôles communs

- Aucune authentification requise (statistiques et sièges sont publics
  dans le périmètre du sujet).
- Toute donnée passe par SQL paramétrée (`?`) — aucune interpolation.
- Format des dates : ISO `YYYY-MM-DD` ; format des heures : `HH:MM`.

## Vérification (SC-005)

Les quatre listes de `/api/statistiques` doivent coïncider avec un
recalcul manuel sur 10 voyages tirés au sort (quickstart S10).
