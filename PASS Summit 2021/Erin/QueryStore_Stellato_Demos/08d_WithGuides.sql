/*============================================================================
  File:     08d_WithGuides.sql

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
	Enable QS and clear data
*/

ALTER DATABASE [WideWorldImporters] SET QUERY_STORE = ON;
GO

ALTER DATABASE [WideWorldImporters] 
SET QUERY_STORE = ON 
    (
      OPERATION_MODE = READ_WRITE, 
      CLEANUP_POLICY = ( STALE_QUERY_THRESHOLD_DAYS = 30 ),
      DATA_FLUSH_INTERVAL_SECONDS = 900,
      MAX_STORAGE_SIZE_MB = 1024, 
      INTERVAL_LENGTH_MINUTES = 1,
      SIZE_BASED_CLEANUP_MODE = AUTO, 
      MAX_PLANS_PER_QUERY = 200,
      WAIT_STATS_CAPTURE_MODE = ON,
      QUERY_CAPTURE_MODE = AUTO
    );


ALTER DATABASE [WideWorldImporters] SET QUERY_STORE CLEAR;
GO


		SELECT @QueryString = N'SELECT w.ColorID, s.StockItemName
								FROM Warehouse.Colors w
								JOIN Warehouse.StockItems s
									ON w.ColorID = s.ColorID
								WHERE w.ColorName = ''' + @ConcatString + ''''
		
		EXEC (@QueryString)

		SELECT @QueryString = N'SELECT TOP 1 o.SalesPersonPersonID, o.OrderDate, ol.StockItemID
								FROM Sales.Orders o
								JOIN Sales.OrderLines ol
									ON o.OrderID = ol.OrderID
								WHERE o.CustomerID = ' + SUBSTRING(@ConcatString,1, 5) + ''

ALTER DATABASE [WideWorldImporters] 
	SET QUERY_STORE CLEAR;
GO

USE [WideWorldImporters];
GO  
EXEC sp_control_plan_guide N'DROP ALL';  
GO  


DECLARE @SQLStatement NVARCHAR(MAX);
DECLARE @Parameters NVARCHAR(MAX);
EXEC sp_get_query_template 
    N'SELECT w.ColorID, s.StockItemName
								FROM Warehouse.Colors w
								JOIN Warehouse.StockItems s
									ON w.ColorID = s.ColorID
								WHERE w.ColorName = ''Black''',
	@SQLStatement OUTPUT,
	@Parameters OUTPUT
	  
EXEC sp_create_plan_guide   
    @name =  N'Query1_PlanGuide',  
	@stmt = @SQLStatement,
    @type = N'TEMPLATE',  
    @module_or_batch = NULL,  
    @params = @Parameters,  
    @hints = N'OPTION (PARAMETERIZATION FORCED)'; 


DECLARE @SQLStatement NVARCHAR(MAX);
DECLARE @Parameters NVARCHAR(MAX);
EXEC sp_get_query_template 
    N'SELECT TOP 1 o.SalesPersonPersonID, o.OrderDate, ol.StockItemID
								FROM Sales.Orders o
								JOIN Sales.OrderLines ol
									ON o.OrderID = ol.OrderID
								WHERE o.CustomerID = 254',
	@SQLStatement OUTPUT,
	@Parameters OUTPUT
	  
EXEC sp_create_plan_guide   
    @name =  N'Query2_PlanGuide',  
	@stmt = @SQLStatement,
    @type = N'TEMPLATE',  
    @module_or_batch = NULL,  
    @params = @Parameters,  
    @hints = N'OPTION (PARAMETERIZATION FORCED)'; 


/*
	Run 5_AdHoc_multiple_clients to generate adhoc workload
	watch PerfMon
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
	[qsq].[avg_compile_duration],
	[rs].[avg_cpu_time],
	[rs].[avg_duration],
	[rs].[avg_logical_io_reads],
	[rs].[last_execution_time],
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
OR type like '%QueryDiskStore%'
GROUP BY type
ORDER BY type;
GO


/*
	Last test
*/
USE [master];
GO

ALTER DATABASE [WideWorldImporters] 
	SET QUERY_STORE CLEAR;
GO

ALTER DATABASE [WideWorldImporters] 
	SET PARAMETERIZATION FORCED WITH NO_WAIT;
GO

USE [WideWorldImporters];
GO  
EXEC sp_control_plan_guide N'DROP ALL';  
GO  


/*
	Run 5_AdHoc_multiple_clients to generate adhoc workload
	watch PerfMon
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
	[qsq].[avg_compile_duration],
	[rs].[avg_cpu_time],
	[rs].[avg_duration],
	[rs].[avg_logical_io_reads],
	[rs].[last_execution_time],
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
OR type like '%QueryDiskStore%'
GROUP BY type
ORDER BY type;
GO

/*
	clean up
*/
USE [master];
GO

ALTER DATABASE [WideWorldImporters] 
	SET PARAMETERIZATION SIMPLE WITH NO_WAIT;
GO