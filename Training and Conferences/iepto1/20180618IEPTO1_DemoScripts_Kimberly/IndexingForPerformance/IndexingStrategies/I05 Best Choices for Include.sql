/*============================================================================
  File:     Best Choices for Include.sql

  Summary:  This script shows a few options for using INCLUDE as well as how
			to see the structures and their differences.
  
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
-- http://www.sqlskills.com/sql-server-resources/sql-server-demos/ 

-- NOTE: You can use a SQL Server 2000 back and restore to: 2000, 2005 or 2008/R2
-- There's also a 2008 backup that you can restore to 2008/R2 or 2012

USE [Credit];
GO

SET STATISTICS IO ON; 
GO

-- You can get my version of sp_helpindex 
-- here: https://www.sqlskills.com/blogs/kimberly/category/sp_helpindex-rewrites/
EXEC [sp_helpindex] '[dbo].[member]';
GO

SELECT lastname, firstname, 
	middleinitial, phone_no
FROM member 
WHERE lastname LIKE '[S-Z]%'

---------------------------------------
-- What if we had an index on 
-- Lastname ONLY? Would SQL Server use
-- it for such a LOW SELECTIVITY query?
CREATE INDEX NCIndexLNOnly
ON member(lastname)

-- nope... so, let's force it 
-- just to check
SELECT lastname, firstname, 
	middleinitial, phone_no
FROM member WITH (INDEX (NCIndexLNOnly))
WHERE lastname LIKE '[S-Z]%'

-- What does SQL Server do?
SELECT lastname, firstname, 
	middleinitial, phone_no
FROM member 
WHERE lastname LIKE '[S-Z]%'

---------------------------------------
-- so, what about covering?
CREATE INDEX NCIndexCoversAll4Cols 
ON member
(lastname, firstname, middleinitial,
	 phone_no)

-- compare this against a table scan
SELECT lastname, firstname, 
	middleinitial, phone_no
FROM member WITH (INDEX (0)) --Index 0 forces a table scan
WHERE lastname LIKE '[S-Z]%'

-- What does SQL Server do?
SELECT lastname, firstname, 
	middleinitial, phone_no
FROM member 
WHERE lastname LIKE '[S-Z]%'
go

-- Quickly get the Index IDs
-- sp_SQLskills_helpindex member

select * from sys.dm_db_index_physical_stats
(db_id(), object_id('member'), null, null, 'detailed')
go

---------------------------------------
-- how about JUST putting lastname in the key
-- and "including" the other columns
CREATE INDEX NCIndexLNinKeyInclude3OtherCols 
ON member(lastname)
INCLUDE (firstname, middleinitial, phone_no)

-- Compare against the fully covering index
SELECT lastname, firstname, 
	middleinitial, phone_no
FROM member WITH (INDEX (NCIndexCoversAll4Cols))
WHERE lastname LIKE '[S-Z]%'

SELECT lastname, firstname, 
	middleinitial, phone_no
FROM member WITH (INDEX (NCIndexLNinKeyInclude3OtherCols))
WHERE lastname LIKE '[S-Z]%'

-- what about index size?
exec sp_dbcmptlevel credit, 90
go

select * from sys.dm_db_index_physical_stats
(db_id(), object_id('member'), null, null, 'detailed')
go
-- basically they're the same size!

-- what index would we *really* create??
CREATE INDEX NCIndexCoveringLnFnMiIncludePhone
ON member(lastname, firstname, middleinitial)
INCLUDE (phone_no)

SELECT lastname, firstname, 
	middleinitial, phone_no
FROM member WITH (INDEX (NCIndexCoversAll4Cols))
WHERE lastname LIKE '[S-Z]%'

SELECT lastname, firstname, 
	middleinitial, phone_no
FROM member WITH (INDEX (NCIndexLNinKeyInclude3OtherCols))
WHERE lastname LIKE '[S-Z]%'

SELECT lastname, firstname, 
	middleinitial, phone_no
FROM member WITH (INDEX (NCIndexCoveringLnFnMiIncludePhone))
WHERE lastname LIKE '[S-Z]%'

-- Ok, if they're all the same, then when NCIndexCoveringLnFnMiIncludePhone????
-- imagine an ORDER BY?
SELECT lastname, firstname, 
	middleinitial, phone_no
FROM member WITH (INDEX (NCIndexCoversAll4Cols))
WHERE lastname LIKE '[S-Z]%'
ORDER BY lastname, firstname, middleinitial

SELECT lastname, firstname, 
	middleinitial, phone_no
FROM member WITH (INDEX (NCIndexLNinKeyInclude3OtherCols))
WHERE lastname LIKE '[S-Z]%'
ORDER BY lastname, firstname, middleinitial

SELECT lastname, firstname, 
	middleinitial, phone_no
FROM member WITH (INDEX (NCIndexCoveringLnFnMiIncludePhone))
WHERE lastname LIKE '[S-Z]%'
ORDER BY lastname, firstname, middleinitial

-- how do these indexes actually differ?

--sp_dbcmptlevel credit, 90
select * from sys.dm_db_index_physical_stats
(db_id(), object_id('member'), null, null, 'detailed')

select * from sys.indexes 
where [object_id] = object_id('member')

-- Can you see INCLUDE columns... not from sp_helpindex
exec sp_helpindex 'member'
go

-- download sp_helpindex2 from my blog: http://www.sqlskills.com/blogs/kimberly/2008/04/02/sphelpindex2ToShowIncludedColumns2005AndFilteredIndexes2008WhichAreNotShownBySphelpindex.aspx
exec sp_SQLskills_helpindex 'member'
go

-- Left-based seeking:
--CREATE INDEX NCIndexCoveringLnFnMiIncludePhone
--ON member(lastname, firstname, middleinitial)
--INCLUDE (phone_no)

-- MI is currently NULL so let's set it...
UPDATE member
	SET middleinitial = substring (firstname, 2, 1)

SELECT lastname, firstname, middleinitial
FROM member
WHERE lastname = 'Anderson'
AND firstname LIKE 'Ki%'

SELECT lastname, firstname, middleinitial
FROM member
WHERE lastname = 'Anderson'
AND middleinitial = 'X'

SELECT lastname, firstname, middleinitial
FROM member
WHERE lastname = 'Barr'
AND middleinitial = 'M'

SELECT lastname, firstname, middleinitial
FROM member
WHERE middleinitial > 'M'
AND firstname LIKE 'K%'
AND lastname = 'Anderson'