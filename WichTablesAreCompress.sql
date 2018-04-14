SET NOCOUNT ON;
GO
SELECT DISTINCT
       SERVERPROPERTY('servername') [instance],
       DB_NAME() [database],
       QUOTENAME(OBJECT_SCHEMA_NAME(sp.object_id))+'.'+QUOTENAME(OBJECT_NAME(sp.object_id)) [table],
       ix.name [index_name],
       sp.data_compression,
       sp.data_compression_desc
FROM sys.partitions SP
     LEFT OUTER JOIN sys.indexes IX ON sp.object_id = ix.object_id
                                       AND sp.index_id = ix.index_id
WHERE sp.data_compression <> 0
ORDER BY 2; 