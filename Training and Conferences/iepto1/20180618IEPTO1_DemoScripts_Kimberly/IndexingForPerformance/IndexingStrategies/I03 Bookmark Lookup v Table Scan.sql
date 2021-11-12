/*============================================================================
  File:     Bookmark Lookup v Table Scan.sql

  Summary:  At what point is a bookmark query NOT selective enough to
			warrant the overhead of the relatively "random" I/Os that
			occur? Is it 50%, 30%, 10% or ???.

			These are numbers that reflect even fewer IOs (therefore rows)
			must be requested in order to move from bookmark lookups to 
			a table scan - on a dual core (re: parallelism benefits).
  
  SQL Server Version: SQL Server 2005+
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

USE credit
go

-------------------------------------------------------------------------------
-- (1) Create two tables which are copies of charge:
-------------------------------------------------------------------------------

-- Create the HEAP
SELECT *
INTO ChargeHeap
FROM Charge
go

-- Create the CL Table
SELECT *
INTO ChargeCL
FROM Charge
go

CREATE CLUSTERED INDEX ChargeCL_CLInd 
	ON ChargeCL (member_no, charge_no)
go

-------------------------------------------------------------------------------
-- (2) Add the same non-clustered indexes to BOTH of these tables:
-------------------------------------------------------------------------------

-- Create the NC index on the HEAP
CREATE INDEX ChargeHeap_NCInd ON ChargeHeap (Charge_no)
go

-- Create the NC index on the CL Table
CREATE INDEX ChargeCL_NCInd ON ChargeCL (Charge_no)
go

-- Review the structures:
select * from sys.dm_db_index_physical_stats
(db_id(), object_id('ChargeHeap'), null, null, 'detailed')
go

select * from sys.dm_db_index_physical_stats
(db_id(), object_id('ChargeCL'), null, null, 'detailed')
go

-------------------------------------------------------------------------------
-- (3) Begin to query these tables and see what kind of access and I/O returns
-------------------------------------------------------------------------------

-- Get ready for a bit of analysis:
SET STATISTICS IO ON
-- Turn Graphical Showplan ON (Ctrl+K)

-- First, a point query (also, see how a bookmark lookup shows up in showplan)
SELECT * FROM ChargeHeap
WHERE Charge_no = 12345
go

SELECT * FROM ChargeCL
WHERE Charge_no = 12345
go

-- What if our query is less selective?
-- 1000 is .0625% of our data... (1,600,000 million rows)
SELECT * FROM ChargeHeap
WHERE Charge_no < 1000 
go

SELECT * FROM ChargeCL
WHERE Charge_no < 1000 
go

-- Reviewing the sizes:
-- ChargeHeap is 9304 pages (in level 0 of the clustered index)
-- ChargeCL is 9524 pages (in level 0 of the clustered index)

-- What if our query is less selective?
-- 16000 is 1% of our data... (1,600,000 million rows)

SELECT * FROM ChargeHeap
WHERE Charge_no < 16000 
--OPTION (MAXDOP 1)
go

SELECT * FROM ChargeCL
WHERE Charge_no < 16000
--OPTION (MAXDOP 1)
go

-------------------------------------------------------------------------------
-- (4) What's the EXACT percentage where the bookmark lookup isn't worth it?

-- REMEMBER, there are some HARDWARE dependencies like # of CPUs and disk affinity
-- So, your mileage may vary. 

-- These numbers are from a DUAL CORE laptop (Lenovo T61p) with 4GB of memory
-------------------------------------------------------------------------------

-- What happens here: Table Scan or Bookmark lookup?
SELECT * FROM ChargeHeap
WHERE Charge_no < 4000
go

SELECT * FROM ChargeCL
WHERE Charge_no < 4000
go

-- What happens here: Table Scan or Bookmark lookup?
SELECT * FROM ChargeHeap
WHERE Charge_no < 3000
go

SELECT * FROM ChargeCL
WHERE Charge_no < 3000
go

-- And - you can narrow it down by trying the middle ground:
-- What happens here: Table Scan or Bookmark lookup?

SELECT * FROM ChargeHeap
WHERE Charge_no < 2500
go

SELECT * FROM ChargeCL
WHERE Charge_no < 2500
go

-- And again:
SELECT * FROM ChargeHeap
WHERE Charge_no < 2750
go

SELECT * FROM ChargeCL
WHERE Charge_no < 2750
go

-- Don't worry, I won't make you go through it all :)
-- what do we know - the tipping point is somewhere between
-- 2750 and 3000 rows (1/4 - 1/3 of the pages in the table)
-- ChargeHeap is 9304 pages (in level 0 of the clustered index)
--		1/4 = 2326		1/3 = 3070
-- ChargeCL is 9524 pages (in level 0 of the clustered index)
--		1/4 = 2381		1/3 = 3143







-- For the Heap Table (in THIS case), the cutoff is: .163% (yes, 1/6th of 1%)
-- SELECT convert(decimal(16,8), 2616)/1600000*100
SELECT * FROM ChargeHeap
WHERE Charge_no < 2616
go
SELECT * FROM ChargeHeap
WHERE Charge_no < 2617
go

-- For the CL Table (in THIS case), the cutoff is: .167% (yes, 1/6th of 1%)
-- SELECT convert(decimal(16,8), 2673)/1600000*100
SELECT * FROM ChargeCL
WHERE Charge_no < 2673
go
SELECT * FROM ChargeCL
WHERE Charge_no < 2674
go



-- In testing - you might actually find that the tipping point is a bit too early...
-- in SQL Server 2008, you can use a FORCESEEK hint. Be careful. This *might*
-- be beneficial AROUND the tipping point but if you go much higher - you might 
-- completely shoot yourself in the foot... For example, check out the plans
-- of these two queries - which are only 2% of the total data:
SELECT * FROM ChargeCL
WHERE Charge_no < 32000
-- SQL Server chooses a scan = 9648 I/Os

SELECT * FROM ChargeCL (FORCESEEK)
WHERE Charge_no < 32000 
-- We force a seek and SQL Server does = 98,066 I/Os
go