# Research — Réservation de billets de bus interurbains (Phase 0)

**Date**: 2026-10-20 | **Plan**: [plan.md](plan.md) | **Spec**: [spec.md](spec.md)

Toutes les zones d'incertitude du Technical Context sont résolues ici.
Aucun `NEEDS CLARIFICATION` ne subsiste.

## Décision 1 — Framework web : Flask (imposé)

- **Decision**: Flask, unique dépendance serveur ; `app.py` mono-fichier.
- **Rationale**: imposé par le sujet et par le porteur ; suffisant pour
  ~15 routes ; mono-fichier = KISS/YAGNI (constitution §V).
- **Alternatives considered**: Django (trop lourd, hors sujet), FastAPI
  (hors sujet, dépendances supplémentaires).

## Décision 2 — Accès aux données : `sqlite3` brut, SQL paramétrée

- **Decision**: module standard `sqlite3`, requêtes avec `?` partout,
  `row_factory = sqlite3.Row` pour des lignes nommées ; fonction d'aide
  `get_db()` en contexte.
- **Rationale**: imposé par le sujet ; constitution §I interdit toute
  concaténation SQL ; pas d'ORM (YAGNI).
- **Alternatives considered**: SQLAlchemy (dépendance + abstraction
  inutile), apsw (hors sujet).

## Décision 3 — Hachage des mots de passe : `werkzeug.security`

- **Decision**: `generate_password_hash` / `check_password_hash` (méthode
  scrypt par défaut de Werkzeug, fourni avec Flask).
- **Rationale**: nommé explicitement par le sujet ; déjà présent via
  Flask ; aucune dépendance ajoutée.
- **Alternatives considered**: bcrypt/passlib (dépendance externe),
  hashlib direct (gère mal le salage itératif).

## Décision 4 — Code de réservation : `secrets.token_urlsafe`

- **Decision**: `secrets.token_urlsafe(8)` → ~11 caractères URL-sûres,
  entropie 64 bits ; contrainte `UNIQUE` en base ; régénéré en cas de
  collision (probabilité quasi nulle).
- **Rationale**: sujet exige « unique et difficile à deviner (module
  secrets) » ; entropie suffisante pour 400 billets (collision < 10⁻¹²).
- **Alternatives considered**: numéros séquentiels (devinables),
  `uuid4` (longueur inutile), `token_hex(6)` (moins lisible à
  recopier).

## Décision 5 — Anti double-vente : `UNIQUE (voyage_id, numero_siege)` + déclencheur capacité

- **Decision**: contrainte `UNIQUE (voyage_id, numero_siege)` dans
  `schema.sql` ; interception de `sqlite3.IntegrityError` → message
  « siège déjà vendu » (HTTP 409 côté serveur, message flash côté page).
  Le bornage `numero_siege <= nombre_places` ne peut pas s'exprimer en
  `CHECK` inter-tables en SQLite : un déclencheur `BEFORE INSERT ON
  billets` vérifie la capacité du bus du voyage et lève une erreur sinon.
- **Rationale**: garantie au niveau du schéma (constitution §II), pas
  seulement dans l'application ; SQLite sérialise les écritures → le
  second achat concurrent reçoit l'erreur UNIQUE. Le déclencheur couvre
  le cas « numéro > capacité » même si l'application est contournée.
- **Alternatives considered**: SELECT puis INSERT (course possible →
  rejeté), CHECK avec capacité copiée sur chaque billet (dénormalisation
  fragile), verrou applicatif (inutile en SQLite, mono-connexion
  d'évaluation).

## Décision 6 — Authentification admin : cookie de session signé Flask

- **Decision**: `session['admin_id']` après vérification du hash ;
  décorateur `administrateur_requis` redirigeant vers
  `/admin/connexion` ; déconnexion en POST ; `SECRET_KEY` chargée depuis
  une variable d'environnement avec valeur de repli documentée (jamais
  commitée en clair dans le code source).
- **Rationale**: sujet exige « connexion » ; session Flask suffit ;
  JWT/SSO = sur-ingénierie (YAGNI).
- **Alternatives considered**: JWT (inutile pour un site serveur-rendu),
  HTTP Basic (mauvaise gestion de déconnexion).

## Décision 7 — Plan des sièges : grille HTML/CSS pilotée par `fetch`

- **Decision**: page `achat.html` affiche un conteneur vide ; `sieges.js`
  appelle `GET /api/voyages/<id>/sieges`, construit une grille de
  boutons/blocs HTML (classes CSS `.siege`, `.siege-libre`,
  `.siege-pris`), sièges pris = grisés + `disabled` ; clic sur libre =
  sélection + champ caché `numero_siege` du formulaire.
- **Rationale**: sujet impose « plan des sièges dessiné en HTML et CSS,
  sièges pris grisés, chargé par fetch ». Rechargement de la page à
  l'achat pour re-fetch (simple, fiable).
- **Alternatives considered**: canvas/SVG (contre le sujet), rendu 100 %
  serveur (contre le fetch exigé).

## Décision 8 — Statistiques : agrégats SQL

- **Decision**: vues/requêtes SQL avec `GROUP BY` et `strftime` (semaines
  ISO `%W`, jours `%Y-%m-%d`), renvoyées par `/api/statistiques` ;
  remplissage = billets/`nombre_places`, recette = somme des prix selon
  le type du bus, heures comptées par `heure`.
- **Rationale**: données minuscules (400 billets) → agrégats instantanés ;
  calcul SQL = moins de code Python (KISS) et facile à vérifier
  manuellement (SC-005).
- **Alternatives considered**: calcul en Python ligne à ligne (plus de
  code, même résultat), bibliothèque pandas (dépendance interdite).

## Décision 9 — CSRF : hors périmètre, documenté

- **Decision**: pas de framework CSRF ; toutes les mutations sont en POST
  avec session cookie (`SameSite=Lax` par défaut des cookies modernes) ;
  limitation assumée et documentée dans le README.
- **Rationale**: le sujet et la constitution n'exigent pas de jeton CSRF ;
  ajouter Flask-WTF serait une dépendance non exigée (YAGNI). Le risque
  résiduel est acceptable pour un projet d'examen monoposte.
- **Alternatives considered**: Flask-WTF (dépendance +), double submit
  cookie maison (code supplémentaire sans exigence).

## Décision 10 — Gestion des statuts de voyage

- **Decision**: `statut TEXT CHECK (statut IN ('prévu','parti','annulé'))`,
  défaut `'prévu'`. Achat autorisé uniquement si `statut = 'prévu'` ET
  `date >= date du jour`. Transition `prévu → annulé` via POST admin ;
  `prévu → parti` manuelle depuis le tableau de bord admin.
- **Rationale**: trois statuts imposés par le sujet ; contrôle serveur à
  chaque achat (constitution §I).
- **Alternatives considered**: machine à états complexe ou dérivation
  automatique seule (l'admin doit pouvoir annuler un voyage à venir).

## Décision 11 — Dates et heures

- **Decision**: dates en ISO `YYYY-MM-DD` (TEXT en SQLite), heures
  `HH:MM` (TEXT) ; comparaisons lexicographiques valides pour l'ISO ;
  format d'affichage français (`jj/mm/aaaa`) dans les gabarits.
- **Rationale**: SQLite n'a pas de type date ; l'ISO trie et compare
  correctement ; `strftime` fonctionne directement.
- **Alternatives considered**: timestamps entiers (illisibles),
  `datetime` natif SQLite (formats variables, moins prévisibles).

## Décision 12 — Police Roboto et charte blanc/gris/noir

- **Decision**: lien Google Fonts dans `base.html`
  (`fonts.googleapis.com/css2?family=Roboto`) avec pile de repli
  `'Roboto', 'Segoe UI', Arial, sans-serif` ; palette via variables CSS
  (`--fond: #ffffff`, `--gris-clair: #f5f5f5`, `--gris: #9e9e9e`,
  `--gris-fonce: #424242`, `--texte: #212121`, `--accent: #000000`) ;
  aucun dégradé criard, boutons noirs, tableaux bordés gris.
- **Rationale**: exigence explicite du porteur ; repli système si le
  poste est hors ligne (l'enseignant peut tester sans internet) ;
  charte classique = « professionnel ».
- **Alternatives considered**: police embarquée en local (fichiers
  binaires dans le dépôt, lourd), CSS framework (dépendance, charte
  imposée incompatible).

## Décision 13 — Stratégie de validation et d'erreurs

- **Decision**: double validation (JS `validation.js` pour le confort +
  revérification systématique côté serveur avec messages flash) ;
  erreurs 404 personnalisée via gabarit ; violation d'intégrité → message
  4xx propre, jamais de trace de traceback à l'écran (`debug=False`).
- **Rationale**: FR-015 + constitution §I ; le serveur ne fait jamais
  confiance au client.
- **Alternatives considered**: validation seule côté client (sécurité),
  validation seule serveur (mauvaise expérience exigée par le sujet).

## Décision 14 — Stratégie de test/validation

- **Decision**: pas de framework de test (YAGNI — le sujet n'en exige
  pas) ; validation manuelle structurée par les 12 scénarios de
  [quickstart.md](quickstart.md) ; volumes vérifiables par requêtes
  rapides dans l'espace admin/statistiques et par `donnees_test.py`.
  Les scénarios couvrent les cas d'erreur (double vente, code erroné,
  admin sans session, siège hors capacité).
- **Rationale**: projet d'examen mono-développeur ; le quickstart sert de
  checklist d'acceptation exécutable ; évite une dépendance pytest sans
  exigence.
- **Alternatives considered**: pytest + Flask test client (utile à plus
  grande échelle, hors besoin ici).

## Décision 15 — Compte administrateur de test

- **Decision**: `donnees_test.py` crée l'utilisateur `admin` avec mot de
  passe documenté dans le README (hash `generate_password_hash` stocké
  en base ; le mot de passe en clair n'apparaît que dans le README et le
  commentaire du script, jamais dans le code applicatif).
- **Rationale**: sujet (« 2.3 Créer le compte administrateur de test ») ;
  l'enseignant doit pouvoir se connecter immédiatement.
- **Alternatives considered**: compte créé au premier lancement (moins
  prévisible pour l'évaluation).
