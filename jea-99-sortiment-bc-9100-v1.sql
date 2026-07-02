-- Test SQL för att se hur man kan få (a) hela A-sortimentet, (b) hela B-sortimentet, (c) Västs C-sortiment i en select från mallbolaget.

WITH cte_artnr_west AS (
  SELECT artnr
  FROM ar AS ar_2000
    LEFT OUTER JOIN ar AS ar_9100
      ON ar_2000.artnr = ar_9100.artnr
      AND ar_9100.ForetagKod = 9100  -- Väst
  WHERE
    ar_2000.ForetagKod = 2000  -- Mall
--    AND ar_2000.extra4 IN (11, 12)
    AND (ar_2000.q_saps4_sortiment NOT IN ('B', 'C')  -- Ej B/C-sortiment, tag alla artiklar.
         OR (ar_2000.q_saps4_sortiment IN ('B', 'C') AND ar_9100.artnr IS NOT NULL))  -- B/C-sortiment, tag endast de som finns i Väst.
)
SELECT
  ar.ForetagKod,
  ar.q_saps4_sortiment,
  count(1) AS antal
FROM ar
WHERE
  ar.ForetagKod = 2000  -- Mall
  AND ar.artnr IN (SELECT artnr FROM cte_artnr_west)  -- AR.extra4 subquery.
GROUP BY ForetagKod, q_saps4_sortiment
ORDER BY ForetagKod, q_saps4_sortiment;


-- END