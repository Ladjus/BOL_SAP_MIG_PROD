-- Jeeves extract article data.
-- !!!PacsOn Väst 9100 only!!!
-- extra4 = 51: Artiklar med global data från ECC och lokal data från Jeeves.

/* Change log
v.1: Inital version. Select only A-assortment plus B/C for PacsOn Väst. Refer:
     dev-ecom-3-mara-11-12-v2.sql
     jea-99-sortiment-bc-9100-v1.sql
     Column MARA_RUN_ID use fixed value 'WEST'. Problem w date is that same article may get multiple records with different dates, then it's a mess. (Only EWM-product makes sense to have separately.)
v.2: Inkludera endast artiklar som finns i Falköping (5000).
v.3: CTE cte_artnr_west: Select A/B-assortment plus C for PacsOn Väst.
v.4: Inkludera artiklar i Väst även om de inte finns i Falköping (5000), undo v.2. Remove INNER JOIN ars and WHERE-condition.
     !!! Fork from jea-5-mara-21-w-v4.sql to jea-7-mara-51-w-v4.sql for articles with extra4 = 51 !!!
     Include Jeeves assortment values DA, DB, DC for duplicates of ECC articles.
     Column MARA_PRODUCT gets Pacudo-nr to match POI ECC (not: artbeskrspec, "Artikelnr").
*/

WITH cte_artnr_west AS (
  SELECT ar_2000.artnr
  FROM ar AS ar_2000
    LEFT OUTER JOIN ar AS ar_9100
      ON ar_2000.artnr = ar_9100.artnr
      AND ar_9100.ForetagKod = 9100  -- Väst
  WHERE
    ar_2000.ForetagKod = 2000  -- Mall
    AND ar_2000.extra4 IN (51)  -- Change v.4.
/* Remove v.3.
    AND (ar_2000.q_saps4_sortiment NOT IN ('B', 'C')  -- Ej B/C-sortiment: alla artiklar.
         OR (ar_2000.q_saps4_sortiment IN ('B', 'C') AND ar_9100.artnr IS NOT NULL))  -- B/C-sortiment: endast artiklar som finns i Väst 9100.
*/
    AND (ar_2000.q_saps4_sortiment IN ('A', 'B', 'DA', 'DB')  -- A/B-sortiment: alla artiklar. Change v.3. Change v.4.
         OR (ar_2000.q_saps4_sortiment IN ('C', 'DC') AND ar_9100.artnr IS NOT NULL))  -- C-sortiment: endast artiklar som finns i Väst 9100. Change v.3. Change v.4.
)
SELECT DISTINCT
  ar_2000.artnr AS AR_ArtNr,  -- Jeeves "Artikel ID". Change v.2 _2000
--  ar_2000.artbeskrspec AS MARA_PRODUCT,  -- SAP Product. Jeeves "Artikelnr". Change v.2 _2000. Remove v.4.
  ar_2000.q_artnr_pacudo AS MARA_PRODUCT,  -- SAP Product. Jeeves "Pacudo ArtNr". Add v.4.
--  CAST(GETDATE() AS date) AS MARA_RUN_ID  -- Remove v.1.
  'WEST' AS MARA_RUN_ID  -- Add v.1.
FROM  -- Refer MARC-query but without AL-table.
  ar AS ar_2000  -- Mall
  INNER JOIN ar AS ar_op  -- Operativa bolag
    ON ar_2000.artnr = ar_op.artnr
    AND ar_2000.ForetagKod = 2000  -- Mall
--  AND ar_op.ForetagKod IN (6000, 9100, 9400, 9500)  -- ÖVNS. Remove v.1.
    AND ar_op.ForetagKod IN (9100)  -- Väst. Add v.1.
/* Remove v.4.
  INNER JOIN ars
    ON ars.foretagkod = ar_op.foretagkod
    AND ars.artnr = ar_op.artnr
*/
WHERE
  -- Specifika lager: ARS.ForetagKod (smallint) och ARS.LagStalle (nvarchar(16))
  -- Ref: "PacsOn Org structure_Final_2.xlsx" URL https://optigroup.sharepoint.com/sites/ASAP-Projektplats/Shared%20Documents/ASAP-%20Projektplats/Arkitektur%20&%20Teknisk%20upps%C3%A4ttning/Org.%20struktur/Pacson%20Org%20structure_Final_2.xlsx
/* Remove v.1.
  (  (ars.ForetagKod = 6000 AND ars.LagStalle IN ('20', '30', '101', '102') )  -- Öst
  OR (ars.ForetagKod = 9100 AND ars.LagStalle IN ('5000') )  -- Väst
  OR (ars.ForetagKod = 9400 AND ars.LagStalle IN ('0', '2', '4', '5', '6') )  -- Norr
  OR (ars.ForetagKod = 9500 AND ars.LagStalle IN ('0', '5', '6', '7', '8') )  -- Syd
  )
*/
--  (ars.ForetagKod = 9100 AND ars.LagStalle IN ('5000') )  -- Väst. Add v.1. Remove v.4.
--  AND  -- Remove v.4.
  ar_2000.artnr IN (SELECT artnr FROM cte_artnr_west)  -- AR.extra4 subquery. Change v.1

ORDER BY 2;

-- END
