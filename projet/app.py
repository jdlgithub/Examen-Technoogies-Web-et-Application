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


# --- Parcours public : achat avec choix du siège (US2) ----------------------
def charger_voyage(voyage_id):
    """Retourne la ligne complète du voyage ou None."""
    return get_db().execute(
        """SELECT v.id, v.date, v.heure, v.statut,
                  b.nombre_places, b.type AS type_bus,
                  t.ville_depart, t.ville_arrivee,
                  CASE WHEN b.type = 'vip' THEN t.prix_vip
                       ELSE t.prix_classique END AS prix
           FROM voyages v
           JOIN bus b ON b.id = v.bus_id
           JOIN trajets t ON t.id = v.trajet_id
           WHERE v.id = ?""",
        (voyage_id,),
    ).fetchone()


def voyage_achetable(voyage):
    """Un voyage est achetable s'il est prévu, à venir et non complet (FR-007)."""
    if voyage is None or voyage["statut"] != "prévu":
        return False
    if voyage["date"] < date.today().isoformat():
        return False
    restantes = get_db().execute(
        """SELECT b.nombre_places - COUNT(bl.id) AS restantes
           FROM voyages v
           JOIN bus b ON b.id = v.bus_id
           LEFT JOIN billets bl ON bl.voyage_id = v.id
           WHERE v.id = ?
           GROUP BY b.nombre_places""",
        (voyage["id"],),
    ).fetchone()
    return restantes is not None and restantes["restantes"] > 0


@app.route("/api/voyages/<int:voyage_id>/sieges")
def api_sieges(voyage_id):
    """État des sièges d'un voyage au format JSON (contrat api.md §1)."""
    voyage = charger_voyage(voyage_id)
    if voyage is None:
        return jsonify({"erreur": "Voyage introuvable"}), 404
    bdd = get_db()
    vendus = {
        ligne["numero_siege"]
        for ligne in bdd.execute(
            "SELECT numero_siege FROM billets WHERE voyage_id = ?",
            (voyage_id,),
        )
    }
    sieges = [
        {"numero": numero, "pris": numero in vendus}
        for numero in range(1, voyage["nombre_places"] + 1)
    ]
    return jsonify({
        "voyage": voyage_id,
        "total_places": voyage["nombre_places"],
        "prix": int(voyage["prix"]),
        "sieges": sieges,
    })


@app.route("/voyages/<int:voyage_id>/acheter", methods=["GET"])
def achat_page(voyage_id):
    """Page d'achat : plan du bus + formulaire (FR-002, FR-003)."""
    voyage = charger_voyage(voyage_id)
    if voyage is None:
        flash("Voyage introuvable.", "erreur")
        return redirect(url_for("recherche"))
    if not voyage_achetable(voyage):
        flash("Ce voyage n'est plus achetable (annulé, parti, passé ou complet).",
              "erreur")
        return redirect(url_for("recherche"))
    return render_template("achat.html", voyage=voyage)


@app.route("/voyages/<int:voyage_id>/acheter", methods=["POST"])
def achat_enregistrer(voyage_id):
    """Enregistre un billet après revérification complète serveur (FR-015)."""
    voyage = charger_voyage(voyage_id)
    if voyage is None or not voyage_achetable(voyage):
        flash("Ce voyage n'est pas achetable.", "erreur")
        return redirect(url_for("recherche"))

    nom = request.form.get("nom", "").strip()
    telephone = request.form.get("telephone", "").strip()
    piece = request.form.get("piece_identite", "").strip()
    brut_siege = request.form.get("numero_siege", "").strip()

    # --- Revérification de chaque champ côté serveur (constitution I) ---
    erreurs = []
    if not nom:
        erreurs.append("Le nom est obligatoire.")
    if not REGEX_TELEPHONE.match(telephone):
        erreurs.append("Numéro de téléphone invalide (ex. 6XXXXXXXX ou +2376XXXXXXXX).")
    if not piece:
        erreurs.append("Le numéro de pièce d'identité est obligatoire.")
    try:
        numero_siege = int(brut_siege)
    except ValueError:
        numero_siege = -1
    if not 1 <= numero_siege <= voyage["nombre_places"]:
        erreurs.append(
            f"Numéro de siège invalide (attendu entre 1 et {voyage['nombre_places']})."
        )
    if erreurs:
        for message in erreurs:
            flash(message, "erreur")
        return redirect(url_for("achat_page", voyage_id=voyage_id))

    bdd = get_db()
    # Génération du code unique et non devinable (module secrets, FR-003)
    while True:
        code = secrets.token_urlsafe(8)
        libre = bdd.execute(
            "SELECT 1 FROM billets WHERE code_reservation = ?", (code,)
        ).fetchone()
        if libre is None:
            break

    try:
        bdd.execute(
            """INSERT INTO billets
               (voyage_id, numero_siege, nom, telephone, piece_identite,
                code_reservation, date_achat)
               VALUES (?, ?, ?, ?, ?, ?, ?)""",
            (voyage_id, numero_siege, nom, telephone, piece, code,
             date.today().isoformat()),
        )
        bdd.commit()
    except sqlite3.IntegrityError:
        # UNIQUE (voyage_id, numero_siege) : siège vendu entre-temps
        bdd.rollback()
        flash("Ce siège vient d'être vendu, choisissez-en un autre.", "erreur")
        return redirect(url_for("achat_page", voyage_id=voyage_id))

    flash("Billet acheté avec succès.", "succes")
    return redirect(url_for("confirmation", code=code))


@app.route("/confirmation")
def confirmation():
    """Affiche le code de réservation et le récapitulatif (FR-003)."""
    code = request.args.get("code", "")
    billet = get_db().execute(
        """SELECT bl.nom, bl.numero_siege, bl.code_reservation,
                  v.date, v.heure,
                  t.ville_depart, t.ville_arrivee
           FROM billets bl
           JOIN voyages v ON v.id = bl.voyage_id
           JOIN trajets t ON t.id = v.trajet_id
           WHERE bl.code_reservation = ?""",
        (code,),
    ).fetchone()
    if billet is None:
        flash("Billet introuvable pour ce code.", "erreur")
        return redirect(url_for("recherche"))
    return render_template("confirmation.html", billet=billet)


# --- Parcours public : retrouver un billet par code (US3) -------------------
def chercher_billet(code):
    """Retourne la ligne du billet correspondant au code, ou None."""
    return get_db().execute(
        """SELECT bl.nom, bl.numero_siege, bl.telephone, bl.code_reservation,
                  v.date, v.heure, v.statut,
                  t.ville_depart, t.ville_arrivee
           FROM billets bl
           JOIN voyages v ON v.id = bl.voyage_id
           JOIN trajets t ON t.id = v.trajet_id
           WHERE bl.code_reservation = ?""",
        (code,),
    ).fetchone()


@app.route("/billets")
def billets_formulaire():
    """Formulaire « retrouver mon billet » (FR-006)."""
    return render_template("retrouver.html", billet=None)


@app.route("/billets/recherche", methods=["POST"])
def billets_recherche():
    """Contrôle du code saisi puis redirection vers la fiche billet."""
    code = request.form.get("code", "").strip()
    if not code:
        flash("Veuillez saisir votre code de réservation.", "erreur")
        return redirect(url_for("billets_formulaire"))
    return redirect(url_for("billets_detail", code=code))


@app.route("/billets/<code>")
def billets_detail(code):
    """Affiche le billet correspondant au code (FR-006)."""
    billet = chercher_billet(code)
    if billet is None:
        flash("Code de réservation introuvable. Vérifiez votre code.",
              "erreur")
        return redirect(url_for("billets_formulaire"))
    return render_template("retrouver.html", billet=billet)


# --- Espace d'administration : connexion et programmation (US4) -------------
@app.route("/admin/connexion", methods=["GET", "POST"])
def admin_connexion():
    """Connexion à l'administration ; mots de passe hachés (FR-009)."""
    if request.method == "POST":
        username = request.form.get("username", "").strip()
        mot_de_passe = request.form.get("mot_de_passe", "")
        administrateur = get_db().execute(
            "SELECT id, password_hash FROM admins WHERE username = ?",
            (username,),
        ).fetchone()
        if (administrateur is None
                or not check_password_hash(
                    administrateur["password_hash"], mot_de_passe)):
            flash("Identifiants incorrects.", "erreur")
            return redirect(url_for("admin_connexion"))
        session["admin_id"] = administrateur["id"]
        session["admin_nom"] = username
        flash(f"Bienvenue, {username}.", "succes")
        return redirect(url_for("admin_tableau"))
    return render_template("admin/login.html")


@app.route("/admin/deconnexion", methods=["POST"])
def admin_deconnexion():
    """Détruit la session administrateur (mutation en POST, constitution I)."""
    session.clear()
    flash("Vous êtes déconnecté.", "succes")
    return redirect(url_for("recherche"))


@app.route("/admin")
@administrateur_requis
def admin_tableau():
    """Tableau de bord : derniers voyages et raccourcis (protégé, FR-008)."""
    voyages = get_db().execute(
        """SELECT v.id, v.date, v.heure, v.statut,
                  t.ville_depart, t.ville_arrivee,
                  b.immatriculation, b.type AS type_bus,
                  (SELECT COUNT(*) FROM billets bl WHERE bl.voyage_id = v.id)
                      AS billets_vendus
           FROM voyages v
           JOIN trajets t ON t.id = v.trajet_id
           JOIN bus b ON b.id = v.bus_id
           ORDER BY v.date DESC, v.heure
           LIMIT 20"""
    ).fetchall()
    return render_template("admin/tableau.html", voyages=voyages)


@app.route("/admin/voyages/nouveau", methods=["GET", "POST"])
@administrateur_requis
def admin_voyage_nouveau():
    """Programmation d'un nouveau voyage par l'administrateur (FR-010)."""
    bdd = get_db()
    if request.method == "POST":
        trajet_id = request.form.get("trajet_id", "")
        bus_id = request.form.get("bus_id", "")
        jour = request.form.get("date", "")
        heure = request.form.get("heure", "")

        # Revérification serveur des quatre champs (constitution I)
        erreurs = []
        try:
            trajet_id = int(trajet_id)
            existe = bdd.execute(
                "SELECT 1 FROM trajets WHERE id = ?", (trajet_id,)
            ).fetchone()
            if existe is None:
                erreurs.append("Trajet inconnu.")
        except ValueError:
            erreurs.append("Trajet invalide.")
        try:
            bus_id = int(bus_id)
            existe = bdd.execute(
                "SELECT 1 FROM bus WHERE id = ?", (bus_id,)
            ).fetchone()
            if existe is None:
                erreurs.append("Bus inconnu.")
        except ValueError:
            erreurs.append("Bus invalide.")
        if not re.match(r"^\d{4}-\d{2}-\d{2}$", jour):
            erreurs.append("Date invalide (format AAAA-MM-JJ).")
        if not re.match(r"^\d{2}:\d{2}$", heure):
            erreurs.append("Heure invalide (format HH:MM).")
        if erreurs:
            for message in erreurs:
                flash(message, "erreur")
        else:
            bdd.execute(
                """INSERT INTO voyages (trajet_id, bus_id, date, heure, statut)
                   VALUES (?, ?, ?, ?, 'prévu')""",
                (trajet_id, bus_id, jour, heure),
            )
            bdd.commit()
            flash("Voyage programmé avec succès.", "succes")
            return redirect(url_for("admin_tableau"))

    trajets = bdd.execute(
        """SELECT id, ville_depart || ' → ' || ville_arrivee AS intitule
           FROM trajets ORDER BY intitule"""
    ).fetchall()
    buses = bdd.execute(
        """SELECT id, immatriculation || ' (' || type || ', ' ||
                  nombre_places || ' places)' AS intitule
           FROM bus ORDER BY immatriculation"""
    ).fetchall()
    return render_template(
        "admin/programmation.html", trajets=trajets, buses=buses
    )


# --- Espace d'administration : passagers et annulation (US5) ----------------
@app.route("/admin/voyages/<int:voyage_id>/passagers")
@administrateur_requis
def admin_passagers(voyage_id):
    """Liste imprimable des passagers d'un voyage (FR-011)."""
    bdd = get_db()
    voyage = bdd.execute(
        """SELECT v.id, v.date, v.heure, v.statut,
                  t.ville_depart, t.ville_arrivee,
                  b.immatriculation, b.nombre_places
           FROM voyages v
           JOIN trajets t ON t.id = v.trajet_id
           JOIN bus b ON b.id = v.bus_id
           WHERE v.id = ?""",
        (voyage_id,),
    ).fetchone()
    if voyage is None:
        flash("Voyage introuvable.", "erreur")
        return redirect(url_for("admin_tableau"))
    passagers = bdd.execute(
        """SELECT nom, telephone, numero_siege, code_reservation
           FROM billets WHERE voyage_id = ?
           ORDER BY numero_siege""",
        (voyage_id,),
    ).fetchall()
    return render_template(
        "admin/passagers.html", voyage=voyage, passagers=passagers
    )


@app.route("/admin/voyages/<int:voyage_id>/annuler", methods=["POST"])
@administrateur_requis
def admin_annuler(voyage_id):
    """Annule un voyage prévu : statut -> annulé (FR-012, POST)."""
    bdd = get_db()
    voyage = bdd.execute(
        "SELECT statut FROM voyages WHERE id = ?", (voyage_id,)
    ).fetchone()
    if voyage is None:
        flash("Voyage introuvable.", "erreur")
        return redirect(url_for("admin_tableau"))
    if voyage["statut"] != "prévu":
        flash("Seul un voyage prévu peut être annulé.", "erreur")
        return redirect(url_for("admin_tableau"))
    bdd.execute(
        "UPDATE voyages SET statut = 'annulé' WHERE id = ?", (voyage_id,)
    )
    bdd.commit()
    flash("Voyage annulé.", "succes")
    return redirect(url_for("admin_tableau"))


@app.route("/admin/voyages/<int:voyage_id>/parti", methods=["POST"])
@administrateur_requis
def admin_parti(voyage_id):
    """Marque un voyage comme parti : statut -> parti (FR-012, POST)."""
    bdd = get_db()
    voyage = bdd.execute(
        "SELECT statut FROM voyages WHERE id = ?", (voyage_id,)
    ).fetchone()
    if voyage is None:
        flash("Voyage introuvable.", "erreur")
        return redirect(url_for("admin_tableau"))
    if voyage["statut"] != "prévu":
        flash("Seul un voyage prévu peut être marqué parti.", "erreur")
        return redirect(url_for("admin_tableau"))
    bdd.execute(
        "UPDATE voyages SET statut = 'parti' WHERE id = ?", (voyage_id,)
    )
    bdd.commit()
    flash("Voyage marqué comme parti.", "succes")
    return redirect(url_for("admin_tableau"))


# --- Page d'erreur 404 personnalisée ----------------------------------------
@app.errorhandler(404)
def page_introuvable(exception):
    """Page d'erreur 404 personnalisée (FR-019)."""
    return render_template("404.html"), 404


# --- Point d'entrée ----------------------------------------------------------
if __name__ == "__main__":
    app.run()
