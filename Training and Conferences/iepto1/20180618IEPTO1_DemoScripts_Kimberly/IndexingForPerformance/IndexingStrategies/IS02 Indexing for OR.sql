/*============================================================================
  File:     IndexingforOR.sql

  Summary:  Various tests and index access patterns using OR.
  
  Date:     February 2011

  SQL Server Version: SQL Server 2005/2008
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

-------------------------------------------------------------------------------
-- Update a few rows on which we will later search.
-------------------------------------------------------------------------------

UPDATE Member
SET LastName = 'Tripp'
WHERE Member_No = 6798
go

UPDATE Member
SET FirstName = 'Kimberly'
WHERE Member_No = 2896
go

UPDATE Member
SET FirstName = 'Kimberly',
	LastName = 'Tripp'
WHERE Member_No = 842
go

-------------------------------------------------------------------------------
-- Create some simple and common (narrow!) indexes
-------------------------------------------------------------------------------

-- Review your index list
EXEC sp_helpindex member
go

-- Create indexes on criteria used in lookups
CREATE INDEX MemberLastName 
	ON Member(LastName)
go

CREATE INDEX MemberFirstName 
	ON Member(FirstName)
go

-------------------------------------------------------------------------------
-- Review the processing and access patterns
-------------------------------------------------------------------------------

SET STATISTICS IO ON
go

SELECT m.LastName, m.FirstName, m.Region_No
FROM dbo.Member AS m
WHERE m.FirstName = 'Kimberly'
	OR m.LastName = 'Tripp'
OPTION (MAXDOP 1)
go

-------------------------------------------------------------------------------
-- What's interesting is that the bookmark lookup can be very costly.
-- if you had covering indexes (maybe for other queries, etc.), would
-- SQL Server use them here?
-------------------------------------------------------------------------------

CREATE INDEX Member1 
	ON dbo.member(firstname)
	   INCLUDE(lastname, region_no)
go

CREATE INDEX Member2 
	ON dbo.member(lastname)
	    INCLUDE(firstname, region_no)
go

-- Run the two search conditions separately:
SELECT m.LastName, m.FirstName, m.Region_No, m.member_no
FROM dbo.Member AS m
WHERE m.FirstName LIKE 'Kimberly'
OPTION (MAXDOP 1)
go
SELECT m.LastName, m.FirstName, m.Region_No, m.member_no
FROM dbo.Member AS m
WHERE m.LastName LIKE 'Tripp'
OPTION (MAXDOP 1)
go

-------------------------------------------------------------------------------
-- Bring them all together!
-------------------------------------------------------------------------------

-- Now, put them together in an OR
SELECT m.LastName, m.FirstName, m.Region_No, m.member_no
FROM dbo.Member AS m
WHERE m.FirstName LIKE 'Kimberly'
	OR m.LastName LIKE 'Tripp'
OPTION (MAXDOP 1)
go

SELECT m.LastName, m.FirstName, m.Region_No, m.member_no
FROM dbo.Member AS m
WHERE m.FirstName LIKE 'Kimberly'
UNION
SELECT m.LastName, m.FirstName, m.Region_No, m.member_no
FROM dbo.Member AS m
WHERE m.LastName LIKE 'Tripp'
OPTION (MAXDOP 1)
go

--SELECT DISTINCT a.* FROM
--(SELECT m.LastName, m.FirstName, m.Region_No, m.member_no
--FROM dbo.Member AS m
--WHERE m.FirstName LIKE 'Kimberly'
--UNION ALL
--SELECT m.LastName, m.FirstName, m.Region_No, m.member_no
--FROM dbo.Member AS m
--WHERE m.LastName LIKE 'Tripp') AS a
--OPTION (MAXDOP 1)
--go

SELECT m.LastName, m.FirstName, m.Region_No, m.member_no
FROM dbo.Member AS m
WHERE m.FirstName LIKE 'Kimberly'
UNION ALL
SELECT m.LastName, m.FirstName, m.Region_No, m.member_no
FROM dbo.Member AS m
WHERE m.LastName LIKE 'Tripp'
OPTION (MAXDOP 1)
go

-------------------------------------------------------------------------------
-- Wait - but can we always do this so easily???? 
-- Is UNION *always* the same as OR?
-------------------------------------------------------------------------------

-- IS UNION always the same as OR...NO!
-- UNION removes dupes based on the SELECT LIST
-- OR removes dupes based on ROWID (OR unique row identifier)

-- Let's update more rows...
UPDATE member
    SET firstname = 'Kimberly',
            lastname = 'Tripp'
    WHERE member_no % 19 = 0

UPDATE member
    SET firstname = 'Kimberly'
    WHERE member_no % 17 = 0
go

-------------------------------------------------------------------------------
-- Let's compare with larger sets and NO KEY
-------------------------------------------------------------------------------

-- Review the number of rows returned from each of these:
SELECT COUNT(*) AS [Row Count for OR] 
FROM (SELECT m.LastName, m.FirstName, m.Region_No
	FROM dbo.Member AS m
	WHERE m.FirstName LIKE 'Kimberly'
		OR m.LastName LIKE 'Tripp') AS Sub
go

SELECT COUNT(*) AS [Row Count for UNION] 
FROM (SELECT m.LastName, m.FirstName, m.Region_No
	FROM dbo.Member AS m
	WHERE m.FirstName LIKE 'Kimberly'
	UNION
	SELECT m.LastName, m.FirstName, m.Region_No
	FROM dbo.Member AS m
	WHERE m.LastName LIKE 'Tripp') AS Sub
go

SELECT COUNT(*) AS [Row Count for UNION ALL] 
FROM (SELECT m.LastName, m.FirstName, m.Region_No
	FROM dbo.Member AS m
	WHERE m.FirstName LIKE 'Kimberly'
	UNION ALL
	SELECT m.LastName, m.FirstName, m.Region_No
	FROM dbo.Member AS m
	WHERE m.LastName LIKE 'Tripp') AS Sub
go

-------------------------------------------------------------------------------
-- Let's compare with larger sets WITH the Primary Key
-------------------------------------------------------------------------------

SELECT m.LastName, m.FirstName, m.Region_No, m.member_no
FROM dbo.Member AS m
WHERE m.FirstName LIKE 'Kimberly'
	OR m.LastName LIKE 'Tripp'
go

SELECT m.LastName, m.FirstName, m.Region_No, m.member_no
FROM dbo.Member AS m
WHERE m.FirstName LIKE 'Kimberly'
UNION
SELECT m.LastName, m.FirstName, m.Region_No, m.member_no
FROM dbo.Member AS m
WHERE m.LastName LIKE 'Tripp'
go

-------------------------------------------------------------------------------
-- UNION ALL may still be BETTER!
-------------------------------------------------------------------------------

-- Remember that UNION ALL does NOT guarantee an identical
-- result set BUT if you
--	Don't care about dupes
--	OR 
--	You know your data REALLY well...
SELECT m.LastName, m.FirstName, m.Region_No, m.member_no
FROM dbo.Member AS m
WHERE m.FirstName LIKE 'Kimberly'
UNION ALL
SELECT m.LastName, m.FirstName, m.Region_No, m.member_no
FROM dbo.Member AS m
WHERE m.LastName LIKE 'Tripp'
go
