/*============================================================================
  File:     10c_ForcingCE.sql

  SQL Server Versions: 2017+, Azure SQL DB
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
	Set compat mode to 110 and
	set DB to use old CE,
	as if we just upgraded from SQL 2012
*/
USE [master];
GO
ALTER DATABASE [WideWorldImporters] 
	SET COMPATIBILITY_LEVEL = 110;

USE [WideWorldImporters]
GO
ALTER DATABASE SCOPED CONFIGURATION 
	SET LEGACY_CARDINALITY_ESTIMATION = ON;
GO

/*
	Create a SP and execute
*/
USE [WideWorldImporters];
GO

DROP PROCEDURE IF EXISTS [Sales].[Order_CE];
GO

CREATE PROCEDURE [Sales].[Order_CE]
	@Description NVARCHAR(200),
	@OrderDate DATE 
AS
BEGIN
	SELECT 
		[ol].[StockItemID], 
		[ol].[Description], 
		[ol].[UnitPrice],
		[o].[CustomerID], 
		[o].[SalespersonPersonID],
		[o].[OrderDate]
	FROM [Sales].[OrderLines] [ol]
	JOIN [Sales].[Orders] [o]
		ON [ol].[OrderID] = [o].[OrderID]
	WHERE [ol].[Description] LIKE @Description
	AND [o].[OrderDate] = @OrderDate;
END
GO

/*
	Run our SP
*/
EXEC [Sales].[Order_CE] @Description = 'Superhero action jacket (Blue)%', @OrderDate = '2016-08-22';
GO

/*
	Find our query
	can note the query_id
*/
SELECT 
    [qst].[query_text_id],
	[qsq].[query_id],  
	[qst].[query_sql_text], 
	[qsp].[compatibility_level],
	[qsp].[engine_version],
	[rs].[count_executions],
	[qsp].[plan_id], 
    [rs].[last_execution_time],
	(DATEADD(MINUTE, -(DATEDIFF(MINUTE, GETDATE(), GETUTCDATE())), 
	[rs].[last_execution_time])) AS [LocalLastExecutionTime],
	TRY_CONVERT(XML, [qsp].[query_plan]) AS [QueryPlan_XML]
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs] 
	ON [qsp].[plan_id] = [rs].[plan_id] 
WHERE [qsp].[compatibility_level] < 120;
--WHERE [qsp].[object_id] = OBJECT_ID('Sales.Order_CE');
GO

/*
	Now set compat mode to 150
*/
USE [master];
GO
ALTER DATABASE [WideWorldImporters] 
	SET COMPATIBILITY_LEVEL = 150;
GO

USE [WideWorldImporters]
GO
ALTER DATABASE SCOPED CONFIGURATION 
	SET LEGACY_CARDINALITY_ESTIMATION = OFF;
GO

/*
	Re-run the SP
*/
EXEC [Sales].[Order_CE] @Description = 'Superhero action jacket (Blue)%', @OrderDate = '2016-08-22';
GO


/*
	Flush QS data to disk
*/
EXEC [sys].[sp_query_store_flush_db];
GO

/*
	Find our query
*/
SELECT 
    [qst].[query_text_id],
	[qsq].[query_id],  
	[qst].[query_sql_text], 
	[qsp].[compatibility_level],
	[qsp].[engine_version],
	[rs].[count_executions],
	[qsp].[plan_id], 
    [rs].[last_execution_time],
	(DATEADD(MINUTE, -(DATEDIFF(MINUTE, GETDATE(), GETUTCDATE())), 
	[rs].[last_execution_time])) AS [LocalLastExecutionTime],
	TRY_CONVERT(XML, [qsp].[query_plan]) AS [QueryPlan_XML]
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs] 
	ON [qsp].[plan_id] = [rs].[plan_id] 
WHERE [qsq].[object_id] = OBJECT_ID('Sales.Order_CE');
--WHERE [qsq].[query_id] = 8293; 
GO

/*
	Compare performance of different compat modes
*/
SELECT 
    [qst].[query_text_id],
	[qsq].[query_id],  
	[qsp].[compatibility_level],
	[qsp].[engine_version],
	[qsp].[plan_id], 
	[rs].[avg_cpu_time],
	[rs].[avg_logical_io_reads],
	[rs].[avg_duration],
	TRY_CONVERT(XML, [qsp].[query_plan]),
	[qst].[query_sql_text],
	[qsp].[query_plan_hash]
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs] 
	ON [qsp].[plan_id] = [rs].[plan_id] 
WHERE [qsq].[object_id] = OBJECT_ID('Sales.Order_CE');
--WHERE [qsq].[query_id] = 8293; 
GO

/*
	Force the old CE plan in the UI 
	(find by query_id)
	Run our query one last time...
	What plan do we get?
*/
EXEC [Sales].[Order_CE] @Description = 'Superhero action jacket (Blue)%', @OrderDate = '2016-08-22';
GO