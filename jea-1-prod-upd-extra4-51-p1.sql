/* Update ar.extra4 (float) to indicate extract for S/4 PROD
Ref: "Artikelfil_harmonisering_infor_migrering-20260624T1056.xlsx" 2026-06-24
Product global data : a1&a2/b1&b2/c2/d1 ==> Single article & Variant article; new # & keep #; global from ECC; keep BUM. ==> MC
(a) single article (category 00) vs. generic (01) and variant (02).
(b) new article number (S/4 internal); not: keep article number (S/4 external)
(c) global data from Jeeves vs. ECC.
(d) article keep base-unit vs. change base-unit."

2026-06-24: Include both single and variant articles, per decision that variant articles should also be loaded via Migration Cockpit (MC)!

Excel-filter:
(1) Local art. stat / Centralt sortiment [K] = 0/1/N/Y (articles from Jeeves).
(2) System [B] = D (dublett)
==> 72 rows.
*/

UPDATE ar
SET extra4 = 51 -- !!!
WHERE ForetagKod = 2000  -- Mallbolaget
  AND artnr  -- "Artikel ID"
    IN (
'19038',
'32271',
'32272',
'715718',
'300459',
'500002',
'522180',
'539267',
'794254',
'872912',
'892155',
'896687',
'896938',
'1005394',
'1019742',
'1020674',
'1023994',
'1024798',
'1026977',
'1027000',
'1027136',
'1028484',
'1044406',
'1044554',
'1044685',
'1044736',
'1059955',
'1062145',
'1065386',
'1065389',
'1066493',
'1067783',
'1069430',
'1073145',
'1073647',
'1074028',
'1074455',
'1076335',
'1079086',
'1080708',
'1081986',
'1082299',
'1085688',
'1085692',
'1088287',
'1089100',
'1089616',
'1089902',
'1090363',
'1090457',
'1091854',
'1092110',
'1093058',
'1095153',
'1095386',
'1096648',
'1099134',
'1100111',
'1101494',
'1101660',
'1101763',
'1102379',
'1102811',
'8782220',
'62538502',
'CIT4LTR',
'HAB2LT',
'SOR2LT',
'T54375',
'1105772',
'1106353',
'1107086'
);

-- END