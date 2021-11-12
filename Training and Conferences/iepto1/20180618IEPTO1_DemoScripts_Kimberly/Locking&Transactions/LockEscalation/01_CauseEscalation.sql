/*============================================================================
	File:     CauseEscalation.sql

	Summary:  Trigger table and partition level lock escalation

  SQL Server Versions: 2008 onwards
------------------------------------------------------------------------------
  (c) 2011, SQLskills.com. All rights reserved.

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  You may alter this code for your own *non-commercial* purposes. You may
  republish altered code as long as you include this copyright and give due
  credit, but you must obtain prior permission before blogging this code.
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/ 

USE master;
GO

IF DATABASEPROPERTYEX ('LockEscalationTest', 'Version') > 0
	DROP DATABASE LockEscalationTest;
GO

CREATE DATABASE [LockEscalationTest];
GO

USE [LockEscalationTest];
GO

-- Create three partitions: -infinity to 7999, 8000-15999, 16000+
CREATE PARTITION FUNCTION MyPartitionFunction (INT)  -- datetime2(3)
AS RANGE RIGHT FOR VALUES (8000, 16000);
GO

CREATE PARTITION SCHEME MyPartitionScheme
AS PARTITION MyPartitionFunction
ALL TO ([PRIMARY]);
GO

-- Create a partitioned table
CREATE TABLE MyPartitionedTable (c1 INT);  -- datetime2(3)
GO

CREATE UNIQUE CLUSTERED INDEX MPT_Clust 
ON MyPartitionedTable (c1)
ON MyPartitionScheme (c1);
GO

-- Fill the table
SET NOCOUNT ON;
GO

DECLARE @a INT = 1;
WHILE (@a < 24000)
BEGIN
	INSERT INTO MyPartitionedTable VALUES (@a);
	SELECT @a = @a + 1;
END;
GO

-- Show how fast the partition 3 
-- query is (Script 03_QueryPartition3.sql)

-- Specifically set lock escalation to be TABLE
ALTER TABLE MyPartitionedTable
SET (LOCK_ESCALATION = TABLE);
go

-- Update only 1000 rows, this won't escalate
BEGIN TRAN
UPDATE MyPartitionedTable 
SET c1 = c1 WHERE c1 < 1000;
GO

-- Try querying partition 3
-- Check the locks being held...

-- Now, another 5100 rows...
UPDATE MyPartitionedTable SET c1 = c1 
WHERE c1 > 2500 
AND c1 < 7600 -- Nope, not quite enough data to escalate
GO

-- Try querying partition 3
-- Check the locks being held...

-- Now, another 5500 rows... (only 5400 locks)
UPDATE MyPartitionedTable SET c1 = c1 
WHERE c1 > 7500 
and c1 < 13000 -- Nope, even this won't work
GO

-- Try querying partition 3
-- Check the locks being held...

UPDATE MyPartitionedTable 
SET c1 = c1 WHERE c1 < 16000 -- more key locks - why?
-- the number that we needed above and beyond what was already
-- held is well under 5K... no need to escalate!
-- check the OBJECT lock
GO

-- Finally, 7K more rows!
UPDATE MyPartitionedTable 
SET c1 = c1 WHERE c1 < 23000 
-- Yes, escalation occurred but notice that key locks are still there...
-- Also, notice the OBJECT lock now = X
GO

-- OK, you won't be able to query partition 3 but the locks are really 
-- what's interesting in this first section!

ROLLBACK TRAN;
GO

-- Now, let's really cause table-level escalation!
-- Cause escalation by updating 7500 rows from
-- partition 1 in a single transaction
BEGIN TRAN
UPDATE MyPartitionedTable 
SET c1 = c1 WHERE c1 < 7500
GO

-- Try querying partition 3 again- NOPE (re: table-level)
-- Check the locks being held...

ROLLBACK TRAN;
GO

-- Finally, set the locking to partition-level

-- Specifically set lock escalation to be AUTO to
-- allow partition level escalation
ALTER TABLE MyPartitionedTable
SET (LOCK_ESCALATION = AUTO);
GO

-- Cause escalation by updating 7500 rows from
-- partition 1 in a single transaction
BEGIN TRAN
--UPDATE MyPartitionedTable SET c1 = c1 WHERE c1 < 2
UPDATE MyPartitionedTable 
SET c1 = c1 WHERE c1 < 7500
GO

-- Try querying partition 3 again

-- Check the locks being held...

-- Go to CauseDeadlock.sql

-- Use this to cause a deadlock
-- Attempts to select a row from partition 2 while it 
-- is exclusively locked.
SELECT * FROM MyPartitionedTable WHERE c1 = 8500;
GO

-- What about lock escalation across partitions:
ALTER TABLE MyPartitionedTable
SET (LOCK_ESCALATION = AUTO);
GO

BEGIN TRAN
UPDATE MyPartitionedTable SET c1 = c1 WHERE c1 < 1000
GO

-- Try querying partition 3
-- Check the locks being held...

UPDATE MyPartitionedTable SET c1 = c1 WHERE c1 < 7500 -- rows
go

UPDATE MyPartitionedTable SET c1 = c1 WHERE c1 > 8000 and c1 < 9000 -- rows
go

UPDATE MyPartitionedTable SET c1 = c1 WHERE c1 > 9000 and c1 < 16000 -- partition-level
go

ROLLBACK TRANSACTION

-- take two - one statement 6000 rows? 3K in each partition

BEGIN TRAN

UPDATE MyPartitionedTable SET c1 = c1 WHERE c1 > 5000 and c1 < 11000 -- rows (in both partitions)

ROLLBACK TRANSACTION


-- take three - one statement 6000 rows? 5,1K and 1K

BEGIN TRAN

UPDATE MyPartitionedTable SET c1 = c1 WHERE c1 > 7000 and c1 < 13000 -- rows (in both partitions)

ROLLBACK TRANSACTION


-- take three - one statement 7000 rows? 6K and 1K

BEGIN TRAN

UPDATE MyPartitionedTable SET c1 = c1 WHERE c1 > 7000 and c1 < 14000 -- partition in 5K+ and rows in 1K case

ROLLBACK TRANSACTION

