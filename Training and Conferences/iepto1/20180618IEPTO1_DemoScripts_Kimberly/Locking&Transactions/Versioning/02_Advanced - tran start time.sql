/*============================================================================
Understanding the point in time when a transaction begins...

  File:     Transaction-level Snapshot.sql

  Summary:  When does a transaction begin and what is the point in time to 
            which all statements reconcile. 
            
            Unfortunately, it's just not as precise as we'd like but this
            will show you the best way to get this value.
  
  SQL Server Version: 2008 R2+
------------------------------------------------------------------------------
  Written by Kimberly L. Tripp, SYSolutions, Inc.

  For more scripts and sample code, check out http://www.SQLskills.com

  This script is intended only as a supplement to demos and lectures
  given by Kimberly L. Tripp.  
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

-- Make sure Credit is clean. 
-- Project: OtherUsefulScripts, Queries: RestoreCredit.sql

-- Set the database to allow transaction-level snapshot isolation
-- NOTE: This turns on versioning

ALTER DATABASE Credit SET ALLOW_SNAPSHOT_ISOLATION ON;
GO

USE [Credit];
GO

-- Part I: run these statements

SET TRANSACTION ISOLATION LEVEL SNAPSHOT
BEGIN TRAN;
SELECT SYSDATETIME(); -- (T1) transaction has not "officially begun"
WAITFOR DELAY '00:00:10.000' -- (T1) transaction has not "officially begun"

-- Within a second or two, go to script: Member_Time-based_Update.sql

-- Come back and execute the following:

SELECT * FROM member where member_no between 1 and 100; -- (T2) transaction t has begun

-- Note: we are seeing data that was modified AFTER we executed
-- BEGIN TRAN. Why? Because that's not officially when our transaction
-- began. This select defined our "begin" and now ALL statements will 
-- reconcile to this point in time.

-- Go and update the data again... (script 2)

-- Come back and before you execute the following - what do you THINK
-- you're going to see?

SELECT * FROM member where member_no between 1 and 100; 

-- Yes! You should see the SAME data as you saw at line 50. This a
-- TRANSACTION-level snapshot. So, even if you update that data
-- numerous times, you will ALWAYS reconcile (in this transaction) to
-- the point in time where the transaction began...


-- The question is - what is that time? Can you see it? KIND OF?!

SELECT dateadd (s, -elapsed_time_seconds, SYSDATETIME()) AS tx_snapshot_time
    , elapsed_time_seconds
FROM sys.dm_tran_active_snapshot_database_transactions AS ast 
    JOIN sys.dm_tran_current_transaction AS ct
        ON ast.transaction_sequence_num = ct.transaction_sequence_num

-- The primary problem with this method is that SQL Server doesn't use a 
-- precise value for elapsed time (it's internal value is divided by 1000 
-- to return seconds). So, while this is close - it's not exact.

-- Finish up this "transaction" 
-- NOTE: Since it doesn't modify data - it doesn't really matter if you
-- commit or rollback. There are *zero* log records associated with it.

COMMIT TRAN;
-- OR
ROLLBACK TRAN;