SELECT
    arMal.foretagkod AS Bolag,
    ar2000.q_saps4_sortiment AS Sortiment_2000,
    COUNT(*) AS Antal_att_uppdatera
FROM ar AS ar2000
INNER JOIN ar AS arMal
    ON arMal.artnr = ar2000.artnr
   AND arMal.foretagkod IN (9100, 6000, 9400, 9500)
WHERE ar2000.foretagkod = 2000
  AND LTRIM(RTRIM(ar2000.q_saps4_sortiment)) IN ('A', 'B', 'C')
  AND ISNULL(LTRIM(RTRIM(arMal.q_saps4_sortiment)), '') <>
      LTRIM(RTRIM(ar2000.q_saps4_sortiment))
GROUP BY
    arMal.foretagkod,
    ar2000.q_saps4_sortiment
ORDER BY
    arMal.foretagkod,
    ar2000.q_saps4_sortiment;