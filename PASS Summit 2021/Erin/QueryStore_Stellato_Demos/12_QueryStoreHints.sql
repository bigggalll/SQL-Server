/*============================================================================
  File:     12_QueryStoreHints.sql

  SQL Server Versions: Azure SQL Database
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
	Clear out anything in QS
*/
ALTER DATABASE [WWI_PS] 
	SET QUERY_STORE CLEAR;
GO


/*
	Create procedure for testing
*/
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


/*
	Enable actual plan
*/
SET STATISTICS IO, TIME ON;
GO

EXEC [Sales].[usp_CustomerTransactionInfo] 860;
GO

EXEC [Sales].[usp_CustomerTransactionInfo] 401;
GO

/*
	Clear cache
*/
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO

/*
	Run with 401 again
*/
EXEC [Sales].[usp_CustomerTransactionInfo] 401;
GO

/*
	Check distribution
*/
SELECT [CustomerID], COUNT(*)
FROM [Sales].[CustomerTransactions]
GROUP BY [CustomerID]
ORDER BY COUNT(*) DESC;
GO

/*
	How to apply the hint?
	Need the query_id
*/
EXEC sys.sp_query_store_set_hints @query_id= 2, @query_hints = N'OPTION(RECOMPILE)';


/*
	Re-run
	No need to clear cache...
	ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
*/
EXEC [Sales].[usp_CustomerTransactionInfo] 860;
GO

EXEC [Sales].[usp_CustomerTransactionInfo] 401;
GO

/*
	Long term solution is to create the recommended index
*/
CREATE NONCLUSTERED INDEX [NCI_CustomerTransactions]
	ON [Sales].[CustomerTransactions] ([CustomerID])
	INCLUDE ([AmountExcludingTax])
	WITH (DROP_EXISTING=ON);
GO

/*
	Another scenario
*/
SELECT o.CustomerID, ol.OrderID, ol.OrderLineID, o.OrderDate
FROM Sales.Orders o
JOIN Sales.OrderLines ol
    ON o.OrderID = ol.OrderID
WHERE o.CustomerID = 402
ORDER BY CustomerID, o.OrderID;
GO

/*
	Find the query_id in QS
*/
EXEC sp_query_store_set_hints @query_id = 9, @value = N'OPTION (HASH JOIN)';
GO

/*
	Re-run and check plan
*/
SELECT o.CustomerID, ol.OrderID, ol.OrderLineID, o.OrderDate
FROM Sales.Orders o
JOIN Sales.OrderLines ol
    ON o.OrderID = ol.OrderID
WHERE o.CustomerID = 402
ORDER BY CustomerID, o.OrderID;
GO

/*
	what's in QS?
*/
SELECT *
FROM sys.query_store_query_hints

SELECT 
	q.query_id, 
	q.query_text_id, 
	p.plan_id, 
	qh.query_id, 
	qh.query_hint_text, 
	qt.query_sql_text
FROM sys.query_store_query q
JOIN sys.query_store_query_text qt 
	ON q.query_text_id = qt.query_text_id
LEFT OUTER JOIN sys.query_store_query_hints qh
	ON q.query_id = qh.query_id
JOIN sys.query_store_plan p
	ON q.query_id = p.query_id
WHERE q.query_id IN (2, 9);
GO


/*
	Does it check syntax?
*/
EXEC sys.sp_query_store_set_hints @query_id= 2, @query_hints = N'OPTION (RECOMPILED)';
GO

EXEC sys.sp_query_store_set_hints @query_id= 2, @query_hints = N'OPTION (OPTIMIZE FOR (@CustomerID = 860))';
GO


/*
	It will override an existing hint without a warning
*/
EXEC sys.sp_query_store_set_hints @query_id= 2, @query_hints = N'OPTION (OPTIMIZE FOR UNKNOWN)';
GO

/*
	Query Store Hints
*/
https://docs.microsoft.com/en-us/sql/relational-databases/performance/query-store-hints?view=azuresqldb-current&viewFallbackFrom=sql-server-ver15

/*
	List of supported hints for QS Hints can be found in here
*/
https://docs.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sys-sp-query-store-set-hints-transact-sql?view=azuresqldb-current

/*
	Query Store Hints Data Exposed video
*/
https://sec.ch9.ms/ch9/6d7a/ba0a1ae7-dd6d-4be8-8c7f-0db54cac6d7a/DATAEXPOSEDQueryStoreHints_high.mp4

/*
	Query Hints
*/
https://docs.microsoft.com/en-us/sql/t-sql/queries/hints-transact-sql-query?view=sql-server-ver15






















/*
	How is it different than a plan guide?
*/
EXEC sp_create_plan_guide   
    @name =  N'CustomerTransactionInfo',  
    @stmt = N'SELECT [CustomerID], SUM([AmountExcludingTax])
	FROM [Sales].[CustomerTransactions]
	WHERE [CustomerID] = @CustomerID
	GROUP BY [CustomerID];',  
    @type = N'OBJECT',  
    @module_or_batch = N'[Sales].[usp_CustomerTransactionInfo]',  
    @params = NULL,  
    @hints = N'OPTION (RECOMPILE)'; 
GO

SELECT *
FROM sys.plan_guides;
GO

/*
	Other plan guide examples
*/
EXEC sp_create_plan_guide   
    @name =  N'CustomerTransactionInfo',  
    @stmt = N'SELECT [CustomerID], SUM([AmountExcludingTax])
	FROM [Sales].[CustomerTransactions]
	WHERE [CustomerID] = @CustomerID
	GROUP BY [CustomerID];',  
    @type = N'OBJECT',  
    @module_or_batch = N'[Sales].[usp_CustomerTransactionInfo]',  
    @params = NULL,  
    @hints = N'OPTION (OPTIMIZE FOR (@CustomerID = 860))'; 
GO

EXEC sp_create_plan_guide   
    @name =  N'CustomerTransactionInfo',  
    @stmt = N'SELECT [CustomerID], SUM([AmountExcludingTax])
	FROM [Sales].[CustomerTransactions]
	WHERE [CustomerID] = @CustomerID
	GROUP BY [CustomerID];',  
    @type = N'OBJECT',  
    @module_or_batch = N'[Sales].[usp_CustomerTransactionInfo]',  
    @params = NULL,  
    @hints = N'OPTION (OPTIMIZE FOR UNKNOWN)'; 
GO




