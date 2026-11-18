select artnr as 'ARTIKELID', artbeskrspec AS Artikelnummer , ar.q_fsc_claim_id,ar.q_fsc_status_id,  
* from ar where foretagkod = 9500 

select * from q_ise_miljomarken where foretagkod = 9500 


select * from q_ise_miljomarke_by_artnr where foretagkod = 9500 

select * from q_repa_sr where foretagkod = 9500 
