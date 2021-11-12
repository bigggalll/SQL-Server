/*============================================================================
  File:     Viewing Statistics Information.sql

  Summary:  See how statistics get automatically created based on query 
			scan. View sys.indexes,	use stats_date, use dbcc show_statistics 
			and use dbcc show_statistics to produce multiple tabular data sets.
  
  SQL Server Version: SQL Server 2005+
------------------------------------------------------------------------------
  Written by Kimberly L. Tripp, SYSolutions, Inc.

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  This script is intended only as a supplement to demos and lectures
  given by Kimberly L. Tripp.  
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHA NTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

-- These samples use the Credit database. You can download and restore the
-- credit database from here:
-- http://www.sqlskills.com/sql-server-resources/sql-server-demos/ 

-- NOTE: You can use a SQL Server 2000 backup and restore to: 2000, 2005 or 2008/R2
-- There's also a 2008 backup that you can restore to 2008/R2 or 2012

USE [Credit];
GO

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
--130	SQL Server 2016
--140	SQL Server 2017

-- Quick/general way to see index list
EXEC [sp_helpindex] 'dbo.member';
GO

-- You can get my version of sp_helpindex 
-- here: https://www.sqlskills.com/blogs/kimberly/category/sp_helpindex-rewrites/
EXEC [sp_SQLskills_helpindex] 'dbo.member';
GO

EXEC [sp_helpstats] 'dbo.member', 'all';
GO

CREATE INDEX [MemberName]
ON [dbo].[Member]([Lastname], [FirstName], [MiddleInitial]);
GO

DBCC SHOW_STATISTICS('Member', 'MemberName') 
GO

SET STATISTICS IO ON; --(turn on actual showplan)
GO

-----------------------------
-- READING HISTOGRAMS
-----------------------------

-- Histogram Step Value
SELECT [m].*
FROM [dbo].[Member] AS [m]
WHERE [m].[LastName] = 'Chen'
GO

DBCC SHOW_STATISTICS('Member', 'MemberName') 
WITH HISTOGRAM;
GO

DBCC SHOW_STATISTICS ('Member', 'member_corporation_link')
WITH HISTOGRAM;
GO

-- Histogram Value In Step Range
SELECT [m].* 
FROM [dbo].[member] AS [m]
WHERE [m].[corp_no] = 404;
GO

-- Histogram Value In Step Range
SELECT [m].* 
FROM [dbo].[member] AS [m]
WHERE [m].[corp_no] = 405;
GO

-- Histogram Value In Step Range
SELECT [m].* 
FROM [dbo].[member] AS [m]
WHERE [m].[corp_no] = 406;
GO

-- Distinct Value Estimation
SELECT DISTINCT [m].[corp_no]
FROM [dbo].[member] AS [m];
GO

DBCC SHOW_STATISTICS('Member', 'member_corporation_link') 
WITH DENSITY_VECTOR;
GO

SELECT 1/0.0025;
GO

-- Unknown Values
DECLARE @Lastname varchar(15) = 'Chen';
SELECT [m].*
FROM [dbo].[Member] AS [m]
WHERE [m].[LastName] = @Lastname;
GO

DBCC SHOW_STATISTICS('Member', 'MemberName') 
WITH DENSITY_VECTOR;
GO

-- Unknown Values
DECLARE @Lastname varchar(15) = 'Fish';
SELECT [m].*
FROM [dbo].[Member] AS [m]
WHERE [m].[LastName] = @Lastname;
GO

-- If you want to see parameters and variables in procedures,
-- open/review the script: 01a ParametersVsVariablesInProcs.sql 

-- Using Density for LastName
SELECT 10000 * 0.03846154

-- Using Density for LastName, FirstName Combo
SELECT 10000 * 0.0001

-- So - what does this tell us about the relationship between LastNames and FirstNames?
EXEC [sp_helpindex] 'dbo.member'
EXEC [sp_helpstats] 'dbo.member', 'all';
GO -- look at messages window (Object does not have any stats)

-- What would you expect this query to do?
SET STATISTICS IO ON; --(turn on graphical showplan)
GO

SELECT [m].[LastName]
    , [m].[FirstName]
    , [m].[MiddleInitial]
	, [m].[Phone_no]
    , [m].[City]
FROM [dbo].[Member] AS [m]
WHERE [m].[FirstName] LIKE 'Kim%'
GO

-- Table Scan (always an option)
-- No Indexes to help find FIRSTNAMES...
-- What about scanning the NC index on LN,FN,MI and then doing bookmarks lookups...
-- seems risky? Would be good if we were guaranteed to only find a VERY small 
-- number of people with firstnames like 'Kim%'?

-- And yet it does - how did it know?

EXEC [sp_helpindex] 'dbo.member'
EXEC [sp_helpstats] 'dbo.member', 'all';
GO

DBCC SHOW_STATISTICS('Member', '_WA_Sys_00000003_0CBAE877')
WITH HISTOGRAM;
GO

-- What happens if we change to 'Ki%' or 'K%'
SELECT [m].[LastName]
    , [m].[FirstName]
    , [m].[MiddleInitial]
	, [m].[Phone_no]
    , [m].[City]
FROM [dbo].[Member] AS [m]
--WHERE [m].[FirstName] LIKE 'Ki%'
WHERE m.FirstName LIKE 'K%'
OPTION (QUERYTRACEON 3604, QUERYTRACEON 9481, QUERYTRACEON 9204, RECOMPILE);

--SELECT [s].* 
--FROM [sys].[stats] AS [s]
--WHERE [s].[object_id] = OBJECT_ID('member')

-- What is the selectivity of K% 
--    = SELECT 159+63*4+6+15+1

-- Is this always a good - generally it works well BUT nothing beats REAL statistics? 
-- In fact, SQL Server created statistics on the FirstName column...

-- Does the existence of "statistics" mean that you MUST create an index... NO but it 
-- is likely that the column is being used in SARGs and/or Join Conditions so it's 
-- something to think about - asking ITW/DTA?

-- New stats are listed as User-Stats

-- To see all of your statistics on indexes as well as the the last time 
-- the stats were updated
SELECT 
	OBJECT_NAME([si].[object_id]) 	AS [TableName]
	, CASE 
		WHEN [si].[index_id] = 0 THEN 'Heap'
		WHEN [si].[index_id] = 1 THEN 'CL'
		WHEN [si].[index_id] BETWEEN 2 AND 31005 
            THEN 'NC ' 
                + RIGHT('0000' + CONVERT(varchar, [si].[index_id]), 5)
		ELSE ''
	  END 							AS [IndexType]
	, [si].[name] 					AS [IndexName]
	, [si].[index_id]				AS [IndexID]
	, CASE
		WHEN [si].[index_id] BETWEEN 1 AND 31005 
                AND STATS_DATE (si.[object_id], si.[index_id]) 
                    < DATEADD(m, -1, GETDATE()) 
			THEN '! More than a month OLD !'
		WHEN [si].[index_id] BETWEEN 1 AND 31005 
                AND STATS_DATE (si.[object_id], si.[index_id]) 
                    < DATEADD(wk, -1, getdate()) 
			THEN '! Within the past month !'
		WHEN [si].[index_id] BETWEEN 1 AND 31005 
            THEN 'Stats recent'
		ELSE ''
	  END
        AS [Warning]
	, STATS_DATE ([si].[object_id], [si].[index_id]) 	
        AS [Last Stats Update]
FROM [sys].[indexes] AS [si]
WHERE OBJECTPROPERTY([si].[object_id], 'IsUserTable') = 1
ORDER BY [TableName], [si].[index_id];
GO

-- Or, how about ALL statistics (even those created on a col not an index)
SELECT 
	OBJECT_NAME([s].[object_id]) 	AS [TableName]
	, CASE 
		WHEN [s].[stats_id] = 0 then 'Heap'
		WHEN [s].[stats_id] = 1 then 'CL'
		WHEN INDEXPROPERTY ( [s].[object_id], [s].[name], 'IsAutoStatistics') = 1 THEN 'Stats-Auto'
		WHEN INDEXPROPERTY ( [s].[object_id], [s].[name], 'IsHypothetical') = 1 THEN 'Stats-HIND'
		WHEN INDEXPROPERTY ( [s].[object_id], [s].[name], 'IsStatistics') = 1 THEN 'Stats-User'
		WHEN [s].[stats_id] BETWEEN 2 AND 31005 -- and, it's not a statistic
			THEN 'NC ' + RIGHT('0000' 
                + convert(varchar, [s].[stats_id]), 5)
		ELSE 'Text/Image'
	  END 							AS [IndexType]
	, [s].[name] 					AS [IndexName]
	, [s].[stats_id]				AS [IndexID]
	, CASE
		WHEN STATS_DATE ([s].[object_id], [s].[stats_id]) 
            < DATEADD(m, -1, getdate()) 
			THEN '!! More than a month OLD !!'
		WHEN STATS_DATE ([s].[object_id], [s].[stats_id]) 
            < DATEADD(wk, -1, getdate()) 
			THEN '! Within the past month !'
		ELSE 'Stats recent'
	  END 							AS [Warning]
	, STATS_DATE ([s].[object_id], [s].[stats_id]) 	
        AS [Last Stats Update]
	, CASE 
		WHEN no_recompute = 0 THEN 'YES'
		ELSE 'NO'
	  END AS 'AutoUpdate'
FROM [sys].[stats] AS [s]
WHERE OBJECTPROPERTY([s].[object_id], 'IsUserTable') = 1
--	AND (INDEXPROPERTY ( si.[object_id], si.[name], 'IsAutoStatistics') = 1 
--			OR INDEXPROPERTY ( si.[object_id], si.[name], 'IsHypothetical') = 1 
--			OR INDEXPROPERTY ( si.[object_id], si.[name], 'IsStatistics') = 1)
--ORDER BY [Last Stats Update] DESC
ORDER BY [TableName], [s].[stats_id];
GO

-- Quick way to see stats_date for a specific table
EXEC [sp_autostats] N'dbo.Member';
GO

-- 2008R2 SP2+ or 2012 SP1+
--sp_sqlskills_helpindex member
SELECT * 
FROM [sys].[dm_db_stats_properties]
(object_id('dbo.member'), 4);
GO

-- Seeing each tabular set from DBCC SHOW_STATISTICS 

DBCC SHOW_STATISTICS('[Credit].[dbo].[member]', 'MemberName')
WITH STAT_HEADER; 
GO

DBCC SHOW_STATISTICS('[Credit].[dbo].[member]', 'MemberName')
WITH DENSITY_VECTOR;
GO

DBCC SHOW_STATISTICS('Member', 'MemberName')
WITH HISTOGRAM;
GO

-- Undoc'ed
DBCC SHOW_STATISTICS ('[Credit].[dbo].[member]','MemberName') 
WITH STAT_HEADER JOIN DENSITY_VECTOR;
GO

-- select TABLE_CARDINALITY/TUPLE_CARDINALITY = All Density 
-- (for each left-base subset starting ending at that ordinal)
-- select 10000/CONVERT(decimal(10, 4), 26)


-- How do you use these programmatically
-- First, create a table into which this information will be inserted
-- Second, use dynamic string execution with an insert...exec to populate

CREATE TABLE [dbo].[MemberNameHistogram]
(
	[RANGE_HI_KEY]			    nvarchar(900),
	[RANGE_ROWS]				bigint,
	[EQ_ROWS]					bigint,
	[DISTINCT_RANGE_ROWS]		bigint,
	[AVG_RANGE_ROWS]			bigint,
);
GO

INSERT [dbo].[MemberNameHistogram]
EXEC ('DBCC SHOW_STATISTICS(''[Credit].[dbo].[member]'', ''MemberName'') WITH HISTOGRAM');
GO

SELECT * FROM [dbo].[MemberNameHistogram];
GO

SET STATISTICS IO OFF;
GO
EXEC [sp_createstats] 'indexonly', 'fullscan';
GO

-- Here's where the CE has an impact

-- What if the data changes:
UPDATE [dbo].[member]
	SET [firstname] = 'Kimberly'
	WHERE [member_no] >= 1 AND [member_no] <= 1000;
GO

----------------------------------------------------

SELECT [m].[LastName]
    , [m].[FirstName]
    , [m].[MiddleInitial]
	, [m].[Phone_no]
    , [m].[City]
FROM [dbo].[Member] AS [m] WITH (INDEX (0))
WHERE [m].[FirstName] LIKE 'Kim%';
GO

SELECT [m].[LastName]
    , [m].[FirstName]
    , [m].[MiddleInitial]
	, [m].[Phone_no]
    , [m].[City]
FROM [dbo].[Member] AS [m] 
WHERE [m].[FirstName] LIKE 'Kim%';
GO

----------------------------------------------------

UPDATE [dbo].[member]
	SET [firstname] = 'Kimberly'
	WHERE [member_no] >= 1000 AND [member_no] <= 2000;
GO

----------------------------------------------------

SELECT [m].[LastName]
    , [m].[FirstName]
    , [m].[MiddleInitial]
	, [m].[Phone_no]
    , [m].[City]
FROM [dbo].[Member] AS [m] WITH (INDEX (0))
WHERE [m].[FirstName] LIKE 'Kim%';
GO

SELECT [m].[LastName]
    , [m].[FirstName]
    , [m].[MiddleInitial]
	, [m].[Phone_no]
    , [m].[City]
FROM [dbo].[Member] AS [m] 
WHERE [m].[FirstName] LIKE 'Kim%';
GO

----------------------------------------------------

UPDATE [dbo].[member]
	SET [firstname] = 'Kimberly'
	WHERE [member_no] >= 2000 AND [member_no] <= 2600;
GO

----------------------------------------------------

SELECT [m].[LastName]
    , [m].[FirstName]
    , [m].[MiddleInitial]
	, [m].[Phone_no]
    , [m].[City]
FROM [dbo].[Member] AS [m] WITH (INDEX (0))
WHERE [m].[FirstName] = 'Kimberly';
GO

SELECT [m].[LastName]
    , [m].[FirstName]
    , [m].[MiddleInitial]
	, [m].[Phone_no]
    , [m].[City]
FROM [dbo].[Member] AS [m] 
WHERE [m].[FirstName] = 'Kimberly';
GO

-- What about a generic "update" routine?
EXEC [sp_updatestats]; -- only requires one row to have changed...
GO

-- An even better choice - Ola's scripts:
-- http://ola.hallengren.com/