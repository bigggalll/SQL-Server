SELECT * 
FROM sys.dm_tran_locks
WHERE [resource_type] NOT IN ('DATABASE','KEY')