select fr.rowcreateddt, fr.ftgnamn, fr.ftgnr,fr.q_saps4, * from fr where foretagkod = 9100 
and fr.rowcreateddt >'2026-03-31 23:27:00.000' 
order by fr.rowcreateddt desc