/*============================================================================
  File:     WastedSpace.sql

  Summary:  Sys.dm_os_buffer_descriptors

  SQL Server Versions: 2005 onwards
------------------------------------------------------------------------------
  Written by Paul S. Randal, SQLskills.com

  (c) 2016, SQLskills.com. All rights reserved.

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  You may alter this code for your own *non-commercial* purposes. You may
  republish altered code as long as you include this copyright and give due
  credit, but you must obtain prior permission before blogging this code.
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/


-- How long will this take to run? Time a select * from sys.dm_os_buffer_descriptors
-- and multiply by the number of databases on the instance.
EXEC sp_MSforeachdb 
    N'IF EXISTS (SELECT 1 FROM (SELECT DISTINCT DB_NAME ([database_id]) AS [name] 
    FROM sys.dm_os_buffer_descriptors) AS [names] WHERE [name] = ''?'')
BEGIN
USE [?]
SELECT
    ''?'' AS [Database],
    OBJECT_NAME ([p].[object_id]) AS [Object],
    [p].[index_id],
    [i].[name] AS [Index],
    [i].[type_desc] AS [Type],
    --[au].[type_desc] AS [AUType],
    --[DPCount] AS [DirtyPageCount],
    --[CPCount] AS [CleanPageCount],
    --[DPCount] * 8 / 1024 AS [DirtyPageMB],
    --[CPCount] * 8 / 1024 AS [CleanPageMB],
    (DPCount + CPCount) * 8 / 1024 AS [TotalMB],
    --[DPFreeSpace] / 1024 / 1024 AS [DirtyPageFreeSpace],
    --[CPFreeSpace] / 1024 / 1024 AS [CleanPageFreeSpace],
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
    WHERE [database_id] = DB_ID (''?'')
    GROUP BY [allocation_unit_id]) AS [buffers]
INNER JOIN sys.allocation_units AS [au]
    ON [au].[allocation_unit_id] = [buffers].[allocation_unit_id]
INNER JOIN sys.partitions AS [p]
    ON [au].[container_id] = [p].[partition_id]
INNER JOIN sys.indexes AS [i]
    ON [i].[index_id] = [p].[index_id] AND [p].[object_id] = [i].[object_id]
WHERE [p].[object_id] > 100 AND ([DPCount] + [CPCount]) > 12800 -- Taking up more than 100MB
ORDER BY [FreeSpacePC] DESC;
END'; 

