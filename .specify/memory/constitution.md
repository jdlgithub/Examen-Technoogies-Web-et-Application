<!--
Sync Impact Report
==================
- Version change: scaffold du template non rempli (aucune version) → 1.0.0
  (ratification initiale du projet GIT-GLO-5-Groupe04).
- Modified principles: n/a — document initial ; aucun principe antérieur renommé.
- Added sections:
  - Core Principles (5 principes):
      I. Sécurité Serveur (NON-NEGOTIABLE)
      II. Intégrité des Données (NON-NEGOTIABLE)
      III. Conformité au Sujet
      IV. Qualité Web (HTML/CSS/JS)
      V. Simplicité et Lisibilité
  - Stack Technique et Contraintes
  - Workflow de Développement
  - Governance
- Removed sections:
  - Tous les placeholders du scaffold ([PROJECT_NAME], [PRINCIPLE_X_NAME],
    [PRINCIPLE_X_DESCRIPTION], [SECTION_2_NAME], [SECTION_2_CONTENT],
    [SECTION_3_NAME], [SECTION_3_CONTENT], [GOVERNANCE_RULES],
    [CONSTITUTION_VERSION], [RATIFICATION_DATE], [LAST_AMENDED_DATE])
    et leurs commentaires d'exemple associés.
- Follow-up TODOs: aucun — tous les placeholders ont été remplis ;
  RATIFICATION_DATE = date de la ratification initiale (2026-10-20).
-->

# Réservation de Billets de Bus — Constitution

Projet d'examen de Technologies Web et Applications (GIT-GLO-5-Groupe04) :
vente en ligne de billets de bus interurbains (Douala, Yaoundé, Bafoussam,
Kribi, Buea) avec choix du siège, espace d'administration et API JSON.

## Core Principles

### I. Sécurité Serveur (NON-NEGOTIABLE)

- Toutes les données reçues du client (recherche, achat, admin) MUST être
  re-vérifiées côté serveur, même lorsque JavaScript a déjà validé le formulaire.
- Toutes les requêtes SQL MUST utiliser des paramètres (`?`) ; la concaténation
  de chaînes dans une requête SQL est interdite.
- Les mots de passe MUST être stockés sous forme d'empreinte
  (`generate_password_hash`) et vérifiés avec `check_password_hash`.
- Les suppressions et les modifications MUST se faire uniquement en POST.
- L'espace d'administration MUST refuser tout accès sans session connectée.
- Le code de réservation MUST être unique et généré via le module `secrets`
  (difficile à deviner).
- `debug=False` dans la version rendue de l'application.

Rationale : l'application vend des billets et collecte nom, téléphone et pièce
d'identité ; une faille serveur ou un code devinable invalide le rendu et le
projet.

### II. Intégrité des Données (NON-NEGOTIABLE)

- Les contraintes MUST être portées par le schéma SQLite (`schema.sql`), pas
  uniquement par le code applicatif :
  - `UNIQUE (voyage, numéro de siège)` : un siège ne peut jamais être vendu
    deux fois pour le même voyage.
  - `CHECK` : un numéro de siège n'existe que s'il est compris entre 1 et le
    nombre de places du bus.
  - `UNIQUE` sur l'immatriculation du bus et sur le code de réservation.
  - `NOT NULL` sur toute colonne métier nécessaire.
- Le schéma MUST comporter au moins trois tables liées par des clés étrangères
  (`trajets`, `bus`, `voyages`, `billets`).
- Toute violation de contrainte MUST être détectée et renvoyer une erreur
  propre (message flash ou code HTTP 4xx), jamais une page d'exception.

Rationale : le sujet l'exige explicitement (contrainte UNIQUE voyage/siège,
bornage des numéros de siège) ; c'est le cœur métier de la réservation.

### III. Conformité au Sujet

- Chaque fonctionnalité du sujet MUST exister et fonctionner, y compris ses
  cas d'erreur : recherche de voyage avec places restantes, plan de siège et
  choix du siège, achat avec affichage du code, retrouver un billet par son
  code, programmation des voyages, liste des passagers imprimable,
  annulation d'un voyage, API JSON (`/api/voyages/<id>/sieges`,
  `/api/statistiques`), vérification de formulaire en JavaScript.
- Les volumes de test minimums MUST être atteints via `donnees_test.py` :
  8 trajets, 6 bus, 60 voyages sur trois semaines, 400 billets, plus les
  statistiques attendues (taux de remplissage par trajet, recette par trajet
  et par semaine, heures de départ les plus demandées, billets vendus par
  jour sur 14 jours).
- Les livrables de remise MUST être complets : `README.md` fonctionnel,
  `requirements.txt`, base `projet.db` remplie, `export_projet.sql`,
  captures ordinateur/téléphone, vidéo de 5 à 10 minutes, diaporama avec
  membres du groupe en première diapositive.
- Les bonus (QR code, réduction aller-retour) MUST être entrepris uniquement
  après complétude totale du minimum obligatoire.

Rationale : l'évaluation se fait par confrontation directe au sujet ; une
fonctionnalité ou un livrable absent coûte des points.

### IV. Qualité Web (HTML/CSS/JS)

- Un gabarit `base.html` MUST hériter de toutes les pages ; les messages flash
  et une page d'erreur 404 personnalisée MUST exister.
- L'HTML MUST utiliser des balises sémantiques, un `alt` sur chaque image et
  un `label` sur chaque champ ; les pages principales MUST passer le validateur
  W3C sans erreur.
- Le CSS MUST être mobile-first, dans des fichiers séparés, avec au moins deux
  points de rupture ; le site MUST rester confortable sur téléphone.
- Le JavaScript MUST vérifier au moins un formulaire avant l'envoi et MUST
  utiliser `fetch` sur au moins une route d'API ; le plan des sièges MUST être
  dessiné en HTML/CSS, avec les sièges pris grisés, chargé par `fetch` sur
  `/api/voyages/<id>/sieges`.
- L'API MUST exposer au moins deux routes renvoyant du JSON (`jsonify`),
  dont `/api/statistiques`.

Rationale : ces exigences techniques communes sont notées séparément par
l'enseignant (validation W3C, adaptatif, JavaScript/API).

### V. Simplicité et Lisibilité

- La stack MUST rester limitée à Python 3, Flask et le module `sqlite3` ;
  ajouter un framework ou une bibliothèque non exigée MUST être justifié
  (YAGNI).
- Le code MUST être commenté en français, avec des noms de fonctions clairs
  et un seul rôle par fonction.
- L'arborescence MUST suivre celle du sujet (`projet/`, `static/`,
  `templates/`, `captures/`) sans dossier `venv` ni fichier inutile commité.

Rationale : le projet est un examen ; la lisibilité du code fait partie de
l'évaluation et une base simple se débogue plus vite sous examen.

## Stack Technique et Contraintes

- Serveur : Python 3, Flask, SQLite via le module `sqlite3` — aucune autre
  dépendance serveur sans justification écrite.
- Dépendances : `requirements.txt` généré par `pip freeze > requirements.txt`
  et respecté à l'installation.
- Base de données : `schema.sql` (création des tables), `projet.db` (base
  remplie), `export_projet.sql` (export complet pour le rendu) — les trois
  MUST rester cohérents entre eux.
- Structure des fichiers : `app.py`, gabarits Jinja2 dans `templates/`,
  `static/css`, `static/js`, `static/images` ; captures dans
  `captures/ordinateur/` et `captures/telephone/`.
- Exécution : le site MUST se lancer sur un ordinateur tiers en suivant
  uniquement le `README.md` (installation, lancement, comptes de test).

## Workflow de Développement

- Le projet MUST être construit de A à Z par phases suivant les étapes du
  sujet (données → schéma → routes publiques → achat/sièges → administration
  → API/JavaScript → statistiques → sécurité → livrables).
- Chaque phase MUST être commitée séparément avec un message multiligne
  précis : titre court (phase concernée), corps détaillant ce qui a été fait,
  les fichiers clés et les points de vérification.
- Un commit MUST intervenir uniquement après vérification que la phase se
  lance et que ses fonctionnalités fonctionnent (y compris les cas d'erreur).
- Avant la remise, la checklist du sujet MUST être passée intégralement :
  lancement sur un autre ordinateur via le README, volumes de données
  respectés, fonctionnalités complètes, W3C sans erreur, confort téléphone,
  espace admin refusant les non-connectés, `debug=False`, aucun `venv`,
  diapositive 1 avec les membres, vidéo 5–10 min audible.

## Governance

- Cette constitution prime sur toute pratique individuelle ; en cas de conflit
  avec un choix technique en cours, le principe concerné l'emporte et le
  travail est adapté.
- Amendements : toute modification MUST être proposée par un membre du groupe,
  documentée (raison + impact sur le travail restant), validée par le groupe,
  puis commitée avec un message indiquant le nouveau numéro de version.
- Versioning (sémantique) : MAJOR = suppression ou redéfinition d'un principe
  ou d'une exigence non négociable ; MINOR = ajout ou élargissement
  substantiel d'un principe/section ; PATCH = clarification, formulation, typo.
- Conformité : chaque commit de phase MUST être relu contre les principes I–V
  avant d'être poussé ; la checklist de remise est le dernier portail de
  conformité et MUST être cochée intégralement avant la remise du projet.

**Version**: 1.0.0 | **Ratified**: 2026-10-20 | **Last Amended**: 2026-10-20
