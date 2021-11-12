/*============================================================================
  File:     04b_UsingQueryStore.sql

  SQL Server Versions: 2016, 2017, 2019
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
	Adaptive Joins
*/
USE [master];
GO
ALTER DATABASE [WideWorldImporters] SET COMPATIBILITY_LEVEL = 140;
GO

USE [WideWorldImporters];
GO

/*
	Need a columnstore index...
*/
ALTER TABLE [Sales].[Invoices] DROP CONSTRAINT [FK_Sales_Invoices_OrderID_Sales_Orders];
GO

ALTER TABLE [Sales].[Orders] DROP CONSTRAINT [FK_Sales_Orders_BackorderOrderID_Sales_Orders];
GO

ALTER TABLE [Sales].[OrderLines] DROP CONSTRAINT [FK_Sales_OrderLines_OrderID_Sales_Orders];
GO

ALTER TABLE [Sales].[Orders] DROP CONSTRAINT [PK_Sales_Orders] WITH ( ONLINE = OFF );
GO

CREATE CLUSTERED COLUMNSTORE INDEX CCI_Orders
ON [Sales].[Orders];

/*
	Enable Query Store and clear anything that may be in there
*/
ALTER DATABASE [WideWorldImporters] SET QUERY_STORE = ON;
GO

ALTER DATABASE [WideWorldImporters] SET QUERY_STORE (
	OPERATION_MODE = READ_WRITE, 
	INTERVAL_LENGTH_MINUTES = 10
	);
GO

ALTER DATABASE [WideWorldImporters] SET QUERY_STORE CLEAR;
GO

/*
	Check distribution
*/
SELECT 
	ContactPersonID, 
	count(*)
FROM Sales.Orders
GROUP BY ContactPersonID
ORDER BY COUNT(*) DESC;

/*
	Query variations
*/
SELECT o.OrderID, o.ContactPersonID, o.SalespersonPersonID, ol.OrderLineID
FROM Sales.Orders o
JOIN Sales.OrderLines ol
	ON o.OrderID = ol.OrderID
WHERE o.ContactPersonID = 3292;
GO

SELECT o.OrderID, o.ContactPersonID, o.SalespersonPersonID, ol.OrderLineID
FROM Sales.Orders o
JOIN Sales.OrderLines ol
	ON o.OrderID = ol.OrderID
WHERE o.ContactPersonID = 3291;
GO

SELECT o.OrderID, o.ContactPersonID, o.SalespersonPersonID, ol.OrderLineID
FROM Sales.Orders o
JOIN Sales.OrderLines ol
	ON o.OrderID = ol.OrderID
WHERE o.ContactPersonID = 3267;
GO

SELECT o.OrderID, o.ContactPersonID, o.SalespersonPersonID, ol.OrderLineID
FROM Sales.Orders o
JOIN Sales.OrderLines ol
	ON o.OrderID = ol.OrderID
WHERE o.ContactPersonID = 1181;
GO

/*
	What's in QS?
*/
USE [WideWorldImporters];
GO

SELECT
	[qsq].[query_id], 
	[qsp].[plan_id],
	[qsq].[object_id],
	[rs].[count_executions],
	[rs].[last_execution_time],
	[qsq].[query_hash],
	[qsp].[query_plan_hash],
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
	ON [qsp].[plan_id] = [rs].[plan_id];
GO


/*
	Put into a SP
*/
DROP PROCEDURE IF EXISTS [Sales].[usp_OrderInfo_ContactPerson];
GO

CREATE PROCEDURE [Sales].[usp_OrderInfo_ContactPerson]
	@ContactPersonID INT
AS	

	SELECT o.OrderID, o.ContactPersonID, o.SalespersonPersonID, ol.OrderLineID
	FROM Sales.Orders o
	JOIN Sales.OrderLines ol
	ON o.OrderID = ol.OrderID
	WHERE o.ContactPersonID = @ContactPersonID;
GO

EXEC [Sales].[usp_OrderInfo_ContactPerson] 3292;
GO

EXEC [Sales].[usp_OrderInfo_ContactPerson] 3267;
GO

EXEC [Sales].[usp_OrderInfo_ContactPerson] 1181;
GO

sp_recompile '[Sales].[usp_OrderInfo_ContactPerson]';
GO

EXEC [Sales].[usp_OrderInfo_ContactPerson] 1181;
GO

EXEC [Sales].[usp_OrderInfo_ContactPerson] 3267;
GO

EXEC [Sales].[usp_OrderInfo_ContactPerson] 3292;
GO



/*
	What's in QS?
*/
USE [WideWorldImporters];
GO

SELECT
	[qsq].[query_id], 
	[qsp].[plan_id],
	[qsq].[object_id],
	[rs].[count_executions],
	[rs].[last_execution_time],
	[qsq].[query_hash],
	[qsp].[query_plan_hash],
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
	ON [qsp].[plan_id] = [rs].[plan_id];
GO

/*
	Queries with multiple plans
*/
SELECT
	[qsq].[query_id], 
	COUNT([qsp].[plan_id]) AS [PlanCount],
	OBJECT_NAME([qsq].[object_id]) [ObjectName], 
	MAX(DATEADD(MINUTE, -(DATEDIFF(MINUTE, GETDATE(), GETUTCDATE())), 
		[qsp].[last_execution_time])) AS [LocalLastExecutionTime],
	MAX([qst].query_sql_text) AS [Query_Text]
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
WHERE [qsp].[last_execution_time] > DATEADD(HOUR, -8, GETUTCDATE())
GROUP BY [qsq].[query_id], [qsq].[object_id]
HAVING COUNT([qsp].[plan_id]) > 1;
GO

/*
	What are the plans for that query?
	(can also use Track Query)
*/
SELECT
	[qsq].[query_id], 
	[qsp].[plan_id],
	[qsq].[object_id],
	[qsq].[query_hash],
	[qsp].[query_plan_hash],
	[qst].[query_sql_text],
	TRY_CONVERT(XML, [qsp].[query_plan]) AS [QueryPlan_XML]
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
WHERE [qsp].[query_id] = 12;
GO



/*
	Set compat mode to 120
*/
ALTER DATABASE [WideWorldImporters] SET COMPATIBILITY_LEVEL = 120;
GO

/*
	Clear procedure cache for the DB
*/
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO

DROP PROCEDURE IF EXISTS [Sales].[usp_OrderInfo_OrderDate];
GO

CREATE PROCEDURE [Sales].[usp_OrderInfo_OrderDate]
	@StartDate DATETIME,
	@EndDate DATETIME
AS
SELECT
	[o].[CustomerID],
	[o].[OrderDate],
	[o].[ContactPersonID],
	[ol].[Quantity]
FROM [Sales].[Orders] [o]
JOIN [Sales].[OrderLines] [ol]
	ON [o].[OrderID] = [ol].[OrderID]
WHERE [OrderDate] BETWEEN @StartDate AND @EndDate
ORDER BY [OrderDate];
GO

/*
	Run each of these a few times and check memory grant
*/
DECLARE @StartDate DATETIME = '2016-01-01'
DECLARE @EndDate DATETIME = '2016-01-08'

EXEC [Sales].[usp_OrderInfo_OrderDate] @StartDate, @EndDate;
GO

DECLARE @StartDate DATETIME = '2016-01-01'
DECLARE @EndDate DATETIME = '2016-06-30'

EXEC [Sales].[usp_OrderInfo_OrderDate] @StartDate, @EndDate;
GO

/*
	What's in QS
*/
SELECT
	[qsq].[query_id], 
	[qsp].[plan_id], 
	[qsq].[object_id], 
	[rs].[count_executions],
	[rs].[avg_query_max_used_memory],
	[rs].[last_query_max_used_memory],
	[rs].[min_query_max_used_memory],
	[rs].[max_query_max_used_memory],
	[rs].[stdev_query_max_used_memory],
	DATEADD(MINUTE, -(DATEDIFF(MINUTE, GETDATE(), GETUTCDATE())), 
		[qsp].[last_execution_time]) AS [LocalLastExecutionTime],
	[qst].[query_sql_text], 
	ConvertedPlan = TRY_CONVERT(XML, [qsp].[query_plan])
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs] 
	ON [qsp].[plan_id] = [rs].[plan_id]
WHERE [qsq].[object_id] = OBJECT_ID(N'Sales.usp_OrderInfo_OrderDate');
GO


/*
	Set compat mode to 140
*/
ALTER DATABASE [WideWorldImporters] SET COMPATIBILITY_LEVEL = 140;
GO

/*
	Clear procedure cache for the DB
*/
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO

/*
	Run each of these a few times and check memory grant
*/
DECLARE @StartDate DATETIME = '2016-01-01'
DECLARE @EndDate DATETIME = '2016-01-08'

EXEC [Sales].[usp_OrderInfo_OrderDate] @StartDate, @EndDate;
GO

DECLARE @StartDate DATETIME = '2016-01-01'
DECLARE @EndDate DATETIME = '2016-06-30'

EXEC [Sales].[usp_OrderInfo_OrderDate] @StartDate, @EndDate;
GO


/*
	What's in QS
*/
SELECT
	[qsq].[query_id], 
	[qsp].[plan_id], 
	[qsq].[object_id], 
	[qsp].[compatibility_level],
	[rs].[count_executions],
	[rs].[avg_query_max_used_memory],
	[rs].[last_query_max_used_memory],
	[rs].[min_query_max_used_memory],
	[rs].[max_query_max_used_memory],
	[rs].[stdev_query_max_used_memory],
	DATEADD(MINUTE, -(DATEDIFF(MINUTE, GETDATE(), GETUTCDATE())), 
		[qsp].[last_execution_time]) AS [LocalLastExecutionTime],
	[qst].[query_sql_text], 
	ConvertedPlan = TRY_CONVERT(XML, [qsp].[query_plan])
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs] 
	ON [qsp].[plan_id] = [rs].[plan_id]
WHERE [qsq].[object_id] = OBJECT_ID(N'Sales.usp_OrderInfo_OrderDate');
GO


/*
	Find queries with high deviation in memory
*/
SELECT
	[qsq].[query_id], 
	[qsp].[plan_id], 
	[qsq].[object_id], 
	[qsp].[compatibility_level],
	[rs].[count_executions],
	[rs].[avg_query_max_used_memory],
	[rs].[last_query_max_used_memory],
	[rs].[min_query_max_used_memory],
	[rs].[max_query_max_used_memory],
	[rs].[stdev_query_max_used_memory],
	DATEADD(MINUTE, -(DATEDIFF(MINUTE, GETDATE(), GETUTCDATE())), 
		[qsp].[last_execution_time]) AS [LocalLastExecutionTime],
	[qst].[query_sql_text], 
	ConvertedPlan = TRY_CONVERT(XML, [qsp].[query_plan])
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs] 
	ON [qsp].[plan_id] = [rs].[plan_id]
WHERE [rs].[stdev_query_max_used_memory] > 1000;
GO

/*
	check the variation report
*/

/*
	reset
*/
ALTER TABLE [Sales].[Orders] ADD  CONSTRAINT [PK_Sales_Orders] PRIMARY KEY CLUSTERED 
(
	[OrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [USERDATA]
GO

ALTER TABLE [Sales].[Invoices]  WITH CHECK ADD  CONSTRAINT [FK_Sales_Invoices_OrderID_Sales_Orders] FOREIGN KEY([OrderID])
REFERENCES [Sales].[Orders] ([OrderID])
GO

ALTER TABLE [Sales].[Invoices] CHECK CONSTRAINT [FK_Sales_Invoices_OrderID_Sales_Orders]
GO

ALTER TABLE [Sales].[Orders]  WITH CHECK ADD  CONSTRAINT [FK_Sales_Orders_BackorderOrderID_Sales_Orders] FOREIGN KEY([BackorderOrderID])
REFERENCES [Sales].[Orders] ([OrderID])
GO

ALTER TABLE [Sales].[Orders] CHECK CONSTRAINT [FK_Sales_Orders_BackorderOrderID_Sales_Orders]
GO

ALTER TABLE [Sales].[OrderLines]  WITH CHECK ADD  CONSTRAINT [FK_Sales_OrderLines_OrderID_Sales_Orders] FOREIGN KEY([OrderID])
REFERENCES [Sales].[Orders] ([OrderID])
GO

ALTER TABLE [Sales].[OrderLines] CHECK CONSTRAINT [FK_Sales_OrderLines_OrderID_Sales_Orders]
GO



/*
	reset
*/
DROP INDEX  CCI_Orders ON [Sales].[Orders];
GO

ALTER TABLE [Sales].[Orders] ADD  CONSTRAINT [PK_Sales_Orders] PRIMARY KEY CLUSTERED 
(
	[OrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [USERDATA]
GO

ALTER TABLE [Sales].[Invoices]  WITH CHECK ADD  CONSTRAINT [FK_Sales_Invoices_OrderID_Sales_Orders] FOREIGN KEY([OrderID])
REFERENCES [Sales].[Orders] ([OrderID])
GO

ALTER TABLE [Sales].[Invoices] CHECK CONSTRAINT [FK_Sales_Invoices_OrderID_Sales_Orders]
GO

ALTER TABLE [Sales].[Orders]  WITH CHECK ADD  CONSTRAINT [FK_Sales_Orders_BackorderOrderID_Sales_Orders] FOREIGN KEY([BackorderOrderID])
REFERENCES [Sales].[Orders] ([OrderID])
GO

ALTER TABLE [Sales].[Orders] CHECK CONSTRAINT [FK_Sales_Orders_BackorderOrderID_Sales_Orders]
GO

ALTER TABLE [Sales].[OrderLines]  WITH CHECK ADD  CONSTRAINT [FK_Sales_OrderLines_OrderID_Sales_Orders] FOREIGN KEY([OrderID])
REFERENCES [Sales].[Orders] ([OrderID])
GO

ALTER TABLE [Sales].[OrderLines] CHECK CONSTRAINT [FK_Sales_OrderLines_OrderID_Sales_Orders]
GO