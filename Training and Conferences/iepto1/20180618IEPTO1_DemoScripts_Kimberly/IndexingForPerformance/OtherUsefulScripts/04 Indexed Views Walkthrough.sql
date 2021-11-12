/*============================================================================
  File:     Indexed Views Walkthrough.sql

  Summary:  This script sets up the queries and indexes needed to show performance
			gains using indexed views. Take your time reviewing all of the code
			in this script. Have fun!

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

USE CREDIT
go

-- These samples use the Credit database. You can download and restore the
-- credit database from here:
-- http://www.sqlskills.com/resources/conferences/CreditBackup80.zip

-- NOTE: This is a SQL Server 2000 backup and MANY examples will work on 
-- SQL Server 2000 in addition to SQL Server 2005.


-- Indexed Views vs performing the aggregate each time!
-- More fully functional IN ENTERPRISE EDITION (or Developer)
IF SERVERPROPERTY('EngineEdition') = 3
	BEGIN
		PRINT 'All features for Indexed Views are fully supported with this Edition.'
	END
ELSE
	BEGIN
		PRINT 'Limited feature support for Indexed Views - must use optimizer hints. See NOEXPAND in the BOL.'
	END
go

USE credit
-- The credit database is a sample database. Unzip the CreditDB.zip file 
-- for a complete set of installation scripts. Read the 1stReadMe.txt 
-- for information on how to create and setup this database.
go
-- A typical and expensive (large worktable - per user) query might be
-- an aggregate like the following:

SELECT c.member_no AS MemberNo, 
	sum(c.charge_amt) AS TotalSales
FROM dbo.charge AS c
GROUP BY c.member_no
go

-- So next we'll create a view...
-- You always start with a view BUT there are a few requirements.
-- The first requirement - of ALL views that will be indexed - is to 
-- create the view with SCHEMABINDING. This forces table stability
-- meaning that all columns on which the view is based cannot be 
-- schematically altered nor can the table be dropped. 
-- To use SCHEMABINDING you must use TWO PART naming for all
-- objects referenced in the view and all objects must exist in the 
-- same database.

/* *******************************************************************
** NOTE: This can have other benefits in that it can protect your tables 
** from being -- dropped accidentally. See the TSQLTutor quick tip, 
** InstantDoc ID #22073 for more information on saving production 
** tables from production dbas.
******************************************************************* */

-- Additionally, on views that contain aggregates, you must include 
-- COUNT_BIG() if you plan to create indexes on the view. 

-- DROP VIEW dbo.SumOfAllChargesByMember

CREATE VIEW dbo.SumOfAllChargesByMember
	WITH SCHEMABINDING  -- required if you plan to index this view!
AS
SELECT c.member_no AS MemberNo, 
	COUNT_BIG(*) AS NumberOfCharges, -- required when GROUP BY is in an indexed view!
	SUM(c.charge_amt) AS TotalSales
FROM dbo.charge AS c
GROUP BY c.member_no
go

-- To test to see if the view has been created and 
-- returns the desired results.
SET STATISTICS IO ON
-- Also, turn on SHOWPLAN (Ctrl+K) if desired.
go
SELECT * FROM dbo.SumOfAllChargesByMember
go
-- Notice the plan. (Showplan Tab in results)
-- When a group by is accessed, the aggregate needs to be 
-- computed on the fly!
-- For each user running the aggregate a worktable will
-- be created. This causes a load on tempdb and cpu - 
-- ultimately it means poor performance when there are
-- numerous users running similar queries.

-- Next we'll track the IOs and time. Clear cache for comparable
-- results. Be cautious not to do this on busy and/or production
-- systems.
-- DBCC FREEPROCCACHE --(to clear plans from cache)
-- DBCC DROPCLEANBUFFERS --(to clear data from cache)
SET STATISTICS IO ON
DECLARE @StartTime	datetime, @EndTime	datetime
SELECT @StartTime = getdate()
SELECT * FROM dbo.SumOfAllChargesByMember
SELECT @EndTime = getdate()
SELECT 'TOTAL TIME (ms)' = datediff (ms, @StartTime, @EndTime)
-- Keep track of time here = ????? ms
-- Keep track of i/o here = ??? Logical Reads
go

-- Next CREATE the Index on the View to Materialize the data
-- fyi - Oracle has a similar feature called Materialized Views, 
-- we call them Indexed Views. They are in fact just another 
-- index on the table and will be used by any query that can 
-- benefit from them!

CREATE UNIQUE CLUSTERED INDEX SumofAllChargesIndex
	ON dbo.SumOfAllChargesByMember (MemberNo) 

-- Notice the column name used here! When an index is placed on a 
-- view with a group by you MUST place the Unique Clustered on 
-- the entire group by clause!

--DROP INDEX dbo.SumOfAllChargesByMember.SumofAllChargesIndex
go

-- Now RESELECT from your view and CHECK out the statistics io 
-- the time AND the graphical showplan with Ctrl+K
-- DBCC FREEPROCCACHE --(to clear plans from cache)
-- DBCC DROPCLEANBUFFERS --(to clear data from cache)
SET STATISTICS IO ON
DECLARE @StartTime	datetime, @EndTime	datetime
SELECT @StartTime = getdate()
SELECT * FROM dbo.SumOfAllChargesByMember  --WITH (NOEXPAND)
ORDER BY memberno
SELECT @EndTime = getdate()
SELECT 'TOTAL TIME (ms)' = datediff (ms, @StartTime, @EndTime)
-- Keep track of time here ???? ms
-- BUT Indexed Views are only accessible AND used
-- on Developer Edition and Enterprise Edition! Check your version
-- with the query at the top of this script and use the WITH (NOEXPAND)
-- to force the index on the view in any other edition!
go

-- BUT on Enterprise/Developer it only gets better!!
-- Any query the can benefit from the index WILL!
-- THIS Query will also use the indexed view (yeah!)

SELECT c.member_no as MemberNo, 
	avg(c.charge_amt) AS TotalSales -- count and sum makes avg easy!
FROM dbo.charge as c -- notice how the view was not even mentioned!
GROUP BY c.member_no
go

-- And how about an Inline table-valued function 
-- for efficient filtering for the indexed view a.k.a.
-- Parameterized Views...

-- DROP FUNCTION dbo.fn_SumforMember

CREATE FUNCTION dbo.fn_SumforMember
	(@member_no int)
RETURNS TABLE 
AS
	RETURN SELECT *
		FROM dbo.SumOfAllChargesByMember WITH (NOEXPAND)
		WHERE MemberNo = @member_no
GO

-- Or a procedure?
-- DROP PROC dbo.SumforMember
CREATE PROC dbo.SumforMember
	(@member_no int)
AS
SELECT *
	FROM dbo.SumOfAllChargesByMember
WHERE MemberNo = @member_no
GO

-- ====================================================
-- Example to execute against the view, the function and the proc
-- ====================================================
SET STATISTICS IO ON
go

SELECT * FROM dbo.SumOfAllChargesByMember 
    WHERE memberno = 9999
	-- Same as function but more typing not as easy to use

SELECT * FROM dbo.fn_SumforMember(9999) 
-- JOIN...
-- WHERE ...
	-- Can add where clauses and programmatically analyze the results

EXEC dbo.SumForMember 9999
	-- just get the data the way the developer wants you to
	-- can be more optimized and you have flexibility in recompilation
go

-- And one more bizarre one for the road
-- what is the avg spending by people with the same 
-- last name?
SET STATISTICS IO ON
go

SELECT m.Lastname, avg(c.charge_amt) AS AvgSales
FROM dbo.charge AS c
	JOIN dbo.member AS m ON m.member_no = c.member_no
GROUP BY m.lastname
go

-- The same query on non-enterprise editions

SELECT m.Lastname, sum(c.TotalSales)/sum(c.NumberOfCharges) AS AvgSales
FROM dbo.SumOfAllChargesByMember AS c WITH (NOEXPAND)
	JOIN dbo.member AS m ON m.member_no = c.MemberNo
GROUP BY m.lastname
go

-------- Or, with SUM  --------
SET STATISTICS IO ON
go

SELECT m.Lastname, sum(c.charge_amt) AS TotalSales
FROM dbo.charge AS c
	JOIN dbo.member AS m ON m.member_no = c.member_no
GROUP BY m.lastname
go

-- The same query on non-enterprise editions

SELECT m.Lastname, sum(c.TotalSales) AS TotalSales
FROM dbo.SumOfAllChargesByMember AS c WITH (NOEXPAND)
	JOIN dbo.member AS m ON m.member_no = c.MemberNo
GROUP BY m.lastname
go