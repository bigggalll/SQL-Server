/*============================================================================
  File:     Transaction madness.sql

  Summary:  What happens in terms of transaction state incl. commit/rollback 
            in the bounds of a transaction.
  
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


USE credit
go

------------------------------------------------------------------------------
-- Scenario 1: Understanding nested transactions and only using rollbacks to 
-- savepoints.
------------------------------------------------------------------------------

SELECT * 
	FROM member 
	WHERE member_no BETWEEN 1260 AND 1262

BEGIN TRAN 
    -- this establishes your user-defined transaction
 
SELECT @@trancount -- 1

UPDATE member
	SET firstname = 'Kimberly'
	WHERE member_no = 1260
	
SELECT @@trancount -- 1

SAVE TRANSACTION bar 
    -- the savepoint creates a name in the transaction to which you can 
    -- rollback STATE but NOT the transaction count (or level, per se) 
    -- because there really isn't any such thing as a nested transaction.

SELECT @@trancount -- 1
    -- you can confirm that the trancount hasn't changed here
    
	BEGIN TRAN
	    -- this creates our "nested transaction" but realize that this is
	    -- nested LOGICALLY but not physically. There is no spoon.
	    
	SELECT @@trancount --2
	    -- You can see the logical nesting here...
	    
	UPDATE member
		SET firstname = 'Kimberly'
		WHERE member_no = 1261
		
	SELECT @@trancount --2
	    -- OK, this isn't really interesting...
	    
	SELECT * 
	FROM member 
	WHERE member_no BETWEEN 1260 AND 1262
	
	    -- Both rows 1260/1261 have been modified
	
	ROLLBACK TRAN bar  -- once you rollback to a savepoint the name is invalidated
	    -- There are two things that are interesting here:
	    --     this rolls back STATE
	    --     this does NOT decrement the trancount
	    
	SELECT * 
	FROM member 
	WHERE member_no BETWEEN 1260 AND 1262
	
	    -- Only row 1260 is changed
		
	SELECT @@trancount --2, We are still in the "nested" transaction
	
	SAVE TRAN foo -- this does NOT change our @@trancount
	
    SELECT @@trancount --2, We are still in the "nested" transaction (prooving point)
    
	UPDATE member
		SET firstname = 'Kimberly'
		WHERE member_no = 1262
	
	SELECT * 
	FROM member 
	WHERE member_no BETWEEN 1260 AND 1262
	    -- Both rows 1260/1262 have been modified
		
	SELECT @@trancount --2, We are still in the "nested" transaction
	
	COMMIT TRAN -- does NOTHING except decrement @@trancount

SELECT @@trancount --1, Now we're out of the "nested" transaction

ROLLBACK TRAN foo
    -- There are two things that are interesting here:
    --     this rolls back STATE (even into the "nested" tran because it doesn't really exist)
    --     this DOES decrement the trancount (ROLLBACK of a tran ALWAYS decrements the @@trancount to 0)

SELECT * 
FROM member 
WHERE member_no BETWEEN 1260 AND 1262

SELECT @@trancount -- 1

--ROLLBACK TRAN
-- OR
COMMIT TRAN

SELECT * 
FROM member 
WHERE member_no BETWEEN 1260 AND 1262