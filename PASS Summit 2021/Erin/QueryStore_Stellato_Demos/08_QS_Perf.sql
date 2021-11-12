/*============================================================================
  File:     08_QS_Perf.sql

  SQL Server Versions: 2016+, Azure SQLDB
------------------------------------------------------------------------------
  Written by Erin Stellato, SQLskills.com
  
  (c) 2021, SQLskills.com. All rights reserved.

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


/*
	Restore database
	*you may need to change the backup
	and restore locations
*/
USE [master]
GO

RESTORE DATABASE [WideWorldImporters] 
	FROM  DISK = N'C:\Backups\WideWorldImporters_Bits.bak' WITH  FILE = 1,  
	MOVE N'WWI_Primary' TO N'C:\Databases\WideWorldImporters\WideWorldImporters.mdf',  
	MOVE N'WWI_UserData' TO N'C:\Databases\WideWorldImporters\WideWorldImporters_UserData.ndf',  
	MOVE N'WWI_Log' TO N'C:\Databases\WideWorldImporters\WideWorldImporters.ldf',  
	NOUNLOAD,  REPLACE,  STATS = 5

GO

/*
	Diagnostic XE session
*/
IF EXISTS (
	SELECT * 
	FROM sys.server_event_sessions
	WHERE [name] = 'QueryStorePerfInfo')
BEGIN
	DROP EVENT SESSION [QueryStorePerfInfo] ON SERVER;
END
GO

CREATE EVENT SESSION [QueryStorePerfInfo] 
	ON SERVER 
		ADD EVENT qds.query_store_buffered_items_memory_below_read_write_target,
		ADD EVENT qds.query_store_buffered_items_over_memory_limit,
		ADD EVENT qds.query_store_db_cleared,
		ADD EVENT qds.query_store_db_data_structs_not_released,
		ADD EVENT qds.query_store_db_diagnostics,
		ADD EVENT qds.query_store_db_hints_diagnostics,
		ADD EVENT qds.query_store_db_hints_hash_map_max_size_reached,
		ADD EVENT qds.query_store_execution_runtime_info,
		ADD EVENT qds.query_store_execution_runtime_info_discarded,
		ADD EVENT qds.query_store_execution_runtime_info_evicted,
		ADD EVENT qds.query_store_global_mem_obj_size_kb,
		ADD EVENT qds.query_store_spinlock_stats,
		ADD EVENT qds.query_store_stmt_hash_map_memory_below_read_write_target,
		ADD EVENT qds.query_store_stmt_hash_map_over_memory_limit,
		ADD EVENT qds.query_store_stmt_hash_map_undecided_queries_cleanup,
		ADD EVENT qds.query_store_wait_runtime_info
	ADD TARGET package0.event_file(
		SET filename=N'C:\temp\QueryStorePerfInfo',max_file_size=(128),max_rollover_files=(10)
		)
WITH (MAX_MEMORY=16384 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,
MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=PER_NODE,TRACK_CAUSALITY=ON,STARTUP_STATE=OFF)
GO

ALTER EVENT SESSION [QueryStorePerfInfo] 
	ON SERVER
	STATE = START;
GO

/*
	open up live data viewer
*/

/*
	Enable QS and clear data
*/

ALTER DATABASE [WideWorldImporters] SET QUERY_STORE = ON;
GO

ALTER DATABASE [WideWorldImporters] SET QUERY_STORE (
	OPERATION_MODE = READ_WRITE, 
	QUERY_CAPTURE_MODE = ALL,
	INTERVAL_LENGTH_MINUTES = 1
	);
GO

ALTER DATABASE [WideWorldImporters] SET QUERY_STORE CLEAR;
GO

/*
	Run 08a_AdHocforWorkload to create SP for adhoc queries
	Run 08b_SPforWorkload to create SP for parameterized queries
*/


/*
	Run SP_multiple_clients to generate workload
*/

/*
	What's in QS?
*/
USE [WideWorldImporters];
GO

SELECT
	[qsq].[query_id], 
	[qsp].[plan_id],
	[qsq].[object_id],
	[qsq].[query_hash],
	[rs].[count_executions],
	[rs].[last_execution_time],
	[rs].[avg_duration],
	[rs].[avg_logical_io_reads],
	[qst].[query_sql_text],
	TRY_CONVERT(XML, [qsp].[query_plan]) AS [QueryPlan_XML]
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs] 
	ON [qsp].[plan_id] = [rs].[plan_id]
--WHERE [qsq].[object_id] > 0;
GO


/*
	Check QS counts
*/
USE [WideWorldImporters];
GO

SELECT COUNT(*) AS CountQueryText                                 
FROM sys.query_store_query_text;
GO

SELECT COUNT(*) AS CountQueries                                     
FROM sys.query_store_query; 
GO

SELECT COUNT(*) AS CountPlanRows                                      
FROM sys.query_store_plan; 
GO

/*
	take note of counts

*/


/*
	Check memory use
*/
SELECT 
	type, 
	sum(pages_kb) AS [MemoryUsed_KB],
	sum(pages_kb)/1024 AS [MemoryUsed_MB]
FROM sys.dm_os_memory_clerks
WHERE type like '%QDS%'
or type like '%QueryDiskStore%'
GROUP BY type
ORDER BY type;
GO

/*
	Run queries again, does memory use change?
*/
SELECT 
	type, 
	sum(pages_kb) AS [MemoryUsed_KB],
	sum(pages_kb)/1024 AS [MemoryUsed_MB]
FROM sys.dm_os_memory_clerks
WHERE type like '%QDS%'
or type like '%QueryDiskStore%'
GROUP BY type
ORDER BY type;
GO


/*
	take note of memory use

*/

/*
	Clear out QS data
*/
ALTER DATABASE [WideWorldImporters] SET QUERY_STORE CLEAR;
GO

/*
	Run AdHoc_multiple_clients_2 to generate adhoc workload
*/


/*
	What's in QS now?
*/
USE [WideWorldImporters];
GO

SELECT
	[qsq].[query_id], 
	[qsp].[plan_id],
	[qsq].[object_id],
	[qsq].[query_hash],
	[rs].[count_executions],
	[rs].[last_execution_time],
	[rs].[avg_duration],
	[rs].[avg_logical_io_reads],
	[qst].[query_sql_text],
	TRY_CONVERT(XML, [qsp].[query_plan]) AS [QueryPlan_XML]
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs] 
	ON [qsp].[plan_id] = [rs].[plan_id]
--WHERE [qsq].[object_id] = 0;
GO


/*
	Check QS counts
*/
USE [WideWorldImporters];
GO

SELECT COUNT(*) AS CountQueryText                                 
FROM sys.query_store_query_text;
GO

SELECT COUNT(*) AS CountQueries                                     
FROM sys.query_store_query; 
GO

SELECT COUNT(*) AS CountPlanRows                                      
FROM sys.query_store_plan; 
GO


/*
	Check memory use
*/
SELECT 
	type, 
	sum(pages_kb) AS [MemoryUsed_KB],
	sum(pages_kb)/1024 AS [MemoryUsed_MB]
FROM sys.dm_os_memory_clerks
WHERE type like '%QDS%'
or type like '%QueryDiskStore%'
GROUP BY type
ORDER BY type;
GO


EXEC sp_query_store_flush_db;
GO

/*
	Run queries again, does memory use change?
*/
SELECT 
	type, 
	sum(pages_kb) AS [MemoryUsed_KB],
	sum(pages_kb)/1024 AS [MemoryUsed_MB]
FROM sys.dm_os_memory_clerks
WHERE type like '%QDS%'
or type like '%QueryDiskStore%'
GROUP BY type
ORDER BY type;
GO



/*
	take note of memory use


*/

/*
	Clear out QS again
	Open up PerfMon
*/
ALTER DATABASE [WideWorldImporters] SET QUERY_STORE CLEAR;
GO

/*
	Run SP_multiple_clients_10 to generate workload
	watch in PerfMon
*/

/*
	Run AdHoc_multiple_clients_2 to generate adhoc workload
	watch in PerfMon
*/


/*
	Now, turn OFF Query Store and monitor PerfMon
*/
ALTER DATABASE [WideWorldImporters] SET QUERY_STORE = OFF;
GO

/*
	Run SP_multiple_clients_10 to generate workload
*/

/*
	Run AdHoc_multiple_clients_2 to generate adhoc workload
*/


/*
	Review Event Session definition
*/
CREATE EVENT SESSION [QueryStorePerfInfo] 
	ON SERVER 
		ADD EVENT qds.query_store_buffered_items_memory_below_read_write_target,
		ADD EVENT qds.query_store_buffered_items_over_memory_limit,
		ADD EVENT qds.query_store_db_cleared,
		ADD EVENT qds.query_store_db_data_structs_not_released,
		ADD EVENT qds.query_store_db_diagnostics,								--DEFINITELY use on-prem for monitoring
		ADD EVENT qds.query_store_db_hints_diagnostics,
		ADD EVENT qds.query_store_db_hints_hash_map_max_size_reached,			--not fired on-prem
		ADD EVENT qds.query_store_execution_runtime_info,
		ADD EVENT qds.query_store_execution_runtime_info_discarded,
		ADD EVENT qds.query_store_execution_runtime_info_evicted,
		ADD EVENT qds.query_store_global_mem_obj_size_kb,						--DEFINITELY use on-prem for monitoring
		ADD EVENT qds.query_store_spinlock_stats,
		ADD EVENT qds.query_store_stmt_hash_map_memory_below_read_write_target, --not fired on-prem
		ADD EVENT qds.query_store_stmt_hash_map_over_memory_limit,				--not fired on-prem
		ADD EVENT qds.query_store_stmt_hash_map_undecided_queries_cleanup,		--not fired on-prem
		ADD EVENT qds.query_store_wait_runtime_info
	ADD TARGET package0.event_file(
		SET filename=N'C:\temp\QueryStorePerfInfo',max_file_size=(128),max_rollover_files=(10)
		)
WITH (MAX_MEMORY=16384 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,
MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=PER_NODE,TRACK_CAUSALITY=ON,STARTUP_STATE=OFF)
GO

/*
	Clean up
*/
IF EXISTS (
	SELECT * 
	FROM sys.server_event_sessions
	WHERE [name] = 'QueryStorePerfInfo')
BEGIN
	DROP EVENT SESSION [QueryStorePerfInfo] ON SERVER;
END
GO