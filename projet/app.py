"""Application Flask - Réservation de billets de bus interurbains.

Projet d'examen Technologies Web et Applications (Groupe 04).
Python 3.12 + Flask + SQLite. Commentaires en français (constitution V).
"""

import os
import re
import secrets
import sqlite3
from datetime import date
from functools import wraps
from pathlib import Path

from flask import (Flask, flash, g, jsonify, redirect, render_template,
                   request, session, url_for)
from werkzeug.security import check_password_hash, generate_password_hash

# --- Configuration de l'application -----------------------------------------
CHEMIN_DOSSIER = Path(__file__).resolve().parent
CHEMIN_BDD = CHEMIN_DOSSIER / "projet.db"

app = Flask(__name__)
# SECRET_KEY via variable d'environnement ; repli de développement seulement
app.config["SECRET_KEY"] = os.environ.get(
    "SECRET_KEY", "cle-de-developpement-a-remplacer-en-production"
)
app.config["DEBUG"] = False  # exigé pour la version rendue (constitution I)

# Expression de validation du téléphone : +2376XXXXXXXX ou 6XXXXXXXX
REGEX_TELEPHONE = re.compile(r"^\+?[0-9]{8,15}$")

# Villes desservies (liste imposée par le sujet)
VILLES = ["Douala", "Yaoundé", "Bafoussam", "Kribi", "Buea"]


# --- Accès à la base de données ---------------------------------------------
def get_db():
    """Retourne la connexion SQLite de la requête courante (lignes nommées)."""
    if "bdd" not in g:
        g.bdd = sqlite3.connect(CHEMIN_BDD)
        g.bdd.row_factory = sqlite3.Row
        g.bdd.execute("PRAGMA foreign_keys = ON")
    return g.bdd


@app.teardown_appcontext
def fermer_bdd(exception):
    """Ferme la base à la fin de chaque requête."""
    bdd = g.pop("bdd", None)
    if bdd is not None:
        bdd.close()


# --- Protection de l'espace d'administration --------------------------------
def administrateur_requis(vue):
    """Refuse l'accès à toute vue admin sans session connectée (constitution I)."""

    @wraps(vue)
    def enveloppe(*args, **kwargs):
        if session.get("admin_id") is None:
            flash("Accès refusé : connectez-vous à l'administration.", "erreur")
            return redirect(url_for("admin_connexion"))
        return vue(*args, **kwargs)

    return enveloppe


# --- Page d'erreur 404 personnalisée ----------------------------------------
@app.errorhandler(404)
def page_introuvable(exception):
    """Page d'erreur 404 personnalisée (FR-019)."""
    return render_template("404.html"), 404


# --- Point d'entrée ----------------------------------------------------------
if __name__ == "__main__":
    app.run()
