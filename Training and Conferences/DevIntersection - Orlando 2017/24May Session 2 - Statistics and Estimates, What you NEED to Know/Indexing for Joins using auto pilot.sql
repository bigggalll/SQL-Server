/*============================================================================
  File:     Autopilot

  Summary:  Will SQL Server use that index? 
			This is a great way of testing the usefulness of indexes 
			without actually creating them!

            This is the SAME example as the joins script but using 
            autopilot instead of creating the indexes!

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
-- These are the two indexes that we THINK 
-- might be useful for a particular join:

--CREATE INDEX TestInd_PriorityToSARG 
--	ON charge(charge_amt, member_no)
--INCLUDE ([provider_no],[statement_no])
--go

--CREATE INDEX TestInd_PriorityToJoin
--	ON charge(member_no, charge_amt)
--INCLUDE ([provider_no],[statement_no])
--go

-- But, how long does it take to create (and test)
-- on a large system?? And, will SQL even use
-- one of these and/or which one?!

-- Let's use autopilot to see...

-- Check out this great article on Simple Talk
-- "Hypothetical Indexes on SQL Server"
-- https://www.simple-talk.com/sql/database-administration/hypothetical-indexes-on-sql-server/
------------------------------------------

CREATE INDEX [TestInd_PriorityToSARG]
	ON [dbo].[charge]([charge_amt], [member_no])
INCLUDE ([provider_no],[statement_no])
WITH STATISTICS_ONLY = -1; -- this is the undoc'ed thing that creates this index as a statistic instead
GO

CREATE INDEX [TestInd_PriorityToJoin]
	ON [dbo].[charge]([member_no], [charge_amt])
INCLUDE ([provider_no],[statement_no])
WITH STATISTICS_ONLY = -1; -- this is the undoc'ed thing that creates this index as a statistic instead
GO

-- Use this to get all of the auto pilot parameters:
SELECT db_id() AS Parameter2, 
	object_id('charge') AS Parameter3;

SELECT [i].[name], [i].[index_id] AS Parameter4
FROM [sys].[indexes] AS [i]
WHERE [i].[object_id] = OBJECT_ID('charge');
GO

-- Params: X, DBID (Parameter2), ObjectID (Parameter3), 
-- IndexID (Parameter4 - but, only for those indexes created with statistics_only = -1)
DBCC AUTOPILOT(0, 5, 229575856, 5);
DBCC AUTOPILOT(0, 5, 229575856, 6);
GO

SET AUTOPILOT ON;
GO

-- Here's the query we want to tune - does it use
-- one of the indexes? (turn on showplan to see)
SELECT c.statement_no
		, s.statement_dt
		, c.charge_amt
		, p.provider_name
		, m.lastname
	FROM dbo.Charge AS c
		INNER JOIN dbo.provider AS p 
			ON p.provider_no = c.provider_no
		INNER JOIN dbo.member AS m 
			ON c.member_no = m.member_no
		INNER JOIN dbo.statement AS s 
			ON c.statement_no = s.statement_no
		INNER JOIN dbo.region AS r 
			ON r.region_no = m.region_no
WHERE r.region_name = 'Japan'
	AND c.charge_amt > 2500;
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
-- SQL Server will use (we can see that in the plan). We can 
-- DROP both of these hypothetical indexes (really -> statistics)
-- and just create the index normally.

DROP INDEX [charge].[TestInd_PriorityToSARG]; -- this is really just a statistic
DROP INDEX [charge].[TestInd_PriorityToJoin]; -- this is really just a statistic
GO

--Now, let's create the REAL index and try the query again!
CREATE INDEX [TestInd_PriorityToJoin]
	ON [dbo].[charge] ([member_no], [charge_amt])
INCLUDE ([provider_no], [statement_no]);
GO

-- Here's the original plan without these indexes:
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
GO

-- Here, SQL Server can do whatever they want:
SELECT c.statement_no
		, s.statement_dt
		, c.charge_amt
		, p.provider_name
		, m.lastname
	FROM dbo.Charge AS c
		INNER JOIN dbo.provider AS p 
			ON p.provider_no = c.provider_no
		INNER JOIN dbo.member AS m 
			ON c.member_no = m.member_no
		INNER JOIN dbo.statement AS s 
			ON c.statement_no = s.statement_no
		INNER JOIN dbo.region AS r 
			ON r.region_no = m.region_no
WHERE r.region_name = 'Japan'
	AND c.charge_amt > 2500;
GO