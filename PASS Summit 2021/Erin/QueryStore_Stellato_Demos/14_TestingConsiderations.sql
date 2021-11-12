/*============================================================================
  File:     14_TestingConsiderations.sql

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
USE [master];
GO
RESTORE DATABASE [WideWorldImporters] 
	FROM  DISK = N'C:\Backups\WideWorldImportersEnlarged.bak' 
	WITH  FILE = 1,  
	MOVE N'WWI_Primary' 
		TO N'C:\Databases\WideWorldImporters\WideWorldImporters.mdf',  
	MOVE N'WWI_UserData' 
		TO N'C:\Databases\WideWorldImporters\WideWorldImporters_UserData.ndf',  
	MOVE N'WWI_Log' 
		TO N'C:\Databases\WideWorldImporters\WideWorldImporters.ldf',  
	MOVE N'WWI_InMemory_Data_1' 
		TO N'C:\Databases\WideWorldImporters\WideWorldImporters_InMemory_Data_1',  
	NOUNLOAD, 
	REPLACE, 
	STATS = 5;
GO

/*
	Enable query store, configure settings

*/
ALTER DATABASE [WideWorldImporters] SET QUERY_STORE = ON;
GO
ALTER DATABASE [WideWorldImporters] SET QUERY_STORE (
	OPERATION_MODE = READ_WRITE, INTERVAL_LENGTH_MINUTES = 10
	);
GO

/*
	Create SPs for testing
*/
USE [WideWorldImporters];
GO

DROP PROCEDURE IF EXISTS [Warehouse].[usp_GetCustomerStockItemHistory];
GO


CREATE PROCEDURE [Warehouse].[usp_GetCustomerStockItemHistory]
	@StartDate DATE,
	@EndDate DATE
AS	

SELECT [CustomerID], SUM([StockItemID])
FROM [Warehouse].[StockItemTransactions]
WHERE [TransactionOccurredWhen] BETWEEN @StartDate AND @EndDate
GROUP BY [CustomerID];

GO



DROP PROCEDURE IF EXISTS [Sales].[usp_GetFullProductInfo];
GO

CREATE PROCEDURE [Sales].[usp_GetFullProductInfo]
	@StockItemID INT
AS	

	SELECT 
		[o].[CustomerID], 
		[o].[OrderDate], 
		[ol].[StockItemID], 
		[ol].[Quantity],
		[ol].[UnitPrice]
	FROM [Sales].[Orders] [o]
	JOIN [Sales].[OrderLines] [ol] 
		ON [o].[OrderID] = [ol].[OrderID]
	WHERE [ol].[StockItemID] = @StockItemID
	ORDER BY [o].[OrderDate] DESC;

	SELECT
		[o].[CustomerID], 
		SUM([ol].[Quantity]*[ol].[UnitPrice])
	FROM [Sales].[Orders] [o]
	JOIN [Sales].[OrderLines] [ol] 
		ON [o].[OrderID] = [ol].[OrderID]
	WHERE [ol].[StockItemID] = @StockItemID
	GROUP BY [o].[CustomerID]
	ORDER BY [o].[CustomerID] ASC;
GO

DROP PROCEDURE IF EXISTS [Application].[usp_GetPersonInfo];
GO

CREATE PROCEDURE [Application].[usp_GetPersonInfo] (@PersonID INT)
AS

	SELECT 
		[p].[FullName], 
		[p].[EmailAddress], 
		[c].[FormalName]
	FROM [Application].[People] [p]
	LEFT OUTER JOIN [Application].[Countries] [c] 
		ON [p].[PersonID] = [c].[LastEditedBy]
	WHERE [p].[PersonID] = @PersonID;
GO


/*
	Run queries outside of SSMS
*/


/*
	Check to see what exists in QS
*/
SELECT 
	[qst].[query_text_id],
	[qsq].[query_id],  
	[qsp].[plan_id],
	[qst].[query_sql_text]
FROM [sys].[query_store_query] [qsq]
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
WHERE [qsq].[object_id] = OBJECT_ID(N'Warehouse.usp_GetCustomerStockItemHistory')
OR [qsq].[object_id] = OBJECT_ID(N'Sales.usp_GetFullProductInfo')
OR [qsq].[object_id] = OBJECT_ID(N'Application.usp_GetPersonInfo');
GO


/*
	Now we need a copy of the database 
	WITH Query Store in it to use for
	testing.

	Options?
		Backup and restore
		DBCC CLONEDATABASE (with 2016 SP1 and higher)
		https://sqlperformance.com/2016/08/sql-statistics/expanding-dbcc-clonedatabase
*/

EXEC sp_query_store_flush_db;
GO

BACKUP DATABASE [WideWorldImporters]
  TO  DISK = N'C:\Backups\WWI_Testing.bak'
  WITH INIT, 
  NOFORMAT, 
  COPY_ONLY, 
  STATS = 10, 
  NAME = N'WWI_Testing_full';
GO

DBCC CLONEDATABASE (N'WideWorldImporters', N'CLONE_WideWorldImporters');
GO

 
/* 
	restore in our TEST/DEV environment 
	(we'll restore locally)
*/
USE [master];
GO

RESTORE DATABASE [TEST_WideWorldImporters] 
	FROM  DISK = N'C:\Backups\WWI_Testing.bak' 
	WITH  FILE = 1,  
	MOVE N'WWI_Primary' TO N'C:\Databases\TEST_WWI\TEST_WWI.mdf',  
	MOVE N'WWI_UserData' TO N'C:\Databases\TEST_WWI\TEST_WWI_UserData.ndf',  
	MOVE N'WWI_Log' TO N'C:\Databases\TEST_WWI\TEST_WWI_log.ldf',  
	MOVE N'WWI_InMemory_Data_1' TO N'C:\Databases\TEST_WWI\TEST_WWI_InMemory_Data_1',  
	NOUNLOAD,  
	REPLACE,  
	STATS = 5;
GO

/*
	Query Store already enabled
	Considerations:
		Do you want any data to age out during testing?
		Do you need to increase space allocated?
*/
ALTER DATABASE [TEST_WideWorldImporters] SET QUERY_STORE ( 
	CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 90),  
	MAX_STORAGE_SIZE_MB = 1024);
GO

USE [TEST_WideWorldImporters];
GO

SELECT 
	[actual_state_desc], 
	[readonly_reason], 
	[desired_state_desc], 
	[current_storage_size_mb], 
    [max_storage_size_mb], 
	[flush_interval_seconds], 
	[interval_length_minutes], 
    [stale_query_threshold_days], 
	[size_based_cleanup_mode_desc], 
    [query_capture_mode_desc], 
	[max_plans_per_query]
FROM [sys].[database_query_store_options];
GO


/*
	Just for fun, confirm info that currently exists
*/
SELECT 
	[qst].[query_text_id],
	[qsq].[query_id],  
	[qsp].[plan_id],
	[qst].[query_sql_text],
	TRY_CONVERT(XML, [qsp].[query_plan]) [QueryPlan]
FROM [sys].[query_store_query] [qsq]
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
WHERE [qsq].[object_id] = OBJECT_ID(N'Warehouse.usp_GetCustomerStockItemHistory')
OR [qsq].[object_id] = OBJECT_ID(N'Sales.usp_GetFullProductInfo')
OR [qsq].[object_id] = OBJECT_ID(N'Application.usp_GetPersonInfo');
GO

/*
	Create the new index 
*/
USE [TEST_WideWorldImporters];
GO
CREATE NONCLUSTERED INDEX NCI_StockItemTransactions_TransactionOccurredWhen
	ON [Warehouse].[StockItemTransactions] ([TransactionOccurredWhen], [CustomerID])
	INCLUDE ([StockItemID])
	ON [USERDATA];
GO


/*
	Run queries outside of SSMS
*/


/*
	Compare performance in the UI 
	using the query_id
	(make sure in the TEST database!)
*/
SELECT 
	[qst].[query_text_id],
	[qsq].[query_id],  
	[qsp].[plan_id],
	[qst].[query_sql_text],
	TRY_CONVERT(XML, [qsp].[query_plan]) [QueryPlan]
FROM [sys].[query_store_query] [qsq]
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
WHERE [qsq].[object_id] = OBJECT_ID(N'Warehouse.usp_GetCustomerStockItemHistory')
OR [qsq].[object_id] = OBJECT_ID(N'Sales.usp_GetFullProductInfo')
OR [qsq].[object_id] = OBJECT_ID(N'Application.usp_GetPersonInfo');
GO


/*
	Include the averages in the output
*/
SELECT 
	[qst].[query_text_id],
	[qsq].[query_id],  
	[qsp].[plan_id],
	[rsi].[start_time],
	[rsi].[end_time],
	[rs].[count_executions],
	[rs].[avg_cpu_time],
	[rs].[avg_logical_io_reads],
	[rs].[avg_duration],
	[qst].[query_sql_text],
	TRY_CONVERT(XML, [qsp].[query_plan])
FROM [sys].[query_store_query] [qsq]
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs]
	ON [qsp].[plan_id] = [rs].[plan_id]
JOIN [sys].[query_store_runtime_stats_interval] [rsi]
		ON [rs].[runtime_stats_interval_id] = [rsi].[runtime_stats_interval_id]
WHERE [qsq].[object_id] = OBJECT_ID(N'Warehouse.usp_GetCustomerStockItemHistory')
	AND [rs].[execution_type] = 0
	AND [rsi].[start_time] > DATEADD(HOUR, -8, GETUTCDATE());  
GO


/*
	What does look like if you test with a CLONEd database?
*/

USE [CLONE_WideWorldImporters];
GO

ALTER DATABASE [CLONE_WideWorldImporters] SET READ_WRITE WITH NO_WAIT;
GO


/*
	Query Store already enabled
	Considerations:
		Do you want any data to age out during testing?
		Do you need to increase space allocated?
*/
ALTER DATABASE [CLONE_WideWorldImporters] SET QUERY_STORE ( 
	CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 90),  
	MAX_STORAGE_SIZE_MB = 1024);
GO

USE [CLONE_WideWorldImporters];
GO

SELECT 
	[actual_state_desc], 
	[readonly_reason], 
	[desired_state_desc], 
	[current_storage_size_mb], 
    [max_storage_size_mb], 
	[flush_interval_seconds], 
	[interval_length_minutes], 
    [stale_query_threshold_days], 
	[size_based_cleanup_mode_desc], 
    [query_capture_mode_desc], 
	[max_plans_per_query]
FROM [sys].[database_query_store_options];
GO


/*
	Again, confirm info that currently exists
*/
SELECT 
	[qst].[query_text_id],
	[qsq].[query_id],  
	[qsp].[plan_id],
	[qst].[query_sql_text],
	TRY_CONVERT(XML, [qsp].[query_plan]) [QueryPlan]
FROM [sys].[query_store_query] [qsq]
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
WHERE [qsq].[object_id] = OBJECT_ID(N'Warehouse.usp_GetCustomerStockItemHistory');
GO

/*
	Create the new index 
*/
USE [CLONE_WideWorldImporters];
GO
CREATE NONCLUSTERED INDEX NCI_StockItemTransactions_TransactionOccurredWhen
	ON [Warehouse].[StockItemTransactions] ([TransactionOccurredWhen], [CustomerID])
	INCLUDE ([StockItemID])
	ON [USERDATA];
GO


/*
	Run queries outside of SSMS
*/


/*
	Compare performance in the UI 
	using the query_id
	(make sure in the CLONE database!)
*/
SELECT 
	[qst].[query_text_id],
	[qsq].[query_id],  
	[qsp].[plan_id],
	[qst].[query_sql_text],
	TRY_CONVERT(XML, [qsp].[query_plan]) [QueryPlan]
FROM [sys].[query_store_query] [qsq]
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
WHERE [qsq].[object_id] = OBJECT_ID(N'Warehouse.usp_GetCustomerStockItemHistory');
GO


/*
	Include the averages in the output
*/
SELECT 
	[qst].[query_text_id],
	[qsq].[query_id],  
	[qsp].[plan_id],
	[rsi].[start_time],
	[rsi].[end_time],
	[rs].[count_executions],
	[rs].[avg_cpu_time],
	[rs].[avg_logical_io_reads],
	[rs].[avg_duration],
	[qst].[query_sql_text],
	TRY_CONVERT(XML, [qsp].[query_plan])
FROM [sys].[query_store_query] [qsq]
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs]
	ON [qsp].[plan_id] = [rs].[plan_id]
JOIN [sys].[query_store_runtime_stats_interval] [rsi]
		ON [rs].[runtime_stats_interval_id] = [rsi].[runtime_stats_interval_id]
WHERE [qsq].[object_id] = OBJECT_ID(N'Warehouse.usp_GetCustomerStockItemHistory')
	AND [rs].[execution_type] = 0
	AND [rsi].[start_time] > DATEADD(HOUR, -8, GETUTCDATE());  
GO



/*
	Change a stored procedure
	(remove aggregation query)
	Check what's in QS first
	**Note the query_text_id for the two queries
8184
8185
*/
USE [TEST_WideWorldImporters];
GO
SELECT 
	[qst].[query_text_id],
	[qsq].[query_id],  
	[qsp].[plan_id],
	OBJECT_NAME([qsq].[object_id]) AS [ObjectName],
	[rsi].[start_time],
	[rsi].[end_time],
	[rs].[count_executions],
	[rs].[avg_cpu_time],
	[rs].[avg_logical_io_reads],
	[rs].[avg_duration],
	TRY_CONVERT(XML, [qsp].[query_plan]),
	[qst].[query_sql_text]
FROM [sys].[query_store_query] [qsq]
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs]
	ON [qsp].[plan_id] = [rs].[plan_id]
JOIN [sys].[query_store_runtime_stats_interval] [rsi]
		ON [rs].[runtime_stats_interval_id] = [rsi].[runtime_stats_interval_id]
WHERE [qsq].[object_id] = OBJECT_ID(N'Sales.usp_GetFullProductInfo')
	AND [rs].[execution_type] = 0
	AND [rsi].[start_time] > DATEADD(HOUR, -12, GETUTCDATE())  
ORDER BY [qst].[query_text_id], [rsi].[start_time];
GO

/*
	Now change the procedure
*/
DROP PROCEDURE IF EXISTS [Sales].[usp_GetFullProductInfo];
GO

CREATE PROCEDURE [Sales].[usp_GetFullProductInfo]
	@StockItemID INT
AS	

	SELECT 
		[o].[CustomerID], 
		[o].[OrderDate], 
		[ol].[StockItemID], 
		[ol].[Quantity],
		[ol].[UnitPrice]
	FROM [Sales].[Orders] [o]
	JOIN [Sales].[OrderLines] [ol] 
		ON [o].[OrderID] = [ol].[OrderID]
	WHERE [ol].[StockItemID] = @StockItemID
	ORDER BY [o].[OrderDate] DESC;
GO


/*
	Run queries outside of SSMS
*/


/*
	Look at performance differences
*/
SELECT 
	[qst].[query_text_id],
	[qsq].[query_id],  
	[qsp].[plan_id],
	OBJECT_NAME([qsq].[object_id]) AS [ObjectName],
	[rsi].[start_time],
	[rsi].[end_time],
	[rs].[count_executions],
	[rs].[avg_cpu_time],
	[rs].[avg_logical_io_reads],
	[rs].[avg_duration],
	TRY_CONVERT(XML, [qsp].[query_plan]),
	[qst].[query_sql_text]
FROM [sys].[query_store_query] [qsq]
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs]
	ON [qsp].[plan_id] = [rs].[plan_id]
JOIN [sys].[query_store_runtime_stats_interval] [rsi]
		ON [rs].[runtime_stats_interval_id] = [rsi].[runtime_stats_interval_id]
WHERE [qsq].[object_id] = OBJECT_ID(N'Sales.usp_GetFullProductInfo')
	AND [rs].[execution_type] = 0
	AND [rsi].[start_time] > DATEADD(HOUR, -12, GETUTCDATE())  
ORDER BY [qst].[query_text_id], [rsi].[start_time];
GO


/*
	We lost the old data...
*/
SELECT 
	[qst].[query_text_id],
	[qsq].[query_id],  
	[qsp].[plan_id],
	OBJECT_NAME([qsq].[object_id]) AS [ObjectName],
	[rsi].[start_time],
	[rsi].[end_time],
	[rs].[count_executions],
	[rs].[avg_cpu_time],
	[rs].[avg_logical_io_reads],
	[rs].[avg_duration],
	TRY_CONVERT(XML, [qsp].[query_plan]),
	[qst].[query_sql_text]
FROM [sys].[query_store_query] [qsq]
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs]
	ON [qsp].[plan_id] = [rs].[plan_id]
JOIN [sys].[query_store_runtime_stats_interval] [rsi]
		ON [rs].[runtime_stats_interval_id] = [rsi].[runtime_stats_interval_id]
WHERE ([qsq].[query_id] IN (8184,8185)
	OR [qsq].[object_id] = OBJECT_ID(N'Sales.usp_GetFullProductInfo'))
	AND [rs].[execution_type] = 0
	AND [rsi].[start_time] > DATEADD(HOUR, -12, GETUTCDATE())  
ORDER BY [qst].[query_text_id], [rsi].[start_time];
GO



/*
	MUST USE ALTER PROCEDURE to maintain object_id
	Change a query in a different SP
	(remove [c].[FormalName])
*/
ALTER PROCEDURE [Application].[usp_GetPersonInfo] (@PersonID INT)
AS

	SELECT 
		[p].[FullName], 
		[p].[EmailAddress]
	FROM [Application].[People] [p]
	LEFT OUTER JOIN [Application].[Countries] [c] 
		ON [p].[PersonID] = [c].[LastEditedBy]
	WHERE [p].[PersonID] = @PersonID;
GO



/*
	Run queries outside of SSMS again
*/

/*
	show how in UI if you look at text of query BEFORE changed SP, you will get:
	-- Containing object no longer contains the selected query text.
*/


/*
	Look at performance differences
*/
SELECT 
	[qst].[query_text_id],
	[qsq].[query_id],  
	[qsp].[plan_id],
	OBJECT_NAME([qsq].[object_id]) AS [ObjectName],
	[rsi].[start_time],
	[rsi].[end_time],
	[rs].[last_execution_time],
	[rs].[count_executions],
	[rs].[avg_cpu_time],
	[rs].[avg_logical_io_reads],
	[rs].[avg_duration],
	TRY_CONVERT(XML, [qsp].[query_plan]),
	[qst].[query_sql_text]
FROM [sys].[query_store_query] [qsq]
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs]
	ON [qsp].[plan_id] = [rs].[plan_id]
JOIN [sys].[query_store_runtime_stats_interval] [rsi]
		ON [rs].[runtime_stats_interval_id] = [rsi].[runtime_stats_interval_id]
WHERE [qsq].[object_id] = OBJECT_ID(N'Application.usp_GetPersonInfo')
	AND [rs].[execution_type] = 0
	AND [rsi].[start_time] > DATEADD(HOUR, -12, GETUTCDATE())  
ORDER BY [qst].[query_text_id], [rsi].[start_time];
GO


/*
	Can we do better?
	Yes, for overall SP perf
	Need to use the time intervals, and
	just get averages for pre-change execution
	(change dates)
*/
SELECT 
	[qst].[query_text_id],
	OBJECT_NAME([qsq].[object_id]) AS [ObjectName],
	SUM([rs].[count_executions]) AS [TotalExecutions],
	AVG([rs].[avg_cpu_time]) AS [AvgCPUTime],
	AVG([rs].[avg_logical_io_reads]) AS [AvgLogicalIO],
	AVG([rs].[avg_duration]) AS [AvgDuration],
	[qst].[query_sql_text]
FROM [sys].[query_store_query] [qsq]
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs]
	ON [qsp].[plan_id] = [rs].[plan_id]
JOIN [sys].[query_store_runtime_stats_interval] [rsi]
		ON [rs].[runtime_stats_interval_id] = [rsi].[runtime_stats_interval_id]
WHERE [qsq].[object_id] = OBJECT_ID(N'Application.usp_GetPersonInfo')
	AND [rs].[execution_type] = 0
AND [rsi].[end_time] <= '2021-05-06 00:00:45.8870000 +00:00'
GROUP BY [qst].[query_text_id],	OBJECT_NAME([qsq].[object_id]), [qst].[query_sql_text];
GO

/*
	Can we do better?
	Yes, for overall SP perf
	Need to use the time intervals, and
	just get averages for pre-change execution
	(change dates)
*/
SELECT 
	[qst].[query_text_id],
	OBJECT_NAME([qsq].[object_id]) AS [ObjectName],
	[qsp].[last_execution_time],
	SUM([rs].[count_executions]) AS [TotalExecutions],
	AVG([rs].[avg_cpu_time]) AS [AvgCPUTime],
	AVG([rs].[avg_logical_io_reads]) AS [AvgLogicalIO],
	AVG([rs].[avg_duration]) AS [AvgDuration],
	[qst].[query_sql_text]
FROM [sys].[query_store_query] [qsq]
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs]
	ON [qsp].[plan_id] = [rs].[plan_id]
JOIN [sys].[query_store_runtime_stats_interval] [rsi]
		ON [rs].[runtime_stats_interval_id] = [rsi].[runtime_stats_interval_id]
WHERE [qsq].[object_id] = OBJECT_ID(N'Application.usp_GetPersonInfo')
	AND [rs].[execution_type] = 0
--AND [rsi].[end_time] >= '2019-11-04 01:40:45.8870000 +00:00'
GROUP BY [qst].[query_text_id],	OBJECT_NAME([qsq].[object_id]), [qsp].[last_execution_time], [qst].[query_sql_text];
GO


/*
	And compare...
*/
WITH PreChangeData
AS
(
	SELECT 
		[qsq].[object_id],
		OBJECT_NAME([qsq].[object_id]) AS [ObjectName],
		[qsp].[last_execution_time],
		AVG([rs].[avg_cpu_time]) AS [PREAvgCPUTime],
		AVG([rs].[avg_logical_io_reads]) AS [PREAvgLogicalIO],
		AVG([rs].[avg_duration]) AS [PREAvgDuration]
	FROM [sys].[query_store_query] [qsq]
	JOIN [sys].[query_store_query_text] [qst]
		ON [qsq].[query_text_id] = [qst].[query_text_id]
	JOIN [sys].[query_store_plan] [qsp] 
		ON [qsq].[query_id] = [qsp].[query_id]
	JOIN [sys].[query_store_runtime_stats] [rs]
		ON [qsp].[plan_id] = [rs].[plan_id]
	JOIN [sys].[query_store_runtime_stats_interval] [rsi]
			ON [rs].[runtime_stats_interval_id] = [rsi].[runtime_stats_interval_id]
	WHERE [qsq].[object_id] = OBJECT_ID(N'Application.usp_GetPersonInfo')
		AND [rs].[execution_type] = 0
		AND [rsi].[end_time] <= '2021-05-06 13:59:59.1100000 +00:00'
	GROUP BY [qsq].[object_id], OBJECT_NAME([qsq].[object_id]), [qsp].[last_execution_time]
)
SELECT 
	OBJECT_NAME([qsq].[object_id]) AS [ObjectName],
	[PreChangeData].[PreAvgCPUTime],
	AVG([rs].[avg_cpu_time]) AS [POSTAvgCPUTime],
	[PreChangeData].[PreAvgLogicalIO],
	AVG([rs].[avg_logical_io_reads]) AS [POSTAvgLogicalIO],
	[PreChangeData].[PreAvgDuration],
	AVG([rs].[avg_duration]) AS [POSTAvgDuration]
FROM [sys].[query_store_query] [qsq]
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs]
	ON [qsp].[plan_id] = [rs].[plan_id]
JOIN [sys].[query_store_runtime_stats_interval] [rsi]
		ON [rs].[runtime_stats_interval_id] = [rsi].[runtime_stats_interval_id]
JOIN PreChangeData
	ON [qsq].[object_id] = [PreChangeData].[object_id]
WHERE [qsq].[object_id] = OBJECT_ID(N'Application.usp_GetPersonInfo')
	AND [rs].[execution_type] = 0
	AND [rsi].[end_time] >= '2021-05-06 14:00:00.1100000 +00:00'
GROUP BY OBJECT_NAME([qsq].[object_id]), [PreChangeData].[PreAvgCPUTime],
	[PreChangeData].[PreAvgLogicalIO], [PreChangeData].[PreAvgDuration];
GO



/*
	Clean up
*/
USE [master];
GO

DROP DATABASE [TEST_WideWorldImporters];
GO

DROP DATABASE [CLONE_WideWorldImporters];
GO