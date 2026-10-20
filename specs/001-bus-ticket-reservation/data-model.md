# Data Model — Réservation de billets de bus interurbains (Phase 1)

**Date**: 2026-10-20 | **Plan**: [plan.md](plan.md) | **Spec**: [spec.md](spec.md)

Source de vérité : `projet/schema.sql`. Types SQLite. Toutes les colonnes
métier en `NOT NULL` sauf mention contraire. Encodage UTF-8.

## Vue d'ensemble

```text
trajets 1───N voyages N───1 bus
                       │
                       1
                       │
                       N
                     billets
admins (autonome, connexion espace d'administration)
```

## Tables

### trajets

Lien entre deux villes desservies avec durée et tarifs.

| Colonne | Type | Contraintes |
|---|---|---|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT |
| ville_depart | TEXT | NOT NULL, CHECK IN ('Douala','Yaoundé','Bafoussam','Kribi','Buea') |
| ville_arrivee | TEXT | NOT NULL, CHECK IN (idem), CHECK (<> ville_depart) |
| duree_minutes | INTEGER | NOT NULL, CHECK (> 0) |
| prix_classique | REAL | NOT NULL, CHECK (> 0) |
| prix_vip | REAL | NOT NULL, CHECK (> 0) |

- **Règles de validation (FR-001)** : les villes sont bornées à la liste
  du sujet ; un trajet ne relie pas une ville à elle-même.
- **Volume test** : ≥ 8 lignes.

### bus

Véhicules affectés aux voyages.

| Colonne | Type | Contraintes |
|---|---|---|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT |
| immatriculation | TEXT | NOT NULL, UNIQUE |
| nombre_places | INTEGER | NOT NULL, CHECK BETWEEN 1 AND 100 |
| type | TEXT | NOT NULL, CHECK IN ('classique','vip') |

- **Règles (FR-002/FR-005)** : `nombre_places` borne la capacité du plan
  de sièges et le contrôle serveur d'achat.
- **Volume test** : ≥ 6 lignes.

### voyages

Trajet effectué par un bus à une date/heure.

| Colonne | Type | Contraintes |
|---|---|---|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT |
| trajet_id | INTEGER | NOT NULL, FK → trajets(id) |
| bus_id | INTEGER | NOT NULL, FK → bus(id) |
| date | TEXT | NOT NULL, format ISO 'YYYY-MM-DD' |
| heure | TEXT | NOT NULL, format 'HH:MM' |
| statut | TEXT | NOT NULL DEFAULT 'prévu', CHECK IN ('prévu','parti','annulé') |

- **Transitions d'état** :
  - `prévu → annulé` : POST admin (FR-012) — irréversible côté interface.
  - `prévu → parti` : POST admin (départ effectué).
  - `annulé` et `parti` : états terminaux pour l'achat (FR-007).
- **Règle d'achat** : achetable ssi `statut = 'prévu'` ET
  `date >= date courante` (FR-007).
- **Volume test** : 60 lignes réparties sur 3 semaines (±15 jours autour
  d'aujourd'hui).

### billets

Place vendue sur un voyage — cœur d'intégrité du projet.

| Colonne | Type | Contraintes |
|---|---|---|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT |
| voyage_id | INTEGER | NOT NULL, FK → voyages(id) |
| numero_siege | INTEGER | NOT NULL, CHECK (>= 1) + déclencheur capacité |
| nom | TEXT | NOT NULL |
| telephone | TEXT | NOT NULL |
| piece_identite | TEXT | NOT NULL |
| code_reservation | TEXT | NOT NULL, UNIQUE |
| date_achat | TEXT | NOT NULL, ISO 'YYYY-MM-DD' |

- **Contrainte anti double-vente (NON-NEGOTIABLE, FR-004)** :
  `UNIQUE (voyage_id, numero_siege)` — un siège ne peut être vendu deux
  fois pour le même voyage, même en contournant l'application.
- **Déclencheur capacité (FR-005)** : `BEFORE INSERT ON billets` —
  vérifie `numero_siege <= bus.nombre_places` du bus du voyage ; lève une
  erreur si hors capacité (le CHECK SQLite ne peut pas joindre deux
  tables). Voir [research.md](research.md) Décision 5.
- **Code de réservation (FR-003)** : généré par
  `secrets.token_urlsafe(8)` ; `UNIQUE` ; jamais dévinable.
- **Volume test** : 400 lignes.
- **Validation serveur avant INSERT** : voyage achetable, siège libre,
  capacité respectée, champs voyageur non vides, téléphone au format
  +N/N (digits, `+` optionnel, 8–15 chiffres).

### admins

Compte(s) de connexion à l'espace d'administration.

| Colonne | Type | Contraintes |
|---|---|---|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT |
| username | TEXT | NOT NULL, UNIQUE |
| password_hash | TEXT | NOT NULL (empreinte Werkzeug, jamais en clair) |

- **Volume test** : 1 ligne (`admin`, mot de passe documenté dans le
  README, hashé par `donnees_test.py` — Décision 15).

## Règles d'intégrité transverses

1. Toute écriture passe par des requêtes paramétrées (`?`) — constitution §I.
2. Toute mutation (INSERT/UPDATE/DELETE) se fait uniquement en POST —
   constitution §I.
3. Suppression logique privilégiée : `annulé` pour les voyages ; aucun
   DELETE de billet dans le périmètre (un billet vendu reste au registre).
4. Les compteurs de places restantes se calculent toujours par
   `nombre_places - COUNT(billets)` — pas de dénormalisation.

## Chiffres dérivés (affichage)

- **Places restantes** : `bus.nombre_places - COUNT(billets.voyage_id)`.
- **Prix du billet** : `trajets.prix_vip` si `bus.type = 'vip'` sinon
  `prix_classique`.
- **Taux de remplissage d'un trajet** : billets vendus ÷ capacité
  cumulée des voyages du trajet (période = ensemble des voyages).
- **Recette** : somme des prix appliqués aux billets vendus (par trajet,
  regroupée par semaine ISO via `strftime('%W', date)`).
