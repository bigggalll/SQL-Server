/*============================================================================
  File:     Containment Examples.sql

  Summary:  Comparisons between the Legacy CE (7.0 = used for versions 7.0-2012)
            and the New CE introduced in SQL Server 2014
            CE 2014 is only available in compat mode 120 OR through TF 9481  
            CE 2014 is only available in compat modes 70-110 OR through TF 2312

  SQL Server Version: 2014
------------------------------------------------------------------------------
  Written by Kimberly L. Tripp, SQLskills.com

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  This script is intended only as a supplement to demos and lectures
  given by Kimberly L. Tripp.  
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

-- You can get AdventureWorks2012 here: http://msftdbprodsamples.codeplex.com/
-- Or, you can use this same script with AdventureWorks2008 or 2008R2 (same location)

USE [AdventureWorks2012];
GO

-- Simple containment
SELECT [od].[SalesOrderID], [od].[SalesOrderDetailID]
FROM 	[Sales].[SalesOrderDetail] AS [od]
INNER JOIN [Production].[Product] AS [p] 
ON [od].[ProductID] = [p].[ProductID]
WHERE 	[p].[Color] = 'Red' AND
[od].[ModifiedDate] = '2008-06-29 00:00:00.000'
OPTION (QUERYTRACEON 9481); -- CardinalityEstimationModelVersion 70

-- Base containment
SELECT [od].[SalesOrderID], [od].[SalesOrderDetailID]
FROM 	[Sales].[SalesOrderDetail] AS [od]
INNER JOIN [Production].[Product] AS [p] 
ON [od].[ProductID] = [p].[ProductID]
WHERE 	[p].[Color] = 'Red' AND
[od].[ModifiedDate] = '2008-06-29 00:00:00.000'
OPTION (QUERYTRACEON 2312); -- CardinalityEstimationModelVersion 120

-- Reduced correlation assumed for non-join predicates

-- For more examples, check out Joe Sack's whitepaper:
-- Optimizing Your Query Plans with the SQL Server 2014 Cardinality Estimator
-- http://msdn.microsoft.com/en-us/library/dn673537.aspx
