-- ============================================================
-- E-COMMERCE SALES ANALYSIS — SQL REPRODUCIBILITY | Phase 3
-- Base : month2_data | Table : online_retail
-- ============================================================
-- Rappels :
--   Annulations   → InvoiceNo LIKE 'C%'
--   Hors-produit  → description IN ('DOTCOM POSTAGE','POSTAGE','SAMPLES','Manual','AMAZON FEE')
--   Anonymes      → customer_id = 'Unknown'
--   TotalPrice    → déjà calculé dans le dataset nettoyé (total_price)
--   Période valid → janvier 2011 → novembre 2011 (décembres exclus)
-- ============================================================

create view vrais_produits as
select *
From online_retail t 
where t.description not in (
    'DOTCOM POSTAGE',
    'POSTAGE',
    'SAMPLES',
    'Manual',
    'AMAZON FEE'
);

create view ventes_reelles as
select *
From online_retail t 
where invoice_no not like 'C%' and t.description not in (
    'DOTCOM POSTAGE',
    'POSTAGE',
    'SAMPLES',
    'Manual',
    'AMAZON FEE'
);

create view periode_valide as
select *
From online_retail t 
where t.description not in (
    'DOTCOM POSTAGE',
    'POSTAGE',
    'SAMPLES',
    'Manual',
    'AMAZON FEE'
) and t."year" = 2011 and t."month" between 1 and 11;


--- fatcure distinctes et factures annulées-----------
select total_factures ,
       annulations,
       round(100*(annulations/total_factures), 2) as taux_annulation
from (
      select
             COUNT(distinct invoice_no) as total_factures,
             COUNT(distinct invoice_no) filter (where invoice_no like 'C%') as annulations
      from vrais_produits) as table_taux


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
select sum(total_price)
from vrais_produits

-- Q02 — Quelle est la valeur moyenne par commande ?
--        (Une facture = un InvoiceNo. Sommer le total_price par facture,
--         puis faire la moyenne. Exclure les factures annulées InvoiceNo LIKE 'C%'.)

select avg (totalprice)
from ( select sum(total_price) as totalprice
       from ventes_reelles
       group by invoice_no ) as subqueries

       --- OU --
SELECT 
    SUM(total_price) / COUNT(DISTINCT invoice_no) AS valeur_moyenne_commande
FROM ventes_reelles;
-- ------------------------------------------------------------
-- 1.2 Top produits
-- ------------------------------------------------------------

-- Q03 — Quels sont les 20 produits qui génèrent le plus de CA ?
--        Afficher aussi : nb transactions, nb commandes distinctes,
--        dépense moyenne, taux d'annulation.
--        (Reproduire le tableau récapitulatif complet de la Phase 3.)

select 
    description,
    sum(total_price)                                                        as ca_produit,
    count(invoice_no)                                                       as nb_transactions,
    count(distinct invoice_no) filter (where invoice_no not like 'C%')     AS nb_commandes,
    avg(total_price) filter (where invoice_no not like 'C%')               AS depense_moyenne,
    round(100.0 * count(distinct invoice_no) filter (where invoice_no like 'C%')
    / count(distinct invoice_no), 2)                                        AS taux_annulation
from vrais_produits
group by description
order by ca_produit DESC
limit 20;

-- Q04 — Quel est le produit le plus commandé (le plus de commandes distinctes) ?
select description,
       count(distinct invoice_no) as nb_commandes
from ventes_reelles
group by description 
order by nb_commandes desc 
limit 1

-- WHITE HANGING HEART T-LIGHT HOLDER

-- Q05 — Quel est le produit avec la plus forte dépense moyenne par ligne de commande ?

select description,
       avg(total_price) as dep_moyenne
from ventes_reelles
group by description 
order by dep_moyenne desc 
limit 1

-- PAPER CRAFT , LITTLE BIRDIE

-- ------------------------------------------------------------
-- 1.3 Annulations
-- ------------------------------------------------------------

-- Q06 — Pour chaque description hors-produit (POSTAGE, AMAZON FEE, SAMPLES,
--        Manual, DOTCOM POSTAGE) : combien de lignes existent dans la table,
--        et combien sont des annulations ?
--        (Vérification qui avait justifié leur isolation plutôt que leur suppression.)

select t.description,
       count(*) as nb_lignes,
       count(*) filter (where invoice_no  like 'C%')  as annulees
from online_retail
where t.description in (
    'DOTCOM POSTAGE',
    'POSTAGE',
    'SAMPLES',
    'Manual',
    'AMAZON FEE'
)
group by description
order by nb_lignes desc

-- Q07 — Quels sont les produits avec le taux d'annulation le plus élevé,
--        parmi ceux qui ont au minimum 10 transactions ?
--        (Le filtre sur 10 transactions évite les taux artificiellement élevés
--         sur 1 ou 2 lignes.)

select description,
       round(100.0 * count(distinct invoice_no) filter (where invoice_no like 'C%')
    / count(distinct invoice_no), 2)                                        AS taux_annulation
from vrais_produits
group by description
having count(invoice_no) >= 10
order by taux_annulation desc

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

select 
    country,
    sum(total_price)                                                        as ca_pays,
    count(distinct invoice_no)                                              as nb_commandes,
    count(invoice_no)                                                       as nb_transactions,
    round(100.0 * count(distinct invoice_no) filter (where invoice_no like 'C%')
    / count(distinct invoice_no), 2)                                        AS taux_annulation
from vrais_produits
group by country
order by ca_pays DESC


-- Q09 — Quelle est la part du Royaume-Uni dans le CA global (en pourcentage) ?
--        (Utiliser une sous-requête ou un CTE pour calculer le CA total,
--         puis diviser le CA UK par ce total.)
select  
    country,
    round(100.0 * sum(total_price) / (select sum(total_price) from vrais_produits), 2) as part_ca
from vrais_produits
where country = 'United Kingdom'
group by country;


-- Q10 — Quel pays a le taux d'annulation le plus élevé ?
--        Combien de commandes distinctes ce pays a-t-il passé au total ?
--        (Ne pas filtrer sur un minimum de commandes — l'anomalie doit apparaître telle quelle.)
select country,
       count(distinct invoice_no)                    as nb_commandes,
       round(100.0 * count(distinct invoice_no) filter (where invoice_no like 'C%')
               /count(distinct invoice_no), 2)                 AS taux_annulation
from vrais_produits
group by country
order by taux_annulation desc
limit 1


-- ------------------------------------------------------------
-- 2.2 Clients
-- ------------------------------------------------------------

-- Q11 — Quels sont les 20 clients classés par CA décroissant ?
--        Afficher : CA, nb commandes, taux d'annulation.

select 
    customer_id ,
    sum(total_price)                                                        as ca_client,
    count(distinct invoice_no)                                              as nb_commandes,
    round(100.0 * count(distinct invoice_no) filter (where invoice_no like 'C%')
    / count(distinct invoice_no), 2)                                        AS taux_annulation
from vrais_produits
group by customer_id 
order by ca_client desc
limit 20

-- Q12 — Quel segment de clients génère le plus de CA et passe le plus de commandes ?
--        (La réponse est dans les données — ne pas présupposer.)
-- Segment Unknown
select customer_id, 
       sum(total_price) as ca_total, 
       count(DISTINCT invoice_no) as nb_commandes
from vrais_produits
where customer_id = 'Unknown'
group by customer_id;

-- Clients identifiés
select customer_id, 
       sum(total_price) as ca_total, 
       count(distinct invoice_no) as nb_commandes
from vrais_produits
where customer_id != 'Unknown'
group by customer_id
order by ca_total DESC
limit 1;


-- ------------------------------------------------------------
-- 2.3 Investigation clients Unknown
-- ------------------------------------------------------------

-- Q13 — Pour chaque pays : CA, nb commandes distinctes, nb transactions
--        et nb produits distincts générés par les clients Unknown.

select 
    country,
    sum(total_price)                       as ca_client_unknown,
    count(invoice_no )                     as nb_transactions,
    count(distinct invoice_no)             as nb_commandes,
    count(distinct description)            as nb_produits                        
from vrais_produits
where customer_id = 'Unknown'
group by country
order by ca_client_unknown desc 


-- Q14 — Pour chaque pays : quelle est la part du CA des Unknown
--        dans le CA total de ce pays (en pourcentage) ?
--        (Utiliser un CTE ou une sous-requête pour le CA total par pays, puis jointure.)
with ca_total_pays as (
    select country,
           sum(total_price) as ca_pays
    from vrais_produits
    group by country
),
ca_unknown_pays as (
    select country,
           sum(total_price) as ca_unknown
    from vrais_produits
    where customer_id = 'Unknown'
    group by country
)
select 
    t.country,
    t.ca_pays,
    u.ca_unknown,
    round(100.0 * u.ca_unknown / t.ca_pays, 2) as part_unknown
from ca_total_pays t
join ca_unknown_pays u on t.country = u.country
order by part_unknown desc;


-- Q15 — Quel pays a 100% de ses clients dans le segment Unknown ?
with compte as (
   select 
        country,
        count (distinct vp.customer_id )                                              as nb_client,
        count (distinct vp.customer_id ) filter (where vp.customer_id = 'Unknown')    as nb_inconnus
   from vrais_produits vp 
   group by vp.country 
   order by nb_client desc
)

select country,
       nb_client,
       nb_inconnus
from compte
where nb_client = nb_inconnus

-- Q16 — Pour le pays dont tous les clients sont Unknown :
--        vérifier en listant toutes ses transactions.
select *
from vrais_produits
where country = 'Hong Kong'
order by invoice_no;



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

select 
      vp."year",
      max(vp.invoice_date) as date_fin,
      min(vp.invoice_date ) as date_debut,
      count(distinct date(vp.invoice_date ) ) as jours_couvert
from vrais_produits vp 
where vp."year" in (2010,2011) and vp."month" = 12
group by "year" 
-- ------------------------------------------------------------
-- 3.2 Analyse mensuelle (janv–nov 2011)
-- ------------------------------------------------------------

-- Q18 — Pour chaque mois de janvier à novembre 2011 :
--        CA total, nb commandes distinctes, nb transactions.
--        Trier par CA décroissant.

select  pv."month" as mois,
        sum(pv.total_price ) as CA_total,
        count (distinct pv.invoice_no )   as  nb_commandes,
        count (pv.invoice_no )   as  nb_transactions
from periode_valide pv 
group by mois
order by ca_total  desc

-- Q19 — Quels sont les 3 mois les plus lucratifs ? Quel est leur CA ?

select  pv."month" as mois,
        sum(pv.total_price ) as CA_total
from periode_valide pv 
group by mois
order by ca_total  desc
limit 3

-- Q20 — Pour chaque mois : calculer le ratio moyen de transactions par commande.
--        (Ratio = nb_transactions / nb_commandes. Doit être stable autour de 20.)

select  pv."month" as mois,
        sum(pv.total_price ) as CA_total,
        round(count (pv.invoice_no )/ count (distinct pv.invoice_no ), 2 ) as ratio
from periode_valide pv 
group by mois
order by ca_total  desc


-- ------------------------------------------------------------
-- 3.3 Analyse par jour de la semaine
-- ------------------------------------------------------------

-- Q21 — Pour chaque jour de la semaine : combien de commandes distinctes
--        ont été passées ? Trier par volume décroissant.

select  pv."day" as jour,
        count (distinct pv.invoice_no )   as  nb_commandes
from periode_valide pv 
group by jour
order by nb_commandes   desc

-- Q22 — Quel est l'écart en nb commandes entre le jour le plus actif
--        et le jour le moins actif ?

select 
      count(distinct pv.invoice_no) filter (where pv."day" = 'Thursday') -
      count(distinct pv.invoice_no) filter (where pv."day" = 'Sunday') as ratio
from periode_valide pv 


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
with ca_total as (
   select sum(total_price) as total
   from vrais_produits
)
select vp.description as produit,
       sum(vp.total_price )                                   as ca_produit,
       round(100.0 * sum(vp.total_price) / ct.total, 2)       as part_ca
from vrais_produits vp 
cross join ca_total ct
group by vp.description, ct.total
order by ca_produit DESC
LIMIT 5;

-- Q24 — En une seule requête : quels sont les 5 pays qui génèrent
--        le plus de CA (UK inclus), avec leur part dans le CA global ?

with ca_total as (
   select sum(total_price) as total
   from vrais_produits
)
select vp.country  as pays,
       sum(vp.total_price )                                   as ca_pays,
       round(100.0 * sum(vp.total_price) / ct.total, 2)       as part_ca
from vrais_produits vp 
cross join ca_total ct
group by vp.country , ct.total
order by ca_pays DESC
LIMIT 5;

-- ------------------------------------------------------------
-- 4.2 Comportement client
-- ------------------------------------------------------------

-- Q25 — Parmi les clients identifiés (hors Unknown) :
--        les 5 clients avec le CA le plus élevé,
--        ET les 5 clients avec le plus de commandes.
--        Est-ce que les deux listes se recoupent ?
--        (Deux requêtes séparées suffisent.)

-- Q25a — Top 5 clients par CA
select 
    customer_id ,
    sum(total_price)  as ca_client               
from vrais_produits
where customer_id != 'Unknown'
group by customer_id 
order by ca_client desc 

-- Q25b — Top 5 clients par nb commandes
select 
    customer_id ,
    count(distinct invoice_no ) as nb_commandes             
from vrais_produits
where customer_id != 'Unknown'
group by customer_id 
order by nb_commandes  desc 


-- Q26 — Taux d'annulation global du segment Unknown,
--        comparé au taux d'annulation des clients identifiés.

-- ======== clients connus ===========
select 
    round(100.0 * count(distinct invoice_no) filter (where invoice_no like 'C%')
    / count(distinct invoice_no), 2)                                        AS taux_annulation_connus
from vrais_produits
where customer_id != 'Unknown'


-- ======== clients inconnus ===========
select 
    round(100.0 * count(distinct invoice_no) filter (where invoice_no like 'C%')
    / count(distinct invoice_no), 2)                                        AS taux_annulation_connus
from vrais_produits
where customer_id = 'Unknown'


-- ------------------------------------------------------------
-- 4.3 Vérification des hypothèses
-- ------------------------------------------------------------

-- Q27 — Confirmer que le Royaume-Uni est le pays avec le plus
--        de transactions et de commandes.

select 
      country,
      count(distinct vp.invoice_no) as nb_commandes,
      count(vp.invoice_no ) as nb_transaction
from vrais_produits vp 
group by country 
order by nb_transaction desc , nb_commandes desc
limit 1

-- Q28 — Confirmer que septembre, octobre et novembre dépassent
--        1 million de livres de CA.

select  pv."month" as mois,
        sum(pv.total_price ) as CA_total
from periode_valide pv 
group by mois
having sum(pv.total_price ) > 1000000



-- Q29 — Taux d'annulation global de la boutique,
--        puis taux d'annulation pour les USA spécifiquement.
--        Mettre les deux en regard.
--        (Illustre pourquoi un taux global 'faible' peut masquer des anomalies locales.)

select 
    round(100.0 * count(distinct invoice_no) filter (where invoice_no like 'C%')
    / count(distinct invoice_no), 2)                                        as taux_annulation_global,
    round(100.0 * count(distinct invoice_no) filter (where invoice_no like 'C%' and country = 'USA')
    / count(distinct invoice_no) filter (where country = 'USA'), 2) as taux_usa
from vrais_produits

-- ============================================================
-- BONUS — Pour aller plus loin
-- ============================================================

-- BONUS — Une requête unique avec plusieurs CTEs reproduisant
--          l'intégralité du tableau de synthèse :
--          produit | CA | nb_commandes | taux_annulation | rang_CA
--          pour les 20 premiers produits.


