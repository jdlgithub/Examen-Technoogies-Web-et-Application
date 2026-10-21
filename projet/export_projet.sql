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
INSERT INTO "admins" (id, username, password_hash) VALUES (1, 'admin', 'scrypt:32768:8:1$Y3YD0TDHHIx8UO9H$e01dd2f193f0e05eda1be8c9b00d2231a5e2bc5a79be4cc19d464ffb7fd61a0f6950d31768c38b9dcfa910334e948005e30ee82a5579fa67cadcb24be814540a');

-- Données de billets
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (1, 41, 8, 'Luc Biyogo', '+237639958838', 'ID3341057', 'ySpXrzCuzpI', '2026-10-21');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (2, 48, 7, 'Sarah Etame', '+237689254563', 'ID8078673', 'nsG-jtWttrk', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (3, 3, 2, 'Pierre Biyogo', '+237677827638', 'ID1445199', 'GgDZRw2ZpjM', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (4, 36, 13, 'Sarah Mangue', '+237639587039', 'ID8536477', 'Dwkn_Bi-mT0', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (5, 38, 18, 'Chantal Mangue', '+237655667651', 'ID5661907', 'Bhd5ER-zk38', '2026-10-21');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (6, 10, 14, 'Fatima Etame', '+237660992979', 'ID2622631', 'j0A2k3m-hkA', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (7, 23, 23, 'Luc Tchoumi', '+237671662963', 'ID9996414', 'Eojmxq9XW1g', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (8, 8, 25, 'Sarah Talla', '+237694374605', 'ID7067228', 'koFHraAP29c', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (9, 37, 13, 'Marie Biyogo', '+237648840994', 'ID2338687', 'eLWoU57COa8', '2026-10-20');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (10, 55, 15, 'David Kamga', '+237670855700', 'ID7120868', 'SNCQrKE7LnA', '2026-10-20');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (11, 11, 24, 'Pierre Kamga', '+237696977837', 'ID2197935', 'DO3K2KFObLk', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (12, 39, 11, 'Aïcha Essomba', '+237672043515', 'ID7366205', 'q_XN79h2KY4', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (13, 18, 41, 'Aïcha Sone', '+237617507864', 'ID4842788', 'LX-iqZRbZC0', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (14, 53, 3, 'David Kamga', '+237618883684', 'ID4539704', '7LP8qCCy7SI', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (15, 59, 21, 'Nadège Ekwalla', '+237696282117', 'ID8698256', 'qC5KC0rqAuc', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (16, 10, 18, 'Aïcha Mvondo', '+237682340307', 'ID5408072', 'BDjKjNKwYpY', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (17, 48, 39, 'Ibrahim Ekwalla', '+237658586340', 'ID4679591', '78Q8lXAjVoY', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (18, 9, 33, 'Paul Tchoumi', '+237624716857', 'ID3564251', '1sDAs5P_L-4', '2026-10-09');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (19, 41, 12, 'Rachel Etame', '+237661642594', 'ID7402509', 'HFdmoTRR8So', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (20, 39, 31, 'Luc Mvondo', '+237611540956', 'ID2921859', 'su_osY4Eeio', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (21, 44, 35, 'Samuel Foka', '+237649392920', 'ID8294150', 'IOwyNcDCSrY', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (22, 11, 31, 'Luc Owona', '+237633978249', 'ID9517485', 'l3E853G7__s', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (23, 59, 7, 'Grace Owona', '+237691734598', 'ID4337174', '6l9zpwoaHhw', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (24, 10, 26, 'Sarah Owona', '+237610076758', 'ID6438436', 'axqmZzn21uc', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (25, 32, 2, 'Esther Talla', '+237642138745', 'ID1971823', 'G28d3QTH058', '2026-10-20');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (26, 16, 37, 'Paul Ndzana', '+237619289546', 'ID9937326', '0z5qL2kbPDE', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (27, 50, 9, 'Nadège Mvondo', '+237632162965', 'ID5446912', 'ep1-wrcQA2o', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (28, 34, 39, 'Pierre Mvondo', '+237636998038', 'ID6229731', 'DrVVL11t0A0', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (29, 26, 43, 'Esther Tabi', '+237679467853', 'ID8574680', 'KCmdxDA541k', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (30, 8, 16, 'Paul Sone', '+237612823170', 'ID4860684', 'vl6Gqw5RRRw', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (31, 38, 15, 'Paul Tchoumi', '+237640728046', 'ID2130789', 'dWxSluRR44M', '2026-10-21');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (32, 58, 3, 'Paul Owona', '+237641944441', 'ID5672073', 'XsmONNNKOl8', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (33, 43, 32, 'Sarah Mbarga', '+237686644106', 'ID8930103', 'GsO2hbNbpxs', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (34, 16, 52, 'Rachel Njoya', '+237622660194', 'ID2626229', 'P018N7d86Os', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (35, 43, 28, 'Rachel Mangue', '+237672682989', 'ID1908841', 'Kj1MSVFdn7Q', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (36, 44, 43, 'Fatima Tchoumi', '+237664038913', 'ID6692553', 'R6lXiuRn7I0', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (37, 52, 7, 'Pierre Njoya', '+237681979055', 'ID8526486', 'Vf3slE6u6EY', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (38, 9, 28, 'Luc Tabi', '+237643528453', 'ID2264748', 'yWFb-NgAFgA', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (39, 29, 7, 'Sarah Ngono', '+237622517517', 'ID4965789', 'SEIQaqTavsQ', '2026-10-21');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (40, 11, 28, 'Nadège Njoya', '+237663826716', 'ID1983738', 'Hpw1FZD590w', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (41, 11, 26, 'David Kamga', '+237671070189', 'ID5785687', 'PPMkCQot7-o', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (42, 28, 45, 'Nadège Mbarga', '+237635487660', 'ID5977931', 'v17_Ji3BM3g', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (43, 14, 4, 'Sarah Tchoumi', '+237652091325', 'ID1959074', 'AakIaMohnzs', '2026-10-09');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (44, 4, 38, 'Blaise Owona', '+237631130263', 'ID1954280', '8tFya9vdbKs', '2026-10-08');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (45, 33, 6, 'Paul Etame', '+237641568532', 'ID7774229', 'DIl_0yBv2qs', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (46, 8, 39, 'Ibrahim Tchoumi', '+237693131979', 'ID2375453', 'p0fEcGFom1k', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (47, 27, 38, 'Blaise Sone', '+237644999379', 'ID4426900', 'GK63iRMP7b0', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (48, 43, 21, 'Luc Ekwalla', '+237627566185', 'ID6033115', 'tMrbOKVDXs4', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (49, 30, 21, 'Jean Tabi', '+237693370583', 'ID2677407', 'r6dSr1s7Im4', '2026-10-20');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (50, 5, 35, 'Blaise Kamga', '+237627778019', 'ID6855396', 'MyIqf5y4F-w', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (51, 57, 5, 'Esther Talla', '+237631172421', 'ID8351517', 'KZAh-d-bQvU', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (52, 54, 35, 'Clarisse Owona', '+237611049999', 'ID6022741', 'mrIdpeEiXLM', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (53, 60, 43, 'Ali Kamga', '+237625492573', 'ID2795765', 'xytbgrk1Bok', '2026-10-20');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (54, 48, 37, 'Luc Talla', '+237691178885', 'ID4533779', '45lXGRuf-Tw', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (55, 46, 22, 'Luc Owona', '+237675569635', 'ID5213115', 'UiUcv7gmzLU', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (56, 58, 5, 'Rachel Kamga', '+237615917225', 'ID1059486', '5pIt9193PWQ', '2026-10-20');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (57, 22, 50, 'Luc Essomba', '+237669302158', 'ID8175395', 'uld7LwqqUC4', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (58, 36, 1, 'Paul Mbarga', '+237683227889', 'ID1604451', 'Tro0g5qhCDA', '2026-10-20');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (59, 54, 24, 'Sarah Mbarga', '+237667684996', 'ID3138181', 'dMdAFOtukLY', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (60, 3, 21, 'Marie Atem', '+237638195995', 'ID5186414', 'HV9J-Cpaqi8', '2026-10-09');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (61, 43, 7, 'Sarah Mangue', '+237693303777', 'ID3592974', '7i_Y3kEj22U', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (62, 60, 16, 'Chantal Mangue', '+237613326769', 'ID4009172', 'ndYa_1AY0Ko', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (63, 48, 23, 'Aïcha Kamga', '+237631367172', 'ID2813543', 'Pr7vgnBZwIQ', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (64, 25, 3, 'Aïcha Njoya', '+237671780854', 'ID6866294', 'fTrOgBMz6L0', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (65, 20, 15, 'Jean Njoya', '+237663481198', 'ID6507321', 'igZ9WQhst1c', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (66, 18, 5, 'Esther Owona', '+237663643924', 'ID9996207', '03acvCfZ0DE', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (67, 22, 2, 'Luc Essomba', '+237687925434', 'ID5453786', 'za_YjUKZ850', '2026-10-20');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (68, 3, 8, 'Rachel Atem', '+237652101056', 'ID8321474', 'RyXZlU2D7Ko', '2026-10-05');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (69, 39, 35, 'David Njoya', '+237644188276', 'ID1744682', 'Cm6WexOKIeo', '2026-10-20');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (70, 46, 29, 'Blaise Mvondo', '+237636445607', 'ID7110622', 'JgcfO4V5MsU', '2026-10-21');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (71, 28, 5, 'Samuel Sone', '+237699038359', 'ID3090865', 'towMP5tQTzg', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (72, 47, 20, 'Grace Mangue', '+237653779528', 'ID7751158', '-6XCpHc4bWo', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (73, 45, 19, 'Ali Njoya', '+237666431351', 'ID7361002', 'cdsTftpcL58', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (74, 44, 50, 'Clarisse Talla', '+237664502486', 'ID1006810', 'VzB7a-vlOxA', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (75, 20, 20, 'Rachel Sone', '+237672409658', 'ID8411939', 'XtFeZRaK-Jc', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (76, 29, 15, 'Nadège Essomba', '+237698429450', 'ID2422633', 'JZRMW3SOvd0', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (77, 19, 33, 'Clarisse Sone', '+237622534217', 'ID4940441', 'KmBpiQnbfqc', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (78, 44, 20, 'Pierre Mbarga', '+237613278320', 'ID1775337', 'TS2-iQfuFmE', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (79, 16, 31, 'Paul Tabi', '+237665625330', 'ID4262081', 'IJp58E5-6b0', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (80, 46, 47, 'Nadège Ekwalla', '+237642747037', 'ID3475836', '4SWV5Rx1_hU', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (81, 42, 45, 'Fatima Mangue', '+237639372360', 'ID3950888', 'uD-T_t_lEyU', '2026-10-21');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (82, 52, 46, 'Olivier Tchoumi', '+237684813739', 'ID5180853', 'FagF8_5EkzY', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (83, 59, 9, 'Ali Tabi', '+237699600766', 'ID9910914', 'JJVwMS4FlC8', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (84, 36, 41, 'Olivier Owona', '+237667276174', 'ID8481188', 'rpMjVkmZhKQ', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (85, 58, 13, 'Olivier Kamga', '+237643183955', 'ID5652512', 'eR-xOlE0GzI', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (86, 50, 35, 'Aïcha Kamga', '+237669038700', 'ID2299954', 'B7XczDkOoxA', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (87, 46, 19, 'Luc Sone', '+237652910691', 'ID2351868', 'XnwN21M9qf4', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (88, 9, 10, 'David Mbarga', '+237638716269', 'ID2077581', 'TEW9T56iNE8', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (89, 27, 27, 'Sarah Tabi', '+237665804273', 'ID2044645', 'NrzJtkJWT3k', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (90, 14, 28, 'Ibrahim Ngono', '+237687267850', 'ID7381734', 'dQ98OhWaDjE', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (91, 31, 1, 'Grace Ekwalla', '+237666240084', 'ID4700025', 'SaPTG9_j6GE', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (92, 32, 16, 'Rachel Ndzana', '+237613895645', 'ID7523941', 'uswC-QEsox8', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (93, 22, 44, 'David Essomba', '+237672732043', 'ID3141239', 'yUKrSN5ZwT0', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (94, 40, 35, 'David Ngono', '+237621267237', 'ID8190929', 'UGzv2nT4AEY', '2026-10-21');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (95, 9, 32, 'Marie Kamga', '+237660882459', 'ID6492066', 'LU8zzWXFKr0', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (96, 14, 32, 'Samuel Ekwalla', '+237647346970', 'ID8072684', '2W8tdfCfrxE', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (97, 17, 6, 'Jean Mvondo', '+237616990811', 'ID6871360', 'WiSlgvqNWVQ', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (98, 15, 5, 'Marie Ngono', '+237643189803', 'ID4344717', '7gGi_P0lInY', '2026-10-09');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (99, 54, 2, 'Ali Biyogo', '+237626941092', 'ID8945036', 'bUwdfvF1344', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (100, 43, 9, 'Pierre Tabi', '+237644392446', 'ID7189034', 'YOG0Xk0fWCk', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (101, 11, 20, 'Fatima Essomba', '+237651746937', 'ID2813596', '6WvHL1IHyMU', '2026-10-08');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (102, 38, 2, 'Ibrahim Ekwalla', '+237663238057', 'ID4327421', 'pCxn0fXTtkg', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (103, 5, 16, 'Grace Foka', '+237685958181', 'ID1689025', '7w1IC_wQ5vw', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (104, 23, 29, 'Esther Etame', '+237677908907', 'ID6724909', '-YSZxUloV1Q', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (105, 1, 27, 'Fatima Mangue', '+237658612055', 'ID8713146', 'QKFyWWqtj70', '2026-10-07');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (106, 46, 10, 'Chantal Owona', '+237697302916', 'ID5531230', '0_k8t2H6yH8', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (107, 40, 53, 'Nadège Tabi', '+237668461818', 'ID5502929', 'vwvv3MexRzw', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (108, 21, 16, 'Luc Tabi', '+237642730796', 'ID8796514', 'GGEIPY5gj6o', '2026-10-20');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (109, 37, 41, 'David Sone', '+237613852048', 'ID9293086', 'A4pNbqqVJno', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (110, 55, 22, 'Nadège Njoya', '+237657623800', 'ID5334434', '9tA7pyQuAao', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (111, 22, 19, 'Luc Mvondo', '+237611362459', 'ID9667566', 'X5jiUCjBBf8', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (112, 13, 6, 'Rachel Ndzana', '+237684514489', 'ID5031966', 'g35HAQUiLxA', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (113, 45, 32, 'Nadège Tabi', '+237612314351', 'ID2561176', 'NI-36rnWKt0', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (114, 19, 15, 'Aïcha Talla', '+237699115205', 'ID7191135', 'mzHIrE2INl8', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (115, 31, 37, 'Esther Mangue', '+237683871890', 'ID6549757', 'v3S-EzqOaLQ', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (116, 23, 32, 'Grace Kamga', '+237640942292', 'ID3024269', 'To0vxfb8q-4', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (117, 47, 13, 'Fatima Mvondo', '+237634850391', 'ID4213524', '3WjWY4UEphI', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (118, 14, 34, 'Ibrahim Owona', '+237690099897', 'ID5747930', 'pZBSleuEjRY', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (119, 7, 13, 'Aïcha Atem', '+237634084236', 'ID6071208', 'XS9XFs3zFVA', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (120, 1, 36, 'Luc Tchoumi', '+237617318358', 'ID5901239', '_P4LMSzY74c', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (121, 45, 9, 'Nadège Foka', '+237611646234', 'ID5770422', 'JIXGhwzeLuw', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (122, 31, 32, 'Samuel Essomba', '+237616895666', 'ID5235884', 'z0jAelQjtNo', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (123, 56, 31, 'Paul Ekwalla', '+237676001106', 'ID2242892', 'G_SCtqpToUk', '2026-10-20');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (124, 37, 43, 'Marie Mbarga', '+237630024960', 'ID6097514', '1ZqQsMZDHXo', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (125, 6, 16, 'Sarah Mangue', '+237691378577', 'ID4786401', '6pc6lZixFN0', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (126, 50, 36, 'Olivier Tabi', '+237649910061', 'ID8194570', 'VDdXS4L-TPI', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (127, 20, 39, 'Marie Foka', '+237637888820', 'ID4540415', '90j5TAyRUeo', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (128, 17, 7, 'Aïcha Essomba', '+237684087145', 'ID2259379', 'dcFeFlLYWK0', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (129, 11, 1, 'Olivier Ndzana', '+237649092160', 'ID1547605', 'etuY7yXGWBE', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (130, 15, 20, 'Olivier Etame', '+237641329612', 'ID5438490', 'rbWLSEfaCBY', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (131, 51, 38, 'Pierre Mangue', '+237625405014', 'ID4771676', 'VNgvNG87Aus', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (132, 42, 10, 'Ali Etame', '+237618004482', 'ID3783722', '8ypIDhShqfg', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (133, 51, 20, 'Ibrahim Talla', '+237668942178', 'ID3086308', '2Pzl0fAuBxw', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (134, 30, 46, 'David Kamga', '+237677172238', 'ID9284509', '9cN42SzSQM0', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (135, 29, 6, 'Marie Mangue', '+237653261270', 'ID5200476', 'YCmy3dLCwuo', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (136, 2, 6, 'Ibrahim Ngono', '+237646173157', 'ID1674975', 'ahYY1TR32HU', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (137, 49, 12, 'Blaise Tabi', '+237647333543', 'ID4044882', 'uYusA3p1GQA', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (138, 38, 31, 'Nadège Etame', '+237673083727', 'ID6837817', 'dTInPlfSBH0', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (139, 27, 22, 'Fatima Essomba', '+237654265498', 'ID7906258', 'N9eaC_plqTg', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (140, 45, 35, 'David Mvondo', '+237614925405', 'ID8630712', '3YQI48FrwaA', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (141, 6, 22, 'Samuel Foka', '+237664247457', 'ID9633492', '5VnsWagIymw', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (142, 53, 1, 'Sarah Tabi', '+237665465150', 'ID1909393', 'nXSY5_263EY', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (143, 13, 35, 'Clarisse Ndzana', '+237693940940', 'ID8416216', '0LFQBLmKIHs', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (144, 49, 4, 'Luc Mvondo', '+237627584297', 'ID5832327', 'WUXFWdbsVgQ', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (145, 29, 35, 'Jean Biyogo', '+237631257157', 'ID6213522', 'YOroLIhGubc', '2026-10-20');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (146, 36, 2, 'Rachel Etame', '+237640158811', 'ID2903561', 'aRMWKs-EgQQ', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (147, 30, 8, 'Ali Ndzana', '+237649172995', 'ID9537455', 'qpwP0vxe6pg', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (148, 46, 20, 'Nadège Ndzana', '+237642713008', 'ID8663605', 'LiLet66ffzs', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (149, 36, 12, 'Pierre Owona', '+237628321839', 'ID2171218', 'dzrQWuON7Tk', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (150, 18, 28, 'Blaise Kamga', '+237610344303', 'ID5745250', 'x9fejJHJemo', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (151, 47, 22, 'Ibrahim Ndzana', '+237629944139', 'ID8491822', 'CRNqn_x1mHA', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (152, 35, 31, 'Samuel Mvondo', '+237682937948', 'ID7328534', 'xp54n98cW14', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (153, 30, 23, 'Aïcha Ekwalla', '+237641348220', 'ID7891662', '7l--JxZ--zI', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (154, 3, 24, 'David Ekwalla', '+237699078806', 'ID3551903', 'rW1ea9jbYoI', '2026-10-07');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (155, 32, 4, 'Blaise Sone', '+237623470708', 'ID8387112', 'VVOP3Ejd9dA', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (156, 7, 35, 'Jean Mbarga', '+237665026398', 'ID3589751', 'fuf_W8VyBGE', '2026-10-09');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (157, 5, 32, 'Samuel Ekwalla', '+237697219599', 'ID2347467', 'Qm1p_wSouas', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (158, 55, 24, 'Sarah Ekwalla', '+237652501540', 'ID9186400', 'S0rkAIxxl2I', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (159, 56, 36, 'Clarisse Etame', '+237641510328', 'ID5821419', 'cIF4KUmt1zI', '2026-10-21');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (160, 15, 7, 'Fatima Foka', '+237669549527', 'ID3791137', 'JvgUQDT6L4A', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (161, 45, 22, 'Marie Sone', '+237617532195', 'ID5921894', 'rjTTJRb657M', '2026-10-21');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (162, 23, 25, 'Ali Biyogo', '+237681291936', 'ID7913081', 'GLe6UlajoHY', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (163, 37, 12, 'Chantal Etame', '+237691804602', 'ID7418028', 'IdBRUqF7BlU', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (164, 40, 45, 'Nadège Mbarga', '+237641163805', 'ID8736811', 'Iu-O5BeGfZw', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (165, 41, 19, 'Luc Ngono', '+237672445234', 'ID5825658', 'C-l0odUG8_k', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (166, 44, 37, 'Paul Tabi', '+237656381032', 'ID6018975', 'rK3bTvQj5jM', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (167, 41, 31, 'Olivier Talla', '+237636738452', 'ID7454081', 'D2FvNdlEKA8', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (168, 55, 34, 'Aïcha Ekwalla', '+237686762164', 'ID7022335', 'XBpivQTucHY', '2026-10-20');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (169, 37, 21, 'Jean Ekwalla', '+237646840133', 'ID1135861', 'ZFSDCU4Mmmw', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (170, 37, 4, 'Nadège Talla', '+237640885967', 'ID6910964', 'HBb6IU3m5TM', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (171, 15, 15, 'Luc Mbarga', '+237694322033', 'ID2630140', '3jxO5D53G7I', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (172, 58, 44, 'Marie Talla', '+237669166287', 'ID1559763', 'lvKSz_gQA-s', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (173, 38, 27, 'Paul Talla', '+237653851498', 'ID7970985', 'S4WN4kjJ7S8', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (174, 12, 13, 'Sarah Atem', '+237681249799', 'ID9418719', 'HaEUZ9opNOw', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (175, 59, 20, 'Luc Ndzana', '+237649613214', 'ID6682698', '23Z1pEJ-nWs', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (176, 52, 9, 'Paul Mbarga', '+237640281491', 'ID7667458', 'uiOCsga8lfM', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (177, 55, 40, 'Paul Ekwalla', '+237611868130', 'ID5436878', 'eJ3ohzS2Cc4', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (178, 35, 8, 'Esther Kamga', '+237688458327', 'ID7392547', '04nAXp92E7w', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (179, 53, 26, 'Aïcha Ndzana', '+237613358751', 'ID6503032', 'Xku18Ezucl0', '2026-10-20');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (180, 59, 24, 'Paul Tabi', '+237650559278', 'ID7850067', 'zNWDUVY4Ik4', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (181, 8, 9, 'Marie Talla', '+237676118957', 'ID2948178', 'VZXF5Uy4L1E', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (182, 7, 17, 'Ali Ekwalla', '+237670887034', 'ID7224540', 's_CpqMERhHk', '2026-10-08');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (183, 43, 40, 'Ibrahim Mbarga', '+237665684858', 'ID2661307', 'NaP6ljc9jGA', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (184, 54, 34, 'Rachel Kamga', '+237614391105', 'ID7216461', '6G0Th4Fod2A', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (185, 14, 31, 'Aïcha Atem', '+237623335151', 'ID7162857', 'YYYTUlc-6rw', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (186, 35, 24, 'David Kamga', '+237635475673', 'ID3049499', '0QmWGM1eLY8', '2026-10-21');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (187, 55, 33, 'Pierre Ngono', '+237616788532', 'ID6595355', 'OyTOxvscAe0', '2026-10-20');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (188, 16, 9, 'Pierre Etame', '+237684384510', 'ID4475523', '_OiMmKwYHgY', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (189, 38, 16, 'Samuel Mbarga', '+237689991301', 'ID1047572', 'HHKqp15OD0M', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (190, 18, 11, 'Sarah Kamga', '+237633420607', 'ID2844258', 'sV_RQghaRIM', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (191, 43, 2, 'Jean Atem', '+237641934639', 'ID6431983', '0CqzUw3b_jo', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (192, 2, 13, 'Marie Mbarga', '+237666500369', 'ID9826250', '54WFzTAKEro', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (193, 8, 5, 'Olivier Atem', '+237678885632', 'ID2829622', 'v5GeSavYOO4', '2026-10-09');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (194, 29, 20, 'Clarisse Tchoumi', '+237698436473', 'ID9748499', 'YmctFCWCAPo', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (195, 20, 32, 'Jean Tchoumi', '+237674287863', 'ID7738019', '5WyY--UAHUM', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (196, 28, 46, 'Nadège Tabi', '+237619863756', 'ID2355439', 'MekM6w4Lo8o', '2026-10-20');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (197, 21, 40, 'Paul Mbarga', '+237646912022', 'ID6455706', 'hBESf-CWWXc', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (198, 25, 40, 'Grace Tabi', '+237677853916', 'ID8217547', 'FaYT6FkYNV0', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (199, 7, 8, 'Sarah Njoya', '+237667723010', 'ID8575834', 'IyNz9DwedsE', '2026-10-06');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (200, 57, 16, 'Samuel Tabi', '+237663516659', 'ID7979148', 'A04HonuNwTs', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (201, 47, 7, 'Rachel Sone', '+237699269266', 'ID5276341', 'tbCgUn_WN8A', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (202, 24, 10, 'Nadège Etame', '+237622243983', 'ID2432176', 'KFhRiKDTbb4', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (203, 6, 30, 'Esther Mbarga', '+237684674816', 'ID2006313', 'RtHYVdg-0SY', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (204, 38, 42, 'Samuel Foka', '+237665137801', 'ID6932391', '0aFCJdSyMHg', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (205, 56, 45, 'Marie Talla', '+237690585678', 'ID6242022', '6tpO7JMurRA', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (206, 23, 4, 'Blaise Njoya', '+237630767532', 'ID9089795', 'wPmV1zX-ZiA', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (207, 15, 9, 'Sarah Atem', '+237625419645', 'ID5673599', 'jrVnp39WSMw', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (208, 37, 18, 'Sarah Mvondo', '+237613523729', 'ID5487028', 'f7wPbfwkcyI', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (209, 2, 14, 'Grace Sone', '+237657113566', 'ID1102438', 'gSXbHaiG4wQ', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (210, 12, 10, 'David Etame', '+237629042093', 'ID1514340', 'NKgrXnggBwU', '2026-10-09');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (211, 6, 37, 'David Mangue', '+237670887307', 'ID6719285', 'GzGBaofkXPA', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (212, 11, 13, 'Samuel Etame', '+237617061037', 'ID3610197', 'Iqbp2TBemVw', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (213, 11, 32, 'Marie Etame', '+237646521025', 'ID8434202', 'xQfp56vuLCI', '2026-10-08');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (214, 43, 34, 'Clarisse Tabi', '+237665590800', 'ID5582979', 'AQLtC9lb-Og', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (215, 14, 38, 'Esther Mangue', '+237624883373', 'ID5752087', '-vyqQyhAiF0', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (216, 44, 48, 'Nadège Owona', '+237699541016', 'ID6174418', 'taJstFEsXVo', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (217, 3, 17, 'Clarisse Tchoumi', '+237611031743', 'ID4429650', 'HgLuagY41Xo', '2026-10-08');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (218, 20, 14, 'Luc Talla', '+237654039837', 'ID3013003', 'BZ_48mfvAmw', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (219, 1, 33, 'Chantal Mbarga', '+237661030579', 'ID9935249', 'TJe5rD9Y8FI', '2026-10-08');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (220, 46, 16, 'Sarah Atem', '+237619673809', 'ID7661748', 'KBDUy8vvD7U', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (221, 56, 3, 'Jean Tabi', '+237620450542', 'ID6252285', '4gM0euFUasc', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (222, 37, 33, 'David Mangue', '+237648858073', 'ID2932288', 'vIuxaGUzzRU', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (223, 26, 2, 'Chantal Tabi', '+237658567046', 'ID2478574', 'hMRrdbVPynM', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (224, 28, 8, 'Rachel Ekwalla', '+237680325062', 'ID2319479', '9j5Fqt613F4', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (225, 26, 21, 'Aïcha Sone', '+237632566390', 'ID2281433', '8pRWbehGzpc', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (226, 33, 9, 'Blaise Njoya', '+237656892354', 'ID6890476', 'ssjjZUiIG6I', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (227, 47, 35, 'Ali Biyogo', '+237623798190', 'ID3456926', 'aLGuZgPBvQA', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (228, 17, 15, 'Clarisse Mbarga', '+237697980930', 'ID2264218', 'eg-6SFcFUI0', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (229, 12, 43, 'Olivier Tabi', '+237685764804', 'ID6422534', 'Qu6Qerl6QLI', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (230, 56, 44, 'Ali Tabi', '+237619165226', 'ID8867190', 'AR7Z4kqioeU', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (231, 29, 25, 'Luc Tchoumi', '+237657236885', 'ID9511700', '4w8ka8nWIck', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (232, 5, 21, 'Olivier Tchoumi', '+237617635653', 'ID7186390', 'Ffng_7_UOeM', '2026-10-08');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (233, 54, 20, 'Paul Owona', '+237661604364', 'ID8763013', 'dyOe4jO_GPw', '2026-10-20');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (234, 38, 43, 'Olivier Njoya', '+237653154591', 'ID8979730', '6ex3NTKMtBk', '2026-10-21');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (235, 33, 12, 'Olivier Foka', '+237656095437', 'ID2414808', 'jli-P4cl2PY', '2026-10-21');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (236, 33, 15, 'Aïcha Tabi', '+237668978194', 'ID9792411', '1YHAMfQDzo8', '2026-10-21');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (237, 34, 41, 'Esther Atem', '+237647969333', 'ID7499771', 'Lt8BU0echFE', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (238, 27, 23, 'Clarisse Tchoumi', '+237694676162', 'ID6614484', '_opXSOIQAk8', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (239, 5, 11, 'Sarah Ekwalla', '+237648137561', 'ID5227787', 'SJPSrqcGULs', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (240, 47, 32, 'Clarisse Mbarga', '+237654743095', 'ID2367376', 'maL_8G-at7o', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (241, 38, 11, 'Grace Ekwalla', '+237627307598', 'ID2421349', '8aRTQy6AXZs', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (242, 20, 41, 'Samuel Mbarga', '+237699941500', 'ID9831414', '97NKWmx0ZOQ', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (243, 6, 46, 'Rachel Owona', '+237658563745', 'ID1305857', 'qjgfYJpizvM', '2026-10-05');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (244, 24, 21, 'Pierre Sone', '+237675266178', 'ID4221313', 'zKN-earyLoc', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (245, 15, 12, 'Paul Talla', '+237623574883', 'ID9517619', 'TTKTJqA2Jn0', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (246, 50, 38, 'Marie Sone', '+237692950779', 'ID3198638', 'W81PjA0VdNA', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (247, 39, 26, 'Chantal Essomba', '+237693851247', 'ID3777286', 'dJaDw6j41VI', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (248, 47, 17, 'Rachel Atem', '+237641880763', 'ID8452417', 'hjLct10rYXI', '2026-10-21');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (249, 40, 19, 'Aïcha Mvondo', '+237642100652', 'ID6192009', 'Y1BFEB7V81U', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (250, 52, 54, 'Pierre Atem', '+237686560394', 'ID8391997', '8XNO4EFgQYQ', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (251, 30, 20, 'Blaise Owona', '+237666191704', 'ID3718884', '1_9nDu2HEAU', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (252, 53, 15, 'Ali Kamga', '+237617003454', 'ID9062973', '9oqLufnLkf0', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (253, 56, 25, 'Fatima Owona', '+237626733967', 'ID5782563', 'kYjY_YY5oo0', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (254, 6, 11, 'Olivier Owona', '+237629776801', 'ID8339571', 'RN7ZZ2PGhhQ', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (255, 6, 17, 'Esther Ngono', '+237665686520', 'ID1893502', 'UkwkpEwvuWo', '2026-10-08');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (256, 26, 35, 'Aïcha Ekwalla', '+237620952896', 'ID7289990', 'H2PjI2xoJxc', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (257, 15, 2, 'Fatima Sone', '+237629602406', 'ID3308538', 'NBjJoofiDog', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (258, 3, 23, 'Ali Ndzana', '+237670210270', 'ID1088100', 'IDBr7GxeBpI', '2026-10-07');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (259, 58, 8, 'Luc Njoya', '+237630068183', 'ID9854536', 'asWDOSqqUo4', '2026-10-21');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (260, 28, 10, 'Aïcha Talla', '+237626354208', 'ID1801102', 'IU-FIGUKMVU', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (261, 16, 28, 'Clarisse Tabi', '+237618429833', 'ID2859886', 'qzGZZx-H9BI', '2026-10-09');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (262, 54, 37, 'Sarah Ngono', '+237694819556', 'ID9646569', 'n8Xw-2Gf1Y8', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (263, 37, 20, 'Grace Mangue', '+237610209961', 'ID6919270', '4fWDIW8q5WM', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (264, 16, 41, 'Chantal Etame', '+237680260907', 'ID7049927', 'YbTFjQTpA5g', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (265, 5, 19, 'Blaise Owona', '+237684377016', 'ID1341153', '6dcdmwzVC_s', '2026-10-07');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (266, 25, 32, 'David Atem', '+237644044361', 'ID1272499', 'Zxmr2H1ohIc', '2026-10-21');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (267, 23, 30, 'Esther Biyogo', '+237698195059', 'ID2739191', 'FDsPzAptCpQ', '2026-10-20');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (268, 50, 42, 'Ali Tchoumi', '+237657284777', 'ID6679880', 'odnd5ABBXAU', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (269, 53, 24, 'Olivier Ndzana', '+237694790150', 'ID4058117', 'Q-XOhj_bUZc', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (270, 52, 11, 'Olivier Tchoumi', '+237649385195', 'ID4382135', 'YDMFqXd8qMs', '2026-10-20');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (271, 3, 15, 'Samuel Talla', '+237679173614', 'ID7681090', 'l7EPJerw8-8', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (272, 53, 21, 'Luc Tchoumi', '+237696825515', 'ID4206183', 'svnxbTLs2Tg', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (273, 19, 24, 'Samuel Kamga', '+237626706752', 'ID7174337', '5ijQ7Ynn7sE', '2026-10-20');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (274, 28, 29, 'David Sone', '+237635074182', 'ID9324908', 'h4k42xsz__8', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (275, 45, 37, 'Blaise Kamga', '+237621087928', 'ID8121922', 'gaPjhUjykb0', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (276, 6, 33, 'Chantal Mvondo', '+237649428661', 'ID6389033', 'WiU0pHeY_Sk', '2026-10-06');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (277, 7, 6, 'Grace Talla', '+237669849800', 'ID8149041', 'h0T0nTaCLkY', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (278, 11, 29, 'Esther Tabi', '+237615684813', 'ID6914963', 'dh-WX9rym9Q', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (279, 40, 29, 'Marie Etame', '+237695565484', 'ID7815076', '1-0CECHhd-U', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (280, 24, 35, 'Chantal Ngono', '+237629163535', 'ID8351320', 'MmSGjYcVh6s', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (281, 3, 11, 'Aïcha Atem', '+237658607028', 'ID7423230', 'aiE_T2F59OI', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (282, 37, 3, 'Ali Tabi', '+237659790013', 'ID7241348', 'ijaaFRmR7vY', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (283, 29, 30, 'Ibrahim Mbarga', '+237681062902', 'ID7156398', 'SG2H0VfWyZ0', '2026-10-20');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (284, 26, 23, 'Luc Biyogo', '+237625226815', 'ID1434753', '-XsiGvOkyJo', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (285, 48, 13, 'Blaise Ekwalla', '+237685386435', 'ID2975701', 's_sgI8Q0hhE', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (286, 17, 20, 'Pierre Talla', '+237675927774', 'ID4358435', 'kAO_ZL6Ilt8', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (287, 8, 11, 'Olivier Essomba', '+237669741812', 'ID2472884', 'jFXJ93jtI2Q', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (288, 52, 48, 'Esther Etame', '+237683819367', 'ID5871470', 'TEcFEJ4QihU', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (289, 58, 24, 'Chantal Atem', '+237678284040', 'ID4762150', 'Mug3bTNxwzw', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (290, 8, 17, 'Aïcha Ndzana', '+237613527782', 'ID7054838', 'wxMtKeGEgpI', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (291, 36, 42, 'Olivier Mvondo', '+237627417599', 'ID2446455', 'RiU-oeuuB0s', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (292, 5, 10, 'Nadège Owona', '+237665135987', 'ID7869154', 'qABH31XE9KY', '2026-10-09');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (293, 53, 23, 'Ali Sone', '+237696213226', 'ID2244282', '3Ck02fRJF2I', '2026-10-20');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (294, 29, 18, 'Blaise Atem', '+237627224779', 'ID4052834', 'zhpjf25f3hk', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (295, 50, 10, 'Blaise Tchoumi', '+237626664623', 'ID9692311', 'OnLjiVtQulA', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (296, 10, 22, 'Chantal Sone', '+237640262109', 'ID6805303', 'A8dH4Nef4XA', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (297, 34, 19, 'Luc Njoya', '+237695235919', 'ID5604524', 'FxOO6FJVR7Q', '2026-10-20');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (298, 9, 21, 'Sarah Etame', '+237677454225', 'ID3829240', 'cZ0FO71IU_o', '2026-10-07');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (299, 38, 47, 'Chantal Sone', '+237685647532', 'ID1691125', 'PnboKmClW-o', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (300, 53, 35, 'Paul Tchoumi', '+237696094462', 'ID5440189', 'v_M-qWIIVL8', '2026-10-21');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (301, 42, 15, 'Rachel Ngono', '+237676845536', 'ID5859883', 'ITjm8nTvUzU', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (302, 42, 22, 'Aïcha Ekwalla', '+237649920898', 'ID8609207', 'jn5A_ddITNk', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (303, 5, 28, 'Chantal Tabi', '+237665783806', 'ID9124385', 'kbPlPSXUk0E', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (304, 30, 15, 'Clarisse Mbarga', '+237651954112', 'ID6357240', 'nnW8Qs2YeCY', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (305, 47, 34, 'David Mbarga', '+237659733063', 'ID9639932', 'AXkuKKlumLA', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (306, 36, 9, 'Aïcha Tabi', '+237626444612', 'ID5487430', 'RkeqnuIWkto', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (307, 29, 10, 'Fatima Tchoumi', '+237648951595', 'ID7444964', '6719bynyle8', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (308, 56, 46, 'Aïcha Essomba', '+237653947691', 'ID6246485', 'NK1oSKIzzWU', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (309, 13, 12, 'Blaise Tabi', '+237676942394', 'ID6176450', 'pNlsm9oP8vI', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (310, 32, 3, 'David Owona', '+237671368457', 'ID5038756', 'D7E69gvtEBs', '2026-10-20');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (311, 14, 44, 'Marie Tchoumi', '+237647763008', 'ID9302946', 'LOD-D0FHqIs', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (312, 39, 34, 'Sarah Ngono', '+237624428014', 'ID8229768', '40Xza3HjFhQ', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (313, 9, 18, 'David Atem', '+237616072331', 'ID7720644', 'nn02LUQWkGI', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (314, 4, 37, 'Pierre Atem', '+237684252324', 'ID5841933', 'XkS9TkzlPw4', '2026-10-07');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (315, 5, 15, 'Olivier Mvondo', '+237647543473', 'ID2993318', '3D2yh6r0XhE', '2026-10-07');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (316, 9, 7, 'Esther Sone', '+237684870921', 'ID7133857', 'or6vu_MW1V0', '2026-10-10');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (317, 49, 11, 'Clarisse Owona', '+237663873262', 'ID9389915', '4x2PkdI6zV0', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (318, 3, 4, 'Ali Sone', '+237673584863', 'ID9712957', 'Zhem1KCQDqw', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (319, 30, 11, 'Blaise Mbarga', '+237654018830', 'ID6344047', '7HIc8iIZKpA', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (320, 11, 15, 'Grace Sone', '+237678090664', 'ID9551583', 'XhihuW15pYI', '2026-10-08');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (321, 35, 35, 'Grace Ndzana', '+237612232974', 'ID7180018', 'pm4O9-gv9yE', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (322, 22, 47, 'Rachel Talla', '+237694457912', 'ID1447065', 'WwrfjmkUCjE', '2026-10-20');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (323, 39, 36, 'Ibrahim Biyogo', '+237616892773', 'ID9060593', 'I5qJ6BTBF0o', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (324, 11, 21, 'Clarisse Ekwalla', '+237629834119', 'ID5063384', 'XTNuw1DZ7sM', '2026-10-07');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (325, 3, 28, 'Pierre Ngono', '+237669195194', 'ID6262886', '1HK96FdbmWg', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (326, 27, 10, 'Pierre Mangue', '+237677353073', 'ID8912226', 'A5CE_OCN8iw', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (327, 56, 5, 'Blaise Njoya', '+237685280948', 'ID6453426', 'ETGd-pQUZ18', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (328, 43, 38, 'David Sone', '+237633244151', 'ID8711874', 'EXrrWWXkMKo', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (329, 59, 22, 'Sarah Atem', '+237696343485', 'ID5435261', 'eURwLho3pg8', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (330, 40, 33, 'Aïcha Kamga', '+237684905122', 'ID6007984', 'hIl_WUuyTwQ', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (331, 15, 27, 'Pierre Ndzana', '+237652552488', 'ID9049765', 'ldw0tvs9F0A', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (332, 23, 19, 'Grace Foka', '+237686970753', 'ID7370211', '975GU90HltM', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (333, 58, 31, 'Ali Talla', '+237615646068', 'ID5825636', 'ijugMKBkFIU', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (334, 46, 6, 'Olivier Kamga', '+237674300930', 'ID4590102', 'TNBansdxpfk', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (335, 13, 38, 'Sarah Kamga', '+237628424464', 'ID2832517', 'ylRxl2F3h-8', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (336, 40, 54, 'Aïcha Biyogo', '+237616813620', 'ID9909397', 'qMK50Qtwyk8', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (337, 15, 22, 'Fatima Mangue', '+237654331259', 'ID8925622', 'BVk_F4ujbY8', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (338, 7, 11, 'Sarah Essomba', '+237664614193', 'ID8980915', 'xU4JMXr-vYE', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (339, 31, 45, 'Grace Sone', '+237648307798', 'ID1992583', '1c5ZbGYI2wY', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (340, 59, 31, 'Ibrahim Biyogo', '+237681826922', 'ID1625760', 'HA6_itpCBzc', '2026-10-20');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (341, 59, 6, 'Chantal Tchoumi', '+237663283709', 'ID9311162', '-TBUbJyd1v0', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (342, 12, 21, 'Jean Talla', '+237686230551', 'ID2800206', 'n_yb1vlRRyY', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (343, 60, 23, 'Olivier Mvondo', '+237680372842', 'ID9286475', 'w3wP7_nwqO4', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (344, 57, 10, 'Olivier Kamga', '+237635878707', 'ID2889899', '1ufflY4BpgE', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (345, 22, 12, 'Luc Essomba', '+237611890348', 'ID6655803', 'mC28knSIixA', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (346, 51, 19, 'Pierre Essomba', '+237692000924', 'ID7802999', 'kzKfMOGaekU', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (347, 53, 17, 'Samuel Etame', '+237663798927', 'ID2600296', 'kaPBhjXsigE', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (348, 12, 9, 'Samuel Biyogo', '+237610916723', 'ID5375250', 'kDh1NRbcrCk', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (349, 25, 17, 'Luc Sone', '+237650526484', 'ID1191859', 'geVA0EP_2rc', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (350, 17, 25, 'Aïcha Tchoumi', '+237699628735', 'ID2983483', 'jky32ijPV1o', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (351, 30, 26, 'David Owona', '+237651738753', 'ID2969909', 'O_yYwZS_AC4', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (352, 41, 34, 'Esther Biyogo', '+237639410942', 'ID3240912', 'KVl-Qm4oC3w', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (353, 31, 11, 'Clarisse Atem', '+237665813853', 'ID8899184', 'tLZSacZylSg', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (354, 49, 38, 'Pierre Biyogo', '+237689968863', 'ID2373555', 'LUJf3keFBag', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (355, 34, 30, 'Esther Etame', '+237685721444', 'ID2882551', 'Hh0g8YFALwo', '2026-10-13');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (356, 4, 36, 'Pierre Mvondo', '+237630112846', 'ID3760475', 'e5mJAfJZ5as', '2026-10-07');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (357, 21, 35, 'Fatima Njoya', '+237688268756', 'ID9201172', 'zsmP5_dFCD8', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (358, 6, 40, 'Marie Tabi', '+237627709269', 'ID9610869', 'bNLteIdeOAg', '2026-10-08');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (359, 27, 34, 'Marie Mvondo', '+237672059365', 'ID6170227', '4gYHyt0SEUg', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (360, 47, 1, 'Luc Ngono', '+237639246218', 'ID2225232', 'PrZpRsfHpYY', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (361, 3, 20, 'Paul Mvondo', '+237618087373', 'ID2157949', 'M6Y8a6HVC-0', '2026-10-09');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (362, 60, 33, 'Grace Mangue', '+237634156684', 'ID3272119', 'hYN7iDXJJjU', '2026-10-21');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (363, 50, 48, 'Rachel Atem', '+237661335545', 'ID8525204', 'GeEWes8Bjx4', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (364, 56, 28, 'Paul Mvondo', '+237627849589', 'ID6834610', '1v-H7RAj2zs', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (365, 8, 15, 'David Owona', '+237627092236', 'ID4736121', 'z41H6RmCWw8', '2026-10-08');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (366, 54, 1, 'Grace Tabi', '+237683074216', 'ID8115687', 'XXpbpB5gjCQ', '2026-10-21');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (367, 35, 14, 'Aïcha Tabi', '+237656460773', 'ID3602504', 'I8hGNoaO3tI', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (368, 18, 15, 'Marie Mangue', '+237692533595', 'ID1262492', 'In_CMWTc6no', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (369, 16, 15, 'Fatima Tchoumi', '+237669920305', 'ID1816653', 'X1t9Q3y8Z2c', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (370, 16, 55, 'David Tabi', '+237641452485', 'ID4645172', 'zPoyEccf8hQ', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (371, 49, 5, 'Blaise Talla', '+237641428626', 'ID6350316', '5bpjt2ORUZE', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (372, 37, 28, 'Grace Mbarga', '+237698612211', 'ID9745141', 'TfUgV2I9KGU', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (373, 15, 21, 'Luc Tchoumi', '+237684721440', 'ID3938247', 'fRiZ4sH0-5g', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (374, 41, 25, 'Sarah Ndzana', '+237616292676', 'ID6778321', 'o9K4MirO3AE', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (375, 42, 47, 'Blaise Sone', '+237665878146', 'ID7849452', 'ByhgrvsRD5U', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (376, 10, 23, 'Chantal Mvondo', '+237673554620', 'ID5042775', 'Kj0TeTkhMPs', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (377, 55, 16, 'Ali Tabi', '+237617734153', 'ID7923579', 'Mqh4KUsWgxE', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (378, 27, 40, 'David Biyogo', '+237644224936', 'ID4411424', 'znss8n_rt9s', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (379, 22, 46, 'Olivier Atem', '+237622410307', 'ID9986473', 'vuW9tLkLmtU', '2026-10-20');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (380, 47, 9, 'Luc Ekwalla', '+237691197624', 'ID1663497', 'ogUMVYYSkeo', '2026-10-21');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (381, 56, 7, 'Ibrahim Mvondo', '+237639127464', 'ID9042900', 'Tq1eWW5Eekk', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (382, 14, 23, 'Jean Njoya', '+237635504548', 'ID2968239', '2pECkDYPNLg', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (383, 48, 34, 'Clarisse Njoya', '+237663235053', 'ID5015307', 'Hbn2GO41MM0', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (384, 36, 26, 'David Tabi', '+237681625307', 'ID7027375', 'TraqvSBnxWA', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (385, 20, 19, 'Blaise Ndzana', '+237672546007', 'ID2654371', 'puem2znYTls', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (386, 52, 52, 'Samuel Njoya', '+237659755172', 'ID6249960', 'HJsLVQub-7c', '2026-10-14');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (387, 27, 3, 'Aïcha Mbarga', '+237612176998', 'ID5375063', '_qmfwQkHuQI', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (388, 36, 46, 'Rachel Talla', '+237630456313', 'ID4291551', 'Yh94vFUqRP0', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (389, 22, 17, 'Ibrahim Biyogo', '+237677015110', 'ID6663388', 'lsaMsw8GMRY', '2026-10-15');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (390, 17, 30, 'Nadège Tabi', '+237632579937', 'ID6908535', 'AIZWbD8bVoM', '2026-10-12');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (391, 11, 6, 'Nadège Essomba', '+237682764376', 'ID1985360', '4hT-o7UAGPM', '2026-10-09');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (392, 34, 3, 'Marie Ngono', '+237665350347', 'ID3306725', 'uqiJavwltDU', '2026-10-20');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (393, 54, 48, 'Paul Mbarga', '+237611226946', 'ID4669507', 'H_6-fONAk8o', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (394, 33, 34, 'Marie Ndzana', '+237698487646', 'ID9184838', '7uJ1C-Pp7B4', '2026-10-16');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (395, 2, 1, 'Sarah Mangue', '+237611590610', 'ID1280618', '-rRiccUeXHE', '2026-10-06');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (396, 34, 52, 'Sarah Talla', '+237612300840', 'ID9425786', 'e1zyF-h6mdc', '2026-10-17');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (397, 53, 31, 'Rachel Essomba', '+237624363501', 'ID2615878', 'zk0iTUJXkIU', '2026-10-11');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (398, 34, 11, 'Pierre Owona', '+237643878996', 'ID6946534', 'oY9qZrKqyYw', '2026-10-18');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (399, 18, 30, 'Esther Ekwalla', '+237671605634', 'ID5080351', 'Ke9uCLIAvjM', '2026-10-19');
INSERT INTO "billets" (id, voyage_id, numero_siege, nom, telephone, piece_identite, code_reservation, date_achat) VALUES (400, 45, 16, 'Paul Tchoumi', '+237622549425', 'ID7799441', 'XsO88yd_qhA', '2026-10-17');

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
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (1, 1, 1, '2026-10-14', '06:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (2, 2, 2, '2026-10-14', '07:30', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (3, 3, 3, '2026-10-14', '08:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (4, 4, 4, '2026-10-15', '10:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (5, 5, 5, '2026-10-15', '12:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (6, 6, 6, '2026-10-15', '14:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (7, 7, 1, '2026-10-16', '16:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (8, 8, 2, '2026-10-16', '18:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (9, 1, 3, '2026-10-16', '20:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (10, 2, 4, '2026-10-17', '06:00', 'annulé');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (11, 3, 5, '2026-10-17', '07:30', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (12, 4, 6, '2026-10-18', '08:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (13, 5, 1, '2026-10-18', '10:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (14, 6, 2, '2026-10-18', '12:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (15, 7, 3, '2026-10-19', '14:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (16, 8, 4, '2026-10-19', '16:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (17, 1, 5, '2026-10-19', '18:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (18, 2, 6, '2026-10-20', '20:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (19, 3, 1, '2026-10-20', '06:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (20, 4, 2, '2026-10-20', '07:30', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (21, 5, 3, '2026-10-21', '08:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (22, 6, 4, '2026-10-21', '10:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (23, 7, 5, '2026-10-22', '12:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (24, 8, 6, '2026-10-22', '14:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (25, 1, 1, '2026-10-22', '16:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (26, 2, 2, '2026-10-23', '18:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (27, 3, 3, '2026-10-23', '20:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (28, 4, 4, '2026-10-23', '06:00', 'annulé');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (29, 5, 5, '2026-10-24', '07:30', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (30, 6, 6, '2026-10-24', '08:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (31, 7, 1, '2026-10-25', '10:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (32, 8, 2, '2026-10-25', '12:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (33, 1, 3, '2026-10-25', '14:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (34, 2, 4, '2026-10-26', '16:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (35, 3, 5, '2026-10-26', '18:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (36, 4, 6, '2026-10-26', '20:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (37, 5, 1, '2026-10-27', '06:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (38, 6, 2, '2026-10-27', '07:30', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (39, 7, 3, '2026-10-27', '08:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (40, 8, 4, '2026-10-28', '10:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (41, 1, 5, '2026-10-28', '12:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (42, 2, 6, '2026-10-29', '14:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (43, 3, 1, '2026-10-29', '16:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (44, 4, 2, '2026-10-29', '18:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (45, 5, 3, '2026-10-30', '20:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (46, 6, 4, '2026-10-30', '06:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (47, 7, 5, '2026-10-30', '07:30', 'annulé');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (48, 8, 6, '2026-10-31', '08:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (49, 1, 1, '2026-10-31', '10:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (50, 2, 2, '2026-10-31', '12:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (51, 3, 3, '2026-11-01', '14:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (52, 4, 4, '2026-11-01', '16:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (53, 5, 5, '2026-11-02', '18:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (54, 6, 6, '2026-11-02', '20:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (55, 7, 1, '2026-11-02', '06:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (56, 8, 2, '2026-11-03', '07:30', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (57, 1, 3, '2026-11-03', '08:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (58, 2, 4, '2026-11-03', '10:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (59, 3, 5, '2026-11-04', '12:00', 'prévu');
INSERT INTO "voyages" (id, trajet_id, bus_id, date, heure, statut) VALUES (60, 4, 6, '2026-11-04', '14:00', 'prévu');

COMMIT;
PRAGMA foreign_keys = ON;
