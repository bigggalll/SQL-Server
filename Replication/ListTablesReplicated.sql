SELECT *
FROM sys.tables
WHERE is_replicated = 1
order by name