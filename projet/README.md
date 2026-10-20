# Réservation de billets de bus interurbains

Application web d'agence de voyage — projet d'examen **Technologies Web et
Application**, Groupe 04.

Recherche de voyages, achat de billets avec plan de sièges, retrouvement par
code, espace administrateur (programmation, passagers imprimables,
annulations) et statistiques d'exploitation.

**Pile technique** : Python 3.12 · Flask 3.1 · SQLite — aucune autre
dépendance applicative.

---

## 1. Prérequis

- Python 3.12 (`python --version`)
- Aucun serveur web ni base de données à installer : SQLite est intégré à
  Python, Flask est installé par `pip` (étape suivante).
- L'accès réseau est facultatif : la police Roboto (Google Fonts) tombe en
  repli système (`Segoe UI`, Arial) hors ligne.

## 2. Installation et lancement

Ouvrir un terminal dans le dossier `projet/` :

```bash
cd projet

# 1. Environnement virtuel (une seule fois)
python -m venv venv

# 2. Activation sous Windows
venv\Scripts\activate
#    (macOS/Linux : source venv/bin/activate)

# 3. Dépendances
pip install -r requirements.txt

# 4. Créer/remplacer la base de données de démonstration
python donnees_test.py

# 5. Démarrer le serveur
python app.py
```

L'application est ensuite accessible sur **http://127.0.0.1:5000/**.

Pour l'arrêter : `Ctrl+C` dans le terminal.

## 3. Compte de test

| Rôle | Utilisateur | Mot de passe | Usage |
|------|-------------|--------------|-------|
| Administrateur | `admin` | `Admin2026!` | `/admin/connexion` : programmation, passagers, annulations, statistiques |

Il n'y a **pas de compte client** : un billet est acheté sans inscription, le
code de réservation fait foi (page « Retrouver un billet »).

## 4. Données initiales

`python donnees_test.py` régénère **de zéro** `projet.db` avec les volumes
imposés par le sujet :

| Table | Contenu |
|-------|---------|
| `trajets` | 8 trajets (Douala, Yaoundé, Bafoussam, Kribi, Buea) |
| `bus` | 6 bus (classique et VIP) |
| `voyages` | 60 voyages répartis sur 3 semaines (statut « prévu ») |
| `billets` | 400 billets déjà vendus |
| `admins` | 1 administrateur (compte ci-dessus) |

> **Attention** : cette commande **détruit** `projet.db` actuel (achats de
> démonstration inclus). À utiliser pour repartir à zéro.

Le schéma seul (sans données) vit dans `schema.sql` : 5 tables + déclencheur
`verifier_capacite_siege` qui bloque tout siège vendu au-delà de la capacité.

## 5. Arborescence

```
projet/
├── app.py                 # Application Flask (toutes les routes)
├── schema.sql             # Schéma : tables, index, déclencheur capacité
├── donnees_test.py        # Génération de la base de démonstration
├── requirements.txt       # Dépendances (pip freeze)
├── projet.db              # Base SQLite (version livrée = volumes du sujet)
├── export_projet.sql      # Export complet SQL réinsérable
├── static/
│   ├── css/style.css      # Charte blanc/gris/noir, mobile-first 600/900 px
│   ├── css/print.css      # Mise en page d'impression (liste passagers)
│   ├── js/sieges.js       # Plan des sièges (fetch de l'API)
│   └── js/validation.js   # Validation JS du formulaire d'achat
└── templates/
    ├── base.html          # Gabarit commun (nav, messages flash)
    ├── index.html         # Recherche de voyage
    ├── resultats.html     # Résultats de recherche
    ├── achat.html         # Plan des sièges + formulaire d'achat
    ├── confirmation.html  # Confirmation avec code de réservation
    ├── retrouver.html     # Recherche de billet par code
    ├── 404.html           # Page introuvable
    └── admin/
        ├── login.html         # Connexion administrateur
        ├── base_admin.html    # Gabarit de l'espace admin
        ├── tableau.html       # Tableau de bord (derniers voyages)
        ├── programmation.html # Création d'un voyage
        ├── passagers.html     # Liste des passagers (imprimable)
        └── statistiques.html  # 4 statistiques (fetch JSON)
```

## 6. Les parcours principaux

**Côté public (aucune connexion)**

1. `/` — rechercher un trajet (départ, arrivée, date) → `resultats.html`
2. « Choisir un siège » → plan des sièges chargé par `fetch` →
   `/api/voyages/<id>/sieges`
3. Remplir nom, téléphone, pièce d'identité → confirmation avec
   **code de réservation** unique
4. `/billets` — retrouver un billet à partir de son code

**Côté administration (`/admin/connexion`)**

1. `admin/Tableau de bord` — derniers voyages, statut, billets vendus
2. `Programmer un voyage` — trajet, bus, date, heure
3. `Passagers` — liste par siège, bouton **Imprimer** (Ctrl+P propre)
4. Boutons **Parti** / **Annuler** par voyage (annulé → retiré de la
   recherche et de l'achat)
5. `Statistiques` — remplissage par trajet, recette par semaine, heures
   demandées, billets par jour (source : `GET /api/statistiques`)

## 7. Export et restauration de la base

Exporter (régénéré par le projet) :

```bash
# export_projet.sql est déjà fourni, régénérable à volonté
```

Restaurer/insérer l'export dans une base neuve :

```bash
sqlite3 nouveau.db < export_projet.sql
# ou sans SQLite externe :
python -c "import sqlite3; sqlite3.connect('nouveau.db').executescript(open('export_projet.sql', encoding='utf-8').read())"
```

## 8. Résolution des problèmes courants

| Symptôme | Cause | Solution |
|----------|-------|----------|
| `ModuleNotFoundError: No module named 'flask'` | Mauvais interpréteur | Activer le venv (`venv\Scripts\activate`) ou lancer `venv\Scripts\python.exe app.py` |
| `Address already in use` (port 5000) | Un ancien serveur tourne encore | Fermer le terminal ou changer de port : dans `app.py`, `app.run(port=5001)` |
| Page d'exception / erreur 500 détaillée | Version de développement | Le livrable force `debug=False` : relancer avec `python app.py` sans éditer le code |
| Base vide ou résultats étranges | Tests ont modifié la base | `python donnees_test.py` régénère une base propre (volumes du sujet) |
| Les sièges affichés ne sont plus à jour | Onglet laissé ouvert pendant un achat | Recharger la page : l'état vient du serveur à chaque affichage |
| Police Roboto non chargée (hors ligne) | Pas d'accès réseau | Sans impact : repli `Segoe UI`/Arial automatique |
| `sqlite3.OperationalError: database is locked` | Deux écritures simultanées | Fermer les autres sessions Python, relancer |
| Les captures/affichages semblent coupés à 360 px | — | Prévu : les tableaux défilent horizontalement dans leur cadre (`.defilement`), la page ne déborde pas |

## 9. Validation

Le guide d'acceptation complet (scénarios **S1 à S12**) se trouve dans
`../specs/001-bus-ticket-reservation/quickstart.md` : chaque scénario décrit
l'action, l'attendu et la vérification (dont les contrôles de sécurité et les
compteurs de volumes 8/6/60/400).
