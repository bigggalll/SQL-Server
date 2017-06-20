-- https://support.microsoft.com/en-us/kb/307487
-- au lieu de redémarrer le service, on peut essayer de vider les caches avnat de faire le shrik des files

use tempdb
GO
CHECKPOINT;
GO

-- Report existing file sizes
SELECT name, size
FROM sys.master_files
WHERE database_id = DB_ID(N'tempdb');
GO
DBCC FREEPROCCACHE -- clean cache
DBCC DROPCLEANBUFFERS -- clean buffers
DBCC FREESYSTEMCACHE ('ALL') -- clean system cache
DBCC FREESESSIONCACHE -- clean session cache
DBCC SHRINKDATABASE(tempdb, 10); -- shrink tempdb
dbcc shrinkfile ('tempdev') -- shrink default db file
dbcc shrinkfile ('tempdev2') -- shrink db file tempdev2
dbcc shrinkfile ('tempdev3') -- shrink db file tempdev3
dbcc shrinkfile ('tempdev4') -- shrink db file tempdev4
dbcc shrinkfile ('templog') -- shrink log file
GO

-- report the new file sizes
SELECT name, size
FROM sys.master_files
WHERE database_id = DB_ID(N'tempdb');
GO