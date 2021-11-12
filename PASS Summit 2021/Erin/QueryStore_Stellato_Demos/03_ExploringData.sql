/*============================================================================
  File:     03_ExploringData.sql

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
	Review intervals
*/
USE [WideWorldImporters];
GO

SELECT 
	[runtime_stats_interval_id],
	[start_time],
	[end_time],
	DATEADD(MINUTE, -(DATEDIFF(MINUTE, GETDATE(), GETUTCDATE())), 
		[start_time]) AS [Local_start_time],
	DATEADD(MINUTE, -(DATEDIFF(MINUTE, GETDATE(), GETUTCDATE())), 
		[end_time]) AS [Local_end_time]
FROM [WideWorldImporters].[sys].[query_store_runtime_stats_interval]
ORDER BY [runtime_stats_interval_id];
GO

/*
	Runtime stats are PER plan, PER interval
*/
SELECT [runtime_stats_interval_id], [plan_id], [count_executions],
[avg_duration], [last_duration], [min_duration], [max_duration], [stdev_duration],
[first_execution_time], [last_execution_time]
FROM [sys].[query_store_runtime_stats]
ORDER BY [plan_id], [runtime_stats_interval_id];
GO

SELECT TOP 10 *
FROM [WideWorldImporters].[sys].[query_store_runtime_stats];
GO


/*
	Look for queries in a specific time frame
	that took longer than 5 seconds
*/
SELECT
	[rsi].[start_time],
	[rsi].[end_time],
	[qt].[query_sql_text], 
	[q].[object_id], 
	[q].[last_execution_time], 
	[qp].[last_execution_time], 
	[rs].[runtime_stats_interval_id],
	[rs].[avg_duration],
	[rs].[avg_cpu_time],
	[rs].[avg_logical_io_reads],
	[rs].[avg_tempdb_space_used],
	[rs].[avg_query_max_used_memory],
	[rs].[avg_log_bytes_used]
FROM [sys].[query_store_query_text] [qt]
JOIN [sys].[query_store_query] [q]
	ON [qt].[query_text_id] = [q].[query_text_id]
JOIN [sys].[query_store_plan] [qp] 
	ON [q].[query_id] = [qp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs] 
	ON [qp].[plan_id] = [rs].[plan_id]
JOIN [sys].[query_store_runtime_stats_interval] [rsi] 
	ON [rs].[runtime_stats_interval_id] = [rsi].[runtime_stats_interval_id]
WHERE [rsi].[end_time] BETWEEN DATEADD(HOUR, -48, GETUTCDATE()) AND DATEADD(HOUR, -24, GETUTCDATE())
AND [rs].[avg_duration] >5000000
ORDER BY [rsi].[start_time], [q].[last_execution_time]



/*
	Highest execution count in last 1 hour
*/
SELECT 
	TOP 20 SUM([rs].[count_executions]) [TotalExecutions],
	[qsq].[query_id],  
	[qst].[query_sql_text], 
	CASE
		WHEN [qsq].[object_id] = 0 THEN N'Ad-hoc'
		ELSE OBJECT_NAME([qsq].[object_id]) 
	END AS [ObjectName],
	[qsp].[plan_id], 
	TRY_CONVERT(XML, [qsp].[query_plan]) [QueryPlan]
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs] 
	ON [qsp].[plan_id] = [rs].[plan_id] 
WHERE [rs].[last_execution_time] > DATEADD(HOUR, -1, GETUTCDATE())  
AND [rs].[execution_type] = 0
GROUP BY [qsq].[query_id], [qst].[query_sql_text], 
[qsq].[object_id], [qsp].[plan_id], [qsp].[query_plan]
ORDER BY SUM([rs].[count_executions]) DESC;  
GO


/*
	Why does the same SP have multiple rows in the above query?
*/
SELECT 	
	[qsq].[query_id],  
	[qst].[query_sql_text], 
	[qsq].[object_id], 
	OBJECT_NAME([qsq].[object_id]) 
FROM  [sys].[query_store_query] [qsq]
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
WHERE [qsq].[object_id] = OBJECT_ID(N'Sales.usp_GetFullProductInfo');
GO

SELECT OBJECT_DEFINITION(OBJECT_ID(N'Sales.usp_GetFullProductInfo'));
GO

/*
	Stored procedure definition
*/
CREATE PROCEDURE [Sales].[usp_GetFullProductInfo]   
	@StockItemID INT  
AS      
	SELECT     
		[o].[CustomerID],     
		[o].[OrderDate],     
		[ol].[StockItemID],     
		[ol].[Quantity],    
		[ol].[UnitPrice]   
	FROM [Sales].[Orders] [o]   JOIN [Sales].[OrderLines] [ol]     
		ON [o].[OrderID] = [ol].[OrderID]   
	WHERE [ol].[StockItemID] = @StockItemID   
	ORDER BY [o].[OrderDate] DESC;     
  
	SELECT    
		[o].[CustomerID],     
		SUM([ol].[Quantity]*[ol].[UnitPrice])   
	FROM [Sales].[Orders] [o]   JOIN [Sales].[OrderLines] [ol]     
		ON [o].[OrderID] = [ol].[OrderID]   
	WHERE [ol].[StockItemID] = @StockItemID   
	GROUP BY [o].[CustomerID]   
	ORDER BY [o].[CustomerID] ASC;  


/*
	Runtime stats for each query in the SP, by interval
*/
SELECT 
	[qsq].[query_id],  
	[qst].[query_sql_text], 
	[rsi].[runtime_stats_interval_id],
	[rsi].[start_time],
	[rsi].[end_time],
	[rs].[count_executions],
	[rs].[avg_duration],
	[rs].[avg_cpu_time],
	[rs].[avg_logical_io_reads],
	CASE
		WHEN [qsq].[object_id] = 0 THEN N'Ad-hoc'
		ELSE OBJECT_NAME([qsq].[object_id]) 
	END AS [ObjectName],
	TRY_CONVERT(XML, [qsp].[query_plan]) [QueryPlan]
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
ORDER BY [qsq].[query_id], [rsi].[runtime_stats_interval_id];
GO

/*
	Runtime stats for the SP (cumulative), by interval
*/
SELECT 
	[rsi].[runtime_stats_interval_id],
	[rsi].[start_time],
	[rsi].[end_time],
	MAX([rs].[count_executions]) [ExecutionCount],
	SUM([rs].[avg_duration]) [Total_Avg_Duration],
	SUM([rs].[avg_cpu_time]) [Total_Avg_CPU],
	SUM([rs].[avg_logical_io_reads]) [Total_Avg_LogicalIO],
	CASE
		WHEN [qsq].[object_id] = 0 THEN N'Ad-hoc'
		ELSE OBJECT_NAME([qsq].[object_id]) 
	END AS [ObjectName]
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
GROUP BY 
	[qsq].[object_id],
	[rsi].[runtime_stats_interval_id],
	[rsi].[start_time],
	[rsi].[end_time]
ORDER BY 
	[rsi].[runtime_stats_interval_id];
GO


/*
	create SP with multiple statements
*/
USE [WideWorldImporters];
GO
 
DROP PROCEDURE IF EXISTS [Sales].[usp_GetCustomerDetail];
GO
 
CREATE PROCEDURE [Sales].[usp_GetCustomerDetail]
     @CustomerName NVARCHAR(100)
AS
 
CREATE TABLE #CustomerList (
     [RowID] INT IDENTITY (1,1),
     [CustomerID] INT,
     [CustomerName] NVARCHAR (100)
     );
 
INSERT INTO #CustomerList (
     [CustomerID],
     [CustomerName]
     )
SELECT
     [CustomerID],
     [CustomerName]
FROM [Sales].[Customers]
WHERE [CustomerName] LIKE @CustomerName
UNION
SELECT
     [CustomerID],
     [CustomerName]
FROM [Sales].[Customers_Archive]
WHERE [CustomerName] LIKE @CustomerName;
 
SELECT
     [o].[CustomerID],
     [o].[OrderID],
     [il].[InvoiceLineID],
     [o].[OrderDate],
     [i].[InvoiceDate],
     [ol].[StockItemID],
     [ol].[Quantity],
     [ol].[UnitPrice],
     [il].[LineProfit]
INTO #CustomerOrders
FROM [Sales].[Orders] [o]
INNER JOIN [Sales].[OrderLines] [ol]
     ON [o].[OrderID] = [ol].[OrderID]
INNER JOIN [Sales].[Invoices] [i]
     ON [o].[OrderID] = [i].[OrderID]
INNER JOIN [Sales].[InvoiceLines] [il]
     ON [i].[InvoiceID] =  [il].[InvoiceID]
     AND [il].[StockItemID] = [ol].[StockItemID]
     AND [il].[Quantity] = [ol].[Quantity]
     AND [il].[UnitPrice] = [ol].[UnitPrice]
WHERE [o].[CustomerID] IN (SELECT [CustomerID] FROM #CustomerList);
 
SELECT
     [cl].[CustomerName],
     [si].[StockItemName],
     SUM([co].[Quantity]) AS [QtyPurchased],
     SUM([co].[Quantity]*[co].[UnitPrice]) AS [TotalCost],
     [co].[LineProfit],
     [co].[OrderDate],
     DATEDIFF(DAY,[co].[OrderDate],[co].[InvoiceDate]) AS [DaystoInvoice]
FROM #CustomerOrders [co]
INNER JOIN #CustomerList [cl]
     ON [co].[CustomerID] = [cl].[CustomerID]
INNER JOIN [Warehouse].[StockItems] [si]
     ON [co].[StockItemID] = [si].[StockItemID]
GROUP BY [cl].[CustomerName], [si].[StockItemName],[co].[InvoiceLineID],
     [co].[LineProfit], [co].[OrderDate], DATEDIFF(DAY,[co].[OrderDate],[co].[InvoiceDate])
ORDER BY [co].[OrderDate];
GO

/*	
	execute SP with different input parameters
*/
EXEC [Sales].[usp_GetCustomerDetail] N'Alvin Bollinger';
GO 10
EXEC [Sales].[usp_GetCustomerDetail] N'Tami Braggs';
GO 10
EXEC [Sales].[usp_GetCustomerDetail] N'Logan Dixon';
GO 10
EXEC [Sales].[usp_GetCustomerDetail] N'Tara Kotadia';
GO 10

/*
	check Top Resource Consumers report
	slowest query in a SP may not be easy to see in report

	Confirm what queries are in the SP
*/
SELECT
     [qsq].[query_id],
     [qsp].[plan_id],
     [qsq].[object_id],
     [qst].[query_sql_text],
     ConvertedPlan = TRY_CONVERT(XML, [qsp].[query_plan])
FROM [sys].[query_store_query] [qsq]
JOIN [sys].[query_store_query_text] [qst]
     ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp]
     ON [qsq].[query_id] = [qsp].[query_id]
WHERE [qsq].[object_id] = OBJECT_ID(N'Sales.usp_GetCustomerDetail');
GO

/*
	Check individual query performance
*/
SELECT
     [qsq].[query_id],
     [qsp].[plan_id],
     [qsq].[object_id],
     [rs].[runtime_stats_interval_id],
     [rsi].[start_time],
     [rsi].[end_time],
     [rs].[count_executions],
     [rs].[avg_duration],
     [rs].[avg_cpu_time],
     [rs].[avg_logical_io_reads],
     [rs].[avg_rowcount],
     [qst].[query_sql_text],
     ConvertedPlan = TRY_CONVERT(XML, [qsp].[query_plan])
FROM [sys].[query_store_query] [qsq]
JOIN [sys].[query_store_query_text] [qst]
     ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp]
     ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs]
     ON [qsp].[plan_id] = [rs].[plan_id]
JOIN [sys].[query_store_runtime_stats_interval] [rsi]
     ON [rs].[runtime_stats_interval_id] = [rsi].[runtime_stats_interval_id]
WHERE [qsq].[object_id] = OBJECT_ID(N'Sales.usp_GetCustomerDetail')
     AND [rs].[last_execution_time] > DATEADD(HOUR, -1, GETUTCDATE())
     AND [rs].[execution_type] = 0
ORDER BY [qsq].[query_id], [qsp].[plan_id], [rs].[runtime_stats_interval_id];
GO

/*
	drill further into the slowest query using the Query Store Tracked Queries 
	report and the query_id 
*/

/*
	we've only run the report 40 times
	run external script to run it a lot more
	(in 3_ExploringQSData)
*/

/*
	Check execution statistics again
	now we have data over more time
*/
SELECT
     [qsq].[query_id],
     [qsp].[plan_id],
     [qsq].[object_id],
     [rs].[runtime_stats_interval_id],
     [rsi].[start_time],
     [rsi].[end_time],
     [rs].[count_executions],
     [rs].[avg_duration],
     [rs].[avg_cpu_time],
     [rs].[avg_logical_io_reads],
     [rs].[avg_rowcount],
     [qst].[query_sql_text],
     ConvertedPlan = TRY_CONVERT(XML, [qsp].[query_plan])
FROM [sys].[query_store_query] [qsq]
JOIN [sys].[query_store_query_text] [qst]
     ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp]
     ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs]
     ON [qsp].[plan_id] = [rs].[plan_id]
JOIN [sys].[query_store_runtime_stats_interval] [rsi]
     ON [rs].[runtime_stats_interval_id] = [rsi].[runtime_stats_interval_id]
WHERE [qsq].[object_id] = OBJECT_ID(N'Sales.usp_GetCustomerDetail')
     AND [rs].[last_execution_time] > DATEADD(HOUR, -1, GETUTCDATE())
     AND [rs].[execution_type] = 0
ORDER BY [qsq].[query_id], [qsp].[plan_id], [rs].[runtime_stats_interval_id];
GO

/*
	When performance issue occurs,
	check data for the last hour for the SP
	(ordered by average execution time)
*/
SELECT
     [qsq].[query_id],
     [qsp].[plan_id],
     OBJECT_NAME([qsq].[object_id])AS [ObjectName],
     SUM([rs].[count_executions]) AS [TotalExecutions],
     AVG([rs].[avg_duration]) AS [Avg_Duration],
     AVG([rs].[avg_cpu_time]) AS [Avg_CPU],
     AVG([rs].[avg_logical_io_reads]) AS [Avg_LogicalReads],
     MIN([qst].[query_sql_text]) AS[Query]
FROM [sys].[query_store_query] [qsq]
JOIN [sys].[query_store_query_text] [qst]
     ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp]
     ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs]
     ON [qsp].[plan_id] = [rs].[plan_id]
JOIN [sys].[query_store_runtime_stats_interval] [rsi]
     ON [rs].[runtime_stats_interval_id] = [rsi].[runtime_stats_interval_id]
WHERE [qsq].[object_id] = OBJECT_ID(N'Sales.usp_GetCustomerDetail')
     AND [rs].[last_execution_time] > DATEADD(HOUR, -1, GETUTCDATE())
     AND [rs].[execution_type] = 0
GROUP BY [qsq].[query_id], [qsp].[plan_id], OBJECT_NAME([qsq].[object_id])
ORDER BY AVG([rs].[avg_cpu_time]) DESC;
GO


/*
	Run SP from SSMS
*/
DBCC FREEPROCCACHE;
GO
USE [WideWorldImporters];
GO
EXEC [Sales].[usp_CustomerTransactionInfo] 1050;
GO

/*
	There was another SP with multiple entries for the same query...
*/
SELECT 
	SUM([rs].[count_executions]) [TotalExecutions],
	[qsq].[query_id],  
	[qst].[query_text_id],
	[qst].[query_sql_text], 
	CASE
		WHEN [qsq].[object_id] = 0 THEN N'Ad-hoc'
		ELSE OBJECT_NAME([qsq].[object_id]) 
	END AS [ObjectName],
	[qsp].[plan_id], 
	TRY_CONVERT(XML, [qsp].[query_plan]) [QueryPlan]
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs] 
	ON [qsp].[plan_id] = [rs].[plan_id] 
WHERE [qsq].[object_id] = OBJECT_ID(N'Sales.usp_CustomerTransactionInfo')
	AND [rs].[execution_type] = 0
GROUP BY [qsq].[query_id], [qst].[query_text_id], [qst].[query_sql_text], 
[qsq].[object_id], [qsp].[plan_id], [qsp].[query_plan]
ORDER BY SUM([rs].[count_executions]) DESC;  
GO


/*
	Check the context settings
	https://skreebydba.com/2017/10/30/return-sql-server-context-settings-from-sys-query_context_settings-set_options-value/
	https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-exec-plan-attributes-transact-sql
*/
SELECT 	
	[qsq].[query_id],
	[qst].[query_text_id],  
	[qst].[query_sql_text], 
	[cs].[context_settings_id],
	[cs].[set_options],
	CONVERT(INT, [cs].[set_options]) AS IntSetOptions,
	[qsq].[object_id], 
	OBJECT_NAME([qsq].[object_id])
FROM  [sys].[query_store_query] [qsq]
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_context_settings] [cs]
	ON [qsq].[context_settings_id] = [cs].[context_settings_id]
WHERE [qsq].[object_id] = OBJECT_ID(N'Sales.usp_CustomerTransactionInfo');
GO

/*
	Values = 4347, 251
	ARITHABORT = 4096
*/
SELECT 4347 - 251;
GO

/*
	Use Frank's SP
*/
EXEC master..ReturnSetOptions 4347
GO

EXEC master..ReturnSetOptions 251
GO

