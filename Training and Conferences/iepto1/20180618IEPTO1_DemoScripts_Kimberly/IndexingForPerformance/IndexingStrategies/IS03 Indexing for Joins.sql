/*============================================================================
  File:     Indexing for Joins - Credit.sql

  Summary:  Various tests and index access patterns using 5 table joins.
  
  SQL Server Version: 2005+
------------------------------------------------------------------------------
  Written by Kimberly L. Tripp, SYSolutions, Inc.

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
-- http://www.sqlskills.com/resources/conferences/CreditBackup80.zip

-- NOTE: This is a SQL Server 2000 backup and MANY examples will work on 
-- SQL Server 2000 in addition to SQL Server 2005.

USE [Credit];
GO

-- Let's start to analyze some queries and their performance:
SET STATISTICS IO ON;
GO

SELECT [c].[statement_no]
		, [s].[statement_dt]
		, [c].[charge_amt]
		, [p].[provider_name]
		, [m].[lastname]
	FROM [dbo].[charge] AS [c]
		INNER JOIN [dbo].[provider] AS [p]
			ON [p].[provider_no] = [c].[provider_no]
		INNER JOIN [dbo].[member] AS [m] 
			ON [c].[member_no] = [m].[member_no]
		INNER JOIN [dbo].[statement] AS [s] 
			ON [c].[statement_no] = [s].[statement_no]
		INNER JOIN [dbo].[region] AS [r] 
			ON [r].[region_no] = [m].[region_no]
WHERE [r].[region_name] = 'Japan'
	AND [c].[charge_amt] > 2500
OPTION (MAXDOP 1);
go

-------------------------------------------------------------------------------
-- First, let's get this plan as our base test case... review the 
-- showplan and FORCE every single index listed.
-------------------------------------------------------------------------------

-- USE:
--	0 = Table Scan
--	1 = Clustered Index Seek/Scan
--	name = for all non-clustered indexes 
--		(name is a bit safer)

SELECT [c].[statement_no]
		, [s].[statement_dt]
		, [c].[charge_amt]
		, [p].[provider_name]
		, [m].[lastname]
	FROM [dbo].[charge] AS [c] WITH (INDEX (1))
		INNER JOIN [dbo].[provider] AS [p] WITH (INDEX (1))
			ON [p].[provider_no] = [c].[provider_no]
		INNER JOIN [dbo].[member] AS [m] WITH (INDEX (1))
			ON [c].[member_no] = [m].[member_no]
		INNER JOIN [dbo].[statement] AS [s] WITH (INDEX (1))
			ON [c].[statement_no] = [s].[statement_no]
		INNER JOIN [dbo].[region] AS [r] WITH (INDEX (region_ident))
			ON [r].[region_no] = [m].[region_no]
WHERE [r].[region_name] = 'Japan'
	AND [c].[charge_amt] > 2500
OPTION (MAXDOP 1)
GO

-------------------------------------------------------------------------------
-- Analyze the costs and find the problem table/join
-------------------------------------------------------------------------------

-- Where is all the cost? (Highest number in showplan output...)
	-- Should be in charge!

-- SO - what does the charge table need in this query?
-- SELECT List		statement_no, charge_amt
-- Join Cond1		*member_no
-- Join Cond2		provider_no
-- Join Cond3		statement_no
-- Search Arg		*charge_amt

-------------------------------------------------------------------------------
-- Verify the potential for Phase I and Phase II
-------------------------------------------------------------------------------

-- Phase I should already be done!
--		But, remember it only works when something (the SARG or the join)
--		is very selective... no point here. Not selective enough.	
-- Phase II should be considered
--		But, remember it only works when the join density is very 
--		selective... again, no point here. Not selective enough.	

-- ***** We need to go to Phase III ***** (line 175)

-- If you want to go through the motions of Phase II - here are the steps:

-- Create "test" Indexes with priority (first column - or high order element) 
-- given to the search argument or the join and come up with some test cases... 
-- Try out the query again and see which one it chooses! Always put the cols of the
-- select list last!!!! They are the least significant!

-- First try just covering the sarg and join - in this case there is no sarg
-- Realize that phase II RARELY works for LOW selectivity. You need to have
-- better join density than we do in order for this to help... but, let's 
-- give it a shot for the join that's really expensive (to member):

CREATE INDEX [TestInd_PriorityToSARG]
	ON [dbo].[charge]([charge_amt], [member_no]);
GO

CREATE INDEX [TestInd_PriorityToJoin]
	ON [dbo].[charge]([member_no], [charge_amt]);
GO

EXEC sp_recompile 'Charge';		-- SCH_M on that table...
GO

-- Compare against first plan
SELECT [c].[statement_no]
		, [s].[statement_dt]
		, [c].[charge_amt]
		, [p].[provider_name]
		, [m].[lastname]
	FROM [dbo].[charge] AS [c] WITH (INDEX (1))
		INNER JOIN [dbo].[provider] AS [p] WITH (INDEX (1))
			ON [p].[provider_no] = [c].[provider_no]
		INNER JOIN [dbo].[member] AS [m] WITH (INDEX (1))
			ON [c].[member_no] = [m].[member_no]
		INNER JOIN [dbo].[statement] AS [s] WITH (INDEX (1))
			ON [c].[statement_no] = [s].[statement_no]
		INNER JOIN [dbo].[region] AS [r] WITH (INDEX (1))
			ON [r].[region_no] = [m].[region_no]
WHERE [r].[region_name] = 'Japan'
	AND [c].[charge_amt] > 2500
OPTION (MAXDOP 1);
GO

SELECT [c].[statement_no]
		, [s].[statement_dt]
		, [c].[charge_amt]
		, [p].[provider_name]
		, [m].[lastname]
	FROM [dbo].[charge] AS [c] 
		INNER JOIN [dbo].[provider] AS [p] 
			ON [p].[provider_no] = [c].[provider_no]
		INNER JOIN [dbo].[member] AS [m] 
			ON [c].[member_no] = [m].[member_no]
		INNER JOIN [dbo].[statement] AS [s] 
			ON [c].[statement_no] = [s].[statement_no]
		INNER JOIN [dbo].[region] AS [r] 
			ON [r].[region_no] = [m].[region_no]
WHERE [r].[region_name] = 'Japan'
	AND [c].[charge_amt] > 2500
OPTION (MAXDOP 1);
GO

-------------------------------------------------------------------------------
-- As expected, Phase II didn't help us. The join density is just NOT
-- selective enough. So, let's move to phase III.
-------------------------------------------------------------------------------

DROP INDEX [charge].[TestInd_PriorityToSARG];
DROP INDEX [charge].[TestInd_PriorityToJoin];
GO

-- You have two options here... figure out Phase III manually OR use DTA
-- DTA will review A LOT more than just the "expensive" table, it will
-- review the entire query. Is that always good or always bad?! Let's see!

----------------------------------------------------------------------
-- What about covering the QUERY:
----------------------------------------------------------------------
-- CREATE INDEX [TestInd_PriorityToSARG-Covering] 
--	ON charge(charge_amt, member_no, provider_no, statement_no)

-- CREATE INDEX [TestInd_PriorityToJoin-Covering]
--	ON charge(member_no, charge_amt, provider_no, statement_no)

----------------------------------------------------------------------
-- What about covering the QUERY using INCLUDE:
----------------------------------------------------------------------
-- CREATE INDEX [TestInd_PriorityToSARG-Covering-wINC] 
--	ON charge(charge_amt, member_no)
--	INCLUDE (provider_no, statement_no)

-- CREATE INDEX [TestInd_PriorityToJoin-Covering-wINC] 
--	ON charge(member_no, charge_amt)
--  INCLUDE (provider_no, statement_no)

-- Let's do this a bit iteratively though... I'm not going to blindly 
-- implement ALL of DTAs indexes. I'm going to start slowly - with 
-- just the indexes against charge:

-- BASELINE VERSION OF THE QUERY:
SELECT [c].[statement_no]
		, [s].[statement_dt]
		, [c].[charge_amt]
		, [p].[provider_name]
		, [m].[lastname]
	FROM [dbo].[charge] AS [c] WITH (INDEX (1))
		INNER JOIN [dbo].[provider] AS [p] WITH (INDEX (1))
			ON [p].[provider_no] = [c].[provider_no]
		INNER JOIN [dbo].[member] AS [m] WITH (INDEX (1))
			ON [c].[member_no] = [m].[member_no]
		INNER JOIN [dbo].[statement] AS [s] WITH (INDEX (1))
			ON [c].[statement_no] = [s].[statement_no]
		INNER JOIN [dbo].[region] AS [r] WITH (INDEX (1))
			ON [r].[region_no] = [m].[region_no]
WHERE [r].[region_name] = 'Japan'
	AND [c].[charge_amt] > 2500
OPTION (MAXDOP 1);
GO

-- SQL Server can do whatever it wants!
SELECT [c].[statement_no]
		, [s].[statement_dt]
		, [c].[charge_amt]
		, [p].[provider_name]
		, [m].[lastname]
	FROM [dbo].[charge] AS [c] 
		INNER JOIN [dbo].[provider] AS [p] 
			ON [p].[provider_no] = [c].[provider_no]
		INNER JOIN [dbo].[member] AS [m] 
			ON [c].[member_no] = [m].[member_no]
		INNER JOIN [dbo].[statement] AS [s] 
			ON [c].[statement_no] = [s].[statement_no]
		INNER JOIN [dbo].[region] AS [r] 
			ON [r].[region_no] = [m].[region_no]
WHERE [r].[region_name] = 'Japan'
	AND [c].[charge_amt] > 2500
OPTION (MAXDOP 1);
GO

----------------------------------------------------------------------
-- Use the following to modify and copy/test against the two above...
-- DTA VERSION OF THE QUERY:
----------------------------------------------------------------------
-- BASELINE VERSION OF THE QUERY:
SELECT [c].[statement_no]
		, [s].[statement_dt]
		, [c].[charge_amt]
		, [p].[provider_name]
		, [m].[lastname]
	FROM [dbo].[charge] AS [c] WITH (INDEX (1))
		INNER JOIN [dbo].[provider] AS [p] WITH (INDEX (1))
			ON [p].[provider_no] = [c].[provider_no]
		INNER JOIN [dbo].[member] AS [m] WITH (INDEX (1))
			ON [c].[member_no] = [m].[member_no]
		INNER JOIN [dbo].[statement] AS [s] WITH (INDEX (1))
			ON [c].[statement_no] = [s].[statement_no]
		INNER JOIN [dbo].[region] AS [r] WITH (INDEX (1))
			ON [r].[region_no] = [m].[region_no]
WHERE [r].[region_name] = 'Japan'
	AND [c].[charge_amt] > 2500
OPTION (MAXDOP 1);
GO

-- Missing Index DMVs VERSION OF THE QUERY:

SELECT [c].[statement_no]
		, [s].[statement_dt]
		, [c].[charge_amt]
		, [p].[provider_name]
		, [m].[lastname]
	FROM [dbo].[charge] AS [c] WITH (INDEX ([TestInd_PriorityToSARG]))
		INNER JOIN [dbo].[provider] AS [p] WITH (INDEX (1))
			ON [p].[provider_no] = [c].[provider_no]
		INNER JOIN [dbo].[member] AS [m] WITH (INDEX (1))
			ON [c].[member_no] = [m].[member_no]
		INNER JOIN [dbo].[statement] AS [s] WITH (INDEX (1))
			ON [c].[statement_no] = [s].[statement_no]
		INNER JOIN [dbo].[region] AS [r] WITH (INDEX (1))
			ON [r].[region_no] = [m].[region_no]
WHERE [r].[region_name] = 'Japan'
	AND [c].[charge_amt] > 2500
OPTION (MAXDOP 1);
GO

SELECT [c].[statement_no]
		, [s].[statement_dt]
		, [c].[charge_amt]
		, [p].[provider_name]
		, [m].[lastname]
	FROM [dbo].[charge] AS [c] WITH (INDEX ([TestInd_PriorityToJoin]))
		INNER JOIN [dbo].[provider] AS [p] WITH (INDEX (1))
			ON [p].[provider_no] = [c].[provider_no]
		INNER JOIN [dbo].[member] AS [m] WITH (INDEX (1))
			ON [c].[member_no] = [m].[member_no]
		INNER JOIN [dbo].[statement] AS [s] WITH (INDEX (1))
			ON [c].[statement_no] = [s].[statement_no]
		INNER JOIN [dbo].[region] AS [r] WITH (INDEX (1))
			ON [r].[region_no] = [m].[region_no]
WHERE [r].[region_name] = 'Japan'
	AND [c].[charge_amt] > 2500
OPTION (MAXDOP 1);
GO

-- Missing Index DMVs VERSION OF THE QUERY:
SELECT [c].[statement_no]
		, [s].[statement_dt]
		, [c].[charge_amt]
		, [p].[provider_name]
		, [m].[lastname]
	FROM [dbo].[charge] AS [c] WITH (INDEX ([MissingIndexDMVsRec]))
		INNER JOIN [dbo].[provider] AS [p] WITH (INDEX (1))
			ON [p].[provider_no] = [c].[provider_no]
		INNER JOIN [dbo].[member] AS [m] WITH (INDEX (1))
			ON [c].[member_no] = [m].[member_no]
		INNER JOIN [dbo].[statement] AS [s] WITH (INDEX (1))
			ON [c].[statement_no] = [s].[statement_no]
		INNER JOIN [dbo].[region] AS [r] WITH (INDEX (1))
			ON [r].[region_no] = [m].[region_no]
WHERE [r].[region_name] = 'Japan'
	AND [c].[charge_amt] > 2500
OPTION (MAXDOP 1);
GO