-- Count ar.extra4 & ar.q_saps4_sortiment i mallbolaget.

SELECT
  ForetagKod,
  extra4,
  q_saps4_sortiment,
  count(*) AS antal
FROM ar
WHERE ForetagKod = 2000  -- Mallbolaget
GROUP BY ForetagKod, extra4, q_saps4_sortiment
ORDER BY ForetagKod, extra4, q_saps4_sortiment;

-- END