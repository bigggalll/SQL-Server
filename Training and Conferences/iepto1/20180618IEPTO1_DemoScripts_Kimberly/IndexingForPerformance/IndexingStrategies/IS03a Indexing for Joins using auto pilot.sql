/*============================================================================
  File:     Autopilot

  Summary:  Will SQL Server use that index? 
			This is a great way of testing the usefulness of indexes 
			without actually creating them!

            This is the SAME example as the joins script but using 
            autopilot instead of creating the indexes!

			If you've never heard about "auto pilot" check out this
			article: https://www.mssqltips.com/sqlservertip/3246/sql-server-performance-tuning-with-hypothetical-indexes/

  SQL Server Version: 2008+
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

USE [Credit];
GO

EXEC [sp_helpindex] '[dbo].[charge]';
GO

------------------------------------------
-- Should we create the index?
-- These are the two indexes that we THINK might be useful
-- to the join from the demo:

--CREATE INDEX TestInd_PriorityToSARG 
--	ON charge(charge_amt, member_no)
--INCLUDE ([provider_no],[statement_no])
--go

--CREATE INDEX TestInd_PriorityToJoin
--	ON charge(member_no, charge_amt)
--INCLUDE ([provider_no],[statement_no])
--go

-- But, how long does it take to create (and test)
-- What about autopilot?

-- Check out this great article on Simple Talk
-- "Hypothetical Indexes on SQL Server"
-- https://www.simple-talk.com/sql/database-administration/hypothetical-indexes-on-sql-server/
------------------------------------------

CREATE INDEX [TestInd_PriorityToSARG]
	ON [dbo].[charge]([charge_amt], [member_no])
INCLUDE ([provider_no],[statement_no])
WITH STATISTICS_ONLY = -1;
GO

CREATE INDEX [TestInd_PriorityToJoin]
	ON [dbo].[charge]([member_no], [charge_amt])
INCLUDE ([provider_no],[statement_no])
WITH STATISTICS_ONLY = -1;
GO

-- You can get my version of sp_helpindex 
-- here: https://www.sqlskills.com/blogs/kimberly/category/sp_helpindex-rewrites/
EXEC [sp_sqlskills_helpindex] 'dbo.charge';
GO

-- Or, if you don't have the sp_helpindex rewrite, run
-- this to get the index IDs.
SELECT db_id() AS Parameter2, 
	object_id('charge') AS Parameter3;
GO

SELECT [i].[name], [i].[index_id] AS Parameter4
FROM [sys].[indexes] AS [i]
WHERE [i].[object_id] = OBJECT_ID('charge');
GO

-- Params: X, DBID (Parameter2), ObjectID (Parameter3), 
-- IndexID (Parameter4 - but, just those that are statistics_only = -1)
DBCC AUTOPILOT(0, 5, 229575856, 7);
DBCC AUTOPILOT(0, 5, 229575856, 8);
GO

SET AUTOPILOT ON;
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
OPTION (MAXDOP 1, QUERYTRACEON 9481);
GO

SET AUTOPILOT OFF;
GO

-- Note: the percentages of these "hypothetical
-- indexes" might not match the final execution as these
-- are likely to get created using sampling.

-- You can confirm this by reviewing the statistic:
DBCC SHOW_STATISTICS ('charge', 'TestInd_PriorityToJoin');
GO

-- Finally, we know that TestInd_PriorityToJoin is the one that 
-- SQL Server will use. We can DROP both of these statistics
-- and just create the index normally.

DROP INDEX [charge].[TestInd_PriorityToSARG]; -- this is really just a statistic
DROP INDEX [charge].[TestInd_PriorityToJoin]; -- this is really just a statistic
GO

-- Finally, create the REAL index that you need:
CREATE INDEX [TestInd_PriorityToJoin]
	ON [dbo].[charge] ([member_no], [charge_amt])
INCLUDE ([provider_no], [statement_no]);
GO

