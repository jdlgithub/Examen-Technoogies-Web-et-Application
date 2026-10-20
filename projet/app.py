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


# --- Parcours public : recherche de voyages (US1) ---------------------------
@app.route("/")
def recherche():
    """Page d'accueil : formulaire de recherche (départ, arrivée, date)."""
    return render_template("index.html", villes=VILLES)


@app.route("/resultats")
def resultats():
    """Liste des voyages disponibles pour un trajet à une date (FR-001)."""
    depart = request.args.get("depart", "")
    arrivee = request.args.get("arrivee", "")
    jour = request.args.get("date", "")

    # Contrôle serveur des critères reçus (constitution I)
    if not depart or not arrivee or not jour:
        flash("Veuillez renseigner le départ, l'arrivée et la date.", "erreur")
        return redirect(url_for("recherche"))
    if depart not in VILLES or arrivee not in VILLES or depart == arrivee:
        flash("Ville de départ ou d'arrivée invalide.", "erreur")
        return redirect(url_for("recherche"))

    bdd = get_db()
    voyages = bdd.execute(
        """SELECT v.id, v.date, v.heure, b.type AS type_bus,
                  b.nombre_places,
                  t.duree_minutes, t.prix_classique, t.prix_vip,
                  t.ville_depart, t.ville_arrivee,
                  (b.nombre_places - COUNT(bl.id)) AS places_restantes
           FROM voyages v
           JOIN trajets t ON t.id = v.trajet_id
           JOIN bus b ON b.id = v.bus_id
           LEFT JOIN billets bl ON bl.voyage_id = v.id
           WHERE t.ville_depart = ? AND t.ville_arrivee = ?
             AND v.date = ? AND v.statut = 'prévu' AND v.date >= ?
           GROUP BY v.id
           HAVING places_restantes > 0
           ORDER BY v.heure""",
        (depart, arrivee, jour, date.today().isoformat()),
    ).fetchall()

    # Prix appliqué selon le type du bus (VIP ou classique)
    resultats = []
    for ligne in voyages:
        resultats.append({
            "id": ligne["id"],
            "heure": ligne["heure"],
            "duree_minutes": ligne["duree_minutes"],
            "type_bus": ligne["type_bus"],
            "prix": (ligne["prix_vip"] if ligne["type_bus"] == "vip"
                     else ligne["prix_classique"]),
            "places_restantes": ligne["places_restantes"],
        })

    return render_template(
        "resultats.html",
        resultats=resultats,
        depart=depart, arrivee=arrivee, jour=jour,
    )


# --- Page d'erreur 404 personnalisée ----------------------------------------
@app.errorhandler(404)
def page_introuvable(exception):
    """Page d'erreur 404 personnalisée (FR-019)."""
    return render_template("404.html"), 404


# --- Point d'entrée ----------------------------------------------------------
if __name__ == "__main__":
    app.run()
