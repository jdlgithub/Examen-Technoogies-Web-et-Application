# Réservation de billets de bus interurbains

Application web d'agence de voyage — projet d'examen **Technologies Web et
Application**, Groupe 04.

Recherche de voyages, achat de billets avec plan de sièges, retrouvement par
code, espace administrateur (programmation, passagers imprimables,
annulations) et statistiques d'exploitation.

**Pile technique** : Python 3.12 · Flask 3.1 · SQLite
---

## 1. Prérequis

- Python 3.12 (`python --version`)
- Aucun serveur web ni base de données à installer : SQLite est intégré à
  Python, Flask est installé par `pip`

## 2. Installation et lancement

Ouvrir un terminal dans le dossier `projet/` :

```bash
cd projet

# 1. Environnement virtuel
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

Compte Administrateur: admin ; mot de passe:Admin2026!
Fonctionnalités: programmation Voyages, passagers, annulations, statistiques 

Il n'y a **pas de compte client** : un billet est acheté sans inscription, le
code de réservation fait foi (page « Retrouver un billet »).

## 4. Arborescence

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

## 5. Les parcours principaux

**Côté public**

1. `/` — rechercher un trajet (départ, arrivée, date) → `resultats.html`
2. « Choisir un siège » → plan des sièges chargé par `fetch` → `/api/voyages/<id>/sieges`
3. Remplir nom, téléphone, pièce d'identité → confirmation avec **code de réservation** unique
4. `/billets` — retrouver un billet à partir de son code

**Côté administration**

1. `admin/Tableau de bord` — derniers voyages, statut, billets vendus
2. `Programmer un voyage` — trajet, bus, date, heure
3. `Passagers` — liste par siège, bouton **Imprimer**
4. Boutons **Parti** / **Annuler** par voyage (annulé → retiré de la recherche et de l'achat)
5. `Statistiques` — remplissage par trajet, recette par semaine, heures demandées, billets par jour

## 6. Export et restauration de la base

Exporter:

```bash
# export_projet.sql est déjà fourni, régénérable à la demande
```

Restaurer/insérer l'export dans une base neuve :

```bash
python -c "import sqlite3; sqlite3.connect('nouveau.db').executescript(open('export_projet.sql', encoding='utf-8').read())"
```






