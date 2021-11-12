/*============================================================================
  File:     Correlated join predicates and independent filter predicates.sql

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

-- These samples use the Credit database. You can download and restore the
-- the 2008 backup of the credit sample database to SQL Server 2014 from here:
-- http://www.sqlskills.com/sql-server-resources/sql-server-demos/ 

USE [Credit];
GO

-- "Simple" containment for the Merge Join
-- Estimated rows, 266.284
SELECT [c].[charge_no]
    , [m].[prev_balance]
FROM [dbo].[charge] AS [c]
    INNER JOIN [dbo].[member] AS [m] 
		ON [m].[member_no] = [c].[member_no]
WHERE [c].[charge_amt] = 50.00
    AND [m].[lastname] = 'ZUCKER'
OPTION (QUERYTRACEON 9481); -- Legacy CE

-- "Base" containment for the Merge Join
-- Estimated rows, 21.8
SELECT [c].[charge_no]
    , [m].[prev_balance]
FROM [dbo].[charge] AS [c]
    INNER JOIN [dbo].[member] AS [m] 
		ON [m].[member_no] = [c].[member_no]
WHERE [c].[charge_amt] = 50.00
    AND [m].[lastname] = 'ZUCKER'
OPTION (QUERYTRACEON 2312); -- New CE

-- Reduced correlation assumed for non-join predicates

-- For more examples, check out Joe Sack's whitepaper:
-- Optimizing Your Query Plans with the SQL Server 2014 Cardinality Estimator
-- http://msdn.microsoft.com/en-us/library/dn673537.aspx
