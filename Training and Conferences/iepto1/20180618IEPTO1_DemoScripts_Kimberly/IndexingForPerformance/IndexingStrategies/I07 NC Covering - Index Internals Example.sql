/*============================================================================
  File:     NC Covering Example.sql

  Summary:  These examples run against the Index Internals database.
            You can find this online on my blog here:
            http://www.sqlskills.com/BLOGS/KIMBERLY/post/Companion-content-for-Chapter-6-(Index-Internals)-of-SQL-Server-2008-Internals.aspx
            
            This highlights the concept shown here are from Module: Internals & Data Access, Slide 16.
  
  SQL Server Version: 2008+ (only because of the backup of IndexInternals)
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

-- You can get my IndexInternals database from my Inside SQL Server 2008, Chapter 6 
-- sample database here: http://www.sqlskills.com/blogs/kimberly/companion-content-for-chapter-6-index-internals-of-sql-server-2008-internals/

USE IndexInternals;
go

SET STATISTICS IO ON;
go
-- Turn Graphical Showplan ON (Ctrl+K)

EXEC sp_helpindex employee;
go

-- You can get my version of sp_helpindex 
-- here: https://www.sqlskills.com/blogs/kimberly/category/sp_helpindex-rewrites/
EXEC sp_SQLskills_helpindex employee;
go


SELECT * FROM SYS.dm_db_index_physical_stats 
    (db_id(), object_id('employee'), null, null, 'detailed')

SELECT e.EmployeeID, e.SSN
FROM dbo.Employee AS e 
WHERE e.SSN BETWEEN '590-05-9238' 
	AND '590-06-0292'
go

SELECT e.EmployeeID, e.SSN
FROM dbo.Employee AS e 
WHERE e.EmployeeID < 10000
go

SELECT e.EmployeeID, e.SSN
FROM dbo.Employee AS e WITH (INDEX (1))
WHERE e.EmployeeID < 10000
go

SELECT e.EmployeeID, e.SSN
FROM dbo.Employee AS e WITH (INDEX (0))
WHERE e.EmployeeID < 10000
go

CREATE INDEX NCCoveringSeekableInd 
ON Employee(EmployeeID, SSN)
go

-- NC Covering Seek
SELECT e.EmployeeID, e.SSN
FROM dbo.Employee AS e 
WHERE e.EmployeeID < 10000
go

-- NC Covering Scan
SELECT e.EmployeeID, e.SSN
FROM dbo.Employee AS e WITH (INDEX ([EmployeeSSNUK]))
WHERE e.EmployeeID < 10000
go

-- What about a small range
SELECT e.EmployeeID, e.SSN
FROM dbo.Employee AS e 
WHERE e.EmployeeID < 10
go

SELECT e.EmployeeID, e.SSN
FROM dbo.Employee AS e WITH (INDEX (1))
WHERE e.EmployeeID < 10
go

--What about a big range??
SELECT e.EmployeeID, e.SSN
FROM dbo.Employee AS e 
WHERE e.EmployeeID < 60000
go

SELECT e.EmployeeID, e.SSN
FROM dbo.Employee AS e WITH (INDEX ([EmployeeSSNUK]))
WHERE e.EmployeeID < 60000
go