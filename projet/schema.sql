-- Schéma de la base de données - Réservation de billets de bus interurbains
-- Contraintes portées par le schéma (constitution II) : NOT NULL, UNIQUE,
-- CHECK, clés étrangères, anti double-vente, capacité de siège.

PRAGMA foreign_keys = ON;

DROP TRIGGER IF EXISTS verifier_capacite_siege;
DROP TABLE IF EXISTS billets;
DROP TABLE IF EXISTS voyages;
DROP TABLE IF EXISTS bus;
DROP TABLE IF EXISTS trajets;
DROP TABLE IF EXISTS admins;

-- 1. Trajets : lien entre deux villes desservies
CREATE TABLE trajets (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    ville_depart    TEXT NOT NULL
                    CHECK (ville_depart IN ('Douala','Yaoundé','Bafoussam','Kribi','Buea')),
    ville_arrivee   TEXT NOT NULL
                    CHECK (ville_arrivee IN ('Douala','Yaoundé','Bafoussam','Kribi','Buea')),
    duree_minutes   INTEGER NOT NULL CHECK (duree_minutes > 0),
    prix_classique  REAL NOT NULL CHECK (prix_classique > 0),
    prix_vip        REAL NOT NULL CHECK (prix_vip > 0),
    CHECK (ville_depart <> ville_arrivee)
);

-- 2. Bus : véhicules affectés aux voyages (immatriculation unique)
CREATE TABLE bus (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    immatriculation TEXT NOT NULL UNIQUE,
    nombre_places   INTEGER NOT NULL CHECK (nombre_places BETWEEN 1 AND 100),
    type            TEXT NOT NULL CHECK (type IN ('classique','vip'))
);

-- 3. Voyages : trajet effectué par un bus à une date/heure
CREATE TABLE voyages (
    id        INTEGER PRIMARY KEY AUTOINCREMENT,
    trajet_id INTEGER NOT NULL REFERENCES trajets(id),
    bus_id    INTEGER NOT NULL REFERENCES bus(id),
    date      TEXT NOT NULL,            -- format ISO AAAA-MM-JJ
    heure     TEXT NOT NULL,            -- format HH:MM
    statut    TEXT NOT NULL DEFAULT 'prévu'
              CHECK (statut IN ('prévu','parti','annulé'))
);

-- 4. Billets : place vendue - cœur d'intégrité du projet
CREATE TABLE billets (
    id               INTEGER PRIMARY KEY AUTOINCREMENT,
    voyage_id        INTEGER NOT NULL REFERENCES voyages(id),
    numero_siege     INTEGER NOT NULL CHECK (numero_siege >= 1),
    nom              TEXT NOT NULL,
    telephone        TEXT NOT NULL,
    piece_identite   TEXT NOT NULL,
    code_reservation TEXT NOT NULL UNIQUE,
    date_achat       TEXT NOT NULL,     -- format ISO AAAA-MM-JJ
    -- Anti double-vente : un siège jamais deux fois pour le même voyage
    UNIQUE (voyage_id, numero_siege)
);

-- Le CHECK SQLite ne pouvant pas joindre deux tables, la borne haute du
-- numéro de siège (capacité du bus) est garantie par ce déclencheur :
-- toute insertion hors capacité échoue, même contournant l'application.
CREATE TRIGGER verifier_capacite_siege
BEFORE INSERT ON billets
FOR EACH ROW
BEGIN
    SELECT CASE
        WHEN NEW.numero_siege > b.nombre_places
        THEN RAISE(ABORT, 'Numéro de siège hors capacité du bus')
    END
    FROM voyages v
    JOIN bus b ON b.id = v.bus_id
    WHERE v.id = NEW.voyage_id;
END;

-- 5. Admins : comptes de l'espace d'administration (mot de passe haché)
CREATE TABLE admins (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    username      TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL
);

-- Index utiles aux recherches fréquentes
CREATE INDEX idx_voyages_date ON voyages(date);
CREATE INDEX idx_voyages_trajet ON voyages(trajet_id);
CREATE INDEX idx_billets_voyage ON billets(voyage_id);
CREATE INDEX idx_billets_code ON billets(code_reservation);
