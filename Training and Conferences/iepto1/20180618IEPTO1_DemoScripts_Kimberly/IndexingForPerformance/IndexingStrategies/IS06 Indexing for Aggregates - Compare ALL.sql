/*============================================================================
  File:     Indexing for Aggregates - Compare ALL.sql

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

SET STATISTICS IO ON
go

--Here's the final comparisons query

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

SELECT c.member_no AS MemberNo, 
	sum(c.charge_amt) AS TotalSales
FROM dbo.charge AS c
GROUP BY c.member_no
ORDER BY c.member_no
OPTION (MAXDOP 1)
go