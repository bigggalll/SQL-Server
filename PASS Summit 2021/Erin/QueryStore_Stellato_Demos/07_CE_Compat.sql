/*============================================================================
  File:     07_CE_Compat.sql

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
	Enable query store, configure settings
	Clear out anything that may be in there

*/
ALTER DATABASE [WideWorldImporters] SET QUERY_STORE = ON;
GO
ALTER DATABASE [WideWorldImporters] SET QUERY_STORE (
	OPERATION_MODE = READ_WRITE, INTERVAL_LENGTH_MINUTES = 10
	);
GO

ALTER DATABASE [WideWorldImporters] SET QUERY_STORE CLEAR;
GO

/*
	CE example...
*/
USE [master];
GO
ALTER DATABASE [WideWorldImporters] 
	SET COMPATIBILITY_LEVEL = 150;

USE [WideWorldImporters]
GO
ALTER DATABASE SCOPED CONFIGURATION 
	SET LEGACY_CARDINALITY_ESTIMATION = ON;
GO

/*
	Query 1
	Enable actual plan!
*/
USE [WideWorldImporters];
GO

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
JOIN [Sales].[Customers] [c]
	ON [o].[CustomerID] = [c].[CustomerID]
WHERE ([o].[OrderDate] >= '2016-10-01'
	AND [o].[OrderDate] <= '2016-12-31')
	AND [c].[CreditLimit] >= 3000.00
GO 10

/*
	Query 2
*/
SELECT 
	[CustomerID], 
	[CustomerTransactionID]
FROM [Sales].[CustomerTransactions]
WHERE [CustomerID] = 401
AND [TransactionDate] = '2016-11-13';
GO 10

/*
	Look at CE version in ACTUAL plans
	*before* running query below!
*/

/*
	Get the query_text_id for both!
	Note the Compat Mode, CE, etc.
*/
SELECT 
    [qst].[query_text_id],
	[qsq].[query_id],  
	[qsq].[query_hash],
	[qst].[query_sql_text], 
	[qsp].[compatibility_level],
	[qsp].[engine_version],
	[qsp].[plan_id], 
    [rs].[last_execution_time],
	(DATEADD(MINUTE, -(DATEDIFF(MINUTE, GETDATE(), GETUTCDATE())), 
	[rs].[last_execution_time])) AS [LocalLastExecutionTime],
	TRY_CONVERT(XML, [qsp].[query_plan])
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs] 
	ON [qsp].[plan_id] = [rs].[plan_id] 
WHERE [qst].[query_sql_text] LIKE '%OrderLines%'
	OR [qst].[query_sql_text] LIKE '%CustomerTransactions%'
ORDER BY (DATEADD(MINUTE, -(DATEDIFF(MINUTE, GETDATE(), GETUTCDATE())), 
	[rs].[last_execution_time])) DESC;
GO


/*
	Switch to new CE
	Leave compat mode at 150
*/
USE [WideWorldImporters]
GO
ALTER DATABASE SCOPED CONFIGURATION 
	SET LEGACY_CARDINALITY_ESTIMATION = OFF;
GO


/*
	Query 1
*/
USE [WideWorldImporters];
GO

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
JOIN [Sales].[Customers] [c]
	ON [o].[CustomerID] = [c].[CustomerID]
WHERE ([o].[OrderDate] >= '2016-10-01'
	AND [o].[OrderDate] <= '2016-12-31')
	AND [c].[CreditLimit] >= 3000.00
GO 10

/*
	Query 2
*/
SELECT 
	[CustomerID], 
	[CustomerTransactionID]
FROM [Sales].[CustomerTransactions]
WHERE [CustomerID] = 401
AND [TransactionDate] = '2016-11-13';
GO 10

/*
	Look at CE version in ACTUAL plans
	*before* running query below!
*/

/*
	Check queries
		For Query 1: NEW PLAN with new CE
		For Query 2: SAME PLAN, but different CE versions in ACTUAL plan
			Only the first version is stored in cache
			(query_plan_hash doesn't change)
*/
SELECT 
    [qst].[query_text_id],
	[qsq].[query_id],  
	[qsp].[plan_id], 
	[qsp].[compatibility_level],
	[qsq].[query_hash],
	[qsp].[query_plan_hash],
	[qsp].[engine_version],
    [rs].[last_execution_time],
	[qst].[query_sql_text], 
	(DATEADD(MINUTE, -(DATEDIFF(MINUTE, GETDATE(), GETUTCDATE())), 
	[rs].[last_execution_time])) AS [LocalLastExecutionTime],
	TRY_CONVERT(XML, [qsp].[query_plan])
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs] 
	ON [qsp].[plan_id] = [rs].[plan_id] 
WHERE [qst].[query_text_id] IN (1,2)
ORDER BY [qsq].[query_id],  [qsp].[plan_id];
GO

/*
	Find the queries with new plans,
	based on when CE change was made
*/	
;WITH new AS
(
	SELECT [p2].[plan_id]
	FROM [sys].[query_store_plan] [p2]
	JOIN (
		SELECT [p].[query_id], [p].[plan_id]
		FROM [sys].[query_store_plan] [p] 
		WHERE [p].[last_execution_time] >	'2021-11-09 04:31:21.4230000 +00:00'
		) [p1] ON [p2].[query_id] = [p1].[query_id]
	GROUP BY [p2].[plan_id]
	HAVING COUNT([p2].[plan_id]) > 1
)
SELECT 
    [qst].[query_text_id],
	[qsq].[query_id],  
	[qsp].[plan_id], 
	[qsp].[compatibility_level],
	[qsq].[query_hash],
	[qsp].[query_plan_hash],
	[qsp].[engine_version],
    [qsp].[last_execution_time],
	[rs].[avg_logical_io_reads], 
	[rs].[avg_duration],
	[rs].[avg_cpu_time],
	[qst].[query_sql_text], 
	TRY_CONVERT(XML, [qsp].[query_plan])
FROM [sys].[query_store_plan] [qsp] 
JOIN [new]
	ON [new].[plan_id] = [qsp].[plan_id]
JOIN [sys].[query_store_query] [qsq] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_runtime_stats] [rs] 
	ON [qsp].[plan_id] = [rs].[plan_id] 
ORDER BY [qsq].[query_id], [qsp].[plan_id];
GO


/*
	just in case...
*/
EXEC sp_query_store_remove_query @query_ID = 1
GO

/*
	Use Columnstore index for next demo, and set DB to use old CE,
	as if we just upgraded from SQL 2012
*/

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
	Run two queries
*/
USE [WideWorldImporters];
GO

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
WHERE [ol].[Description] LIKE 'Superhero action jacket (Blue)%'
AND [o].[OrderDate] = '2016-08-22';
GO 10

SELECT
	[o].[CustomerID], 
	SUM([ol].[Quantity]*[ol].[UnitPrice])
FROM [Sales].[Orders] [o]
JOIN [Sales].[OrderLines] [ol] 
	ON [o].[OrderID] = [ol].[OrderID]
WHERE [ol].[StockItemID] = 90
GROUP BY [o].[CustomerID]
ORDER BY [o].[CustomerID] ASC;
GO 5


/*
	Find our queries
	note the query_ids
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
GO

/*
	Change compat mode to 150
*/
USE [master];
GO
ALTER DATABASE [WideWorldImporters] 
	SET COMPATIBILITY_LEVEL = 150;
GO


/*
	Re-run our queries
*/
USE [WideWorldImporters];
GO

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
WHERE [ol].[Description] LIKE 'Superhero action jacket (Blue)%'
AND [o].[OrderDate] = '2016-08-22';
GO 10

SELECT
	[o].[CustomerID], 
	SUM([ol].[Quantity]*[ol].[UnitPrice])
FROM [Sales].[Orders] [o]
JOIN [Sales].[OrderLines] [ol] 
	ON [o].[OrderID] = [ol].[OrderID]
WHERE [ol].[StockItemID] = 90
GROUP BY [o].[CustomerID]
ORDER BY [o].[CustomerID] ASC;
GO 5


/*
	Flush QS data to disk
*/
EXEC [sys].[sp_query_store_flush_db];
GO

/*
	Find our queries again
*/
SELECT 
    [qst].[query_text_id],
	[qsq].[query_id],  
	[qst].[query_sql_text], 
	[qsp].[compatibility_level],
	[qsp].[engine_version],
	[qsq].[query_hash],
	[qsp].[query_plan_hash],
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
WHERE [qst].[query_text_id] in (15, 16); 
GO

/*
	Could also test with QUERYTRACEON hints
	But this creates a different query_text_id
*/
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
WHERE [ol].[Description] LIKE 'Superhero action jacket (Blue)%'
AND [o].[OrderDate] = '2016-08-22'
OPTION (QUERYTRACEON 9481); -- revert to 2012 CE
GO 10

/*
	Find the query again...
	Note the compatibility_level
	Can use query_plan_hash to confirm they're the same
*/
SELECT 
    [qst].[query_text_id],
	[qsq].[query_id],  
	[qst].[query_sql_text], 
	[qsp].[compatibility_level],
	[qsp].[engine_version],
	[qsq].[query_hash],
	[qsp].[query_plan_hash],
	[qsp].[plan_id], 
    [rs].[last_execution_time],
	(DATEADD(MINUTE, -(DATEDIFF(MINUTE, GETDATE(), GETUTCDATE())), 
	[rs].[last_execution_time])) AS [LocalLastExecutionTime],
	TRY_CONVERT(XML, [qsp].[query_plan])
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs] 
	ON [qsp].[plan_id] = [rs].[plan_id] 
WHERE [qst].[query_sql_text] LIKE '%Superhero action%'
ORDER BY (DATEADD(MINUTE, -(DATEDIFF(MINUTE, GETDATE(), GETUTCDATE())), 
	[rs].[last_execution_time])) DESC;
GO



/*
	Restore DB (has SPs created)
*/
USE [master];
GO
RESTORE DATABASE [AdventureWorks2012] 
	FROM  DISK = N'C:\Backups\AW2012_QTA.bak' WITH  FILE = 1,  
	REPLACE,  
	STATS = 5;
GO

ALTER DATABASE [AdventureWorks2012] SET COMPATIBILITY_LEVEL = 100;
GO

/*
USE [master]
GO
CREATE LOGIN [aw_webuser] WITH PASSWORD=N'12345', DEFAULT_DATABASE=[AdventureWorks2012], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
USE [AdventureWorks2012]
GO
CREATE USER [aw_webuser] FOR LOGIN [aw_webuser]
GO
*/
USE [AdventureWorks2012]
GO
ALTER ROLE [db_owner] ADD MEMBER [aw_webuser]
GO


/*
	Check compat mode
*/
SELECT 
	name, 
	compatibility_level
FROM sys.databases
WHERE name = 'AdventureWorks2012'


/*
	Start QTA through UI
	Start Workload
	Can check tables created
*/
USE [AdventureWorks2012];
GO

SELECT *
FROM [msqta].[ExecutionStat];
GO

SELECT *
FROM [msqta].[MetaData];
GO

SELECT *
FROM [msqta].[QueryOptionGroup];
GO

SELECT *
FROM [msqta].[TuningQuery];
GO

SELECT *
FROM [msqta].[TuningSession];
GO

SELECT *
FROM [msqta].[TuningSession_TuningQuery];
GO


/*
	Go through UI
	Check compat mode after...
*/
SELECT 
	name, 
	compatibility_level
FROM sys.databases
WHERE name = 'AdventureWorks2012'

/*
	Check QTA tables after
*/
USE [AdventureWorks2012];
GO

SELECT *
FROM [msqta].[ExecutionStat];
GO

SELECT *
FROM [msqta].[MetaData];
GO

SELECT *
FROM [msqta].[QueryOptionGroup];
GO

SELECT *
FROM [msqta].[TuningQuery];
GO

SELECT *
FROM [msqta].[TuningSession];
GO

SELECT *
FROM [msqta].[TuningSession_TuningQuery];
GO

/*
	find plan guide info
*/
SELECT *
FROM sys.plan_guides;
GO


/*
	Clean up (optional)
*/
/*
DROP TABLE [msqta].[ExecutionStat];
GO
DROP TABLE [msqta].[MetaData];
GO
DROP TABLE [msqta].[QueryOptionGroup];
GO
DROP TABLE [msqta].[TuningQuery];
GO
DROP TABLE [msqta].[TuningSession];
GO
DROP TABLE [msqta].[TuningSession_TuningQuery];
GO
*/




/*
	kick off restore of DB for next demos!
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
