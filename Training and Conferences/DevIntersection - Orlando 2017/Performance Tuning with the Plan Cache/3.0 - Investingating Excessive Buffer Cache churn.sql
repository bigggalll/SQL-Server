--Look at Buffer Cache Summary by database
SELECT 
   (CASE WHEN ([database_id] = 32767)
       THEN 'Resource Database'
       ELSE DB_NAME ([database_id]) END) AS [DatabaseName],
   COUNT (*) * 8 / 1024 AS [MBUsed],
   SUM (CAST ([free_space_in_bytes] AS BIGINT)) / (1024 * 1024) AS [MBEmpty]
FROM sys.dm_os_buffer_descriptors
GROUP BY [database_id]
HAVING COUNT(*) * 8 / 1024 > 0;
GO 


USE [AdventureWorks2014];
GO

-- Look at Buffer Cache usage for the specific database
SELECT
    OBJECT_NAME (p.[object_id]) AS [Object],
    p.[index_id],
    i.[name] AS [Index],
    i.[type_desc] AS [Type],
    (DPCount + CPCount) * 8 / 1024 AS [TotalMB],
    ([DPFreeSpace] + [CPFreeSpace]) / 1024 / 1024 AS [FreeSpaceMB],
    CAST (ROUND (100.0 * (([DPFreeSpace] + [CPFreeSpace]) / 1024) / (([DPCount] + [CPCount]) * 8), 1) AS DECIMAL (4, 1)) AS [FreeSpacePC]
FROM
    (SELECT
        allocation_unit_id,
        SUM (CASE WHEN ([is_modified] = 1)
            THEN 1 ELSE 0 END) AS [DPCount], 
        SUM (CASE WHEN ([is_modified] = 1)
            THEN 0 ELSE 1 END) AS [CPCount],
        SUM (CASE WHEN ([is_modified] = 1)
            THEN CAST ([free_space_in_bytes] AS BIGINT) ELSE 0 END) AS [DPFreeSpace], 
        SUM (CASE WHEN ([is_modified] = 1)
            THEN 0 ELSE CAST ([free_space_in_bytes] AS BIGINT) END) AS [CPFreeSpace]
    FROM sys.dm_os_buffer_descriptors
    WHERE [database_id] = DB_ID ()
    GROUP BY [allocation_unit_id]) AS buffers
INNER JOIN sys.allocation_units AS au
    ON au.[allocation_unit_id] = buffers.[allocation_unit_id]
INNER JOIN sys.partitions AS p
    ON au.[container_id] = p.[partition_id]
INNER JOIN sys.indexes AS i
    ON i.[index_id] = p.[index_id] AND p.[object_id] = i.[object_id]
WHERE p.[object_id] > 100 
  AND ([DPCount] + [CPCount]) > 12800 -- Taking up more than 100MB
ORDER BY [FreeSpacePC] DESC;




-- Find what uses the index
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
DECLARE @IndexName AS NVARCHAR(128) = 'PK_SalesOrderDetailEnlarged_SalesOrderID_SalesOrderDetailID'; 

-- Make sure the name passed is appropriately quoted 
IF (LEFT(@IndexName, 1) <> '[' AND RIGHT(@IndexName, 1) <> ']') SET @IndexName = QUOTENAME(@IndexName); 
--Handle the case where the left or right was quoted manually but not the opposite side 
IF LEFT(@IndexName, 1) <> '[' SET @IndexName = '['+@IndexName; 
IF RIGHT(@IndexName, 1) <> ']' SET @IndexName = @IndexName + ']'; 

-- Dig into the plan cache and find all plans using this index 
;WITH XMLNAMESPACES 
   (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')    
SELECT 
stmt.value('(@StatementText)[1]', 'varchar(max)') AS SQL_Text, 
obj.value('(@Database)[1]', 'varchar(128)') AS DatabaseName, 
obj.value('(@Schema)[1]', 'varchar(128)') AS SchemaName, 
obj.value('(@Table)[1]', 'varchar(128)') AS TableName, 
obj.value('(@Index)[1]', 'varchar(128)') AS IndexName, 
obj.value('(@IndexKind)[1]', 'varchar(128)') AS IndexKind, 
cp.plan_handle, 
query_plan 
FROM sys.dm_exec_cached_plans AS cp 
CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS qp 
CROSS APPLY query_plan.nodes('//StmtSimple') AS batch(stmt) 
CROSS APPLY stmt.nodes('.//IndexScan/Object[@Index=sql:variable("@IndexName")]') AS idx(obj) 
OPTION(MAXDOP 1, RECOMPILE); 







-- Find what uses the index (faster with less detail)
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
DECLARE @IndexName AS NVARCHAR(128) = 'PK_SalesOrderDetailEnlarged_SalesOrderID_SalesOrderDetailID'; 

-- Make sure the name passed is appropriately quoted 
IF (LEFT(@IndexName, 1) <> '[' AND RIGHT(@IndexName, 1) <> ']') SET @IndexName = QUOTENAME(@IndexName); 
--Handle the case where the left or right was quoted manually but not the opposite side 
IF LEFT(@IndexName, 1) <> '[' SET @IndexName = '['+@IndexName; 
IF RIGHT(@IndexName, 1) <> ']' SET @IndexName = @IndexName + ']'; 

-- Dig into the plan cache and find all plans using this index 
;WITH XMLNAMESPACES 
   (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')    
SELECT *
FROM sys.dm_exec_cached_plans AS cp 
CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS qp 
CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS st
WHERE query_plan.exist('//IndexScan/Object[@Index=sql:variable("@IndexName")]') = 1
OPTION(MAXDOP 1, RECOMPILE); 


