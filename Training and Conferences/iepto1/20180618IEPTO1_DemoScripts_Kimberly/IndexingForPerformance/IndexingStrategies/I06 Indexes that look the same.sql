/*============================================================================
  File:     Indexes that look the same.sql

  Summary:  Because SQL Server adds the clustering key into the nonclustered
            indexes, indexes that *LOOK* different may not be?!
  
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

USE JunkDB
go

-- drop procedure test

-- Interesting example
CREATE TABLE Test
(
    TestID  int identity,
    [Name]  char(16)
)
go

CREATE UNIQUE CLUSTERED INDEX TestInd 
ON Test(TestID)
go
CREATE INDEX I1 ON Test ([Name])
go
CREATE INDEX I2 ON Test ([Name], [TestID])
go
CREATE INDEX I3 ON Test ([Name])
INCLUDE ([TestID])
go

sp_helpindex Test
go

-- You can get my version of sp_helpindex 
-- here: https://www.sqlskills.com/blogs/kimberly/category/sp_helpindex-rewrites/
EXEC sp_SQLskills_helpindex Test;
EXEC sp_SQLskills_SQL2008_finddupes;
go

-- Another example using Credit

-- You can download and restore the credit database from here:
-- http://www.sqlskills.com/sql-server-resources/sql-server-demos/ 

-- NOTE: You can use a SQL Server 2000 back and restore to: 2000, 2005 or 2008/R2
-- There's also a 2008 backup that you can restore to 2008/R2 or 2012

USE Credit
go

CREATE INDEX MemberCovering1 
ON member(firstname, region_no, member_no)
INCLUDE (lastname)
go

CREATE INDEX MemberCovering2 
ON member(firstname, region_no)
INCLUDE (lastname)
go

CREATE INDEX MemberCovering3 
ON member(firstname, region_no)
INCLUDE (member_no, lastname)
go

CREATE UNIQUE INDEX MemberCovering4 
ON member(firstname, region_no)
INCLUDE (member_no, lastname)
go

--drop index member.MemberCovering1
--drop index member.MemberCovering2
--drop index member.MemberCovering3
--drop index member.MemberCovering4
go

sp_SQLskills_helpindex member
go

-- See these posts:
-- Understanding duplicate indexes: http://www.sqlskills.com/BLOGS/KIMBERLY/post/UnderstandingDuplicateIndexes.aspx
-- Removing duplicate indexes: http://www.sqlskills.com/BLOGS/KIMBERLY/post/RemovingDuplicateIndexes.aspx

-- The code in the 2nd post (Removing...) will remove all duplicates - even 
-- those that have a different order to the column in the INCLUDE clause.
