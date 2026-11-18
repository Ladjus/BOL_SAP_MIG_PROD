-- Jeeves extract article data.
-- ART_REF
--
-- MASTER: ForetagKod 2000
--
-- Urvalsprincip:
--   * Artikel måste finnas i bolag 2000
--   * extra4 måste vara satt (inte NULL / 0)
--   * q_saps4_sortiment måste vara satt
--
-- Ingen kontroll görs längre mot specifika extra4-värden
-- såsom 11, 21, 51 osv.
--
-- Hellre för många artiklar än för få.
-- Saknas extra4 eller SAP-sortiment i masterbolag 2000
-- kommer artikeln inte med.

/*
3 * SELECT, one per load-file tab:

(1) Tab "Header":
    structure S_CLF_MAT_KSSK_HEAD

(2) Tab "Numerical Value Allocation":
    structure S_CLF_MAT_AUSP_NUM
    -- Utkommenterad sedan v.2

(3) Tab "Character Value Allocation":
    structure S_CLF_MAT_AUSP_CHAR
*/


/* ============================================================
   (1) HEADER
   Structure: S_CLF_MAT_KSSK_HEAD
   Class ART_REF: Article References
   ============================================================ */

SELECT
    ar.artnr AS AR_ArtNr,                  -- Jeeves Artikel ID
    '#001' AS KSSK_KLART,                 -- Class type
    'ART_REF' AS KSSK_CLASSNUM,           -- Class name
    ar.artbeskrspec AS KSSK_PRODUCT,      -- SAP Product / Jeeves Artikelnr
    '1' AS KSSK_STATU                     -- Classification status

FROM ar

WHERE
    ar.foretagkod = 2000                  -- Mall / Master

    -- Extra4 måste vara satt
    AND ISNULL(ar.extra4, 0) <> 0

    -- SAP-sortiment måste vara satt
    AND NULLIF(
            LTRIM(RTRIM(ar.q_saps4_sortiment)),
            ''
        ) IS NOT NULL

ORDER BY
    KSSK_PRODUCT;


/* ============================================================
   (2) NUMERICAL VALUE ALLOCATION
   Structure: S_CLF_MAT_AUSP_NUM

   Borttagen / utkommenterad sedan v.2 eftersom ECC_MATNR
   ändrades till character-type i PROD.
   ============================================================ */

/*
SELECT
    ar.artnr AS AR_ArtNr,
    '#001' AS AUSP_NUM_KLART,
    'ART_REF' AS AUSP_NUM_CLASSNUM,
    ar.artbeskrspec AS AUSP_NUM_PRODUCT,
    'ECC_MATNR' AS AUSP_NUM_CHARACT,
    '_001' AS AUSP_NUM_POSNR,
    ar.q_artnr_pacudo AS AUSP_NUM_ATFLV

FROM ar

WHERE
    ar.foretagkod = 2000

    AND ISNULL(ar.extra4, 0) <> 0

    AND NULLIF(
            LTRIM(RTRIM(ar.q_saps4_sortiment)),
            ''
        ) IS NOT NULL

    AND ar.q_artnr_pacudo IS NOT NULL

ORDER BY
    AUSP_NUM_KLART,
    AUSP_NUM_CLASSNUM,
    AUSP_NUM_PRODUCT,
    AUSP_NUM_CHARACT;
*/


/* ============================================================
   (3) CHARACTER VALUE ALLOCATION
   Structure: S_CLF_MAT_AUSP_CHAR
   ============================================================ */


/* ------------------------------------------------------------
   (3.a)
   Characteristic:
   JEEVES_ART_ID
   Jeeves Artikel ID [AR.artnr]
   ------------------------------------------------------------ */

SELECT
    ar.artnr AS AR_ArtNr,
    '#001' AS AUSP_CHAR_KLART,
    'ART_REF' AS AUSP_CHAR_CLASSNUM,
    ar.artbeskrspec AS AUSP_CHAR_PRODUCT,
    'JEEVES_ART_ID' AS AUSP_CHAR_CHARACT,
    '_001' AS AUSP_CHAR_POSNR,
    ar.artnr AS AUSP_CHAR_ATFLV

FROM ar

WHERE
    ar.foretagkod = 2000

    AND ISNULL(ar.extra4, 0) <> 0

    AND NULLIF(
            LTRIM(RTRIM(ar.q_saps4_sortiment)),
            ''
        ) IS NOT NULL

    AND ar.artnr IS NOT NULL


UNION ALL


/* ------------------------------------------------------------
   (3.b)
   Characteristic:
   JEEVES_ART_NR
   Jeeves Artikelnr [AR.artbeskrspec]
   ------------------------------------------------------------ */

SELECT
    ar.artnr AS AR_ArtNr,
    '#001' AS AUSP_CHAR_KLART,
    'ART_REF' AS AUSP_CHAR_CLASSNUM,
    ar.artbeskrspec AS AUSP_CHAR_PRODUCT,
    'JEEVES_ART_NR' AS AUSP_CHAR_CHARACT,
    '_001' AS AUSP_CHAR_POSNR,
    ar.artbeskrspec AS AUSP_CHAR_ATFLV

FROM ar

WHERE
    ar.foretagkod = 2000

    AND ISNULL(ar.extra4, 0) <> 0

    AND NULLIF(
            LTRIM(RTRIM(ar.q_saps4_sortiment)),
            ''
        ) IS NOT NULL

    AND ar.artbeskrspec IS NOT NULL


UNION ALL


/* ------------------------------------------------------------
   (3.c)
   Characteristic:
   JEEVES_ART_PACUDO
   Jeeves Pacudo ArtNr [AR.q_artnr_pacudo]
   ------------------------------------------------------------ */

SELECT
    ar.artnr AS AR_ArtNr,
    '#001' AS AUSP_CHAR_KLART,
    'ART_REF' AS AUSP_CHAR_CLASSNUM,
    ar.artbeskrspec AS AUSP_CHAR_PRODUCT,
    'JEEVES_ART_PACUDO' AS AUSP_CHAR_CHARACT,
    '_001' AS AUSP_CHAR_POSNR,
    ar.q_artnr_pacudo AS AUSP_CHAR_ATFLV

FROM ar

WHERE
    ar.foretagkod = 2000

    AND ISNULL(ar.extra4, 0) <> 0

    AND NULLIF(
            LTRIM(RTRIM(ar.q_saps4_sortiment)),
            ''
        ) IS NOT NULL

    AND ar.q_artnr_pacudo IS NOT NULL


UNION ALL


/* ------------------------------------------------------------
   (3.d)
   Characteristic:
   ECC_MATNR
   ECC Material Nr [MARA.MATNR]
   ------------------------------------------------------------ */

SELECT
    ar.artnr AS AR_ArtNr,
    '#001' AS AUSP_CHAR_KLART,
    'ART_REF' AS AUSP_CHAR_CLASSNUM,
    ar.artbeskrspec AS AUSP_CHAR_PRODUCT,
    'ECC_MATNR' AS AUSP_CHAR_CHARACT,
    '_001' AS AUSP_CHAR_POSNR,
    ar.q_artnr_pacudo AS AUSP_CHAR_ATFLV

FROM ar

WHERE
    ar.foretagkod = 2000

    AND ISNULL(ar.extra4, 0) <> 0

    AND NULLIF(
            LTRIM(RTRIM(ar.q_saps4_sortiment)),
            ''
        ) IS NOT NULL

    AND ar.q_artnr_pacudo IS NOT NULL


ORDER BY
    AUSP_CHAR_KLART,
    AUSP_CHAR_CLASSNUM,
    AUSP_CHAR_PRODUCT,
    AUSP_CHAR_CHARACT;


-- END