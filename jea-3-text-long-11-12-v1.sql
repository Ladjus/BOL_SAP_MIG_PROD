-- Jeeves extract article data.
-- Singelartikel, behåller artikelnummer = 11; AI "Variant/produkt" = S Singelartikel utan "kompisar".
-- Singelartikel m PH2, behåller artikelnummer = 12; AI "Variant/produkt" = P Singelartiklar som ska hållas ihop som en produkt i Artikelhierarki 2.

/* Change log
v.1: Initial version. CTE cte_artnr for artnr synched from jea-2-mara-makt-mean-11-12-v3.sql. Refer:
     dev-ecom-3-text-long-11-12-v4.sql
     
*/

-- Ecom articles from Jeeves.
-- Singelartikel, behåller artikelnummer = 11; AI "Variant/produkt" = S Singelartikel utan "kompisar".
-- Singelartikel m PH2, behåller artikelnummer = 12; AI "Variant/produkt" = P Singelartiklar som ska hållas ihop som en produkt i Artikelhierarki 2.

/* Change log
v.1: Initial.
v.2: Column MARA_RUN_ID correction.
     Column PRODUCT_RUN_ID correction.
v.3: TRIM() instead of LTRIM(RTRIM()).
v.4: Intern text AR.q_interntext ==> Internal note (IVER) only Swedish. 2026-03-17
*/

-- (1) Product (mandatory) [S_MARA]
WITH cte_artnr AS (
  SELECT artnr
  FROM ar
  WHERE
    ForetagKod = 2000  -- Mall
    AND extra4 IN (11, 12)
)
SELECT
  ar.artnr AS AR_ArtNr,  -- Jeeves "Artikel ID"
  ar.artbeskrspec AS MARA_PRODUCT,  -- SAP Product. Jeeves "Artikelnr"
  CAST(GETDATE() AS date) AS MARA_RUN_ID
FROM ar
WHERE
  ar.foretagkod = 2000  -- Mall
  AND ar.artnr IN (SELECT artnr FROM cte_artnr)  -- AR.extra4 subquery. Change v.1.
ORDER BY 2;

-- (2) Product Text [S_PRODUCT]
-- Basic text (GRUN).
-- Internal note (IVER)
-- Not in v.1: Purchase text (BEST), Inspection text (PRUE).
-- English (en) UNION ALL Swedish (sv).
WITH cte_artnr AS (
  SELECT artnr
  FROM ar
  WHERE
    ForetagKod = 2000  -- Mall
    AND extra4 IN (11, 12)
)
SELECT
  ar.artnr AS AR_ArtNr,  -- Jeeves "Artikel ID"
  ar.artbeskrspec AS MARA_PRODUCT,  -- SAP Product. Jeeves "Artikelnr"
  CAST(GETDATE() AS date) AS PRODUCT_RUN_ID,
  'GRUN' AS PRODUCT_TDID,  -- SAP Text ID: Basic text (GRUN)
  'EN' AS PRODUCT_TDSPRAS,  -- SAP language key English
  CONCAT(TRIM(ar.artbeskr), ' ', TRIM(ar.artbeskr2)) AS PRODUCT_LONGTEXT
FROM ar
WHERE
  ar.foretagkod = 2000  -- Mall
  AND ar.artnr IN (SELECT artnr FROM cte_artnr)  -- AR.extra4 subquery. Change v.1.

UNION ALL  -- No duplicates

SELECT
  ar.artnr AS AR_ArtNr,  -- Jeeves "Artikel ID"
  ar.artbeskrspec AS MARA_PRODUCT,  -- SAP Product. Jeeves "Artikelnr"
  CAST(GETDATE() AS date) AS PRODUCT_RUN_ID,
  'GRUN' AS PRODUCT_TDID,  -- SAP Text ID: Basic text (GRUN)
  'SV' AS PRODUCT_TDSPRAS,  -- SAP language key Swedish
  CONCAT(TRIM(ar.artbeskr), ' ', TRIM(ar.artbeskr2)) AS PRODUCT_LONGTEXT
FROM ar
WHERE
  ar.foretagkod = 2000  -- Mall
  AND ar.artnr IN (SELECT artnr FROM cte_artnr)  -- AR.extra4 subquery. Change v.1.

UNION ALL  -- No duplicates

SELECT
  ar.artnr AS AR_ArtNr,  -- Jeeves "Artikel ID"
  ar.artbeskrspec AS MARA_PRODUCT,  -- SAP Product. Jeeves "Artikelnr"
  CAST(GETDATE() AS date) AS PRODUCT_RUN_ID,
  'IVER' AS PRODUCT_TDID,  -- SAP Text ID: Internal note (IVER)
  'SV' AS PRODUCT_TDSPRAS,  -- SAP language key Swedish
  TRIM(ar.q_interntext) AS PRODUCT_LONGTEXT  -- Jeeves Interntext, nvarchar(100) nullable
FROM ar
WHERE
  ar.foretagkod = 2000  -- Mall
  AND ar.artnr IN (SELECT artnr FROM cte_artnr)  -- AR.extra4 subquery. Change v.1.
  AND LEN(TRIM(COALESCE(ar.q_interntext, ''))) > 0  -- Only if filled.

ORDER BY 2, 4, 5;

-- (3) "MRP text" tab, structure S_MDTXT
-- N/A v.4.

-- (4) "Sales text" tab, structure S_MVKE
-- N/A v.4.

-- END