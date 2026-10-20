---

description: "Task list for feature 001-bus-ticket-reservation"
---

# Tasks: Réservation de billets de bus interurbains

**Input**: Design documents from `/specs/001-bus-ticket-reservation/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md), [contracts/](contracts/), [quickstart.md](quickstart.md)

**Tests**: Aucune tâche de test automatisé — non demandé par le sujet ni
par le porteur (YAGNI) ; la validation se fait par les scénarios
quickstart S1–S12 attachés à chaque checkpoint d'histoire.

**Organization**: Tasks are grouped by user story to enable independent
implementation and testing of each story. Code commentaires et noms en
français (constitution §V). Commit multiligne après chaque phase
(constitution §Workflow).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

Structure imposée par le sujet : application Flask unique dans `projet/`
(voir plan.md §Project Structure). Tous les chemins sont relatifs à la
racine du dépôt `GIT-GLO-5-Groupe04/`.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Initialisation du dépôt et de l'arborescence conforme au sujet

- [X] T001 Créer l'arborescence du projet : `projet/`,
  `projet/static/css/`, `projet/static/js/`, `projet/static/images/`,
  `projet/templates/admin/`, `captures/ordinateur/`, `captures/telephone/`
  (plan.md §Project Structure)
- [X] T002 Créer `projet/requirements.txt` contenant Flask (point de
  départ de `pip freeze`)
- [X] T003 [P] Créer `projet/static/css/style.css` : variables de la
  charte (blanc `#ffffff`, gris clair `#f5f5f5`, gris `#9e9e9e`, gris
  foncé `#424242`, texte `#212121`, accent `#000000`), import Roboto
  avec repli système, styles de base mobile-first (research.md Décision 12)
- [X] T004 [P] Créer `projet/static/css/print.css` squelette
  (règles `@media print` vides, rempli en US5)
- [X] T005 Initialiser le dépôt Git (`git init`), créer le
  `.gitignore` racine excluant `venv/`, `__pycache__/`,
  `projet/projet.db-journal`, puis commit d'initialisation multiligne

**Checkpoint**: arborescence et socle CSS prêts.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Schéma, application squelette et données de test — bloquant
pour TOUTES les user stories

**?? CRITICAL**: Aucune user story ne peut démarrer avant la fin de cette phase

- [X] T006 Écrire `projet/schema.sql` d'après data-model.md : tables
  `trajets`, `bus`, `voyages`, `billets`, `admins` avec NOT NULL, UNIQUE,
  CHECK, clés étrangères, `UNIQUE (voyage_id, numero_siege)` et déclencheur
  `BEFORE INSERT ON billets` vérifiant la capacité du bus (Décision 5)
- [X] T007 Créer `projet/app.py` squelette : application Flask,
  `SECRET_KEY` via variable d'environnement avec repli, `get_db()` avec
  `sqlite3.Row`, messages flash, `debug=False`, gestionnaire 404 →
  gabarit `404.html`, décorateur `administrateur_requis` (session
  `admin_id`, redirection `/admin/connexion`)
- [X] T008 [P] Créer `projet/templates/base.html` : squelette HTML5
  sémantique (header/nav/main/footer), lien Roboto + `style.css`,
  bloc `{% with messages = get_flashed_messages() %}`, placeholder
  `{% block contenu %}` (FR-017/FR-019)
- [X] T009 [P] Créer `projet/templates/404.html` héritant de `base.html`
  (page d'erreur personnalisée, FR-019)
- [X] T010 Créer `projet/donnees_test.py` : applique `schema.sql` puis
  remplit les volumes imposés — 8 trajets sur les 5 villes, 6 bus
  (immatriculations uniques, mixte classique/VIP), 60 voyages sur 3
  semaines autour d'aujourd'hui (statuts majoritairement `prévu`),
  400 billets répartis sans double-vente (INSERT avec rejeu sur
  collision UNIQUE), 1 compte `admin` avec
  `generate_password_hash` (mot de passe documenté dans le commentaire
  du script) ; exécuter le script et vérifier les compteurs
- [X] T011 [P] Créer `projet/templates/admin/login.html` héritant de
  `base.html` (formulaire username/mot de passe avec labels, FR-009)

**Checkpoint**: `python donnees_test.py` crée `projet/projet.db` remplie ;
`python app.py` démarre et sert une page 404 propre. Fondation prête.

---

## Phase 3: User Story 1 - Rechercher un voyage et voir les places restantes (Priority: P1)

**Goal**: Un visiteur cherche départ/arrivée/date et voit les voyages avec
places restantes (FR-001, FR-007).

**Independent Test**: quickstart S1 — recherche Douala→Yaoundé demain →
liste avec heure/durée/prix/places ; combinaison vide → message clair.

### Implementation for User Story 1

- [X] T012 [US1] Implémenter `GET /` dans `projet/app.py` rendant
  `projet/templates/index.html` (formulaire départ, arrivée, date avec
  `label` sur chaque champ, villes proposées en liste déroulante)
- [X] T013 [US1] Implémenter `GET /resultats` dans `projet/app.py` :
  requête paramétrée (`?`) joignant voyages/bus/trajets, filtre
  `statut='prévu'`, `date >= aujourd'hui`, places restantes =
  `nombre_places - COUNT(billets)`, rendu de
  `projet/templates/resultats.html` (tableau hour/durée/prix/places +
  lien « Choisir un siège » vers `/voyages/<id>/acheter`)
- [X] T014 [US1] Gérer le cas vide dans `projet/app.py` +
  `projet/templates/resultats.html` : message flash/état vide « aucun
  voyage ne correspond » (Edge case spec)

**Checkpoint**: S1 validé — US1 fonctionne seule avec les données de test.

---

## Phase 4: User Story 2 - Choisir son siège et acheter un billet (Priority: P1) ?? MVP

**Goal**: Plan de sièges interactif + achat + code de réservation unique
(FR-002 à FR-005, FR-015) — cœur métier.

**Independent Test**: quickstart S2–S6 — plan grisé via fetch, achat avec
code affiché, double-vente refusée, siège hors capacité refusé, formulaire
invalide bloqué.

### Implementation for User Story 2

- [X] T015 [P] [US2] Implémenter `GET /api/voyages/<id>/sieges` dans
  `projet/app.py` selon le contrat [contracts/api.md](contracts/api.md)
  §1 : JSON `{voyage, total_places, prix, sieges:[{numero, pris}]}` ;
  404 JSON si voyage inexistant
- [X] T016 [US2] Créer `projet/static/js/sieges.js` : `fetch` de l'API
  sièges, construction de la grille HTML (classes `.siege`,
  `.siege-libre`, `.siege-pris` grisé + `disabled`), sélection d'un siège
  libre → champ caché `numero_siege` du formulaire (dépend T015)
- [X] T017 [P] [US2] Créer `projet/templates/achat.html` héritant de
  `base.html` : conteneur `id="plan-sieges"`, formulaire d'achat (nom,
  téléphone, pièce d'identité, champ caché siège) avec labels, chargement
  de `sieges.js`
- [X] T018 [US2] Implémenter `GET /voyages/<id>/acheter` dans
  `projet/app.py` : contrôle achetable (`prévu` + date + place libre),
  rendu `achat.html` (dépend T017)
- [X] T019 [US2] Implémenter `POST /voyages/<id>/acheter` dans
  `projet/app.py` : revérification serveur complète (FR-015), génération
  `secrets.token_urlsafe(8)` avec rejeu sur collision, INSERT billet,
  interception `sqlite3.IntegrityError` → flash « siège déjà vendu »,
  succès → redirection `GET /confirmation?code=...`
- [X] T020 [US2] Créer `projet/templates/confirmation.html` +
  implémenter `GET /confirmation` dans `projet/app.py` : récapitulatif
  + code de réservation mis en avant (FR-003)
- [X] T021 [P] [US2] Créer `projet/static/js/validation.js` : vérification
  du formulaire d'achat avant envoi (champs requis, téléphone
  `^\+?[0-9]{8,15}$`), brancher sur le formulaire de
  `projet/templates/achat.html`

**Checkpoint MVP**: parcours complet visiteur (S1–S6) fonctionne de bout
en bout. Valider S2 à S6 avant de continuer.

---

## Phase 5: User Story 3 - Retrouver son billet avec son code (Priority: P2)

**Goal**: Récupération d'un billet par code seul (FR-006).

**Independent Test**: quickstart S7 — code valide → billet complet ;
`CODEFAUX` → message d'erreur, pas de 500.

### Implementation for User Story 3

- [X] T022 [US3] Créer `projet/templates/retrouver.html` (formulaire
  code + zone résultat) et implémenter dans `projet/app.py` : `GET
  /billets` (formulaire), `POST /billets/recherche` (contrôle serveur,
  redirection), `GET /billets/<code>` (rendu du billet : voyage, date,
  heure, siège, passager ; code inconnu → flash « code introuvable »)

**Checkpoint**: S7 validé — les trois histoires P1/P2 publiques
fonctionnent indépendamment.

---

## Phase 6: User Story 4 - Espace d'administration : connexion et programmation (Priority: P2)

**Goal**: Connexion protégée + programmation de voyages (FR-008 à FR-010).

**Independent Test**: quickstart S8–S9 — accès admin refusé sans session,
mauvais mot de passe refusé, bon compte → programme un voyage visible
publiquement.

### Implementation for User Story 4

- [X] T023 [US4] Implémenter dans `projet/app.py` : `GET/POST
  /admin/connexion` (vérification `check_password_hash`, session
  `admin_id`, échec → flash) et `POST /admin/deconnexion` (destruction
  de session) — utilise `projet/templates/admin/login.html` (T011)
- [X] T024 [US4] Créer `projet/templates/admin/base_admin.html`
  héritant de `base.html` (barre admin, bouton déconnexion POST) et
  `projet/templates/admin/tableau.html` + route `GET /admin` protégée
  (derniers voyages, raccourcis)
- [X] T025 [US4] Créer `projet/templates/admin/programmation.html` et
  implémenter `GET/POST /admin/voyages/nouveau` dans `projet/app.py` :
  formulaire trajet (liste des `trajets`), bus (liste des `bus`), date
  ISO, heure `HH:MM` ; contrôle serveur (champs, cohérence date) ;
  INSERT statut `prévu` ; succès → flash + redirection tableau

**Checkpoint**: S8 et S9 validés — l'espace admin refuse les non-connectés
et crée des voyages.

---

## Phase 7: User Story 5 - Liste des passagers imprimable et annulation (Priority: P2)

**Goal**: Opérations agence : liste passagers imprimable + annulation /
statut parti (FR-011, FR-012).

**Independent Test**: quickstart S10 — liste propre à l'impression ;
annulation retire le voyage de la recherche publique et bloque l'achat.

### Implementation for User Story 5

- [X] T026 [US5] Créer `projet/templates/admin/passagers.html` et
  implémenter `GET /admin/voyages/<id>/passagers` dans `projet/app.py` :
  tableau nom/téléphone/siège/code, lien d'impression ; compléter
  `projet/static/css/print.css` (masquer navigation, tableau propre en
  `@media print`)
- [X] T027 [US5] Implémenter dans `projet/app.py` : `POST
  /admin/voyages/<id>/annuler` (`prévu → annulé`, état terminal → flash
  d'erreur) et `POST /admin/voyages/<id>/parti` (`prévu → parti`) ;
  ajouter les boutons correspondants dans
  `projet/templates/admin/tableau.html`

**Checkpoint**: S10 validé — opérations admin complètes.

---

## Phase 8: User Story 6 - Statistiques de l'activité (Priority: P3)

**Goal**: API + page des 4 statistiques (FR-013, FR-014).

**Independent Test**: quickstart S11 — 4 jeux cohérents avec un recalcul
manuel (SC-005) ; base sans vente → zéro sans erreur.

### Implementation for User Story 6

- [X] T028 [US6] Implémenter `GET /api/statistiques` dans
  `projet/app.py` selon [contracts/api.md](contracts/api.md) §2 :
  agrégats SQL paramétrés — remplissage par trajet, recette par
  trajet/semaine (`strftime('%W')`), heures les plus demandées, billets
  des 14 derniers jours (jours vides à 0)
- [X] T029 [US6] Créer `projet/templates/admin/statistiques.html` +
  implémenter `GET /admin/statistiques` (protégée) : quatre tableaux
  remplis par `fetch` sur `/api/statistiques` — petit bloc script dédié
  dans le gabarit ou fonction distincte dans
  `projet/static/js/validation.js`, sans duplication de code

**Checkpoint**: S11 validé — toutes les user stories sont fonctionnelles.

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Durcissement, conformité W3C/mobile, livrables de remise —
UNIQUEMENT après code 100 % fonctionnel (FR-020)

- [X] T030 [P] Audit sécurité dans tous les fichiers de `projet/` :
  100 % de SQL paramétrée, mutations en POST uniquement,
  `debug=False`, `SECRET_KEY` hors source, aucun mot de passe en clair
  hors README/script de seed (contrôles constitution §I, quickstart S12)
- [X] T031 [P] Passer les pages principales au validateur W3C et
  corriger `projet/templates/*.html` (sémantique, `alt`, `label`, ordre
  d'en-têtes) — FR-019
- [X] T032 [P] Compléter `projet/static/css/style.css` : ≥ 2 points de
  rupture mobile-first, vérification à 360 px sur recherche, achat et
  admin — FR-018
- [X] T033 Générer `projet/export_projet.sql` depuis
  `projet/projet.db` (export complet, INSERT réinsertibles)
- [X] T034 Régénérer `projet/requirements.txt` par
  `pip freeze > requirements.txt` dans l'environnement du projet
- [X] T035 Exécuter la totalité de [quickstart.md](quickstart.md)
  (S1 à S12 + compteurs de volumes) et corriger toute anomalie trouvée
- [X] T036 Écrire `projet/README.md` : installation, lancement, comptes
  de test (admin), arborescence, résolution des problèmes courants —
  l'enseignant doit pouvoir tout faire avec ce fichier seul (SC-007)
- [ ] T037 Prendre les captures dans `captures/ordinateur/` et
  `captures/telephone/` (recherche, achat, confirmation, admin,
  passagers, statistiques, saisie refusée) pour le diaporama et la vidéo
- [ ] T038 Commit final multiligne + checklist de remise du sujet passée
  intégralement (constitution §Workflow)

**Checkpoint**: projet remettable — livrables (PPTX, vidéo) produits à
partir des captures.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: aucune dépendance — démarrage immédiat
- **Foundational (Phase 2)**: dépend de Setup — **BLOQUE toutes les user
  stories**
- **US1 (Phase 3)**: dépend de Phase 2 — indépendante des autres stories
- **US2 (Phase 4)**: dépend de Phase 2 — intègre le lien US1 (resultats →
  achat) mais est testable seule par URL directe
- **US3 (Phase 5)**: dépend de Phase 2 + de l'existence de billets
  (US2 pour les données de démo ; testable avec billets seedés)
- **US4 (Phase 6)**: dépend de Phase 2 (table `admins` + décorateur)
- **US5 (Phase 7)**: dépend de US4 (routes protégées)
- **US6 (Phase 8)**: dépend de Phase 2 + données billets (US2/seed) ;
  route admin dépend de US4
- **Polish (Phase 9)**: dépend de toutes les stories retenues

### User Story Dependencies

- **US1 (P1)**: après Phase 2 seulement
- **US2 (P1)**: après Phase 2 ; lien naturel depuis US1 mais indépendable
  par accès direct `/voyages/<id>/acheter`
- **US3 (P2)**: après Phase 2 (+ billets existants)
- **US4 (P2)**: après Phase 2
- **US5 (P2)**: après US4 (authentification requise)
- **US6 (P3)**: après Phase 2 + US4 pour la page admin (l'API publique
  est testable dès Phase 2 + seed)

### Within Each User Story

- Modèles/SQL de la story → services/logique → routes → gabarits → JS
- Chaque story se termine par son scénario quickstart exécuté

### Parallel Opportunities

- T003 et T004 (CSS) en parallèle
- T008, T009, T011 (gabarits indépendants) en parallèle
- T015 (API sièges) et T017 (achat.html) et T021 (validation.js) en
  parallèle — fichiers distincts
- T030, T031, T032 (audits Polish) en parallèle
- Avec plusieurs développeurs : après Phase 2 → dev A = US1+US2 (public),
  dev B = US4+US5 (admin), dev C = US6 (stats)

---

## Parallel Example: User Story 2

```bash
# Trois tâches sans dépendance mutuelle, lancements simultanés :
Task: "T015 Implémenter GET /api/voyages/<id>/sieges dans projet/app.py"
Task: "T017 Créer projet/templates/achat.html"
Task: "T021 Créer projet/static/js/validation.js"

# Puis enchaînement dépendant :
Task: "T016 sieges.js (dépend T015 pour le contrat JSON)"
Task: "T018 GET achat (dépend T017)"
Task: "T019 POST achat (dépend T018)"
Task: "T020 confirmation (dépend T019)"
```

---

## Implementation Strategy

### MVP First (User Story 1 + User Story 2)

1. Terminer Phase 1 (Setup) + Phase 2 (Foundational)
2. Terminer Phase 3 (US1) — recherche opérationnelle
3. Terminer Phase 4 (US2) — **MVP : le site vend des billets**
4. **STOP et VALIDER** : quickstart S1–S6
5. Commit multiligne de la phase MVP (constitution §Workflow)

### Incremental Delivery

1. Setup + Foundational → fondation prête (commit phase)
2. US1 → S1 validé (commit phase)
3. US2 → S2–S6 validés — MVP (commit phase)
4. US3 → S7 validé (commit phase)
5. US4 → S8–S9 validés (commit phase)
6. US5 → S10 validé (commit phase)
7. US6 → S11 validé (commit phase)
8. Polish → S12 + livrables (commit phase)

### Ordre recommandé (développeur unique)

Priorité stricte P1 → P2 → P3 (une story à la fois, validation
quickstart entre chaque), conformément au Workflow de la constitution.

---

## Notes

- Chaque phase se conclut par un **commit Git multiligne** (titre phase +
  corps détaillé) — constitution §Workflow ; ne jamais committer une
  phase non vérifiée.
- Aucune tâche de test automatisé : non demandé (YAGNI) ; quickstart.md
  tient le rôle de checklist d'acceptation exécutable.
- Ne pas commencer README/captures (T036–T037) avant que S1–S12 ne
  passent (FR-020, priorité explicite du porteur).
- Bonus sujet (QR code, aller-retour) : hors liste de tâches tant que le
  minimum n'est pas remis (constitution §III).
