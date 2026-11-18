SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRANSACTION;

SELECT
    ar2000.artnr,
    ar2000.artbeskrspec,
    ar2000.q_saps4_sortiment AS Sortiment_2000,
    ar9500.q_saps4_sortiment AS Sortiment_9500_Fore
FROM ar AS ar2000
INNER JOIN ar AS ar9500
    ON ar9500.artnr = ar2000.artnr
   AND ar9500.foretagkod = 9500
WHERE ar2000.foretagkod = 2000
  AND LTRIM(RTRIM(ar2000.q_saps4_sortiment)) IN ('A', 'B', 'C')
  AND ISNULL(LTRIM(RTRIM(ar9500.q_saps4_sortiment)), '') <>
      LTRIM(RTRIM(ar2000.q_saps4_sortiment))
ORDER BY ar2000.artnr;


UPDATE ar9500
SET ar9500.q_saps4_sortiment =
    LTRIM(RTRIM(ar2000.q_saps4_sortiment))
FROM ar AS ar9500
INNER JOIN ar AS ar2000
    ON ar2000.artnr = ar9500.artnr
   AND ar2000.foretagkod = 2000
WHERE ar9500.foretagkod = 9500
  AND LTRIM(RTRIM(ar2000.q_saps4_sortiment)) IN ('A', 'B', 'C')
  AND ISNULL(LTRIM(RTRIM(ar9500.q_saps4_sortiment)), '') <>
      LTRIM(RTRIM(ar2000.q_saps4_sortiment));

PRINT 'Antal uppdaterade rader i bolag 9500: '
      + CAST(@@ROWCOUNT AS VARCHAR(20));

COMMIT TRANSACTION;
PRINT 'ROLLBACK genomförd för bolag 9500. Ingen data sparades.';

-- COMMIT TRANSACTION;