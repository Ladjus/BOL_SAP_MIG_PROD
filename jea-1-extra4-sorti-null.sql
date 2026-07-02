-- Jeeves articles to migrate, extra4 > 0, but missing assortment.

SELECT
  ar.Foretagkod,
  ar.artnr,  -- Jeeves "Artikel ID"
  CONCAT('_', ar.artnr) AS _artnr,  -- Jeeves "Artikel ID". Preserve leading zero in excel
  ar.artbeskrspec,  -- SAP Product. Jeeves "Artikelnr"
  CONCAT('_', ar.artbeskrspec) AS _artbeskrspec,    -- SAP Product. Jeeves "Artikelnr". Preserve leading zero in excel
  ar.artbeskr,
  ar.artbeskr2,
  ar.enhetskod,
  ar.itemstatuscode,  -- Jeeves "Artikelstatus"
  ar.extra4,
  ar.q_saps4_sortiment
FROM ar
WHERE
  ar.ForetagKod = 2000  -- Mallbolaget
  AND ar.extra4 > 0
--  AND ar.q_saps4_sortiment NOT IN ('A', 'B', 'C');  -- NULL or junk; fails for NULL!
  AND (ar.q_saps4_sortiment IS NULL  -- NULL
       OR ar.q_saps4_sortiment NOT IN ('A', 'B', 'C'))  -- or junk
ORDER BY 1, 2;

-- END