SET NOCOUNT ON;

DECLARE @AntalRader INT = 1;
DECLARE @TotaltAntal INT = 0;
DECLARE @Batchstorlek INT = 100;

WHILE @AntalRader > 0
BEGIN
    UPDATE TOP (@Batchstorlek) ar9400
    SET ar9400.q_saps4_sortiment = ar2000.q_saps4_sortiment
    FROM ar AS ar9400
    INNER JOIN ar AS ar2000
        ON ar2000.artnr = ar9400.artnr
       AND ar2000.foretagkod = 2000
    WHERE ar9400.foretagkod = 9400
      AND NULLIF(LTRIM(RTRIM(ar2000.q_saps4_sortiment)), '') IS NOT NULL
      AND NULLIF(LTRIM(RTRIM(ar9400.q_saps4_sortiment)), '') IS NULL;

    SET @AntalRader = @@ROWCOUNT;
    SET @TotaltAntal = @TotaltAntal + @AntalRader;

    RAISERROR(
        'Uppdaterat %d rader i denna batch. Totalt klart: %d',
        0,
        1,
        @AntalRader,
        @TotaltAntal
    ) WITH NOWAIT;
END;

RAISERROR(
    'Klart! Totalt uppdaterades %d artiklar.',
    0,
    1,
    @TotaltAntal
) WITH NOWAIT;