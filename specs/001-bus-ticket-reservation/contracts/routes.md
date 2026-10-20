# Contract — Pages et routes HTML

**Date**: 2026-10-20 | **Spec**: US1–US5 | **Plan**: [plan.md](plan.md)

Routes de l'application Flask (rendu serveur Jinja2). Toutes les
mutations sont en POST (constitution §I). Gabarit parent : `base.html`.

## Parcours public

| Méthode | Route | Page | Rôle |
|---|---|---|---|
| GET | `/` | `index.html` | Formulaire de recherche (départ, arrivée, date). |
| GET | `/resultats` | `resultats.html` | Liste des voyages correspondants : heure, durée, prix, places restantes ; lien « Choisir un siège ». Paramètres : `depart`, `arrivee`, `date`. |
| GET | `/voyages/<id>/acheter` | `achat.html` | Plan des sièges (vide, rempli par `sieges.js`) + formulaire d'achat (nom, téléphone, pièce, siège). |
| POST | `/voyages/<id>/acheter` | → redirection | Enregistre le billet (revérifié serveur) → redirection `GET /confirmation?code=...` ; en cas d'échec (siège pris, hors capacité, voyage non achetable) → flash + retour achat. |
| GET | `/confirmation` | `confirmation.html` | Affiche le code de réservation et le récapitulatif. Paramètre : `code`. |
| GET | `/billets` | `retrouver.html` | Formulaire « retrouver mon billet » (champ code). |
| POST | `/billets/recherche` | → `retrouver.html` | Recherche par code ; erreur → flash « code introuvable ». |
| GET | `/billets/<code>` | `retrouver.html` | Affiche le billet trouvé (voyage, date, heure, siège, passager). |
| GET | `/404` | `404.html` | Page d'erreur personnalisée (catch-all). |

## Espace d'administration (protégé)

Protection : décorateur `administrateur_requis` sur chaque route sauf
connexion ; sans session → redirection `GET /admin/connexion` (SC-004).

| Méthode | Route | Page | Rôle |
|---|---|---|---|
| GET | `/admin/connexion` | `admin/login.html` | Formulaire username/mot de passe. |
| POST | `/admin/connexion` | → redirection | Vérifie le hash ; succès → session + `/admin` ; échec → flash + login. |
| POST | `/admin/deconnexion` | → redirection | Détruit la session → `/`. |
| GET | `/admin` | `admin/tableau.html` | Tableau de bord : derniers voyages, raccourcis. |
| GET | `/admin/voyages/nouveau` | `admin/programmation.html` | Formulaire de programmation (trajet, bus, date, heure). |
| POST | `/admin/voyages/nouveau` | → redirection | Crée le voyage (statut `prévu`) → flash + `/admin`. |
| GET | `/admin/voyages/<id>/passagers` | `admin/passagers.html` | Liste imprimable : nom, téléphone, siège, code — via `print.css` + `@media print`. |
| POST | `/admin/voyages/<id>/annuler` | → redirection | `prévu → annulé` ; déjà parti/annulé → flash d'erreur. |
| POST | `/admin/voyages/<id>/parti` | → redirection | `prévu → parti`. |
| GET | `/admin/statistiques` | `admin/statistiques.html` | Tableaux des 4 statistiques (données via `/api/statistiques`). |

## Contrôles communs

- Toute route admin renvoie une redirection ou un rendu 4xx/flash —
  jamais un traceback (`debug=False`).
- Toutes les données de formulaire sont revérifiées côté serveur (FR-015).
- Les messages utilisateur passent par le mécanisme de flash de Flask.
- HTML sémantique, `label` sur chaque champ, `alt` sur chaque image,
  pages principales valides au validateur W3C (FR-019).
