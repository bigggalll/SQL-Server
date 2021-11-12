/*============================================================================
  File:     00_QSPrep.sql

  SQL Server Versions: 2016, 2017, 2019
------------------------------------------------------------------------------
  Written by Erin Stellato, SQLskills.com
  
  (c) 2019, SQLskills.com. All rights reserved.

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

*/
ALTER DATABASE [WideWorldImporters] SET QUERY_STORE = ON;
GO
ALTER DATABASE [WideWorldImporters] SET QUERY_STORE (
	OPERATION_MODE = READ_WRITE, INTERVAL_LENGTH_MINUTES = 10
	);
GO

/*
	Optional: Clear out anything that may be in there
	ALTER DATABASE [WideWorldImporters] SET QUERY_STORE CLEAR;
	GO
*/

/*
	Create stored procedures for testing if they don't exist
	(they do exist if using CLONE database provided)
*/

/*
USE [WideWorldImporters]
GO

DROP PROCEDURE IF EXISTS [Sales].[usp_CustomerOrdersByDate];
GO

CREATE PROCEDURE [Sales].[usp_CustomerOrdersByDate]
	@StartDate DATE, @EndDate DATE
AS	

	SELECT [o].[CustomerID], [ol].[StockItemID], SUM([ol].[Quantity])
	FROM Sales.Orders [o]
	JOIN Sales.OrderLines [ol]
		ON [o].[OrderID] = [ol].[OrderID]
	WHERE [o].[OrderDate] BETWEEN @StartDate AND @EndDate
	GROUP BY [o].[CustomerID], [ol].[StockItemID]
	ORDER BY [o].[CustomerID], [ol].[StockItemID]

GO


DROP PROCEDURE IF EXISTS [Sales].[usp_CustomerTransactionInfo];
GO

CREATE PROCEDURE [Sales].[usp_CustomerTransactionInfo]
	@CustomerID INT
AS	

	SELECT [CustomerID], SUM([AmountExcludingTax])
	FROM [Sales].[CustomerTransactions]
	WHERE [CustomerID] = @CustomerID
	GROUP BY [CustomerID];
GO


DROP PROCEDURE IF EXISTS [Sales].[usp_FindOrderByDescription];
GO

CREATE PROCEDURE [Sales].[usp_FindOrderByDescription]
	@Description VARCHAR(100)
AS	

	SELECT [ol].[StockItemID], [ol].[Description], [ol].[UnitPrice],
		[o].[CustomerID], [o].[SalespersonPersonID]
	FROM [Sales].[OrderLines] [ol]
	JOIN [Sales].[Orders] [o]
		ON [ol].[OrderID] = [o].[OrderID]
	WHERE [ol].[Description] = @Description 

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
*/



/*
	Run the query below to ensure the
	appropriate plan is in cache for demo
*/
DBCC FREEPROCCACHE;
GO
USE [WideWorldImporters];
GO
EXEC [Sales].[usp_CustomerTransactionInfo] 1050;
GO


/*
	Start workload using these two files
	(external to SSMS):
	
	0_Prep_create_2_clients_usp_CustomerTransactionInfo.cmd
	0_Prep_create_2_clients_usp_GetPersonInfo.cmd
	0_Prep_create_2_clients_usp_GetFullProductInfo.cmd

	Let workload run for 2-3 minutes
*/


/*
	Add some data to the table
	to simulate data being added during a
	normal work day
*/
USE [WideWorldImporters];
GO

INSERT INTO [Sales].[CustomerTransactions](
	[CustomerTransactionID], 
	[CustomerID],
	[TransactionTypeID],
	[InvoiceID],
	[PaymentMethodID],
	[TransactionDate], 
	[AmountExcludingTax],
	[TaxAmount],
	[TransactionAmount],
	[OutstandingBalance],
	[FinalizationDate],
	[LastEditedBy],
	[LastEditedWhen]
	)
SELECT 
	[CustomerTransactionID] + 1000000, [CustomerID], 
	[TransactionTypeID], 1, [PaymentMethodID], 
	[TransactionDate], ([CustomerID] + 5) * 2, 
	(([CustomerID] + 5) * 2) * .05, 
	(([CustomerID] + 5) * 2) + ((([CustomerID] + 5) * 2) * .05), 
	[OutstandingBalance],[FinalizationDate],[LastEditedBy],
	[LastEditedWhen]
FROM [WideWorldImporters].[Sales].[CustomerTransactions] 
WHERE [AmountExcludingTax] < 100;
GO


/*
	Query to run after loading data
	to force the "bad" plan for the demo
*/
DBCC FREEPROCCACHE;
GO
USE [WideWorldImporters];
GO
EXEC [Sales].[usp_CustomerTransactionInfo] 401;
GO


/*
	Query to confirm the plan in cache
	currently is the index seek
*/
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
GO
SELECT 
	[qs].execution_count, 
	[s].[text], 
	[qs].[query_hash], 
	[qs].[query_plan_hash], 
	[cp].[size_in_bytes]/1024 AS [PlanSizeKB], 
	[qp].[query_plan], 
	[qs].[plan_handle]
FROM sys.dm_exec_query_stats AS [qs]
CROSS APPLY sys.dm_exec_query_plan ([qs].[plan_handle]) AS [qp]
CROSS APPLY sys.dm_exec_sql_text([qs].[plan_handle]) AS [s]
INNER JOIN sys.dm_exec_cached_plans AS [cp] 
	ON [qs].[plan_handle] = [cp].[plan_handle]
WHERE [s].[text] LIKE '%CustomerTransactionInfo%';
GO
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
GO

