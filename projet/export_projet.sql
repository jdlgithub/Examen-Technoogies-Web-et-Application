-- Export complet de projet.db (Réservation de billets de bus)
-- Regénéré par export ; réinsérable : sqlite3 projet.db < export_projet.sql
-- 8 trajets, 6 bus, 60 voyages, 400 billets, 1 administrateur
PRAGMA foreign_keys = OFF;
BEGIN TRANSACTION;
CREATE TABLE admins (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    username      TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL
);
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
CREATE TABLE bus (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    immatriculation TEXT NOT NULL UNIQUE,
    nombre_places   INTEGER NOT NULL CHECK (nombre_places BETWEEN 1 AND 100),
    type            TEXT NOT NULL CHECK (type IN ('classique','vip'))
);
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
CREATE TABLE voyages (
    id        INTEGER PRIMARY KEY AUTOINCREMENT,
    trajet_id INTEGER NOT NULL REFERENCES trajets(id),
    bus_id    INTEGER NOT NULL REFERENCES bus(id),
    date      TEXT NOT NULL,            -- format ISO AAAA-MM-JJ
    heure     TEXT NOT NULL,            -- format HH:MM
    statut    TEXT NOT NULL DEFAULT 'prévu'
              CHECK (statut IN ('prévu','parti','annulé'))
);
CREATE INDEX idx_billets_code ON billets(code_reservation);
CREATE INDEX idx_billets_voyage ON billets(voyage_id);
CREATE INDEX idx_voyages_date ON voyages(date);
CREATE INDEX idx_voyages_trajet ON voyages(trajet_id);
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

-- Données de admins
INSERT INTO "admins" (id, username, password_hash) VALUES (1, 'admin', 'scrypt:32768:8:1$mSAxhQawm4gYIBx1$5fb2df88782bc9c73fb17af9899917f85f873e47a7e69e3cdb319dadce6f0992be5cc00968faae61b116b1663613b3b70fe27013d17c2e951aa8e16b35549d03');

-- Données de billets
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (1, 41, 8, 'Luc Biyogo', '+237639958838', 'ID3341057', 'EAnEsNAKuVI', '2026-10-20');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (2, 48, 7, 'Sarah Etame', '+237689254563', 'ID8078673', 'T0Y3EDSnJ0Q', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (3, 3, 2, 'Pierre Biyogo', '+237677827638', 'ID1445199', 'TTlZJ04-t8s', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (4, 36, 13, 'Sarah Mangue', '+237639587039', 'ID8536477', 'RUMxvKEgUoM', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (5, 38, 18, 'Chantal Mangue', '+237655667651', 'ID5661907', 'ZSCvG4KgtpY', '2026-10-20');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (6, 10, 14, 'Fatima Etame', '+237660992979', 'ID2622631', 'uSaJzTjaXQI', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (7, 23, 23, 'Luc Tchoumi', '+237671662963', 'ID9996414', 'XyvjVT_kGpc', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (8, 8, 25, 'Sarah Talla', '+237694374605', 'ID7067228', 'ah3YsqRri88', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (9, 37, 13, 'Marie Biyogo', '+237648840994', 'ID2338687', 'ocsncFbK49s', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (10, 55, 15, 'David Kamga', '+237670855700', 'ID7120868', 'nIX5dPIy06c', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (11, 11, 24, 'Pierre Kamga', '+237696977837', 'ID2197935', 'Wd9OM3lqUPQ', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (12, 39, 11, 'Aïcha Essomba', '+237672043515', 'ID7366205', 'icPdRxuvRA0', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (13, 18, 41, 'Aïcha Sone', '+237617507864', 'ID4842788', '3Ue5XaSQv6M', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (14, 53, 3, 'David Kamga', '+237618883684', 'ID4539704', 'GR6mCAA7DnQ', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (15, 59, 21, 'Nadège Ekwalla', '+237696282117', 'ID8698256', 'AQ3bZxAq9Qc', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (16, 10, 18, 'Aïcha Mvondo', '+237682340307', 'ID5408072', 're89ZwogxSs', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (17, 48, 39, 'Ibrahim Ekwalla', '+237658586340', 'ID4679591', 'XvfL4v4hJu8', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (18, 9, 33, 'Paul Tchoumi', '+237624716857', 'ID3564251', 'XsooBKdfosE', '2026-10-08');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (19, 41, 12, 'Rachel Etame', '+237661642594', 'ID7402509', '1bTQWjFCHOw', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (20, 39, 31, 'Luc Mvondo', '+237611540956', 'ID2921859', 'Hyi4sWyKaZI', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (21, 44, 35, 'Samuel Foka', '+237649392920', 'ID8294150', 'YfDaCXMfaMQ', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (22, 11, 31, 'Luc Owona', '+237633978249', 'ID9517485', 'wNjiii0SUeg', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (23, 59, 7, 'Grace Owona', '+237691734598', 'ID4337174', '8OJGpJXJosg', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (24, 10, 26, 'Sarah Owona', '+237610076758', 'ID6438436', 'pP1gjCie0Yw', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (25, 32, 2, 'Esther Talla', '+237642138745', 'ID1971823', 'Ar8F_liwx4k', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (26, 16, 37, 'Paul Ndzana', '+237619289546', 'ID9937326', 'ba8VBh3A-RA', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (27, 50, 9, 'Nadège Mvondo', '+237632162965', 'ID5446912', 'JP7k3UIzDDg', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (28, 34, 39, 'Pierre Mvondo', '+237636998038', 'ID6229731', 'h4L6PV5gNGE', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (29, 26, 43, 'Esther Tabi', '+237679467853', 'ID8574680', 'kvq-9eFTHWE', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (30, 8, 16, 'Paul Sone', '+237612823170', 'ID4860684', 'E_0Hmdz2U2U', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (31, 38, 15, 'Paul Tchoumi', '+237640728046', 'ID2130789', 'UmoaNZuCvuQ', '2026-10-20');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (32, 58, 3, 'Paul Owona', '+237641944441', 'ID5672073', 'C6Zapd-lq20', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (33, 43, 32, 'Sarah Mbarga', '+237686644106', 'ID8930103', 'aBnAZgNQ7BE', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (34, 16, 52, 'Rachel Njoya', '+237622660194', 'ID2626229', 'gHxhtOUs3JM', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (35, 43, 28, 'Rachel Mangue', '+237672682989', 'ID1908841', 'd6bDzhdQc0Y', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (36, 44, 43, 'Fatima Tchoumi', '+237664038913', 'ID6692553', 'J8OSeeA2Prk', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (37, 52, 7, 'Pierre Njoya', '+237681979055', 'ID8526486', 'ejX-B99Bxi0', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (38, 9, 28, 'Luc Tabi', '+237643528453', 'ID2264748', 'jae8eog9BYw', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (39, 29, 7, 'Sarah Ngono', '+237622517517', 'ID4965789', 'MHd9-K_CYwM', '2026-10-20');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (40, 11, 28, 'Nadège Njoya', '+237663826716', 'ID1983738', 'LS_-SKILV0I', '2026-10-09');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (41, 11, 26, 'David Kamga', '+237671070189', 'ID5785687', 'UsJDLG5p9O0', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (42, 28, 45, 'Nadège Mbarga', '+237635487660', 'ID5977931', '88w0vzV_VOQ', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (43, 14, 4, 'Sarah Tchoumi', '+237652091325', 'ID1959074', 'Hfb8Pn1K6cc', '2026-10-08');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (44, 4, 38, 'Blaise Owona', '+237631130263', 'ID1954280', 'p7GgGo_s7ro', '2026-10-07');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (45, 33, 6, 'Paul Etame', '+237641568532', 'ID7774229', 'vQcIl7T_UpI', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (46, 8, 39, 'Ibrahim Tchoumi', '+237693131979', 'ID2375453', 'UaJ0tyltGDA', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (47, 27, 38, 'Blaise Sone', '+237644999379', 'ID4426900', 'QP1H1NDS7pY', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (48, 43, 21, 'Luc Ekwalla', '+237627566185', 'ID6033115', 'aBObMdS5MaI', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (49, 30, 21, 'Jean Tabi', '+237693370583', 'ID2677407', 'vfsia94mNKw', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (50, 5, 35, 'Blaise Kamga', '+237627778019', 'ID6855396', 'WuOTyCS74qw', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (51, 57, 5, 'Esther Talla', '+237631172421', 'ID8351517', 'DWWVK_6VJzs', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (52, 54, 35, 'Clarisse Owona', '+237611049999', 'ID6022741', 'le0ST9oz7cw', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (53, 60, 43, 'Ali Kamga', '+237625492573', 'ID2795765', 'rWbmbJx5zHM', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (54, 48, 37, 'Luc Talla', '+237691178885', 'ID4533779', 'vr19XLM2zz0', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (55, 46, 22, 'Luc Owona', '+237675569635', 'ID5213115', 'Nj19K-inZXU', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (56, 58, 5, 'Rachel Kamga', '+237615917225', 'ID1059486', 'UbGh7IPq1ws', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (57, 22, 50, 'Luc Essomba', '+237669302158', 'ID8175395', 'd54vk9Dp6gM', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (58, 36, 1, 'Paul Mbarga', '+237683227889', 'ID1604451', '_3Z9OmZ5Aso', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (59, 54, 24, 'Sarah Mbarga', '+237667684996', 'ID3138181', 'AEFeB6g8Hgo', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (60, 3, 21, 'Marie Atem', '+237638195995', 'ID5186414', 'AZvVSraUj5A', '2026-10-08');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (61, 43, 7, 'Sarah Mangue', '+237693303777', 'ID3592974', '8_Ylvm0JSXo', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (62, 60, 16, 'Chantal Mangue', '+237613326769', 'ID4009172', 'upCyaER96vU', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (63, 48, 23, 'Aïcha Kamga', '+237631367172', 'ID2813543', '89jG3_5A0Yw', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (64, 25, 3, 'Aïcha Njoya', '+237671780854', 'ID6866294', '3up2-QPgiNI', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (65, 20, 15, 'Jean Njoya', '+237663481198', 'ID6507321', 'qiJO1MCMYqw', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (66, 18, 5, 'Esther Owona', '+237663643924', 'ID9996207', 't5a1wRS8yCI', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (67, 22, 2, 'Luc Essomba', '+237687925434', 'ID5453786', 'obdt9WOpVOY', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (68, 3, 8, 'Rachel Atem', '+237652101056', 'ID8321474', 'mBZwA8qQ3Ls', '2026-10-04');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (69, 39, 35, 'David Njoya', '+237644188276', 'ID1744682', 'v9P4oZbgxyA', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (70, 46, 29, 'Blaise Mvondo', '+237636445607', 'ID7110622', 'd46hqW25r7E', '2026-10-20');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (71, 28, 5, 'Samuel Sone', '+237699038359', 'ID3090865', '6lLU0gyUKdk', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (72, 47, 20, 'Grace Mangue', '+237653779528', 'ID7751158', '7WGymZ-ioXE', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (73, 45, 19, 'Ali Njoya', '+237666431351', 'ID7361002', '27KXQVrI2W0', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (74, 44, 50, 'Clarisse Talla', '+237664502486', 'ID1006810', 'Q53h6GkoqPE', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (75, 20, 20, 'Rachel Sone', '+237672409658', 'ID8411939', '3sTYcPH-LG8', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (76, 29, 15, 'Nadège Essomba', '+237698429450', 'ID2422633', 'MhHJ2trgiCU', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (77, 19, 33, 'Clarisse Sone', '+237622534217', 'ID4940441', '7u-miaIbSaU', '2026-10-09');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (78, 44, 20, 'Pierre Mbarga', '+237613278320', 'ID1775337', '4IBtx5SUOzA', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (79, 16, 31, 'Paul Tabi', '+237665625330', 'ID4262081', 'gawBYnwCkKY', '2026-10-09');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (80, 46, 47, 'Nadège Ekwalla', '+237642747037', 'ID3475836', 'xpPNL40HkhM', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (81, 42, 45, 'Fatima Mangue', '+237639372360', 'ID3950888', 'pPRJGm0Wm8Q', '2026-10-20');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (82, 52, 46, 'Olivier Tchoumi', '+237684813739', 'ID5180853', 'Gi5m7h1KZq0', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (83, 59, 9, 'Ali Tabi', '+237699600766', 'ID9910914', 'JUrFnHLwIr4', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (84, 36, 41, 'Olivier Owona', '+237667276174', 'ID8481188', 'XxLxlqQRjzs', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (85, 58, 13, 'Olivier Kamga', '+237643183955', 'ID5652512', 'gxFU8aY9xFg', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (86, 50, 35, 'Aïcha Kamga', '+237669038700', 'ID2299954', 'oIDpCfdjDxQ', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (87, 46, 19, 'Luc Sone', '+237652910691', 'ID2351868', 'hRJBNuzUogs', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (88, 9, 10, 'David Mbarga', '+237638716269', 'ID2077581', 'dm6sHbGqVdE', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (89, 27, 27, 'Sarah Tabi', '+237665804273', 'ID2044645', 'ZGL0yC5YBTs', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (90, 14, 28, 'Ibrahim Ngono', '+237687267850', 'ID7381734', 'NRDY-ET1AR4', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (91, 31, 1, 'Grace Ekwalla', '+237666240084', 'ID4700025', '3suTaSCA_yg', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (92, 32, 16, 'Rachel Ndzana', '+237613895645', 'ID7523941', 'ORf2Z1LVNo4', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (93, 22, 44, 'David Essomba', '+237672732043', 'ID3141239', 'G2TzD49h8do', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (94, 40, 35, 'David Ngono', '+237621267237', 'ID8190929', 'WpoNiv_28pM', '2026-10-20');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (95, 9, 32, 'Marie Kamga', '+237660882459', 'ID6492066', 'z-iWvj1lS7c', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (96, 14, 32, 'Samuel Ekwalla', '+237647346970', 'ID8072684', 'VUqqPRWcKR4', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (97, 17, 6, 'Jean Mvondo', '+237616990811', 'ID6871360', 'GUwHwpoNY3o', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (98, 15, 5, 'Marie Ngono', '+237643189803', 'ID4344717', '99HpyjnT_bo', '2026-10-08');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (99, 54, 2, 'Ali Biyogo', '+237626941092', 'ID8945036', 'aScbgaZaLBg', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (100, 43, 9, 'Pierre Tabi', '+237644392446', 'ID7189034', 'A2cp7dGHc_M', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (101, 11, 20, 'Fatima Essomba', '+237651746937', 'ID2813596', 'qQhoDS4JiAU', '2026-10-07');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (102, 38, 2, 'Ibrahim Ekwalla', '+237663238057', 'ID4327421', 'RKDBe-kDFCE', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (103, 5, 16, 'Grace Foka', '+237685958181', 'ID1689025', '4G7QNpJy_Ng', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (104, 23, 29, 'Esther Etame', '+237677908907', 'ID6724909', 'ue0VZwsPLLU', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (105, 1, 27, 'Fatima Mangue', '+237658612055', 'ID8713146', 'Gh8YkaRNJ4E', '2026-10-06');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (106, 46, 10, 'Chantal Owona', '+237697302916', 'ID5531230', 'ovFg0rurowU', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (107, 40, 53, 'Nadège Tabi', '+237668461818', 'ID5502929', 'yrNc7A2XHcc', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (108, 21, 16, 'Luc Tabi', '+237642730796', 'ID8796514', 'FMizOzOPZPM', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (109, 37, 41, 'David Sone', '+237613852048', 'ID9293086', 'nZkDwNT1CHA', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (110, 55, 22, 'Nadège Njoya', '+237657623800', 'ID5334434', 'Fb7JEyg-Ivs', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (111, 22, 19, 'Luc Mvondo', '+237611362459', 'ID9667566', 'cFbG1Zap5sQ', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (112, 13, 6, 'Rachel Ndzana', '+237684514489', 'ID5031966', 'X9yIbwpmoC8', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (113, 45, 32, 'Nadège Tabi', '+237612314351', 'ID2561176', 'izfv9BMUj-U', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (114, 19, 15, 'Aïcha Talla', '+237699115205', 'ID7191135', 'db4iOuS86zU', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (115, 31, 37, 'Esther Mangue', '+237683871890', 'ID6549757', 'eEf-uZg-kok', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (116, 23, 32, 'Grace Kamga', '+237640942292', 'ID3024269', 'RPyhzdYkZN4', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (117, 47, 13, 'Fatima Mvondo', '+237634850391', 'ID4213524', 'dVwBGVXUtIc', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (118, 14, 34, 'Ibrahim Owona', '+237690099897', 'ID5747930', 'vfBb9QIqQOw', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (119, 7, 13, 'Aïcha Atem', '+237634084236', 'ID6071208', 'SIXOhv844rs', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (120, 1, 36, 'Luc Tchoumi', '+237617318358', 'ID5901239', 'AJMlUK501iY', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (121, 45, 9, 'Nadège Foka', '+237611646234', 'ID5770422', 'plnsE1W61ss', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (122, 31, 32, 'Samuel Essomba', '+237616895666', 'ID5235884', 'KgfqVRbLNkI', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (123, 56, 31, 'Paul Ekwalla', '+237676001106', 'ID2242892', 'aA3cW1wC5Xs', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (124, 37, 43, 'Marie Mbarga', '+237630024960', 'ID6097514', 'Qld_254ICng', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (125, 6, 16, 'Sarah Mangue', '+237691378577', 'ID4786401', 'BDuDYZwT7T4', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (126, 50, 36, 'Olivier Tabi', '+237649910061', 'ID8194570', 'eR1PbqXfqyY', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (127, 20, 39, 'Marie Foka', '+237637888820', 'ID4540415', 'jLGr_Yzd7Yc', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (128, 17, 7, 'Aïcha Essomba', '+237684087145', 'ID2259379', 'KuZVAGDFOn0', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (129, 11, 1, 'Olivier Ndzana', '+237649092160', 'ID1547605', '5kHR8Eylyy8', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (130, 15, 20, 'Olivier Etame', '+237641329612', 'ID5438490', 'zFnF-LC5EqY', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (131, 51, 38, 'Pierre Mangue', '+237625405014', 'ID4771676', 'rd6MvYtbhPo', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (132, 42, 10, 'Ali Etame', '+237618004482', 'ID3783722', '06QRt4edqGk', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (133, 51, 20, 'Ibrahim Talla', '+237668942178', 'ID3086308', '5bq-h04HQho', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (134, 30, 46, 'David Kamga', '+237677172238', 'ID9284509', 'F5JTGA9d60I', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (135, 29, 6, 'Marie Mangue', '+237653261270', 'ID5200476', 'aLKELkK7p6U', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (136, 2, 6, 'Ibrahim Ngono', '+237646173157', 'ID1674975', 'uPY-gOKX5bs', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (137, 49, 12, 'Blaise Tabi', '+237647333543', 'ID4044882', 'cw9FVfE6CL0', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (138, 38, 31, 'Nadège Etame', '+237673083727', 'ID6837817', 'Z2OelCcgh38', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (139, 27, 22, 'Fatima Essomba', '+237654265498', 'ID7906258', 'ceMlmR20duY', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (140, 45, 35, 'David Mvondo', '+237614925405', 'ID8630712', 'eHns3n7obVI', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (141, 6, 22, 'Samuel Foka', '+237664247457', 'ID9633492', 'QMKwu-wGY0Q', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (142, 53, 1, 'Sarah Tabi', '+237665465150', 'ID1909393', '5cD06PhIp4I', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (143, 13, 35, 'Clarisse Ndzana', '+237693940940', 'ID8416216', '0ZdcQFneiZE', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (144, 49, 4, 'Luc Mvondo', '+237627584297', 'ID5832327', '7bpckMvc04U', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (145, 29, 35, 'Jean Biyogo', '+237631257157', 'ID6213522', 'F-r1EPFuwSo', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (146, 36, 2, 'Rachel Etame', '+237640158811', 'ID2903561', 'X0Lcpo-qFfE', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (147, 30, 8, 'Ali Ndzana', '+237649172995', 'ID9537455', 'EKwlWyCjoU0', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (148, 46, 20, 'Nadège Ndzana', '+237642713008', 'ID8663605', 'hMbK377mly4', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (149, 36, 12, 'Pierre Owona', '+237628321839', 'ID2171218', '_kZApeeEgBk', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (150, 18, 28, 'Blaise Kamga', '+237610344303', 'ID5745250', 'BPfNcslxi10', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (151, 47, 22, 'Ibrahim Ndzana', '+237629944139', 'ID8491822', 'bBVtlHX8gY0', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (152, 35, 31, 'Samuel Mvondo', '+237682937948', 'ID7328534', 'isY4JS-qlBg', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (153, 30, 23, 'Aïcha Ekwalla', '+237641348220', 'ID7891662', 'Ue2RgmeqrSc', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (154, 3, 24, 'David Ekwalla', '+237699078806', 'ID3551903', 'MA4LVLUfHTs', '2026-10-06');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (155, 32, 4, 'Blaise Sone', '+237623470708', 'ID8387112', '51c3yPBC_qg', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (156, 7, 35, 'Jean Mbarga', '+237665026398', 'ID3589751', '-oDUF-jnQ7g', '2026-10-08');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (157, 5, 32, 'Samuel Ekwalla', '+237697219599', 'ID2347467', 'uSIuPo7U_7c', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (158, 55, 24, 'Sarah Ekwalla', '+237652501540', 'ID9186400', 'uPTkt0rk79Q', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (159, 56, 36, 'Clarisse Etame', '+237641510328', 'ID5821419', 'WngCQ3jgvg0', '2026-10-20');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (160, 15, 7, 'Fatima Foka', '+237669549527', 'ID3791137', 'fF-rENJo_9k', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (161, 45, 22, 'Marie Sone', '+237617532195', 'ID5921894', '8vX5dfUe7s4', '2026-10-20');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (162, 23, 25, 'Ali Biyogo', '+237681291936', 'ID7913081', '_YFWPErdfKA', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (163, 37, 12, 'Chantal Etame', '+237691804602', 'ID7418028', 'bMLdoJCBv-Q', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (164, 40, 45, 'Nadège Mbarga', '+237641163805', 'ID8736811', 'JcKGQF4IjuQ', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (165, 41, 19, 'Luc Ngono', '+237672445234', 'ID5825658', 'UeUyOtslAig', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (166, 44, 37, 'Paul Tabi', '+237656381032', 'ID6018975', 'x8XhrzyDv4s', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (167, 41, 31, 'Olivier Talla', '+237636738452', 'ID7454081', 'OUt2tAlWZg4', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (168, 55, 34, 'Aïcha Ekwalla', '+237686762164', 'ID7022335', 'ShLJ__Sw7M8', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (169, 37, 21, 'Jean Ekwalla', '+237646840133', 'ID1135861', '4JQUMi9GW5U', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (170, 37, 4, 'Nadège Talla', '+237640885967', 'ID6910964', 'c3t-7R3sgp4', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (171, 15, 15, 'Luc Mbarga', '+237694322033', 'ID2630140', 'JrIEUd9-Oeo', '2026-10-09');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (172, 58, 44, 'Marie Talla', '+237669166287', 'ID1559763', 'Jm4CThlh31M', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (173, 38, 27, 'Paul Talla', '+237653851498', 'ID7970985', 'M7D1n18HF2g', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (174, 12, 13, 'Sarah Atem', '+237681249799', 'ID9418719', 'mZAuxAiz8zA', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (175, 59, 20, 'Luc Ndzana', '+237649613214', 'ID6682698', 'WnrW6jKrGiM', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (176, 52, 9, 'Paul Mbarga', '+237640281491', 'ID7667458', 'zBbYpio-LD8', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (177, 55, 40, 'Paul Ekwalla', '+237611868130', 'ID5436878', '570rAcmHgcU', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (178, 35, 8, 'Esther Kamga', '+237688458327', 'ID7392547', 'wrG5twFhGlA', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (179, 53, 26, 'Aïcha Ndzana', '+237613358751', 'ID6503032', '1cL-MdZ3FNs', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (180, 59, 24, 'Paul Tabi', '+237650559278', 'ID7850067', 'DckN0SABUa4', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (181, 8, 9, 'Marie Talla', '+237676118957', 'ID2948178', 'MVzMoAxSf4s', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (182, 7, 17, 'Ali Ekwalla', '+237670887034', 'ID7224540', 'xsQPAxmErjM', '2026-10-07');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (183, 43, 40, 'Ibrahim Mbarga', '+237665684858', 'ID2661307', '5NnRAzIbFSE', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (184, 54, 34, 'Rachel Kamga', '+237614391105', 'ID7216461', '93iv8sIaxtA', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (185, 14, 31, 'Aïcha Atem', '+237623335151', 'ID7162857', '5V1tFujo6S0', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (186, 35, 24, 'David Kamga', '+237635475673', 'ID3049499', 'J9ACbeluKmU', '2026-10-20');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (187, 55, 33, 'Pierre Ngono', '+237616788532', 'ID6595355', 'Osu117YqzgM', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (188, 16, 9, 'Pierre Etame', '+237684384510', 'ID4475523', 'zj9SsBzsk7M', '2026-10-09');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (189, 38, 16, 'Samuel Mbarga', '+237689991301', 'ID1047572', 'XYLrE5Cjo-8', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (190, 18, 11, 'Sarah Kamga', '+237633420607', 'ID2844258', 'NZV4mQxap_I', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (191, 43, 2, 'Jean Atem', '+237641934639', 'ID6431983', 'ORjWxxAwkDw', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (192, 2, 13, 'Marie Mbarga', '+237666500369', 'ID9826250', 'bOJMVBljNEQ', '2026-10-09');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (193, 8, 5, 'Olivier Atem', '+237678885632', 'ID2829622', 'IRr_JYHP9-U', '2026-10-08');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (194, 29, 20, 'Clarisse Tchoumi', '+237698436473', 'ID9748499', 'tD6RyK99eSo', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (195, 20, 32, 'Jean Tchoumi', '+237674287863', 'ID7738019', 'A2UhhTTVXT8', '2026-10-09');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (196, 28, 46, 'Nadège Tabi', '+237619863756', 'ID2355439', 'BKCg5zbWVlc', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (197, 21, 40, 'Paul Mbarga', '+237646912022', 'ID6455706', 'Q4ryhdqPKlI', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (198, 25, 40, 'Grace Tabi', '+237677853916', 'ID8217547', 'Aeqd9-Nbves', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (199, 7, 8, 'Sarah Njoya', '+237667723010', 'ID8575834', 'AIwBgWcdKg0', '2026-10-05');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (200, 57, 16, 'Samuel Tabi', '+237663516659', 'ID7979148', '0vAEAms7ORs', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (201, 47, 7, 'Rachel Sone', '+237699269266', 'ID5276341', 'HPCNNM-Tm4k', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (202, 24, 10, 'Nadège Etame', '+237622243983', 'ID2432176', 'opq3YPv0pGw', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (203, 6, 30, 'Esther Mbarga', '+237684674816', 'ID2006313', 'ovy_fSEeNjI', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (204, 38, 42, 'Samuel Foka', '+237665137801', 'ID6932391', '3RRzj_D9aWQ', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (205, 56, 45, 'Marie Talla', '+237690585678', 'ID6242022', 'wqgWOsMxx9Y', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (206, 23, 4, 'Blaise Njoya', '+237630767532', 'ID9089795', 'Dmwz6fa729I', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (207, 15, 9, 'Sarah Atem', '+237625419645', 'ID5673599', 'UbKAKE9mgAM', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (208, 37, 18, 'Sarah Mvondo', '+237613523729', 'ID5487028', 'L53K3uX1UNc', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (209, 2, 14, 'Grace Sone', '+237657113566', 'ID1102438', 'sIbjjZKAz4c', '2026-10-09');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (210, 12, 10, 'David Etame', '+237629042093', 'ID1514340', 'MjWgo2QfbT0', '2026-10-08');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (211, 6, 37, 'David Mangue', '+237670887307', 'ID6719285', 'jfM6LI2UwO0', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (212, 11, 13, 'Samuel Etame', '+237617061037', 'ID3610197', 'N_JsSYUWMx4', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (213, 11, 32, 'Marie Etame', '+237646521025', 'ID8434202', 'ptcDfJyuxQM', '2026-10-07');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (214, 43, 34, 'Clarisse Tabi', '+237665590800', 'ID5582979', 'DLu3LsKuOwE', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (215, 14, 38, 'Esther Mangue', '+237624883373', 'ID5752087', 'ExWRum9kGb8', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (216, 44, 48, 'Nadège Owona', '+237699541016', 'ID6174418', 'ipb6nERQhAk', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (217, 3, 17, 'Clarisse Tchoumi', '+237611031743', 'ID4429650', 'W7yh9gEkiqo', '2026-10-07');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (218, 20, 14, 'Luc Talla', '+237654039837', 'ID3013003', 'fSio-erLyxQ', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (219, 1, 33, 'Chantal Mbarga', '+237661030579', 'ID9935249', 'lGip5B3opzU', '2026-10-07');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (220, 46, 16, 'Sarah Atem', '+237619673809', 'ID7661748', 'F59Fa-TgiSY', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (221, 56, 3, 'Jean Tabi', '+237620450542', 'ID6252285', 'AoYzNPvE800', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (222, 37, 33, 'David Mangue', '+237648858073', 'ID2932288', 'IzPf2fwBSjA', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (223, 26, 2, 'Chantal Tabi', '+237658567046', 'ID2478574', 'OQK9lP9V0Pc', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (224, 28, 8, 'Rachel Ekwalla', '+237680325062', 'ID2319479', '5vLgxNrfcS4', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (225, 26, 21, 'Aïcha Sone', '+237632566390', 'ID2281433', 'pEwYANVVc4o', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (226, 33, 9, 'Blaise Njoya', '+237656892354', 'ID6890476', 'wgJvtE2ObZg', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (227, 47, 35, 'Ali Biyogo', '+237623798190', 'ID3456926', '3AgdG3budpY', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (228, 17, 15, 'Clarisse Mbarga', '+237697980930', 'ID2264218', 'oyaxLDfZH4w', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (229, 12, 43, 'Olivier Tabi', '+237685764804', 'ID6422534', '-ZFr6ZIFolw', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (230, 56, 44, 'Ali Tabi', '+237619165226', 'ID8867190', 'GpNAZmZpJ6Y', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (231, 29, 25, 'Luc Tchoumi', '+237657236885', 'ID9511700', 'FCBSKdJYM84', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (232, 5, 21, 'Olivier Tchoumi', '+237617635653', 'ID7186390', 'v549LpsIYzg', '2026-10-07');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (233, 54, 20, 'Paul Owona', '+237661604364', 'ID8763013', 'LAJ3O7LMUPo', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (234, 38, 43, 'Olivier Njoya', '+237653154591', 'ID8979730', 'X5IE4gyCDLM', '2026-10-20');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (235, 33, 12, 'Olivier Foka', '+237656095437', 'ID2414808', 'SVMCuFi7Ug8', '2026-10-20');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (236, 33, 15, 'Aïcha Tabi', '+237668978194', 'ID9792411', 'sGJlDcOfp5U', '2026-10-20');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (237, 34, 41, 'Esther Atem', '+237647969333', 'ID7499771', 'vOS2Xng_epQ', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (238, 27, 23, 'Clarisse Tchoumi', '+237694676162', 'ID6614484', 'UqAHuXZDGLU', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (239, 5, 11, 'Sarah Ekwalla', '+237648137561', 'ID5227787', 'G01aSv3e3VA', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (240, 47, 32, 'Clarisse Mbarga', '+237654743095', 'ID2367376', 'XGh0nEG4j4c', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (241, 38, 11, 'Grace Ekwalla', '+237627307598', 'ID2421349', 'VgAJ_QlUgoI', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (242, 20, 41, 'Samuel Mbarga', '+237699941500', 'ID9831414', '1XJ17XaU2io', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (243, 6, 46, 'Rachel Owona', '+237658563745', 'ID1305857', 'qveNpA-yddw', '2026-10-04');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (244, 24, 21, 'Pierre Sone', '+237675266178', 'ID4221313', 'FDY0dAT50dQ', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (245, 15, 12, 'Paul Talla', '+237623574883', 'ID9517619', 'DVmrO3oN-_I', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (246, 50, 38, 'Marie Sone', '+237692950779', 'ID3198638', '5y6FPnHn1_A', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (247, 39, 26, 'Chantal Essomba', '+237693851247', 'ID3777286', 'UxkTWAWlRPA', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (248, 47, 17, 'Rachel Atem', '+237641880763', 'ID8452417', '1lpcc3Kw8KA', '2026-10-20');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (249, 40, 19, 'Aïcha Mvondo', '+237642100652', 'ID6192009', 'ljC6X-nj8sg', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (250, 52, 54, 'Pierre Atem', '+237686560394', 'ID8391997', 'V638aZ9UXB0', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (251, 30, 20, 'Blaise Owona', '+237666191704', 'ID3718884', '6E2A6ohvT4g', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (252, 53, 15, 'Ali Kamga', '+237617003454', 'ID9062973', 'Bz6kwqnlaCY', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (253, 56, 25, 'Fatima Owona', '+237626733967', 'ID5782563', 'DspgEKgUmeU', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (254, 6, 11, 'Olivier Owona', '+237629776801', 'ID8339571', 'AB98OupHLsM', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (255, 6, 17, 'Esther Ngono', '+237665686520', 'ID1893502', 'OjL1KtESsEQ', '2026-10-07');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (256, 26, 35, 'Aïcha Ekwalla', '+237620952896', 'ID7289990', '1V3xLmPrFmo', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (257, 15, 2, 'Fatima Sone', '+237629602406', 'ID3308538', 'bw77f6fMCeM', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (258, 3, 23, 'Ali Ndzana', '+237670210270', 'ID1088100', 'ZTh_3wvpR7E', '2026-10-06');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (259, 58, 8, 'Luc Njoya', '+237630068183', 'ID9854536', '15dwr1NwCo4', '2026-10-20');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (260, 28, 10, 'Aïcha Talla', '+237626354208', 'ID1801102', 'HsrZiC5DHpA', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (261, 16, 28, 'Clarisse Tabi', '+237618429833', 'ID2859886', '3TM3x0WXS3A', '2026-10-08');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (262, 54, 37, 'Sarah Ngono', '+237694819556', 'ID9646569', '7JTotDXZeiM', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (263, 37, 20, 'Grace Mangue', '+237610209961', 'ID6919270', 'yctEVwnuhZM', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (264, 16, 41, 'Chantal Etame', '+237680260907', 'ID7049927', 'PqQYpIKE_Zs', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (265, 5, 19, 'Blaise Owona', '+237684377016', 'ID1341153', 'DGpaJz8gKz0', '2026-10-06');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (266, 25, 32, 'David Atem', '+237644044361', 'ID1272499', 't0w4oPHOP4s', '2026-10-20');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (267, 23, 30, 'Esther Biyogo', '+237698195059', 'ID2739191', 'MmOEges2p8Y', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (268, 50, 42, 'Ali Tchoumi', '+237657284777', 'ID6679880', '8fg8q_uD11c', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (269, 53, 24, 'Olivier Ndzana', '+237694790150', 'ID4058117', '57UGPVTmV-A', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (270, 52, 11, 'Olivier Tchoumi', '+237649385195', 'ID4382135', 'uZagUqayDqc', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (271, 3, 15, 'Samuel Talla', '+237679173614', 'ID7681090', 'Jx7rKbfTI0c', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (272, 53, 21, 'Luc Tchoumi', '+237696825515', 'ID4206183', 'uMf9uf6jKcQ', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (273, 19, 24, 'Samuel Kamga', '+237626706752', 'ID7174337', '8wvekwM6rCs', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (274, 28, 29, 'David Sone', '+237635074182', 'ID9324908', 'o6VMphQMCVk', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (275, 45, 37, 'Blaise Kamga', '+237621087928', 'ID8121922', 'kTg1s47is88', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (276, 6, 33, 'Chantal Mvondo', '+237649428661', 'ID6389033', 'XE7BI5T-C7U', '2026-10-05');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (277, 7, 6, 'Grace Talla', '+237669849800', 'ID8149041', 'bQP2SbvSXoM', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (278, 11, 29, 'Esther Tabi', '+237615684813', 'ID6914963', 'wMHTsxzczx0', '2026-10-09');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (279, 40, 29, 'Marie Etame', '+237695565484', 'ID7815076', 'FB79xQ9aXdU', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (280, 24, 35, 'Chantal Ngono', '+237629163535', 'ID8351320', 'ZG_0ydYGKEQ', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (281, 3, 11, 'Aïcha Atem', '+237658607028', 'ID7423230', 'tzdXgWWftsY', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (282, 37, 3, 'Ali Tabi', '+237659790013', 'ID7241348', '2TnkCOXPE84', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (283, 29, 30, 'Ibrahim Mbarga', '+237681062902', 'ID7156398', 'cTIDj4nY9Kg', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (284, 26, 23, 'Luc Biyogo', '+237625226815', 'ID1434753', 'yECvt3zzHvk', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (285, 48, 13, 'Blaise Ekwalla', '+237685386435', 'ID2975701', 'jsjOSlJ0fGg', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (286, 17, 20, 'Pierre Talla', '+237675927774', 'ID4358435', 'Lci1aJad77g', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (287, 8, 11, 'Olivier Essomba', '+237669741812', 'ID2472884', 'pgMd0a89sAg', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (288, 52, 48, 'Esther Etame', '+237683819367', 'ID5871470', 'cKb4YtzdZww', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (289, 58, 24, 'Chantal Atem', '+237678284040', 'ID4762150', 'nagAgtkJ1P8', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (290, 8, 17, 'Aïcha Ndzana', '+237613527782', 'ID7054838', '4V9S2VKfPDo', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (291, 36, 42, 'Olivier Mvondo', '+237627417599', 'ID2446455', 'typS_vXt4MA', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (292, 5, 10, 'Nadège Owona', '+237665135987', 'ID7869154', 'LfgOTDSsEjc', '2026-10-08');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (293, 53, 23, 'Ali Sone', '+237696213226', 'ID2244282', 'pQbFgFfcmNM', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (294, 29, 18, 'Blaise Atem', '+237627224779', 'ID4052834', 'hwvc-1LWn_8', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (295, 50, 10, 'Blaise Tchoumi', '+237626664623', 'ID9692311', '-EIaWGofQ2I', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (296, 10, 22, 'Chantal Sone', '+237640262109', 'ID6805303', 'J3tcpze1nCs', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (297, 34, 19, 'Luc Njoya', '+237695235919', 'ID5604524', '9N6_rPAndJ0', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (298, 9, 21, 'Sarah Etame', '+237677454225', 'ID3829240', 'ZYWaJoNzDC0', '2026-10-06');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (299, 38, 47, 'Chantal Sone', '+237685647532', 'ID1691125', '_xJrZMs2xFA', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (300, 53, 35, 'Paul Tchoumi', '+237696094462', 'ID5440189', 'zsJ-WjER3as', '2026-10-20');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (301, 42, 15, 'Rachel Ngono', '+237676845536', 'ID5859883', 'EXp4-iSBXZ4', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (302, 42, 22, 'Aïcha Ekwalla', '+237649920898', 'ID8609207', 'tFYMac2MgWk', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (303, 5, 28, 'Chantal Tabi', '+237665783806', 'ID9124385', 'K8gL0_n3wO4', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (304, 30, 15, 'Clarisse Mbarga', '+237651954112', 'ID6357240', 'xPxaRO7CjPo', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (305, 47, 34, 'David Mbarga', '+237659733063', 'ID9639932', 'MeYT3LAD3Uc', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (306, 36, 9, 'Aïcha Tabi', '+237626444612', 'ID5487430', '5OMH-evgj94', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (307, 29, 10, 'Fatima Tchoumi', '+237648951595', 'ID7444964', 'zN4jfsdmdEU', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (308, 56, 46, 'Aïcha Essomba', '+237653947691', 'ID6246485', 'aLVQ8zA4HdM', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (309, 13, 12, 'Blaise Tabi', '+237676942394', 'ID6176450', 'TKMLy5IV7-M', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (310, 32, 3, 'David Owona', '+237671368457', 'ID5038756', 'ADxTy3cQpCM', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (311, 14, 44, 'Marie Tchoumi', '+237647763008', 'ID9302946', '8PSLsJy2Zto', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (312, 39, 34, 'Sarah Ngono', '+237624428014', 'ID8229768', 'AZj9lJxAC4Y', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (313, 9, 18, 'David Atem', '+237616072331', 'ID7720644', '3OY30xq1poQ', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (314, 4, 37, 'Pierre Atem', '+237684252324', 'ID5841933', 'i3cfFgcLJyw', '2026-10-06');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (315, 5, 15, 'Olivier Mvondo', '+237647543473', 'ID2993318', 'uPJo9Kw7sIs', '2026-10-06');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (316, 9, 7, 'Esther Sone', '+237684870921', 'ID7133857', 'B34UPv4e9Rg', '2026-10-09');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (317, 49, 11, 'Clarisse Owona', '+237663873262', 'ID9389915', '5sqzufefK04', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (318, 3, 4, 'Ali Sone', '+237673584863', 'ID9712957', 'nRDdmUdUGtg', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (319, 30, 11, 'Blaise Mbarga', '+237654018830', 'ID6344047', 'Aqr1CSQIjEo', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (320, 11, 15, 'Grace Sone', '+237678090664', 'ID9551583', 'XPtZSOiLYgM', '2026-10-07');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (321, 35, 35, 'Grace Ndzana', '+237612232974', 'ID7180018', 'UK3uLtrN_F4', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (322, 22, 47, 'Rachel Talla', '+237694457912', 'ID1447065', 'EtFZzmK06oI', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (323, 39, 36, 'Ibrahim Biyogo', '+237616892773', 'ID9060593', 'KX1dO_CJPxE', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (324, 11, 21, 'Clarisse Ekwalla', '+237629834119', 'ID5063384', 'pZatTgy3MIo', '2026-10-06');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (325, 3, 28, 'Pierre Ngono', '+237669195194', 'ID6262886', 'JyaCvICPbHg', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (326, 27, 10, 'Pierre Mangue', '+237677353073', 'ID8912226', 'Ng7RTG8XwCc', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (327, 56, 5, 'Blaise Njoya', '+237685280948', 'ID6453426', 'r_jcOD5SHSA', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (328, 43, 38, 'David Sone', '+237633244151', 'ID8711874', 'tJ_qHWOaNeU', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (329, 59, 22, 'Sarah Atem', '+237696343485', 'ID5435261', '5K0zaPl2xFc', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (330, 40, 33, 'Aïcha Kamga', '+237684905122', 'ID6007984', 'TpUdpmhznf4', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (331, 15, 27, 'Pierre Ndzana', '+237652552488', 'ID9049765', 'h2AHvKtqv5Q', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (332, 23, 19, 'Grace Foka', '+237686970753', 'ID7370211', 'DldPbjIG6NM', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (333, 58, 31, 'Ali Talla', '+237615646068', 'ID5825636', 'Zn92SSXN-fU', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (334, 46, 6, 'Olivier Kamga', '+237674300930', 'ID4590102', 'iBU4d72ZuEg', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (335, 13, 38, 'Sarah Kamga', '+237628424464', 'ID2832517', 'RTkmH4Bwhb8', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (336, 40, 54, 'Aïcha Biyogo', '+237616813620', 'ID9909397', 'ZlRYiW38go0', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (337, 15, 22, 'Fatima Mangue', '+237654331259', 'ID8925622', 'XuQvvWTtqbk', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (338, 7, 11, 'Sarah Essomba', '+237664614193', 'ID8980915', 'OMLt6A7-xGI', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (339, 31, 45, 'Grace Sone', '+237648307798', 'ID1992583', 'nFmMsqtFvNU', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (340, 59, 31, 'Ibrahim Biyogo', '+237681826922', 'ID1625760', '2xGRzirT7yg', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (341, 59, 6, 'Chantal Tchoumi', '+237663283709', 'ID9311162', 'VlKQ4WOKhxg', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (342, 12, 21, 'Jean Talla', '+237686230551', 'ID2800206', 'iMrb6ban_v0', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (343, 60, 23, 'Olivier Mvondo', '+237680372842', 'ID9286475', 'V3H5s6F6BhE', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (344, 57, 10, 'Olivier Kamga', '+237635878707', 'ID2889899', 'UMYK79JJgNE', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (345, 22, 12, 'Luc Essomba', '+237611890348', 'ID6655803', 'X1y4xBdwd24', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (346, 51, 19, 'Pierre Essomba', '+237692000924', 'ID7802999', 'lttrveymjbQ', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (347, 53, 17, 'Samuel Etame', '+237663798927', 'ID2600296', 'Xzb3LMfe_hc', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (348, 12, 9, 'Samuel Biyogo', '+237610916723', 'ID5375250', 'bqBF83IIl50', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (349, 25, 17, 'Luc Sone', '+237650526484', 'ID1191859', 'D-jD0kgZEq4', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (350, 17, 25, 'Aïcha Tchoumi', '+237699628735', 'ID2983483', 'rI-qF0JlD_k', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (351, 30, 26, 'David Owona', '+237651738753', 'ID2969909', 'YkiD8n9rfys', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (352, 41, 34, 'Esther Biyogo', '+237639410942', 'ID3240912', 'rGzAlGae8iQ', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (353, 31, 11, 'Clarisse Atem', '+237665813853', 'ID8899184', 'LGObJ9dp_tE', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (354, 49, 38, 'Pierre Biyogo', '+237689968863', 'ID2373555', 'NPky8r8VFLk', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (355, 34, 30, 'Esther Etame', '+237685721444', 'ID2882551', 'P_LJfK1MeWs', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (356, 4, 36, 'Pierre Mvondo', '+237630112846', 'ID3760475', '3ZKT6OtH4yc', '2026-10-06');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (357, 21, 35, 'Fatima Njoya', '+237688268756', 'ID9201172', 'EdJM_ak2wkI', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (358, 6, 40, 'Marie Tabi', '+237627709269', 'ID9610869', '8xF7zOG9BL0', '2026-10-07');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (359, 27, 34, 'Marie Mvondo', '+237672059365', 'ID6170227', 'CyKbS8fVsJw', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (360, 47, 1, 'Luc Ngono', '+237639246218', 'ID2225232', '1ylyWFkruEY', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (361, 3, 20, 'Paul Mvondo', '+237618087373', 'ID2157949', 'tIvRNR45sIs', '2026-10-08');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (362, 60, 33, 'Grace Mangue', '+237634156684', 'ID3272119', 'zKdcHUx4WUI', '2026-10-20');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (363, 50, 48, 'Rachel Atem', '+237661335545', 'ID8525204', '27cx854SXEY', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (364, 56, 28, 'Paul Mvondo', '+237627849589', 'ID6834610', 'FuOdFoo6pCs', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (365, 8, 15, 'David Owona', '+237627092236', 'ID4736121', 'u2PYhlz40vA', '2026-10-07');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (366, 54, 1, 'Grace Tabi', '+237683074216', 'ID8115687', 'FNfrT9BGefU', '2026-10-20');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (367, 35, 14, 'Aïcha Tabi', '+237656460773', 'ID3602504', 'hy9YVISnPoE', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (368, 18, 15, 'Marie Mangue', '+237692533595', 'ID1262492', 'R3TbP-UIRRA', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (369, 16, 15, 'Fatima Tchoumi', '+237669920305', 'ID1816653', '30x5Rcg6ZTc', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (370, 16, 55, 'David Tabi', '+237641452485', 'ID4645172', 'fHpvvJISIWE', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (371, 49, 5, 'Blaise Talla', '+237641428626', 'ID6350316', 'KCBg1mfortY', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (372, 37, 28, 'Grace Mbarga', '+237698612211', 'ID9745141', 'vsgPEZiU1rU', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (373, 15, 21, 'Luc Tchoumi', '+237684721440', 'ID3938247', 'zMDwvppNanM', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (374, 41, 25, 'Sarah Ndzana', '+237616292676', 'ID6778321', 'oYTRrNVtNoE', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (375, 42, 47, 'Blaise Sone', '+237665878146', 'ID7849452', '9rz3ufXDbSo', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (376, 10, 23, 'Chantal Mvondo', '+237673554620', 'ID5042775', 'LrJET3qB6rY', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (377, 55, 16, 'Ali Tabi', '+237617734153', 'ID7923579', 'WJDn_SyH7FA', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (378, 27, 40, 'David Biyogo', '+237644224936', 'ID4411424', 'TGK-3jgZb2s', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (379, 22, 46, 'Olivier Atem', '+237622410307', 'ID9986473', 'nXfLfMeOBBs', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (380, 47, 9, 'Luc Ekwalla', '+237691197624', 'ID1663497', 'L7SVDLbCVEY', '2026-10-20');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (381, 56, 7, 'Ibrahim Mvondo', '+237639127464', 'ID9042900', 'K6jIW9VvNLA', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (382, 14, 23, 'Jean Njoya', '+237635504548', 'ID2968239', '8crMTxJd_sQ', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (383, 48, 34, 'Clarisse Njoya', '+237663235053', 'ID5015307', '-QA_7vpcRik', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (384, 36, 26, 'David Tabi', '+237681625307', 'ID7027375', 'eCgUuVXlLxs', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (385, 20, 19, 'Blaise Ndzana', '+237672546007', 'ID2654371', 'nh3fGrOtfFw', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (386, 52, 52, 'Samuel Njoya', '+237659755172', 'ID6249960', 'zcWLG6SlZcg', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (387, 27, 3, 'Aïcha Mbarga', '+237612176998', 'ID5375063', 'X_0WxW_iNj8', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (388, 36, 46, 'Rachel Talla', '+237630456313', 'ID4291551', '6HuWr2Cjwys', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (389, 22, 17, 'Ibrahim Biyogo', '+237677015110', 'ID6663388', 'bUPhinBvZa0', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (390, 17, 30, 'Nadège Tabi', '+237632579937', 'ID6908535', 'YHnXLjh8-sk', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (391, 11, 6, 'Nadège Essomba', '+237682764376', 'ID1985360', 'D0O_fFDqvAY', '2026-10-08');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (392, 34, 3, 'Marie Ngono', '+237665350347', 'ID3306725', 'rY3_4VJ6_f8', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (393, 54, 48, 'Paul Mbarga', '+237611226946', 'ID4669507', 'kRk9K1cRQjc', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (394, 33, 34, 'Marie Ndzana', '+237698487646', 'ID9184838', 'yRNx1KcrH-o', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (395, 2, 1, 'Sarah Mangue', '+237611590610', 'ID1280618', 'oBRP7pfHf5w', '2026-10-05');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (396, 34, 52, 'Sarah Talla', '+237612300840', 'ID9425786', 'Jl45wyGrhaQ', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (397, 53, 31, 'Rachel Essomba', '+237624363501', 'ID2615878', 'A7ddympQAV0', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (398, 34, 11, 'Pierre Owona', '+237643878996', 'ID6946534', 'Amm-HfthBCI', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (399, 18, 30, 'Esther Ekwalla', '+237671605634', 'ID5080351', 'kP_rmSRBidA', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (400, 45, 16, 'Paul Tchoumi', '+237622549425', 'ID7799441', '9Gy9oHANoWU', '2026-10-16');

-- Données de bus
INSERT INTO "bus" (id, immatriculation, nombre_places, type) VALUES (1, 'CE-101-AB', 45, 'classique');
INSERT INTO "bus" (id, immatriculation, nombre_places, type) VALUES (2, 'CE-102-CD', 50, 'classique');
INSERT INTO "bus" (id, immatriculation, nombre_places, type) VALUES (3, 'CE-103-EF', 40, 'vip');
INSERT INTO "bus" (id, immatriculation, nombre_places, type) VALUES (4, 'CE-104-GH', 55, 'classique');
INSERT INTO "bus" (id, immatriculation, nombre_places, type) VALUES (5, 'CE-105-IJ', 35, 'vip');
INSERT INTO "bus" (id, immatriculation, nombre_places, type) VALUES (6, 'CE-106-KL', 48, 'classique');

-- Données de trajets
INSERT INTO "trajets" (id, ville_depart, ville_arrivee, duree_minutes, prix_classique, prix_vip) VALUES (1, 'Douala', 'Yaoundé', 240, 4000.0, 6500.0);
INSERT INTO "trajets" (id, ville_depart, ville_arrivee, duree_minutes, prix_classique, prix_vip) VALUES (2, 'Yaoundé', 'Douala', 240, 4000.0, 6500.0);
INSERT INTO "trajets" (id, ville_depart, ville_arrivee, duree_minutes, prix_classique, prix_vip) VALUES (3, 'Douala', 'Bafoussam', 180, 3500.0, 5500.0);
INSERT INTO "trajets" (id, ville_depart, ville_arrivee, duree_minutes, prix_classique, prix_vip) VALUES (4, 'Yaoundé', 'Bafoussam', 300, 5000.0, 7500.0);
INSERT INTO "trajets" (id, ville_depart, ville_arrivee, duree_minutes, prix_classique, prix_vip) VALUES (5, 'Douala', 'Kribi', 150, 3000.0, 5000.0);
INSERT INTO "trajets" (id, ville_depart, ville_arrivee, duree_minutes, prix_classique, prix_vip) VALUES (6, 'Yaoundé', 'Kribi', 210, 4500.0, 7000.0);
INSERT INTO "trajets" (id, ville_depart, ville_arrivee, duree_minutes, prix_classique, prix_vip) VALUES (7, 'Douala', 'Buea', 70, 1500.0, 2500.0);
INSERT INTO "trajets" (id, ville_depart, ville_arrivee, duree_minutes, prix_classique, prix_vip) VALUES (8, 'Buea', 'Douala', 70, 1500.0, 2500.0);

-- Données de voyages
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (1, 1, 1, '2026-10-13', '06:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (2, 2, 2, '2026-10-13', '07:30', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (3, 3, 3, '2026-10-13', '08:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (4, 4, 4, '2026-10-14', '10:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (5, 5, 5, '2026-10-14', '12:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (6, 6, 6, '2026-10-14', '14:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (7, 7, 1, '2026-10-15', '16:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (8, 8, 2, '2026-10-15', '18:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (9, 1, 3, '2026-10-15', '20:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (10, 2, 4, '2026-10-16', '06:00', 'annulé');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (11, 3, 5, '2026-10-16', '07:30', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (12, 4, 6, '2026-10-17', '08:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (13, 5, 1, '2026-10-17', '10:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (14, 6, 2, '2026-10-17', '12:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (15, 7, 3, '2026-10-18', '14:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (16, 8, 4, '2026-10-18', '16:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (17, 1, 5, '2026-10-18', '18:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (18, 2, 6, '2026-10-19', '20:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (19, 3, 1, '2026-10-19', '06:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (20, 4, 2, '2026-10-19', '07:30', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (21, 5, 3, '2026-10-20', '08:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (22, 6, 4, '2026-10-20', '10:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (23, 7, 5, '2026-10-21', '12:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (24, 8, 6, '2026-10-21', '14:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (25, 1, 1, '2026-10-21', '16:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (26, 2, 2, '2026-10-22', '18:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (27, 3, 3, '2026-10-22', '20:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (28, 4, 4, '2026-10-22', '06:00', 'annulé');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (29, 5, 5, '2026-10-23', '07:30', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (30, 6, 6, '2026-10-23', '08:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (31, 7, 1, '2026-10-24', '10:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (32, 8, 2, '2026-10-24', '12:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (33, 1, 3, '2026-10-24', '14:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (34, 2, 4, '2026-10-25', '16:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (35, 3, 5, '2026-10-25', '18:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (36, 4, 6, '2026-10-25', '20:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (37, 5, 1, '2026-10-26', '06:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (38, 6, 2, '2026-10-26', '07:30', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (39, 7, 3, '2026-10-26', '08:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (40, 8, 4, '2026-10-27', '10:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (41, 1, 5, '2026-10-27', '12:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (42, 2, 6, '2026-10-28', '14:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (43, 3, 1, '2026-10-28', '16:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (44, 4, 2, '2026-10-28', '18:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (45, 5, 3, '2026-10-29', '20:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (46, 6, 4, '2026-10-29', '06:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (47, 7, 5, '2026-10-29', '07:30', 'annulé');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (48, 8, 6, '2026-10-30', '08:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (49, 1, 1, '2026-10-30', '10:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (50, 2, 2, '2026-10-30', '12:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (51, 3, 3, '2026-10-31', '14:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (52, 4, 4, '2026-10-31', '16:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (53, 5, 5, '2026-11-01', '18:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (54, 6, 6, '2026-11-01', '20:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (55, 7, 1, '2026-11-01', '06:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (56, 8, 2, '2026-11-02', '07:30', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (57, 1, 3, '2026-11-02', '08:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (58, 2, 4, '2026-11-02', '10:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (59, 3, 5, '2026-11-03', '12:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (60, 4, 6, '2026-11-03', '14:00', 'prévu');

COMMIT;
PRAGMA foreign_keys = ON;
