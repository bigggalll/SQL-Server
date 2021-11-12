/*============================================================================
  File:     Estimates.sql

  Summary:  Where do estimates come from?
				Existing statistics?
				Auto-created statistics?
				Heuristics?
  
  SQL Server Version: 
        SQL Server 2008+ with some Legacy vs. New CE code
        The "New CE" is only available in SQL Server 2014+
        The "Legacy CE" applies to SQL Server 7.0-2012 (inclusive)
        
        In 2014+, you can choose which CE you want to use...
                       
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
-- credit database from here:
-- http://www.sqlskills.com/sql-server-resources/sql-server-demos/ 

-- NOTE: You can use a SQL Server 2000 backup and restore to: 2000, 2005 or 2008/R2
-- There's also a 2008 backup that you can restore to 2008/R2 or 2012

---------------------------------------------
-- Even distribution
---------------------------------------------

USE [Credit];
GO

-- Just to make sure - set the DB to 120 (SQL 2014)
-- This will start us in the "Legacy CE"
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

-- Rewrite to give better index details/internals
-- Get here: http://www.sqlskills.com/blogs/kimberly/use-this-new-sql-server-2012-rewrite-for-sp_helpindex/ 
EXEC [sp_SQLskills_helpindex] 'dbo.member';
GO

EXEC [sp_helpstats] 'dbo.member', 'all';
GO

CREATE INDEX [membername]
ON [dbo].[member]
([lastname], [firstName], [middleinitial]);
GO

SET STATISTICS IO ON;
-- Turn on showplan 
-- Use: Query, Include Actual Execution Plan [Ctrl + M]
GO

SELECT [m].* 
FROM [dbo].[member] AS [m]
WHERE [m].[lastname] = 'Anderson';  
GO

-- Where did this come from?
--	Key: adhoc, can be sniffed, uses the histogram
--	Value is an actual step - uses EQ_ROWS
DBCC SHOW_STATISTICS('dbo.member', 'membername')
WITH HISTOGRAM
GO

-- What about a value that's NOT in as a step:
SELECT [m].* 
FROM [dbo].[member] AS [m]
WHERE [m].[lastname] = 'Smith';  
GO

-- Where did this come from?
--	Key: adhoc, can be sniffed, uses the histogram
--	Value is in the range: RYAN - STEIN
--  uses AVG_RANGE_ROWS
DBCC SHOW_STATISTICS('dbo.member', 'membername')
WITH HISTOGRAM;
GO

---------------------------------------------
-- What if I use a variable?
---------------------------------------------

DECLARE @LastNameVar	varchar(15) = 'Tripp'
		-- this is the EXACT same data type as the column
SELECT [m].* 
FROM [dbo].[member] AS [m]
WHERE [m].[lastname] = @LastNameVar;
GO

-- Here - the value cannot be "sniffed" and as a result
-- they can't use the histogram to find the estimate

-- Instead they use the density vector:
-- Take All density * rows = average rows returned

SELECT 0.03846154	-- All density: for lastname
	    * 10000		-- Rows: from the header
--  = 384.61540000	-- On average, you will get back
					-- 385 rows for a single lastname
					-- supplied in a query

---------------------------------------------
-- What if we don't have statistics?
---------------------------------------------

-- First, let's the drop index we've been using
DROP INDEX [dbo].[member].[membername];
GO

-- Then, let's turn off auto create statistics
-- Generally speaking - this is NOT recommended! 
ALTER DATABASE [Credit] 
SET AUTO_CREATE_STATISTICS OFF
go

-- Check to see if there are ANY stats that could
-- be used for lastname:
EXEC [sp_SQLskills_helpindex] 'dbo.member';
EXEC [sp_helpstats] 'dbo.member', 'all';
GO

-- No indexes or stats that even have lastname IN
-- the index (not even in INCLUDE).

-- Since our compatibility mode is 120 (for SQL 2014)
-- We can compare the Legacy CE to the NEW CE

-- Literal/parameter
-- NEW CE
SELECT [m].* 
FROM [dbo].[member] AS [m]
WHERE [m].[lastname] = 'anderson';  
GO

-- Legacy CE (7.0 - 2012)
SELECT [m].* 
FROM [dbo].[member] AS [m]
WHERE [m].[lastname] = 'anderson'
--OPTION (QUERYTRACEON 9481); -- use "Legacy CE" if DB is "New CE"
--OPTION (QUERYTRACEON 2312); -- use "New CE" if DB is "Legacy CE"
GO

-- No statistics therefore HEURISTICS 
-- Heuristics = internal rules

-- Legacy CE
-- Rule for equality on one column is:
--   # of rows in the table to the power of 3/4
--   10000 ^ 3/4 = 1000

-- The rules for more than 2 columns are (simply put)
-- fractionally smaller (but more complicated). 
-- But, the main point statistics are WAY better 
-- than heuristics.

-- Other things to note:
--	The warning symbol
--	Columns with no statistics

-- NOTE: If you've upgraded a database to SQL 2014 but have NOT
-- yet changed the compatibility mode to 120 then you can still
-- see the impact of the New CE with a trace flag to use it per
-- query

-- Let's pretend we're in 2008 R2 compat mode
IF DATABASEPROPERTYEX('Credit', 'Collation') IS NOT NULL
	ALTER DATABASE Credit
		SET COMPATIBILITY_LEVEL = 100;
go

--Here are the valid values for Compatibility Level
--80	SQL Server 2000
--90	SQL Server 2005
--100	SQL Server 2008 and SQL Server 2008 R2
--110	SQL Server 2012
--120	SQL Server 2014

-- Literal/parameter
-- Legacy CE because of compat mode
SELECT [m].* 
FROM [dbo].[member] AS [m]
WHERE [m].[lastname] = 'anderson';  
GO

-- New CE for just one query
SELECT [m].* 
FROM [dbo].[member] AS [m]
WHERE [m].[lastname] = 'anderson'
OPTION (QUERYTRACEON 2312); 
GO

-- New CE for an entire script / session
DBCC TRACEON (2312);
go
SELECT [m].* 
FROM [dbo].[member] AS [m]
WHERE [m].[lastname] = 'anderson'
