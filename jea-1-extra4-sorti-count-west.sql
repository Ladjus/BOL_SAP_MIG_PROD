-- Count ar.extra4 & ar.q_saps4_sortiment i mallbolaget och väst.

SELECT
  ar_2000.extra4,
  ar_2000.q_saps4_sortiment,
  COUNT(ar_2000.artnr) AS antal_2000,  -- Antal i mallbolag
  COUNT(ar_9100.artnr) AS antal_9100  -- Antal i PacsOn Väst
FROM ar AS ar_2000
  LEFT OUTER JOIN ar AS ar_9100
    ON ar_2000.artnr = ar_9100.artnr
    AND ar_9100.ForetagKod = 9100  -- Väst
WHERE
  ar_2000.ForetagKod = 2000  -- Mall
GROUP BY
  ar_2000.extra4,
  ar_2000.q_saps4_sortiment
ORDER BY
  ar_2000.extra4,
  ar_2000.q_saps4_sortiment;

-- END
