-- Count ar.extra4 i mallbolaget.

SELECT
  extra4,
  count(*) AS antal
FROM ar
WHERE ForetagKod = 2000  -- Mallbolaget
GROUP BY extra4
ORDER BY extra4;

-- END