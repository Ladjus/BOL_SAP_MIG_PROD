DECLARE @KopInnanDatum date = '2026-08-11';

SELECT
     fr.ftgnr [Ftgnr]
    ,fr.ftgnamn [Företagsnamn]

    /* Senaste order som kolumn 3 */
    ,oh1.orddatumMax [Senaste order]

    ,fr.rowcreatedby [Skapad av]
    ,fr.rowcreateddt [Skapad datum]

    /* Kontaktperson */
    ,kontakt.FtgKontaktNr AS [KontaktNr]
    ,kontakt.FtgPerson AS [Kontaktperson]

    /* Telefon */
    ,kontakt.TelefonDirekt AS [Telefon direkt]
    ,kontakt.Telefon1 AS [Telefon 1]
    ,kontakt.Telefon2 AS [Telefon 2]

    /* Mejl */
    ,kontakt.PersonligMejl AS [Personlig mejl]
    ,kontakt.ForetagsMejl AS [Företagsmejl]
    ,COALESCE(kontakt.PersonligMejl, kontakt.ForetagsMejl) AS [Mejl]

    ,kontakt.q_kp_default_vid_order AS [Standardkontakt order]

    ,CASE 
        WHEN kus.ftgnr IS NULL
            THEN 'Nej'
        ELSE 'Ja'
     END [Är kund]

    ,CASE 
        WHEN le.ftgnr IS NULL
            THEN 'Nej'
        ELSE 'Ja'
     END [Är leverantör]

    ,oh2.orddatumMax [Senaste order med Lev.plats]

    /* Senaste order oavsett vanlig kund eller leveransplats */
    ,CASE
        WHEN oh1.orddatumMax IS NULL THEN oh2.orddatumMax
        WHEN oh2.orddatumMax IS NULL THEN oh1.orddatumMax
        WHEN oh1.orddatumMax >= oh2.orddatumMax THEN oh1.orddatumMax
        ELSE oh2.orddatumMax
     END AS [Senaste köp]

    ,ofh1.offertdatumMax [Senaste Offert]
    ,bh1.[Beställningsdatum MAX] [Senaste Beställning]
    ,lr.[LevFaktDat MAX] AS [Senaste Levfaktura]

    ,CASE 
        WHEN oh1.orddatumMax IS NULL
            AND oh2.orddatumMax IS NULL
            AND ofh1.offertdatumMax IS NULL
            THEN 'Nej'
        ELSE 'Ja'
     END [Har använts i order/offert]

FROM fr WITH (READUNCOMMITTED)


/* =========================================================
   KUND
   ========================================================= */
LEFT OUTER JOIN kus WITH (READUNCOMMITTED)
    ON kus.foretagkod = fr.foretagkod
    AND kus.ftgnr = fr.ftgnr


/* =========================================================
   LEVERANTÖR
   ========================================================= */
LEFT OUTER JOIN le WITH (READUNCOMMITTED)
    ON le.foretagkod = fr.foretagkod
    AND le.ftgnr = fr.ftgnr


/* =========================================================
   KONTAKTPERSON + TELEFON + MEJL

   Telefon:
   ComKod 1 = Telefon direkt
   ComKod 3 = Telefon 1
   ComKod 4 = Telefon 2

   Mejl:
   ComKod 7 = Företagsmejl
   ComKod 8 = Personlig mejl

   Prioriterar standardkontakt vid order.
   ========================================================= */
OUTER APPLY (
    SELECT TOP (1)
         kp.FtgKontaktNr
        ,kp.FtgPerson
        ,kp.q_kp_default_vid_order

        /* Telefon direkt - ComKod 1 */
        ,MAX(
            CASE 
                WHEN cr.ComKod = 1
                    THEN cr.ComNr
            END
         ) AS TelefonDirekt

        /* Telefon 1 - ComKod 3 */
        ,MAX(
            CASE 
                WHEN cr.ComKod = 3
                    THEN cr.ComNr
            END
         ) AS Telefon1

        /* Telefon 2 - ComKod 4 */
        ,MAX(
            CASE 
                WHEN cr.ComKod = 4
                    THEN cr.ComNr
            END
         ) AS Telefon2

        /* Personlig mejl - ComKod 8 */
        ,MAX(
            CASE 
                WHEN cr.ComKod = 8
                    THEN cr.ComNr
            END
         ) AS PersonligMejl

        /* Företagsmejl - ComKod 7 */
        ,MAX(
            CASE 
                WHEN cr.ComKod = 7
                    THEN cr.ComNr
            END
         ) AS ForetagsMejl

    FROM kp WITH (READUNCOMMITTED)

    LEFT JOIN cr WITH (READUNCOMMITTED)
        ON cr.ForetagKod = kp.ForetagKod
        AND cr.FtgNr = kp.FtgNr
        AND cr.FtgKontaktNr = kp.FtgKontaktNr

    WHERE kp.ForetagKod = fr.ForetagKod
      AND kp.FtgNr = fr.FtgNr

    GROUP BY
         kp.FtgKontaktNr
        ,kp.FtgPerson
        ,kp.q_kp_default_vid_order

    ORDER BY
         /* Standardkontakt först */
         CASE 
            WHEN kp.q_kp_default_vid_order = 1 THEN 0
            ELSE 1
         END

         /* Kontakt med mejl prioriteras */
        ,CASE
            WHEN MAX(CASE WHEN cr.ComKod = 8 THEN cr.ComNr END) IS NOT NULL THEN 0
            WHEN MAX(CASE WHEN cr.ComKod = 7 THEN cr.ComNr END) IS NOT NULL THEN 1
            ELSE 2
         END

        ,kp.FtgKontaktNr

) AS kontakt


/* =========================================================
   SENASTE ORDER
   ========================================================= */
LEFT OUTER JOIN (
    SELECT
         oh.foretagkod
        ,MAX(oh.orddatum) AS orddatumMax
        ,oh.ftgnr

    FROM oh WITH (READUNCOMMITTED)

    GROUP BY 
         oh.foretagkod
        ,oh.ftgnr

) AS oh1
    ON oh1.foretagkod = fr.foretagkod
    AND oh1.ftgnr = fr.ftgnr


/* =========================================================
   SENASTE ORDER VIA LEVERANSPLATS
   ========================================================= */
LEFT OUTER JOIN (
    SELECT
         oh.foretagkod
        ,MAX(oh.orddatum) AS orddatumMax
        ,oh.OrdLevPlats1

    FROM oh WITH (READUNCOMMITTED)

    GROUP BY 
         oh.foretagkod
        ,oh.OrdLevPlats1

) AS oh2
    ON oh2.foretagkod = fr.foretagkod
    AND oh2.OrdLevPlats1 = fr.ftgnr


/* =========================================================
   SENASTE OFFERT
   ========================================================= */
LEFT OUTER JOIN (
    SELECT
         ofh.foretagkod
        ,MAX(ofh.offertdat) AS offertdatumMax
        ,ofh.ftgnr

    FROM ofh WITH (READUNCOMMITTED)

    GROUP BY 
         ofh.foretagkod
        ,ofh.ftgnr

) AS ofh1
    ON ofh1.foretagkod = fr.foretagkod
    AND ofh1.ftgnr = fr.ftgnr


/* =========================================================
   SENASTE BESTÄLLNING
   ========================================================= */
LEFT OUTER JOIN (
    SELECT
         bh.foretagkod
        ,MAX(bh.regdat) AS [Beställningsdatum MAX]
        ,bh.ftgnr

    FROM bh WITH (READUNCOMMITTED)

    GROUP BY 
         bh.foretagkod
        ,bh.ftgnr

) AS bh1
    ON bh1.foretagkod = fr.foretagkod
    AND bh1.ftgnr = fr.ftgnr


/* =========================================================
   SENASTE LEVERANTÖRSFAKTURA
   ========================================================= */
LEFT OUTER JOIN (
    SELECT
         lr.foretagkod
        ,MAX(lr.LevFaktDat) AS [LevFaktDat MAX]
        ,lr.ftgnr

    FROM lr WITH (READUNCOMMITTED)

    GROUP BY 
         lr.foretagkod
        ,lr.ftgnr

) AS lr
    ON lr.foretagkod = fr.foretagkod
    AND lr.ftgnr = fr.ftgnr


/* =========================================================
   URVAL

   Visar endast kunder som INTE haft order
   från och med angivet datum.
   ========================================================= */
WHERE fr.foretagkod = 9100

    /* Endast kunder */
    AND kus.ftgnr IS NOT NULL

    /* Ingen vanlig order från gränsdatum */
    AND (
        oh1.orddatumMax IS NULL
        OR oh1.orddatumMax < @KopInnanDatum
    )

    /* Ingen order via leveransplats från gränsdatum */
    AND (
        oh2.orddatumMax IS NULL
        OR oh2.orddatumMax < @KopInnanDatum
    )


/* =========================================================
   SORTERING
   Senaste köp överst.
   Kunder som aldrig haft order hamnar längst ner.
   ========================================================= */
ORDER BY
    CASE
        WHEN oh1.orddatumMax IS NULL THEN oh2.orddatumMax
        WHEN oh2.orddatumMax IS NULL THEN oh1.orddatumMax
        WHEN oh1.orddatumMax >= oh2.orddatumMax THEN oh1.orddatumMax
        ELSE oh2.orddatumMax
    END DESC,
    fr.ftgnamn;