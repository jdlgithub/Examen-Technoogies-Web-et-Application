# Feature Specification: Réservation de billets de bus interurbains

**Feature Branch**: `001-bus-ticket-reservation`

**Created**: 2026-10-20

**Status**: Draft

**Input**: User description: "Application web de vente de billets de bus interurbains pour une agence de voyage reliant Douala, Yaoundé, Bafoussam, Kribi et Buea. Les voyageurs cherchent un voyage, choisissent leur siège sur le plan du bus, achètent leur billet et reçoivent un code de réservation ; ils peuvent retrouver leur billet avec ce code. Un espace d'administration protégé permet de programmer les voyages, d'afficher la liste imprimable des passagers et d'annuler un voyage. Des statistiques de remplissage, de recette et de fréquentation sont exposées. Charte graphique professionnelle : blanc, gris, noir, police Roboto. Priorité au code source fonctionnel avant les livrables (README, diaporama, captures, vidéo)."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Rechercher un voyage et voir les places restantes (Priority: P1)

Un visiteur indique sa ville de départ, sa ville d'arrivée et la date voulue.
Le système affiche les voyages disponibles ce jour-là : heure de départ,
durée, prix (classique et VIP), type de bus et nombre de places encore
disponibles. Les voyages complets, annulés ou déjà partis n'apparaissent pas
comme achetables.

**Why this priority** : sans recherche, aucun voyageur ne peut ni voir ni
acheter un billet ; c'est la porte d'entrée de tout le service et le
prérequis de l'achat.

**Independent Test** : on saisit « Douala → Yaoundé, demain » et on vérifie
que la liste affiche des voyages avec un décompte de places restantes
cohérent avec les billets déjà vendus dans les données de test.

**Acceptance Scenarios**:

1. **Given** des voyages programmés Douala→Yaoundé demain avec des places
   libres, **When** le visiteur lance la recherche avec ces critères,
   **Then** il voit chaque voyage correspondant avec heure, durée, prix et
   places restantes.
2. **Given** aucun voyage programmé Bafoussam→Kribi à une date donnée,
   **When** le visiteur lance cette recherche, **Then** un message
   clair indique qu'aucun voyage ne correspond.
3. **Given** un voyage complet (0 place), **When** le visiteur lance la
   recherche, **Then** le voyage n'est pas proposé à l'achat (ou est
   clairement signalé complet).

---

### User Story 2 - Choisir son siège et acheter un billet (Priority: P1)

Le voyageur sélectionne un voyage, voit le plan du bus dessiné à l'écran
avec les sièges déjà vendus grisés et non sélectionnables, choisit un siège
libre, remplit ses informations (nom, téléphone, numéro de pièce
d'identité) et valide l'achat. Le système enregistre le billet et affiche un
code de réservation unique, impossible à deviner.

**Why this priority** : c'est le cœur métier du sujet — vendre un billet
avec choix du siège. Sans lui, l'application n'a pas de raison d'être.

**Independent Test** : on choisit un siège libre, on paie pas (simple
réservation), on reçoit un code ; le même siège redevient immédiatement
grisé et un second achat du même siège pour le même voyage est refusé.

**Acceptance Scenarios**:

1. **Given** un voyage avec places libres, **When** le voyageur choisit un
   siège et valide le formulaire complet, **Then** le billet est enregistré,
   le siège apparaît vendu et un code de réservation unique s'affiche.
2. **Given** un siège déjà vendu pour ce voyage, **When** un second
   visiteur tente de l'acheter (même en contournant l'interface), **Then**
   la vente est refusée avec un message explicite.
3. **Given** un formulaire incomplet ou un numéro de téléphone invalide,
   **When** le voyageur valide, **Then** l'envoi est bloqué côté client et
   côté serveur avec un message de champ concerné.
4. **Given** un numéro de siège hors capacité du bus, **When** la demande
   arrive, **Then** elle est refusée.

---

### User Story 3 - Retrouver son billet avec son code (Priority: P2)

Le voyageur saisit le code de réservation reçu à l'achat. Le système
affiche son billet : voyage, date, heure, siège, nom du passager. Un code
inconnu ou malformé renvoie un message d'erreur compréhensible.

**Why this priority** : valeur immédiate pour le voyageur sans compte ni
connexion ; indispensable à l'usage réel du billet, mais secondaire par
rapport à la vente elle-même.

**Independent Test** : avec un code généré à l'achat, on retrouve le billet
correspondant ; avec « XYZ123 » on obtient un message d'erreur, pas une
page d'exception.

**Acceptance Scenarios**:

1. **Given** un billet acheté avec code C, **When** le voyageur saisit C
   dans le formulaire de recherche de billet, **Then** son billet complet
   s'affiche.
2. **Given** un code inexistant, **When** on le saisit, **Then** un message
   « code introuvable » s'affiche.

---

### User Story 4 - Espace d'administration : connexion et programmation des voyages (Priority: P2)

L'administrateur se connecte avec un compte protégé (mot de passe
chiffré). Il programme de nouveaux voyages : trajet, bus, date, heure de
départ. Sans connexion, l'espace d'administration est totalement inaccessible.

**Why this priority** : l'agence doit alimenter l'offre de voyages ; sans
programmation, il n'y a rien à vendre. Priorité P2 car l'offre de
démonstration existe via les données de test.

**Independent Test** : on tente d'ouvrir une page d'administration sans
session → accès refusé ; connecté, on crée un voyage et il apparaît dans
la recherche publique.

**Acceptance Scenarios**:

1. **Given** aucun utilisateur connecté, **When** on ouvre l'URL d'un espace
   d'administration, **Then** l'accès est refusé et on est redirigé vers la
   connexion.
2. **Given** un admin connecté, **When** il valide un formulaire de
   programmation (trajet, bus, date, heure), **Then** le voyage est créé
   avec le statut « prévu » et visible dans la recherche.
3. **Given** un mot de passe erroné, **When** on tente la connexion,
   **Then** elle échoue avec un message clair.

---

### User Story 5 - Liste des passagers imprimable et annulation d'un voyage (Priority: P2)

L'administrateur ouvre la liste des passagers d'un voyage : nom, siège,
téléphone, code — mise en page proprement imprimable. Il peut annuler un
voyage : le voyage passe à « annulé », n'est plus achetable et disparaît
des résultats de recherche.

**Why this priority** : opérations quotidiennes de l'agence (embarquement,
gestion des annulations) ; dépend de l'existence de voyages et de billets.

**Independent Test** : on génère la liste des passagers d'un voyage chargé
(400 billets répartis) et on l'imprime ; on annule un voyage et on vérifie
qu'il n'est plus achetable.

**Acceptance Scenarios**:

1. **Given** un voyage avec plusieurs billets, **When** l'admin ouvre la
   liste des passagers, **Then** tous les passagers apparaissent avec
   siège, téléphone et code, dans une mise en page dédiée à l'impression.
2. **Given** un voyage au statut « prévu », **When** l'admin l'annule
   (action en POST), **Then** le statut devient « annulé » et le voyage
   n'est plus achetable.
3. **Given** un voyage déjà annulé, **When** un visiteur lance une
   recherche, **Then** ce voyage n'est pas proposé.

---

### User Story 6 - Statistiques de l'activité (Priority: P3)

L'application expose les statistiques d'exploitation : taux de remplissage
moyen par trajet, recette par trajet et par semaine, heures de départ les
plus demandées, nombre de billets vendus par jour sur les 14 derniers
jours. Les chiffres sont calculés à partir des données réelles.

**Why this priority** : valeur de pilotage pour l'agence et exigence du
sujet, mais n'empêche pas de vendre des billets ; traitée après le
parcours complet voyageur et admin.

**Independent Test** : on compare les statistiques affichées à un
recalcul manuel sur un échantillon de billets ; les valeurs coïncident.

**Acceptance Scenarios**:

1. **Given** des billets vendus sur plusieurs trajets et semaines,
   **When** on consulte les statistiques, **Then** remplissage, recette,
   heures de pointe et billets des 14 derniers jours sont cohérents avec
   les données.
2. **Given** une base sans billet sur une période, **When** on consulte
   les statistiques, **Then** les valeurs sont à zéro sans erreur.

---

### Edge Cases

- Deux voyageurs choisissent le même siège presque simultanément : le
  second achat doit être refusé (impossible d'avoir deux billets pour le
  même siège et le même voyage).
- Saisie d'un numéro de siège > nombre de places du bus ou ≤ 0 : refus
  côté serveur.
- Code de réservation saisie avec faute de frappe : message « code
  introuvable », jamais une erreur technique.
- Voyage annulé alors que des billets existent : le voyage n'est plus
  achetable ; l'annulation reste enregistrée.
- Bus dont la capacité change après programmation : les sièges vendus
  restent valables tant qu'ils sont ≤ capacité ; nouvelle vente refusée au
 -delà.
- Date de voyage passée ou voyage au statut « parti » : plus d'achat
  possible.
- Formulaire d'achat vidé ou rempli de caractères invalides : bloqué côté
  client et côté serveur.
- Tentative d'accès à l'administration sans session ou avec session
  expirée : refus systématique.
- Recherche sur une ville ou une date sans aucun voyage : message vide
  clair, pas d'erreur 500.

## Requirements *(mandatory)*

### Functional Requirements

**Parcours public**

- **FR-001**: Le système MUST permettre de rechercher un voyage par ville
  de départ, ville d'arrivée et date, et afficher pour chaque résultat
  l'heure de départ, la durée, le prix (classique et VIP selon le bus) et
  le nombre de places restantes.
- **FR-002**: Le système MUST afficher le plan du bus sous forme de grille
  interactive avec les sièges vendus grisés et non sélectionnables, les
  sièges libres sélectionnables, numérotés de 1 à la capacité du bus.
- **FR-003**: Le système MUST permettre l'achat d'un billet (nom, numéro de
  téléphone, numéro de pièce d'identité, siège choisi) et MUST afficher à
  l'issue un code de réservation unique, généré de façon non devinable.
- **FR-004**: Le système MUST interdire qu'un même siège soit vendu deux
  fois pour un même voyage, y compris en cas de tentative simultanée ou de
  contournement de l'interface.
- **FR-005**: Le système MUST accepter un numéro de siège que s'il est
  compris entre 1 et le nombre de places du bus, sinon refuser avec un
  message clair.
- **FR-006**: Le système MUST permettre de retrouver un billet à partir de
  son code de réservation seul (sans compte) et afficher voyage, date,
  heure, siège et passager ; un code inconnu MUST renvoyer un message
  d'erreur compréhensible.
- **FR-007**: Seuls les voyages au statut « prévu » avec au moins une
  place libre et une date non passée MUST être achetables.

**Espace d'administration**

- **FR-008**: Le système MUST exiger une connexion pour tout l'espace
  d'administration ; sans session valide, tout accès MUST être refusé.
- **FR-009**: Le système MUST stocker les mots de passe administrateur sous
  forme d'empreinte irréversible (jamais en clair).
- **FR-010**: L'administrateur connecté MUST pouvoir programmer un voyage
  (trajet, bus, date, heure de départ) avec le statut « prévu ».
- **FR-011**: L'administrateur MUST pouvoir afficher la liste des
  passagers d'un voyage (nom, téléphone, siège, code) dans une mise en
  page imprimable.
- **FR-012**: L'administrateur MUST pouvoir annuler un voyage ; le voyage
  passe au statut « annulé » et cesse d'être achetable. Toute annulation
  ou modification administrateur MUST se faire par une action confirmée
  (pas de modification par simple visite d'une page).

**Données, API et JavaScript**

- **FR-013**: Le système MUST exposer au moins deux jeux de données
  consultables par le navigateur au format JSON : l'état des sièges d'un
  voyage (alimentant le plan des sièges, rafraîchi sans rechargement de
  page) et les statistiques.
- **FR-014**: Le système MUST calculer et exposer : taux de remplissage
  moyen par trajet, recette par trajet et par semaine, heures de départ
  les plus demandées, billets vendus par jour sur les 14 derniers jours.
- **FR-015**: Le navigateur MUST valider le formulaire d'achat avant
  l'envoi ; le serveur MUST revérifier systématiquement toutes les
  données reçues (aucune donnée n'est crue sur parole au client).
- **FR-016**: Le système MUST être peuplé par un jeu de données de test
  d'au moins : 8 trajets, 6 bus, 60 voyages répartis sur trois semaines,
  400 billets, plus un compte administrateur de test.

**Qualité et identité visuelle**

- **FR-017**: Toutes les pages MUST respecter une charte graphique
  professionnelle : palette blanc / gris / noir, police Roboto, rendu
  classique et épuré, cohérent sur toutes les pages.
- **FR-018**: Le site MUST être confortable sur téléphone comme sur
  ordinateur (mise en page adaptative, navigation utilisable au doigt).
- **FR-019**: Les pages MUST être sémantiques et accessibles : un texte
  alternatif sur chaque image, un libellé sur chaque champ de formulaire,
  page d'erreur 404 personnalisée, messages de confirmation/erreur
  visibles par l'utilisateur.
- **FR-020**: Le code source MUST être fonctionnel de bout en bout avant
  toute production de livrables (README, diaporama, captures, vidéo).

### Key Entities

- **Trajet** : lien entre deux villes parmi Douala, Yaoundé, Bafoussam,
  Kribi, Buea ; attributs : ville de départ, ville d'arrivée, durée,
  prix classique, prix VIP.
- **Bus** : véhicule affecté aux voyages ; attributs : immatriculation
  unique, nombre de places, type (classique ou VIP).
- **Voyage** : trajet effectué par un bus à une date et une heure ;
  attributs : trajet, bus, date, heure de départ, statut (prévu, parti,
  annulé).
- **Billet** : place vendue sur un voyage ; attributs : voyage, numéro de
  siège, nom du voyageur, téléphone, numéro de pièce d'identité, code de
  réservation unique, date d'achat. Relation : plusieurs billets
  appartiennent à un voyage ; un billet porte sur un trajet (via le
  voyage) et un bus (via le voyage).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Un voyageur sans aide peut terminer le parcours complet
  recherche → choix du siège → achat → réception du code en moins de
  3 minutes.
- **SC-002**: Sur l'ensemble du jeu de données de test (400 billets,
  60 voyages), le nombre de sièges vendus deux fois pour un même voyage
  est exactement 0.
- **SC-003**: Un voyageur retrouve son billet avec son code en moins
  d'une minute, et un code erroné produit un message d'erreur compréhensible
  dans 100 % des cas.
- **SC-004**: 100 % des tentatives d'accès à l'administration sans
  session valide se soldent par un refus d'accès.
- **SC-005**: Les statistiques affichées coïncident à 100 % avec un
  recalcul manuel sur un échantillon de 10 voyages tirés au sort.
- **SC-006**: L'ensemble des parcours (visiteur et administrateur) est
  réalisable sur un écran de téléphone de 360 px de large sans défilement
  horizontal ni action impossible.
- **SC-007**: Un évaluateur peut lancer le site sur un ordinateur neuf en
  suivant uniquement la documentation fournie, sans aide humaine.
- **SC-008**: Les trois semaines de voyages test sont exploitées :
  100 % des 60 voyages sont consultables et les volumes minimums
  (8 trajets, 6 bus, 400 billets) sont atteints.

## Assumptions

- **Environnement imposé par le porteur du projet** (contrainte de
  commanditaire, non un choix de conception) : application réalisée en
  Python 3.12, Flask et SQLite ; aucune autre technologie serveur.
- Aucun paiement en ligne : « acheter » signifie enregistrer la réservation
  et éditer le code ; aucun flux bancaire n'est géré (hors sujet).
- Interface entièrement en français.
- Villes desservies fixes : Douala, Yaoundé, Bafoussam, Kribi, Buea ;
  les trajets proposés sont un sous-ensemble de ces villes (≥ 8 trajets).
- Un seul compte administrateur de test suffit ; il est créé par le jeu de
  données de démonstration.
- Les sièges sont numérotés linéairement de 1 à la capacité du bus ; le
  plan du bus est une grille simple (pas de disposition réelle du véhicule).
- Le prix d'un billet est fixé par le type du bus du voyage (classique ou
  VIP) selon le tarif du trajet.
- Les statuts « prévu / parti / annulé » sont gérés manuellement ou par
  date passée ; aucune automatisation avancée de statut n'est exigée.
- Les bonus du sujet (billet imprimable avec QR code, réduction
  aller-retour) sont hors périmètre tant que le minimum obligatoire n'est
  pas intégralement fonctionnel.
- La priorité explicite du commanditaire : le code source fonctionnel est
  livré et vérifié avant toute production de livrables (README,
  diaporama, captures, vidéo), sans exception.
