/*============================================================================
	File:     CauseDeadlock.sql

	Summary:  Trigger another partition level lock esclation and
			eventually a deadlock

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

-- Cause escalation to another partition X lock by
-- updating all rows from partition 2 in a single
-- transaction
USE LockEscalationTest;
GO

BEGIN TRAN
UPDATE MyPartitionedTable set c1 = c1
	WHERE c1 > 8000 AND c1 < 16000;
GO

-- Check the locks being held...

ROLLBACK TRAN;
GO

-- Use this to cause a deadlock
-- Selects a row from partition 1 while that partition
-- is X locked
SELECT * FROM MyPartitionedTable WHERE c1 = 100;
GO


