SELECT dbschemas.[name] AS SchemaName,
       dbtables.[name] AS TableName,
       dbindexes.[name] AS IndexName,
       indexstats.avg_fragmentation_in_percent AS Fragmentation,
       indexstats.page_count AS PageCount,
       dbindexes.allow_page_locks AS AllowPageLocks
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) AS indexstats
     INNER JOIN sys.tables dbtables ON dbtables.[object_id] = indexstats.[object_id]
     INNER JOIN sys.schemas dbschemas ON dbtables.[schema_id] = dbschemas.[schema_id]
     INNER JOIN sys.indexes AS dbindexes ON dbindexes.[object_id] = indexstats.[object_id]
                                            AND indexstats.index_id = dbindexes.index_id
WHERE indexstats.database_id = DB_ID()
      AND indexstats.avg_fragmentation_in_percent > 1
      AND indexstats.page_count > 0
      AND dbindexes.[name] IS NOT NULL
      AND dbtables.[name] = 'retailgroupmemberline'
ORDER BY indexstats.avg_fragmentation_in_percent DESC;