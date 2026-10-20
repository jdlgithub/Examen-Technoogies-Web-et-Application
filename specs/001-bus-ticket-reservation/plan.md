# Implementation Plan: Réservation de billets de bus interurbains

**Branch**: `001-bus-ticket-reservation` | **Date**: 2026-10-20 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/001-bus-ticket-reservation/spec.md`

## Summary

Application web complète de vente de billets de bus interurbains pour
l'agence (Douala, Yaoundé, Bafoussam, Kribi, Buea) : recherche de voyages
avec places restantes, plan de bus interactif et achat avec choix du siège,
récupération de billet par code unique non devinable, espace
d'administration protégé (programmation, passagers imprimables,
annulation), API JSON (sièges + statistiques). Approche technique : une
application Flask unique servie en rendu serveur (Jinja2) + un peu de
JavaScript côté navigateur (validation de formulaire, `fetch` du plan des
sièges), base SQLite imposée, données de test scriptées aux volumes du
sujet (8 trajets, 6 bus, 60 voyages, 400 billets). Code source fonctionnel
prioritaire ; livrables de remise produits uniquement à la fin.

## Technical Context

**Language/Version**: Python 3.12 (installé sur le poste du porteur)

**Primary Dependencies**: Flask (seule dépendance serveur imposée) ;
`sqlite3`, `secrets`, `string`/`secrets` pour les codes — modules
standard ; `werkzeug.security` (fourni par Flask) pour le hachage des mots
de passe. Rien d'autre (YAGNI, constitution §V).

**Storage**: SQLite — `projet.db` créée par `schema.sql`, remplie par
`donnees_test.py`, exportée en `export_projet.sql`.

**Testing**: Validation manuelle scriptée via [quickstart.md](quickstart.md)
(scénarios S1–S12 avec résultats attendus) + volumes garantis par
`donnees_test.py`. Aucun framework de test ajouté (YAGNI ; le sujet
n'en exige pas).

**Target Platform**: poste Windows du porteur (Python 3.12) ; doit aussi
se lancer sur n'importe quel poste suivant uniquement le README (Windows/
macOS/Linux). Serveur de développement Flask, debug=False en version
rendue.

**Project Type**: web application (server-rendered + JS navigateur + API
JSON interne).

**Performance Goals**: échelle monoposte/évaluateur — recherche et plan de
sièges rendus en < 1 s ; statistiques calculées sur ≤ 400 billets
instantanément.

**Constraints**: constitution v1.0.0 — SQL paramétrée partout, mots de
 passe hachés, mutations en POST uniquement, admin protégé par session,
 codes de réservation via `secrets` + UNIQUE, `debug=False` ; contraintes
 d'intégrité au niveau du schéma (UNIQUE voyage/siège, CHECK capacité) ;
 HTML sémantique validé W3C, mobile-first ≥ 2 points de rupture ; charte
 blanc/gris/noir, police Roboto ; interface en français ; code commenté en
 français.

**Scale/Scope**: 4 entités métier + 1 table admin ; 5 tables au total ;
 ~12 gabarits ; ~15 routes HTML + 2 routes JSON ; volumes de test : 8
 trajets, 6 bus, 60 voyages sur 3 semaines, 400 billets.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Porte (constitution v1.0.0) | Verdict | Preuve dans ce plan |
|---|---|---|
| I. Sécurité serveur (NON-NEGOTIABLE) | PASS | SQL 100 % paramétrée (`?`) ; `generate_password_hash`/`check_password_hash` ; mutations en POST ; décorateur de session admin ; codes via `secrets.token_urlsafe` + UNIQUE ; `debug=False` (quickstart S11). |
| II. Intégrité des Données (NON-NEGOTIABLE) | PASS | `UNIQUE (voyage_id, numero_siege)` ; CHECK capacité via déclencheur SQLite (voir [research.md](research.md) Décision 5) ; CHECK statut ; NOT NULL ; FK sur les 4 tables du sujet + admins (voir [data-model.md](data-model.md)). |
| III. Conformité au Sujet | PASS | 6 user stories du spec → phases d'implémentation ; volumes imposés par `donnees_test.py` ; livrables reportés après code fonctionnel (FR-020) ; bonus hors scope. |
| IV. Qualité Web (HTML/CSS/JS) | PASS | `base.html` parent de tous ; flash + 404 ; W3C ; mobile-first 2 breakpoints ; plan de sièges en grille HTML/CSS alimenté par `fetch` ; 2 routes JSON (contrats dans [contracts/](contracts/)). |
| V. Simplicité et Lisibilité (NON-NEGOTIABLE) | PASS | Flask + `sqlite3` seuls ; arborescence imposée par le sujet (`projet/`) ; commentaires et noms en français ; pas de couche d'abstraction inutile. |

Aucune violation → [Complexity Tracking](#complexity-tracking) reste vide.

## Project Structure

### Documentation (this feature)

```text
specs/001-bus-ticket-reservation/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
│   ├── api.md           # Contrat des 2 routes JSON
│   └── routes.md        # Contrat des pages/routes HTML
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

Arborescence conforme au sujet (l'enseignant l'attend telle quelle) :

```text
GIT-GLO-5-Groupe04/
├── rapport_Groupe04.pptx        # livrable, produit en fin de projet
├── video_demo.mp4               # livrable, produit en fin de projet
├── projet/
│   ├── README.md                # livrable, produit après code fonctionnel
│   ├── requirements.txt         # pip freeze > requirements.txt
│   ├── app.py                   # application Flask (routes + helpers)
│   ├── schema.sql               # création des tables + contraintes + déclencheur
│   ├── donnees_test.py          # remplit la base aux volumes du sujet
│   ├── projet.db                # base SQLite déjà remplie
│   ├── export_projet.sql        # export complet de la base
│   ├── static/
│   │   ├── css/
│   │   │   ├── style.css        # mobile-first + breakpoints + charte
│   │   │   └── print.css        # mise en page imprimable (passagers)
│   │   ├── js/
│   │   │   ├── validation.js    # vérification des formulaires avant envoi
│   │   │   └── sieges.js        # fetch /api/voyages/<id>/sieges + grille
│   │   └── images/
│   └── templates/
│       ├── base.html            # parent de tous les gabarits (Roboto, charte)
│       ├── index.html           # recherche de voyage
│       ├── resultats.html       # liste des voyages + places restantes
│       ├── achat.html           # plan du bus + formulaire d'achat
│       ├── confirmation.html    # affichage du code de réservation
│       ├── retrouver.html       # formulaire + résultat de billet par code
│       ├── 404.html             # page d'erreur personnalisée
│       └── admin/
│           ├── login.html
│           ├── base_admin.html  # hérite de base.html, barre d'admin
│           ├── tableau.html     # tableau de bord (accès rapide)
│           ├── programmation.html  # formulaire nouveau voyage
│           ├── passagers.html   # liste imprimable (@media print)
│           └── statistiques.html
└── captures/
    ├── ordinateur/
    └── telephone/
```

**Structure Decision**: Option web application (serveur + navigateur) telle
quelle — structure imposée par le sujet d'examen ; `app.py` unique (KISS :
une seule application, pas de blueprints) sauf si la taille justifie une
séparation admin ; l'arborescence racine respecte strictement le gabarit
du sujet. Pas de dossier `src/` ni de découpage framework.

## Complexity Tracking

Aucune violation de la constitution à justifier — tous les gates passent
sans exception (tableau ci-dessus).
