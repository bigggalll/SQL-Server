/*============================================================================
  File:     Indexing for Aggregates.sql

  Summary:  This script sets up the queries and indexes needed to show performance
			gains for indexing aggregate queries.

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

USE CREDIT
go

-- Review your index list
EXEC sp_helpindex charge
go

-- Let's start to analyze some queries and their performance:
SET STATISTICS IO ON
go

-------------------------------------------------------------------------------
-- Start with a simple aggregate
-------------------------------------------------------------------------------

SELECT c.member_no AS MemberNo, 
	sum(c.charge_amt) AS TotalSales
FROM dbo.charge AS c	
GROUP BY c.member_no
OPTION (MAXDOP 1)
go

-- Notice that the data does not come back ordered by the GROUP BY
-- HASH aggregates do NOT return the data ordered. 
-- You MUST add order by if you want the data ordered.

SELECT c.member_no AS MemberNo, 
	sum(c.charge_amt) AS TotalSales
FROM dbo.charge AS c	
GROUP BY c.member_no
ORDER BY c.member_no
OPTION (MAXDOP 1)
go
-- Notice that adding the ORDER BY also adds an additional step to sort
-- the data. Depending on the result size, this could be expensive!

-------------------------------------------------------------------------------
-- What if we didn't need to TABLE SCAN to get the data
-- What if another index was created for another higher priority
-- query - that covered this query??!
-------------------------------------------------------------------------------

CREATE INDEX Covering1 
ON dbo.charge(charge_amt, member_no) 
	-- Not in order by the Group By 
go

SELECT member_no AS MemberNo, 
	sum(charge_amt) AS TotalSales
FROM dbo.charge 
GROUP BY member_no
ORDER BY member_no
OPTION (MAXDOP 1)
go
-- Notice that we still see a HASH AGGREGATE but on a narrower
-- set... When we compare all of these you'll see that this yields 
-- fewer I/Os and is therefore a less expensive plan.
go

SELECT c.member_no AS MemberNo, 
	sum(c.charge_amt) AS TotalSales
FROM dbo.charge AS c WITH (INDEX(0))
GROUP BY c.member_no
ORDER BY c.member_no
OPTION (MAXDOP 1)
go

SELECT c.member_no AS MemberNo, 
	sum(c.charge_amt) AS TotalSales
FROM dbo.charge AS c
GROUP BY c.member_no
ORDER BY c.member_no
OPTION (MAXDOP 1)
go

-------------------------------------------------------------------------------
-- What if we didn't need to do a HASH aggregate to access/sum the data
-- What if we covered this query in the order of the GROUP BY?
-- Then you can "stream" the aggregates as you move through the data...
-------------------------------------------------------------------------------

-- There are two ways of doing this really:
CREATE INDEX Covering2 
ON charge(member_no, charge_amt) 
WITH (MAXDOP =1)
go

-- Covering2
--Btree: member_no, charge_amt, charge_no
--LEAF : member_no, charge_amt, charge_no

-- CoveringWithInclude 
--Btree: member_no, charge_no
--Leaf : member_no, charge_no, charge_amt

-- Or use include:
CREATE INDEX CoveringWithInclude 
ON dbo.charge (member_no)
INCLUDE (charge_amt)
WITH (MAXDOP =1)
go

-- In terms of size, there's NO difference:
SELECT * 
FROM sys.dm_db_index_physical_stats
(db_id(), object_id('charge'), NULL, NULL, 'detailed')
go

sp_helpindex charge
go

SELECT index_id, [name]
FROM sys.indexes
WHERE object_id = object_id('charge')
go

-- You can get my version of sp_helpindex 
-- here: https://www.sqlskills.com/blogs/kimberly/category/sp_helpindex-rewrites/
EXEC sp_SQLskills_helpindex charge;
go

SELECT index_id, index_type_desc, index_depth, index_level, page_count, record_count 
FROM sys.dm_db_index_physical_stats(db_id(), object_id('charge'), NULL, NULL, 'detailed')
WHERE index_id IN (7,8)
go

-------------------------------------------------------------------------------
-- OK, so they're the same structures but what about query perf
-------------------------------------------------------------------------------

SELECT c.member_no AS MemberNo, 
	sum(c.charge_amt) AS TotalSales
FROM dbo.charge AS c WITH (INDEX(Covering2))
GROUP BY c.member_no
ORDER BY c.member_no
OPTION (MAXDOP 1)
go

SELECT c.member_no AS MemberNo, 
	sum(c.charge_amt) AS TotalSales
FROM dbo.charge AS c WITH (INDEX(CoveringWithInclude))
GROUP BY c.member_no
ORDER BY c.member_no
OPTION (MAXDOP 1)
go

-------------------------------------------------------------------------------
-- Now - let's compare ALL three
-------------------------------------------------------------------------------

SELECT c.member_no AS MemberNo, 
	sum(c.charge_amt) AS TotalSales
FROM dbo.charge AS c WITH (INDEX (0))
GROUP BY c.member_no
ORDER BY c.member_no
OPTION (MAXDOP 1)
go

SELECT c.member_no AS MemberNo, 
	sum(c.charge_amt) AS TotalSales
FROM dbo.charge AS c WITH (INDEX (Covering1))
GROUP BY c.member_no
ORDER BY c.member_no
OPTION (MAXDOP 1)
go

SELECT c.member_no AS MemberNo, 
	sum(c.charge_amt) AS TotalSales
FROM dbo.charge AS c WITH (INDEX(CoveringWithInclude))
GROUP BY c.member_no
ORDER BY c.member_no
OPTION (MAXDOP 1)
go

-- But.. in all cases we still needed to compute the aggregate!

SELECT c.member_no AS MemberNo, 
	max(c.charge_amt) AS TotalSales
FROM dbo.charge AS c WITH (INDEX(CoveringWithInclude))
where member_no = 80
GROUP BY c.member_no
ORDER BY c.member_no
OPTION (MAXDOP 1)
go

SELECT c.member_no AS MemberNo, 
	max(c.charge_amt) AS TotalSales
FROM dbo.charge AS c WITH (INDEX(Covering2))
where member_no = 80
GROUP BY c.member_no
ORDER BY c.member_no
OPTION (MAXDOP 1)
go