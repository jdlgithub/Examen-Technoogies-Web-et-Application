"""Remplit la base de données avec les données de test du sujet.

Volumes imposés : 8 trajets, 6 bus, 60 voyages sur 3 semaines, 400 billets,
1 compte administrateur de test.

Usage :  python donnees_test.py
(exécute schema.sql puis insère les données ; recrée la base à chaque run)

Compte admin de test :  utilisateur = admin   mot de passe = Admin2026!
"""

import random
import secrets
import sqlite3
from datetime import date, timedelta
from pathlib import Path

from werkzeug.security import generate_password_hash

CHEMIN_DOSSIER = Path(__file__).resolve().parent
CHEMIN_BDD = CHEMIN_DOSSIER / "projet.db"
CHEMIN_SCHEMA = CHEMIN_DOSSIER / "schema.sql"

# Mot de passe du compte admin de démonstration (documenté dans le README)
MOT_DE_PASSE_ADMIN = "Admin2026!"

# Liste déterministe pour rendre le seed reproductible
random.seed(42)

PRENOMS = ["Jean", "Marie", "Paul", "Fatima", "Ali", "Chantal", "Pierre",
           "Aïcha", "Luc", "Grace", "Samuel", "Esther", "David", "Rachel",
           "Olivier", "Nadège", "Blaise", "Sarah", "Ibrahim", "Clarisse"]
NOMS = ["Ngono", "Tchoumi", "Etame", "Foka", "Mbarga", "Essomba", "Njoya",
        "Biyogo", "Kamga", "Talla", "Sone", "Atem", "Ekwalla", "Mangue",
        "Tabi", "Ndzana", "Owona", "Mvondo"]
HEURES = ["06:00", "07:30", "08:00", "10:00", "12:00", "14:00", "16:00",
          "18:00", "20:00"]


def creer_base():
    """Applique schema.sql : recrée toutes les tables et contraintes."""
    if CHEMIN_BDD.exists():
        CHEMIN_BDD.unlink()
    bdd = sqlite3.connect(CHEMIN_BDD)
    bdd.row_factory = sqlite3.Row
    bdd.execute("PRAGMA foreign_keys = ON")
    bdd.executescript(CHEMIN_SCHEMA.read_text(encoding="utf-8"))
    bdd.commit()
    return bdd


def remplir_trajets(bdd):
    """8 trajets sur les villes du sujet, avec tarifs classique et VIP."""
    trajets = [
        ("Douala", "Yaoundé", 240, 4000, 6500),
        ("Yaoundé", "Douala", 240, 4000, 6500),
        ("Douala", "Bafoussam", 180, 3500, 5500),
        ("Yaoundé", "Bafoussam", 300, 5000, 7500),
        ("Douala", "Kribi", 150, 3000, 5000),
        ("Yaoundé", "Kribi", 210, 4500, 7000),
        ("Douala", "Buea", 70, 1500, 2500),
        ("Buea", "Douala", 70, 1500, 2500),
    ]
    bdd.executemany(
        """INSERT INTO trajets
           (ville_depart, ville_arrivee, duree_minutes, prix_classique, prix_vip)
           VALUES (?, ?, ?, ?, ?)""",
        trajets,
    )
    bdd.commit()


def remplir_bus(bdd):
    """6 bus : immatriculations uniques, mixte classique et VIP."""
    bus = [
        ("CE-101-AB", 45, "classique"),
        ("CE-102-CD", 50, "classique"),
        ("CE-103-EF", 40, "vip"),
        ("CE-104-GH", 55, "classique"),
        ("CE-105-IJ", 35, "vip"),
        ("CE-106-KL", 48, "classique"),
    ]
    bdd.executemany(
        "INSERT INTO bus (immatriculation, nombre_places, type) VALUES (?, ?, ?)",
        bus,
    )
    bdd.commit()


def remplir_voyages(bdd):
    """60 voyages répartis sur 3 semaines (-7 à +14 jours autour d'aujourd'hui)."""
    aujourdhui = date.today()
    ids = []
    for numero in range(60):
        trajet_id = (numero % 8) + 1
        bus_id = (numero % 6) + 1
        # Répartition sur 22 jours : -7 (passé) à +14 (à venir)
        jour = aujourdhui + timedelta(days=-7 + (numero * 22) // 60)
        heure = HEURES[numero % len(HEURES)]
        # Quelques voyages annulés pour tester les cas d'erreur
        statut = "annulé" if numero in (9, 27, 46) else "prévu"
        curseur = bdd.execute(
            """INSERT INTO voyages (trajet_id, bus_id, date, heure, statut)
               VALUES (?, ?, ?, ?, ?)""",
            (trajet_id, bus_id, jour.isoformat(), heure, statut),
        )
        ids.append((curseur.lastrowid, jour))
    bdd.commit()
    return ids


def prix_du_voyage(bdd, voyage_id):
    """Retourne le prix appliqué au voyage (type du bus × tarif du trajet)."""
    ligne = bdd.execute(
        """SELECT CASE WHEN b.type = 'vip' THEN t.prix_vip ELSE t.prix_classique END AS prix
           FROM voyages v
           JOIN trajets t ON t.id = v.trajet_id
           JOIN bus b ON b.id = v.bus_id
           WHERE v.id = ?""",
        (voyage_id,),
    ).fetchone()
    return int(ligne["prix"])


def generer_code(bdd):
    """Génère un code de réservation unique (même logique que l'application)."""
    while True:
        code = secrets.token_urlsafe(8)
        libre = bdd.execute(
            "SELECT 1 FROM billets WHERE code_reservation = ?", (code,)
        ).fetchone()
        if libre is None:
            return code


def remplir_billets(bdd, voyages):
    """400 billets répartis sans jamais vendre deux fois le même siège."""
    capacites = {
        ligne["id"]: ligne["nombre_places"]
        for ligne in bdd.execute("SELECT id, nombre_places FROM bus")
    }
    bus_des_voyages = {
        ligne["id"]: ligne["bus_id"]
        for ligne in bdd.execute("SELECT id, bus_id FROM voyages")
    }
    sieges_pris = {}  # voyage_id -> ensemble des numéros vendus
    inseres = 0

    while inseres < 400:
        voyage_id, jour_voyage = random.choice(voyages)
        pris = sieges_pris.setdefault(voyage_id, set())
        capacite = capacites[bus_des_voyages[voyage_id]]
        libres = [n for n in range(1, capacite + 1) if n not in pris]
        if not libres:
            continue  # bus complet : on prend un autre voyage
        numero_siege = random.choice(libres)
        # Date d'achat : jusqu'à 10 jours avant le voyage, jamais après
        jour_limite = min(jour_voyage, date.today())
        date_achat = (
            jour_limite - timedelta(days=random.randint(0, 10))
        ).isoformat()

        nom = f"{random.choice(PRENOMS)} {random.choice(NOMS)}"
        telephone = f"+2376{random.randint(10000000, 99999999)}"
        piece = f"ID{random.randint(1000000, 9999999)}"

        bdd.execute(
            """INSERT INTO billets
               (voyage_id, numero_siege, nom, telephone, piece_identite,
                code_reservation, date_achat)
               VALUES (?, ?, ?, ?, ?, ?, ?)""",
            (voyage_id, numero_siege, nom, telephone, piece,
             generer_code(bdd), date_achat),
        )
        pris.add(numero_siege)
        inseres += 1

    bdd.commit()


def creer_admin(bdd):
    """Compte administrateur de démonstration (mot de passe haché)."""
    bdd.execute(
        "INSERT INTO admins (username, password_hash) VALUES (?, ?)",
        ("admin", generate_password_hash(MOT_DE_PASSE_ADMIN)),
    )
    bdd.commit()


def verifier_volumes(bdd):
    """Contrôle que les volumes minimums du sujet sont atteints."""
    attendus = {"trajets": 8, "bus": 6, "voyages": 60, "billets": 400}
    for table, minimum in attendus.items():
        total = bdd.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
        statut = "OK" if total >= minimum else "ÉCHEC"
        print(f"  {table:<10} {total:>4} lignes  [{statut}]")


def main():
    """Crée et remplit la base de test."""
    print("Création de la base de données de test...")
    bdd = creer_base()
    remplir_trajets(bdd)
    remplir_bus(bdd)
    voyages = remplir_voyages(bdd)
    remplir_billets(bdd, voyages)
    creer_admin(bdd)
    print("Vérification des volumes :")
    verifier_volumes(bdd)
    bdd.close()
    print(f"Base prête : {CHEMIN_BDD}")
    print(f"Admin de test : admin / {MOT_DE_PASSE_ADMIN}")


if __name__ == "__main__":
    main()
