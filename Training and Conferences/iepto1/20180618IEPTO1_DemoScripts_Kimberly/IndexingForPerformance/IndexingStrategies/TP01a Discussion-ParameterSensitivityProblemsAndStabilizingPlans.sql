-- This was a quick example building on the original LACK
-- of indexes against the FactInternetSales table
-- Remember, if you created the beneficial "covering" index
-- for FactInternetSales (CustomerKey) INCLUDE (SalesAmount)
-- it would stabilize the plan... make sure that index
-- doesn't exist when you start this script

USE [AdventureWorksDW2008_ModifiedSalesKey];
GO

-- Turn on showplan (Ctrl+M)
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

EXEC [sp_SQLskills_helpindex] 'dbo.FactInternetSales';
GO

IF (SELECT INDEXPROPERTY ( OBJECT_ID('FactInternetSales')
							, 'IX_FactInternetSales_CustomerKey_INCSalesAmount'
							, 'IndexID')) IS NOT NULL
	DROP INDEX [dbo].[FactInternetSales].[IX_FactInternetSales_CustomerKey_INCSalesAmount];
GO

IF OBJECTPROPERTY(OBJECT_ID('GetSumOfSales'), 'IsProcedure') IS NOT NULL
	DROP PROCEDURE [dbo].[GetSumOfSales];
GO

CREATE PROC [GetSumOfSales]
	(@ck	int)
AS
SELECT [c].[CustomerKey], [c].[LastName], sum([s].[SalesAmount])
FROM [dbo].[FactInternetSales] AS [s]
	INNER JOIN [dbo].[DimCustomer] AS [c]
		ON [s].[CustomerKey] = [c].[CustomerKey]
WHERE [c].[CustomerKey] < @ck
GROUP BY [c].[CustomerKey], [c].[LastName];
GO

EXEC [GetSumOfSales] 11002; -- highly selective value (uses an index)
GO

EXEC [GetSumOfSales] 15000; -- NOT selective value (should NOT use an index but the plan is cached)
GO

-- Suspect parameter sensitivity...
EXEC [GetSumOfSales] 15000; 
EXEC [GetSumOfSales] 15000 WITH RECOMPILE;
GO

-- Are the plans different?
-- Yes, so it's definitely PSP

-- Could have the problem, but with a different plan

-- First, get rid of the plan in cache
EXEC sp_recompile [GetSumOfSales];
GO

EXEC [GetSumOfSales] 15000; -- NOT selective value (uses a table scan)
GO

EXEC [GetSumOfSales] 11002; -- highly selective value (should use a NC index but the plan is cached)
GO

-- Thinking that it's parameter sensitivity...
EXEC [GetSumOfSales] 11002; 
EXEC [GetSumOfSales] 11002 WITH RECOMPILE;
GO

-- Again, you can see that the plans different?
-- And confirm that it's PSP

-- Fixing this problem by "STABILIZING the PLAN"

-- Create an index that's ideal for this request (whether selective or not)
CREATE NONCLUSTERED INDEX [IX_FactInternetSales_CustomerKey_INCSalesAmount]
ON [dbo].[FactInternetSales] ([CustomerKey])
INCLUDE ([SalesAmount]);
GO

-- Doesn't matter in what order you execute, you'll get a "stable" 
-- and consistent plan!

-- Now, there's still "an issue" with regard to parallelism and the
-- memory grant. You could still use OPTION (RECOMPILE) to eliminate
-- this. It depends on how large the table / how big the grant is! 

EXEC [GetSumOfSales] 15000; 
GO

EXEC [GetSumOfSales] 11002; 
GO

EXEC sp_recompile [GetSumOfSales];
GO

EXEC [GetSumOfSales] 11002; 
GO

EXEC [GetSumOfSales] 15000; 
GO