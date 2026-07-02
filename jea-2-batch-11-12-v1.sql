-- Jeeves extract article data.
-- Singelartikel, behåller artikelnummer = 11; AI "Variant/produkt" = S Singelartikel utan "kompisar".
-- Singelartikel m PH2, behåller artikelnummer = 12; AI "Variant/produkt" = P Singelartiklar som ska hållas ihop som en produkt i Artikelhierarki 2.

-- Migration Object: Batch unique at material and client level

/* Change log
v.1: Initial version.

*/

WITH cte_artnr AS (
  SELECT artnr
  FROM ar
  WHERE
    ForetagKod = 2000  -- Mall
    AND extra4 IN (11, 12)
)
-- Batch Basic Data (mandatory) [S_BATCH]
SELECT
  ar_2000.artnr AS AR_ArtNr,  -- Jeeves "Artikel ID"
  ar_2000.artbeskrspec AS BATCH_MATERIAL,  -- SAP Product. Jeeves "Artikelnr"
  'MIG0000001' AS BATCH_BATCH,  -- SAP Batch Number
  CONCAT(TRIM(ar_2000.artbeskr), ' ', TRIM(ar_2000.artbeskr2)) AS INFO_ARTBESKR1_2
FROM
  ar AS ar_2000
WHERE
  ar_2000.foretagkod = 2000  -- Mall
  AND ar_2000.artnr IN (SELECT artnr FROM cte_artnr)  -- AR.extra4 subquery.
  AND ar_2000.q_livsmedelgodkand = '1'  -- Jeeves boolean TRUE
ORDER BY 2;

-- END