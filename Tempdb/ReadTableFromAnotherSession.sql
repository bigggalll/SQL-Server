select * from tempdb.sys.tables where name like '#tblStopID%'

-- Erreur pas possible de lire directement la table
--select * from tempdb.dbo.[#tblStopID__________________________________________________________________________________________________________000000316A2C] (NOLOCK)


-- Voir nombre de record et index_id
select * from tempdb.sys.partitions (nolock) where object_id=-1475345208

-- Extraire les pages utilisé par cette objet
dbcc ind('tempdb', -1475345208, 0)

-- Voir le contenu des pages utilisé par l'objet
dbcc traceon(3604);
dbcc page(tempdb, 4, 525, 3) with tableresults
dbcc page(tempdb, 1, 179704, 3) with tableresults
