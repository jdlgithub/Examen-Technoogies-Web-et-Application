# Quickstart — Guide de validation exécutable (Phase 1)

**Date**: 2026-10-20 | **Spec**: [spec.md](spec.md) | **Contrats** :
[api.md](contracts/api.md), [routes.md](contracts/routes.md)

Ce guide sert de checklist d'acceptation : il prouve le fonctionnement de
bout en bout sans entrer dans le code (les corps d'implémentation vivent
dans `tasks.md` et la phase d'implémentation).

## Prérequis

- Python 3.12 installé (`python --version`).
- Accès réseau facultatif (la police Roboto tombe en repli système hors
  ligne — Décision 12).

## Installation et démarrage

```bash
cd projet
python -m venv venv
venv\Scripts\activate          # Windows (ou source venv/bin/activate ailleurs)
pip install -r requirements.txt
python donnees_test.py         # applique schema.sql puis remplit : 8 trajets, 6 bus, 60 voyages, 400 billets, admin
python app.py                  # http://127.0.0.1:5000
```

Compte admin de test : documenté dans le `README.md` (utilisateur
`admin`).

## Scénarios de validation

### S1 — Recherche de voyage (US1, FR-001)

1. Ouvrir `http://127.0.0.1:5000/`.
2. Saisir départ `Douala`, arrivée `Yaoundé`, date = un jour avec voyages.
3. **Attendu** : liste avec heure, durée, prix, places restantes > 0.
4. Rechercher une combinaison vide → message « aucun voyage ».

### S2 — Plan de sièges via fetch (US2, FR-002, FR-013)

1. Cliquer « Choisir un siège » sur un voyage.
2. **Attendu** : grille de 1 à `nombre_places` affichée sans rechargement
   ; sièges vendus grisés et non cliquables ; sièges libres cliquables.
3. Ouvrir l'onglet réseau : une requête `GET /api/voyages/<id>/sieges`
   renvoie du JSON valide (contrat api.md §1).

### S3 — Achat avec choix de siège (US2, FR-003)

1. Choisir un siège libre, remplir nom, téléphone, pièce d'identité.
2. Valider.
3. **Attendu** : page de confirmation avec code de réservation unique
   (~11 caractères URL-sûres) ; le siège redevient grisé après
   rechargement.

### S4 — Anti double-vente (US2, FR-004, SC-002)

1. Noter un siège vendu en S3.
2. Tenter de l'acheter à nouveau (depuis une autre session/navigateur, en
   saisissant le numéro directement dans le formulaire si nécessaire).
3. **Attendu** : refus avec message « siège déjà vendu » ; vérifier en
   base : `SELECT COUNT(*) FROM billets WHERE voyage_id=… AND numero_siege=…`
   → 1.

### S5 — Siège hors capacité (FR-005)

1. Tenter un achat avec le numéro `nombre_places + 1` (contournement du
   plan).
2. **Attendu** : refus côté serveur, message explicite, aucun billet
   créé.

### S6 — Formulaire invalide (FR-015)

1. Vider le nom ou saisir un téléphone invalide (`abc`).
2. **Attendu** : bloqué côté navigateur (message de champ) ; en contournant
   le JS, le serveur refuse également.

### S7 — Retrouver un billet (US3, FR-006)

1. Aller sur `/billets`, saisir le code de S3 → billet complet affiché.
2. Saisir `CODEFAUX` → message « code introuvable », pas d'erreur 500.

### S8 — Administration : refus sans session (US4, FR-008, SC-004)

1. Ouvrir `http://127.0.0.1:5000/admin` en navigation privée.
2. **Attendu** : redirection vers la page de connexion ; aucune page
   d'admin accessible.

### S9 — Administration : connexion et programmation (US4, FR-009/010)

1. Se connecter avec le compte `admin` ; mauvais mot de passe → refus.
2. Programmer un voyage (trajet, bus, date, heure) → visible dans
   `/admin` et dans la recherche publique avec statut « prévu ».

### S10 — Passagers imprimables et annulation (US5, FR-011/012)

1. Ouvrir la liste des passagers d'un voyage chargé ; Ctrl+P → la mise en
   page d'impression est propre (en-tête, tableau, sans menu).
2. Annuler un voyage `prévu` → il disparaît de la recherche publique ;
   re-tenter l'achat direct → refus.

### S11 — Statistiques (US6, FR-014, SC-005)

1. Ouvrir `/admin/statistiques` ou `GET /api/statistiques`.
2. **Attendu** : 4 jeux de données présents et cohérents ; vérifier le
   remplissage et la recette de 2 trajets par calcul manuel sur la base.

### S12 — Contrôles transverses (constitution)

1. `debug=False` dans `app.py` (vérifier qu'aucune page d'exception
   n'apparaît en erreur 500).
2. Pages principales valides au validateur W3C.
3. Aperçu mobile (360 px) : recherche, achat et admin utilisables sans
   défilement horizontal (captures `captures/telephone/`).
4. `sqlite3 projet.db ".tables"` → 5 tables ; volumes :
   `SELECT COUNT(*)` sur `trajets` (≥8), `bus` (≥6), `voyages` (60),
   `billets` (≥400).

## Critères de sortie

Les 12 scénarios passent sans erreur → le code source est fonctionnel de
bout en bout (FR-020) et la production des livrables (README, captures,
diaporama, vidéo, export SQL) peut commencer.
