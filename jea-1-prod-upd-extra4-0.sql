-- Jeeves extract article data S/4 PROD.

/* Change log
v.1: Initial version. Refer: dev-ecom-1-upd-extra4.sql
     Set 11 etc in separate sql-files.
*/

-- Nolla alla
UPDATE AR
SET extra4 = 0  -- float
WHERE ForetagKod = 2000;  -- Mallbolaget

-- END