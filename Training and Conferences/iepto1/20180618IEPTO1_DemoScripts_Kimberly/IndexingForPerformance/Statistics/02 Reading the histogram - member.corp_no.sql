/*============================================================================
  File:     Reading the histogram.sql

  Summary:  Another example for reading the histogram

  SQL Server Version: 2005-2012
------------------------------------------------------------------------------
  Written by Kimberly L. Tripp & Paul S. Randal, SQLskills.com

  For more scripts and sample code, check out http://www.SQLskills.com

  This script is intended as a supplement to the SQL Server 2008 Jumpstart or
  Metro training.
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

-- These samples use the Credit database. You can download and restore the
-- credit database from here:
-- http://www.sqlskills.com/sql-server-resources/sql-server-demos/ 

-- NOTE: You can use a SQL Server 2000 backup and restore to: 2000, 2005 or 2008/R2
-- There's also a 2008 backup that you can restore to 2008/R2 or 2012

USE [Credit];
GO

-----------------------------------------------
-- **** CE Doesn't matter for this example ****
-----------------------------------------------

-- Just to make sure - set the DB to 120 (SQL 2014)
IF DATABASEPROPERTYEX('Credit', 'Collation') IS NOT NULL
	ALTER DATABASE Credit
		SET COMPATIBILITY_LEVEL = 120;
GO

--Here are the valid values for Compatibility Level
--80	SQL Server 2000
--90	SQL Server 2005
--100	SQL Server 2008 and SQL Server 2008 R2
--110	SQL Server 2012
--120	SQL Server 2014

-- Quick/general way to see index list
EXEC [sp_helpindex] 'dbo.member';
GO

EXEC [sp_helpstats] 'dbo.member', 'all';
GO

-- First - the entire statistics blob
DBCC SHOW_STATISTICS ('[credit].[dbo].[member]', 'member_corporation_link');
GO

-- Just the histogram
DBCC SHOW_STATISTICS ('[credit].[dbo].[member]', 'member_corporation_link')
WITH HISTOGRAM;
GO

SELECT [m].* 
FROM [dbo].[member] AS [m]
WHERE [m].[corp_no] = 403;
GO

SELECT [m].* 
FROM [dbo].[member] AS [m]
WHERE [m].[corp_no] = 404;
GO

SELECT [m].* 
FROM [dbo].[member] AS [m]
WHERE [m].[corp_no] = 405;
GO

SELECT [m].* 
FROM [dbo].[member] AS [m]
WHERE [m].[corp_no] = 406;
GO

SELECT [m].* 
FROM [dbo].[member] AS [m]
WHERE [m].[corp_no] = 407;
GO

-- Another range to play around with
--SELECT [m].* 
--FROM [dbo].[member] AS [m]
--WHERE [m].[corp_no] =  202;
--GO

--SELECT [m].* 
--FROM [dbo].[member] AS [m]
--WHERE [m].[corp_no] =  203;
--GO

--SELECT [m].* 
--FROM [dbo].[member] AS [m]
--WHERE [m].[corp_no] =  204;
--GO

--SELECT [m].* 
--FROM [dbo].[member] AS [m]
--WHERE [m].[corp_no] = 205;
--GO

--SELECT [m].* 
--FROM [dbo].[member] AS [m]
--WHERE [m].[corp_no] = 364;
--GO

--SELECT [m].* 
--FROM [dbo].[member] AS [m]
--WHERE [m].[corp_no] = 365;
--GO

--SELECT [m].* 
--FROM [dbo].[member] AS [m]
--WHERE [m].[corp_no] = 366;
--GO

--SELECT [m].* 
--FROM [dbo].[member] AS [m]
--WHERE [m].[corp_no] = 367;
--GO

-- What about those NULLs and the "average"
-- shown by "all density"?

-- Let's compare the density vector with 
-- one that doesn't include NULL values

CREATE STATISTICS [GoodDensityVector]
ON [dbo].[member] ([corp_no])
WHERE [corp_no] IS NOT NULL;
GO

DBCC SHOW_STATISTICS ('member', 'member_corporation_link') with density_vector;
DBCC SHOW_STATISTICS ('member', 'GoodDensityVector') with density_vector;
GO

DBCC SHOW_STATISTICS ('member', 'member_corporation_link') ;
DBCC SHOW_STATISTICS ('member', 'GoodDensityVector') ;
GO
-- At first glance they look the same... but, are they?
-- Remember, average is calculated as ALL DENSITY * ROWS

-- For the statistic on 'member_corporation_link':
SELECT 0.0025 * 10000 AS [Average # of Rows from member_corporation_link]

-- For the statistic on 'GoodDensityVector':
SELECT 0.002506266 * 1502 AS [Average # of Rows from GoodDensityVector]
GO

-- Is it true?
SELECT AVG([CountofCorps])
FROM (SELECT CONVERT(DECIMAL, COUNT(*)) AS [CountofCorps] 
	FROM member
	--WHERE corp_no IS NOT NULL
	GROUP BY corp_no) AS [Counts]

SELECT AVG([CountofCorps])
FROM (SELECT CONVERT(DECIMAL, COUNT(*)) AS [CountofCorps] 
	FROM member
	WHERE corp_no IS NOT NULL
	GROUP BY corp_no) AS [Counts]
