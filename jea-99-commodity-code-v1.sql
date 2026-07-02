-- Jeeves article data.

/* Change log
v.1: Initial version. Refer:
     dev-ecom-99-commodity-code-v3.sql
     Column INFO_EXTRA4 added.
*/

WITH cte_artnr AS (
    SELECT artnr
    FROM ar
    WHERE ForetagKod = 2000  -- Mall
      AND extra4 > 0.0  -- Mig-flag set.
)
SELECT
  ar_2000.artnr AS AR_ArtNr,  -- Jeeves "Artikel ID"
  ar_2000.artbeskrspec AS MARITC_MATNR,  -- SAP Product. Jeeves "Artikelnr"
  CONCAT(CAST(ars.ForetagKod AS nvarchar(4)), '#', TRIM(ars.LagStalle)) AS MARITC_PLANT,  -- SAP plant
  ar_2000.artstatnr AS MARITC_COMCO,  -- SAP commodity code
  ar_2000.extra4 AS INFO_EXTRA4  -- Migration flag
FROM
  ar AS ar_2000  -- Mall
  INNER JOIN ar AS ar_op  -- Operativa bolag
    ON ar_2000.artnr = ar_op.artnr
    AND ar_2000.ForetagKod = 2000  -- Mall
    AND ar_op.ForetagKod IN (6000, 9100, 9400, 9500)  -- ÖVNS
  INNER JOIN ars
    ON ars.foretagkod = ar_op.foretagkod
    AND ars.artnr = ar_op.artnr
WHERE
  -- Specifika lager: ARS.ForetagKod (smallint) och ARS.LagStalle (char)
  -- Ref: "PacsOn Org structure_Final_2.xlsx" URL https://optigroup.sharepoint.com/sites/ASAP-Projektplats/Shared%20Documents/ASAP-%20Projektplats/Arkitektur%20&%20Teknisk%20upps%C3%A4ttning/Org.%20struktur/Pacson%20Org%20structure_Final_2.xlsx
  (  ( ars.ForetagKod = 6000 AND ars.LagStalle IN ('20', '30', '101', '102') )  -- Öst
  OR ( ars.ForetagKod = 9100 AND ars.LagStalle IN ('5000') )  -- Väst
  OR ( ars.ForetagKod = 9400 AND ars.LagStalle IN ('0', '2', '4', '5', '6') )  -- Norr
  OR ( ars.ForetagKod = 9500 AND ars.LagStalle IN ('0', '5', '6', '7', '8') )  -- Syd
  )
  AND ar_2000.artnr IN (SELECT artnr FROM cte_artnr)  -- AR.extra4 subquery
  AND ar_2000.artstatnr IS NOT NULL
ORDER BY 2, 3;

-- END