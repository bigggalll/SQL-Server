/*============================================================================
  File:     IndexingforAND.sql

  Summary:  Various tests and index access patterns using SARGs with AND.
			Clustered index, index intersection, covering indexes
  
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
go

-- Review your index list
EXEC [dbo].[sp_helpindex] N'member';
go

-- Create this single column index
CREATE INDEX MemberFirstName 
ON Member(FirstName)
go

-- Let's start to analyze some queries and their performance:
-- Also turn on showplan
SET STATISTICS IO ON
go

-- Think about three criteria where NONE are selective:
-- index fname, member_no 1/26 * 1/2 = 1/52 but the scan is still 1/26
-- index region_no, member_no 1/3 * 1/2 = 1/6 but the scan is still 1/3

SELECT m.Member_No, m.FirstName, m.Region_No--, lastname
FROM dbo.Member AS m
WHERE m.FirstName LIKE 'K%'		-- guess 1/26 of table
        AND m.Region_No > 6		-- guess 1/3 of table
        AND m.Member_No < 5000	-- guess 1/2 of the table
OPTION (MAXDOP 1)
go

-- The good... not a table scan
-- The bad... created a worktable (HASH)

-- WITH ONLY the indexes created as above this query does
-- as best it can by joining two indexes to cover the query!
-- Great but not as optimal as it could be?!

-------------------------------------------------------------------------------
-- But - let's compare to a table scan
-------------------------------------------------------------------------------

SELECT m.Member_No, m.FirstName, m.Region_No
FROM dbo.Member AS m WITH (INDEX (0))
WHERE m.FirstName LIKE 'K%'		
        AND m.Region_No > 6		
        AND m.Member_No < 5000
OPTION (MAXDOP 1)
go

SELECT m.Member_No, m.FirstName, m.Region_No
FROM dbo.Member AS m
WHERE m.FirstName LIKE 'K%'		
        AND m.Region_No > 6		
        AND m.Member_No < 5000
OPTION (MAXDOP 1)
go

-------------------------------------------------------------------------------
-- Let's compare to a clustered index scan
-------------------------------------------------------------------------------

-- But, wait! We're searching on the CL key...does SQL really need
-- to do a FULL table scan?

SELECT m.Member_No, m.FirstName, m.Region_No
FROM dbo.Member AS m WITH (INDEX (0))
WHERE m.FirstName LIKE 'K%'		
        AND m.Region_No > 6		
        AND m.Member_No < 5000
OPTION (MAXDOP 1)
go

SELECT m.Member_No, m.FirstName, m.Region_No
FROM dbo.Member AS m WITH (INDEX (1))
WHERE m.FirstName LIKE 'K%'		
        AND m.Region_No > 6		
        AND m.Member_No < 5000
OPTION (MAXDOP 1)
go

SELECT m.Member_No, m.FirstName, m.Region_No
FROM dbo.Member AS m
WHERE m.FirstName LIKE 'K%'		
        AND m.Region_No > 6		
        AND m.Member_No < 5000
OPTION (MAXDOP 1)
go

-------------------------------------------------------------------------------
-- Can we do better? Yes, but...
-------------------------------------------------------------------------------

-- It's true, the best choice for indexing for AND is...
-- (1) Create an index on ANY very selective column. If something 
-- is *VERY* selective then that's the *ONLY* index you need!
-- (2) Create an index on ANY combination of selective criteria. You
-- don't need everything from the WHERE clause but try and supply
-- the combination of columns that will yield the most selective set!
-- (3) If nothing is selective - even when combined - then consider 
-- covering the query for high priority/low selectivity range queries.

CREATE INDEX MemberCovering 
ON member(firstname)
INCLUDE(region_no, member_no)

--fn, mno
--fn, mno, rno

-- Is the same as this:
CREATE INDEX MemberCovering_Identical 
ON member(firstname, member_no)
INCLUDE(region_no)

-- Is the same as this:
CREATE INDEX MemberCovering2 
ON member(firstname)
INCLUDE(region_no)

-- You can get my version of sp_helpindex 
-- here: https://www.sqlskills.com/blogs/kimberly/category/sp_helpindex-rewrites/
EXEC sp_SQLskills_helpindex member;
go

-- You can get this procedure here: http://www.sqlskills.com/blogs/kimberly/removing-duplicate-indexes/
sp_sqlskills_SQL2008_finddupes
go

--DROP INDEX [dbo].[member].[MemberCovering_Identical]
--DROP INDEX [dbo].[member].[MemberCovering2]
-----------------------------------------------------------------
-- BEGIN: Internals tangent
-----------------------------------------------------------------
-- A few reminders on index internals:

--CREATE INDEX MemberCovering 
--ON member(firstname, region_no, member_no)

-- IS identical to...

--CREATE INDEX MemberCoveringSame 
--ON member(firstname, region_no)

-- because the member_no column is the clustered index 
-- and therefore will be included - if not already - in the index.

-- It's not identical to this

--CREATE UNIQUE INDEX MemberCoveringUnique
--ON member(firstname, region_no)

-- If you want to see the differences between these indexes use:
-- EXEC sp_SQLskills_helpindex member
-- and
-- SELECT * FROM sys.dm_db_index_physical_stats
--     (DB_ID(), object_id('member'), null, null, 'detailed')

--CREATE INDEX MemberCovering3Cols 
--ON member(firstname)
--INCLUDE (region_no, member_no)

--CREATE INDEX MemberCovering3ColsSame 
--ON member(firstname, member_no)
--INCLUDE (region_no)

---- If firstnames were unique then that would change things:
---- What if we wanted to make a UNIQUE index on FIRSTNAME

---- Find the dupes
--SELECT firstname, count(*) 
--FROM member 
--GROUP BY firstname
--HAVING count(*) > 1

----Modify the two dupe values (MVE and BXI)
--UPDATE member 
--    SET firstname = 'foo' 
--    WHERE member_no = 9292
    
--UPDATE member 
--    SET firstname = 'bar' 
--    WHERE member_no = 4907
    
---- If the values are unique...
--CREATE UNIQUE INDEX MemberCoveringFNUnique
--ON member(firstname)
--INCLUDE (region_no, member_no)

---- Clean up all of these test indexes
--drop index member.MemberCoveringSame
--drop index member.MemberCoveringUnique
--drop index member.MemberCovering3Cols
--drop index member.MemberCovering3ColsSame
--drop index member.MemberCoveringFNUnique
-----------------------------------------------------------------
-- END: Internals tangent :)
-----------------------------------------------------------------


-------------------------------------------------------------------------------
-- Let's compare this current plan to the TWO previous
-------------------------------------------------------------------------------

-- PARTIAL Table Scan
SELECT m.Member_No, m.FirstName, m.Region_No
FROM dbo.Member AS m WITH (INDEX (1))
WHERE m.FirstName LIKE 'K%'		
        AND m.Region_No > 6		
        AND m.Member_No < 5000
OPTION (MAXDOP 1)
go

-- Index intersection/HASH Match
SELECT m.Member_No, m.FirstName, m.Region_No
FROM dbo.Member AS m WITH (INDEX (MemberFirstName, member_region_link))
WHERE m.FirstName LIKE 'K%'		
        AND m.Region_No > 6		
        AND m.Member_No < 5000
OPTION (MAXDOP 1)
go

-- No hints, SQL Server can do whatever it wants :)
SELECT m.Member_No, m.FirstName, m.Region_No
FROM dbo.Member AS m
WHERE m.FirstName LIKE 'K%'		
        AND m.Region_No > 6		
        AND m.Member_No < 5000
OPTION (MAXDOP 1)
go

-------------------------------------------------------------------------------
-- What if we had OTHER covering indexes that could also help this
-- query?! 
-------------------------------------------------------------------------------

--Corresponds to the index in the middle on the slide of the 3 choices
CREATE INDEX MemberCovering2 
ON member (region_no)
INCLUDE(member_no, firstname)

--Corresponds to the index on the right on the slide of the 3 choices
CREATE INDEX MemberCovering3 
ON member (member_no)
INCLUDE(region_no, firstname)

-----------------------------------------------------------------
-- BEGIN: Internals tangent 
-----------------------------------------------------------------
-- Note: MemberCovering2 has multiple dupe indexes:
--CREATE INDEX MemberCovering2_Identical1
--ON member (region_no, member_no)
--INCLUDE(firstname)

--CREATE INDEX MemberCovering2_Identical2
--ON member (region_no)
--INCLUDE(firstname)

-- Use sp_SQLskills_helpindex to review the internals
-- go
-----------------------------------------------------------------
-- END: Internals tangent :)
-----------------------------------------------------------------

-- How do these additional covering indexes compare to the others?!

-- PARTIAL Table Scan
SELECT m.Member_No, m.FirstName, m.Region_No
FROM dbo.Member AS m WITH (INDEX (1))
WHERE m.FirstName LIKE 'K%'		
        AND m.Region_No > 6		
        AND m.Member_No < 5000
OPTION (MAXDOP 1)
go

-- Index intersection/HASH Match
SELECT m.Member_No, m.FirstName, m.Region_No
FROM dbo.Member AS m WITH (INDEX (MemberFirstName, member_region_link))
WHERE m.FirstName LIKE 'K%'		
        AND m.Region_No > 6		
        AND m.Member_No < 5000
OPTION (MAXDOP 1)
go

SELECT m.Member_No, m.FirstName, m.Region_No
FROM dbo.Member AS m WITH (INDEX (MemberCovering3))
WHERE m.FirstName LIKE 'K%'		
        AND m.Region_No > 6		
        AND m.Member_No < 5000
OPTION (MAXDOP 1)
go

SELECT m.Member_No, m.FirstName, m.Region_No
FROM dbo.Member AS m WITH (INDEX (MemberCovering2))
WHERE m.FirstName LIKE 'K%'		
        AND m.Region_No > 6		
        AND m.Member_No < 5000
OPTION (MAXDOP 1)
go

-- No hints, SQL Server can do whatever it wants :)
SELECT m.Member_No, m.FirstName, m.Region_No
FROM dbo.Member AS m
WHERE m.FirstName LIKE 'K%'		
        AND m.Region_No > 6		
        AND m.Member_No < 5000
OPTION (MAXDOP 1)
go


-------------------------------------------------------------------------------
-- If you want to do a bit more testing/learning:
-------------------------------------------------------------------------------

-- What if we could only use one index? Would it be worthwhile?
-- NO! BUT prior to 7.0, SQL Server could only use one index per table
-- per query...these two queries are worse than a table scan! SQL
-- Server would have chosen a table scan over using any of these
-- indexes ALONE.

SELECT m.Member_No, m.FirstName, m.Region_No
FROM dbo.Member AS m WITH (INDEX (MemberFirstName))
WHERE m.FirstName LIKE 'K%'   
        AND m.Region_No > 6 
        AND m.Member_No < 5000  

SELECT m.Member_No, m.FirstName, m.Region_No
FROM dbo.Member AS m WITH (INDEX (member_region_link))
WHERE m.FirstName LIKE 'K%'   
        AND m.Region_No > 6 
        AND m.Member_No < 5000  

-- SO - using two indexes is certainly a better choice! If you ever 
-- want to force multiple indexes, the index order IS IMPORTANT.
-- Make sure to "copy" the plan that SQL Server comes up with and then
-- put the indexes in the same order as they were joined. If you're just
-- testing different combinations then it's best to put the most selective 
-- index first in the hints.
-- Compare these two and you'll see the first is faster because the cost
-- of the HASH match where the smaller table is used as the build and the
-- bigger table is used as the probe is what makes the difference. Remember,
-- you can hover over the LINES to see the row counts going to each processing
-- step.

SELECT m.Member_No, m.FirstName, m.Region_No
FROM dbo.Member AS m WITH (INDEX (MemberFirstName, member_region_link))
WHERE m.FirstName LIKE 'K%'   
        AND m.Region_No > 6 
        AND m.Member_No < 5000  

SELECT m.Member_No, m.FirstName, m.Region_No
FROM dbo.Member AS m WITH (INDEX (member_region_link, MemberFirstName))
WHERE m.FirstName LIKE 'K%'   
        AND m.Region_No > 6 
        AND m.Member_No < 5000  

SELECT m.Member_No, m.FirstName, m.Region_No
FROM dbo.Member AS m
WHERE m.FirstName LIKE 'K%'   
        AND m.Region_No > 6 
        AND m.Member_No < 5000  
go

-- FINALLY, it's important to realize that if our index doesn't cover,
-- then THEN the best index might be NOT to use one...TABLE SCAN
-- A Table scan isn't always the worst choice but, often you can do better!
-- You just have to weigh the cost of wider/covering nonclustered indexes
-- (and more of them) to the insert/update/delete "overhead" that occurs. 
-- It's always a trade-off... In SQL Server 2005, you CAN cover anything 
-- but in the real-world you can't cover everything!!!

SELECT m.Member_No, m.FirstName, m.Region_No, m.phone_no
FROM dbo.Member AS m 
WHERE m.FirstName LIKE 'K%'   
        AND m.Region_No > 6 
        AND m.Member_No < 5000  

SELECT m.Member_No, m.FirstName, m.Region_No, m.phone_no
FROM dbo.Member AS m WITH (index (MemberFirstName))
WHERE m.FirstName LIKE 'K%'   
        AND m.Region_No > 6 
        AND m.Member_No < 5000  

SELECT m.Member_No, m.FirstName, m.Region_No, m.phone_no
FROM dbo.Member AS m WITH (index (member_region_link))
WHERE m.FirstName LIKE 'K%'   
        AND m.Region_No > 6 
        AND m.Member_No < 5000  

-- When forcing multiple indexes - order may be relevant
SELECT m.Member_No, m.FirstName, m.Region_No, m.phone_no
FROM dbo.Member AS m WITH (index (MemberFirstName, member_region_link))
WHERE m.FirstName LIKE 'K%'   
        AND m.Region_No > 6 
        AND m.Member_No < 5000  

SELECT m.Member_No, m.FirstName, m.Region_No, m.phone_no
FROM dbo.Member AS m WITH (index (member_region_link, MemberFirstName))
WHERE m.FirstName LIKE 'K%'   
        AND m.Region_No > 6 
        AND m.Member_No < 5000  

SELECT m.Member_No, m.FirstName, m.Region_No, m.phone_no
FROM dbo.Member AS m WITH (index (MemberCovering))
WHERE m.FirstName LIKE 'K%'   
        AND m.Region_No > 6 
        AND m.Member_No < 5000  

-- DROP INDEX Member.MemberLastName
-- DROP INDEX Member.MemberFirstName
-- DROP INDEX Member.MemberCovering