SELECT *
FROM sys.tables
WHERE is_replicated = 1
order by name

EXEC sp_removedbreplication 'AX2012R3'

checkpoint