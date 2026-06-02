-- ============================================================
-- E-COMMERCE SALES ANALYSIS — SQL REPRODUCIBILITY | Phase 3
-- Base : data_month2 | Table : online_retail
-- ============================================================
-- Rappels :
--   Annulations   → InvoiceNo LIKE 'C%'
--   Hors-produit  → description IN ('DOTCOM POSTAGE','POSTAGE','SAMPLES','Manual','AMAZON FEE')
--   Anonymes      → customer_id = 'Unknown'
--   TotalPrice    → déjà calculé dans le dataset nettoyé (total_price)
--   Période valid → janvier 2011 → novembre 2011 (décembres exclus)
-- ============================================================


-- ============================================================
-- 1. DIMENSION PRODUITS
-- Reproduire l'analyse de la colonne description — hors-produit exclus
-- ============================================================

-- ------------------------------------------------------------
-- 1.1 Métriques globales
-- ------------------------------------------------------------

-- Q01 — Quel est le chiffre d'affaires global de la boutique,
--        toutes transactions confondues ?
--        (Penser à exclure les descriptions hors-produit avant d'agréger.)



-- Q02 — Quelle est la valeur moyenne par commande ?
--        (Une facture = un InvoiceNo. Sommer le total_price par facture,
--         puis faire la moyenne. Exclure les factures annulées InvoiceNo LIKE 'C%'.)



-- ------------------------------------------------------------
-- 1.2 Top produits
-- ------------------------------------------------------------

-- Q03 — Quels sont les 20 produits qui génèrent le plus de CA ?
--        Afficher aussi : nb transactions, nb commandes distinctes,
--        dépense moyenne, taux d'annulation.
--        (Reproduire le tableau récapitulatif complet de la Phase 3.)



-- Q04 — Quel est le produit le plus commandé (le plus de commandes distinctes) ?



-- Q05 — Quel est le produit avec la plus forte dépense moyenne par ligne de commande ?
--        (Attention : la dépense moyenne inclut les lignes annulées.
--         Croiser avec le taux d'annulation.)



-- ------------------------------------------------------------
-- 1.3 Annulations
-- ------------------------------------------------------------

-- Q06 — Pour chaque description hors-produit (POSTAGE, AMAZON FEE, SAMPLES,
--        Manual, DOTCOM POSTAGE) : combien de lignes existent dans la table,
--        et combien sont des annulations ?
--        (Vérification qui avait justifié leur isolation plutôt que leur suppression.)



-- Q07 — Quels sont les produits avec le taux d'annulation le plus élevé,
--        parmi ceux qui ont au minimum 10 transactions ?
--        (Le filtre sur 10 transactions évite les taux artificiellement élevés
--         sur 1 ou 2 lignes.)




-- ============================================================
-- 2. DIMENSION CLIENTS & GÉOGRAPHIE
-- Reproduire l'analyse par customer_id et country — hors-produit exclus
-- ============================================================

-- ------------------------------------------------------------
-- 2.1 Géographie — par pays
-- ------------------------------------------------------------

-- Q08 — Quels sont les 30 pays classés par CA décroissant ?
--        Afficher aussi : nb commandes distinctes, nb transactions,
--        taux d'annulation par pays.



-- Q09 — Quelle est la part du Royaume-Uni dans le CA global (en pourcentage) ?
--        (Utiliser une sous-requête ou un CTE pour calculer le CA total,
--         puis diviser le CA UK par ce total.)



-- Q10 — Quel pays a le taux d'annulation le plus élevé ?
--        Combien de commandes distinctes ce pays a-t-il passé au total ?
--        (Ne pas filtrer sur un minimum de commandes — l'anomalie doit apparaître telle quelle.)



-- ------------------------------------------------------------
-- 2.2 Clients
-- ------------------------------------------------------------

-- Q11 — Quels sont les 20 clients classés par CA décroissant ?
--        Afficher : CA, nb commandes, taux d'annulation.



-- Q12 — Quel segment de clients génère le plus de CA et passe le plus de commandes ?
--        (La réponse est dans les données — ne pas présupposer.)



-- ------------------------------------------------------------
-- 2.3 Investigation clients Unknown
-- ------------------------------------------------------------

-- Q13 — Pour chaque pays : CA, nb commandes distinctes, nb transactions
--        et nb produits distincts générés par les clients Unknown.



-- Q14 — Pour chaque pays : quelle est la part du CA des Unknown
--        dans le CA total de ce pays (en pourcentage) ?
--        (Utiliser un CTE ou une sous-requête pour le CA total par pays, puis jointure.)



-- Q15 — Quel pays a 100% de ses clients dans le segment Unknown ?



-- Q16 — Pour le pays dont tous les clients sont Unknown :
--        vérifier en listant toutes ses transactions.




-- ============================================================
-- 3. DIMENSION TEMPORELLE
-- Reproduire l'analyse par période — décembres 2010 et 2011 exclus
-- Période valide : janvier 2011 → novembre 2011
-- ============================================================

-- ------------------------------------------------------------
-- 3.1 Vérification des périodes
-- ------------------------------------------------------------

-- Q17 — Pour décembre 2010 et décembre 2011 :
--        quelle est la date de début et de fin des transactions,
--        et combien de jours distincts sont couverts ?
--        (Requête qui justifie leur exclusion de l'analyse mensuelle.)



-- ------------------------------------------------------------
-- 3.2 Analyse mensuelle (janv–nov 2011)
-- ------------------------------------------------------------

-- Q18 — Pour chaque mois de janvier à novembre 2011 :
--        CA total, nb commandes distinctes, nb transactions.
--        Trier par CA décroissant.



-- Q19 — Quels sont les 3 mois les plus lucratifs ? Quel est leur CA ?



-- Q20 — Pour chaque mois : calculer le ratio moyen de transactions par commande.
--        (Ratio = nb_transactions / nb_commandes. Doit être stable autour de 20.)



-- ------------------------------------------------------------
-- 3.3 Analyse par jour de la semaine
-- ------------------------------------------------------------

-- Q21 — Pour chaque jour de la semaine : combien de commandes distinctes
--        ont été passées ? Trier par volume décroissant.
--        (La colonne 'day' contient un entier. Utiliser CASE WHEN ou TO_CHAR
--         selon la représentation dans la table.)



-- Q22 — Quel est l'écart en nb commandes entre le jour le plus actif
--        et le jour le moins actif ?




-- ============================================================
-- 4. QUESTIONS DE SYNTHÈSE
-- Reproduire les réponses aux 3 problématiques business en SQL
-- ============================================================

-- ------------------------------------------------------------
-- 4.1 Analyse des revenus
-- ------------------------------------------------------------

-- Q23 — En une seule requête : quels sont les 5 produits qui génèrent
--        le plus de CA, avec leur part dans le CA global ?
--        (Utiliser une fenêtre analytique SUM() OVER() ou un CTE.)



-- Q24 — En une seule requête : quels sont les 5 pays qui génèrent
--        le plus de CA (UK inclus), avec leur part dans le CA global ?



-- ------------------------------------------------------------
-- 4.2 Comportement client
-- ------------------------------------------------------------

-- Q25 — Parmi les clients identifiés (hors Unknown) :
--        les 5 clients avec le CA le plus élevé,
--        ET les 5 clients avec le plus de commandes.
--        Est-ce que les deux listes se recoupent ?
--        (Deux requêtes séparées suffisent.)

-- Q25a — Top 5 clients par CA


-- Q25b — Top 5 clients par nb commandes


-- Q26 — Taux d'annulation global du segment Unknown,
--        comparé au taux d'annulation des clients identifiés.



-- ------------------------------------------------------------
-- 4.3 Vérification des hypothèses
-- ------------------------------------------------------------

-- Q27 — Confirmer que le Royaume-Uni est le pays avec le plus
--        de transactions et de commandes.



-- Q28 — Confirmer que septembre, octobre et novembre dépassent
--        1 million de livres de CA.



-- Q29 — Taux d'annulation global de la boutique,
--        puis taux d'annulation pour les USA spécifiquement.
--        Mettre les deux en regard.
--        (Illustre pourquoi un taux global 'faible' peut masquer des anomalies locales.)




-- ============================================================
-- BONUS — Pour aller plus loin
-- ============================================================

-- BONUS — Une requête unique avec plusieurs CTEs reproduisant
--          l'intégralité du tableau de synthèse :
--          produit | CA | nb_commandes | taux_annulation | rang_CA
--          pour les 20 premiers produits.


