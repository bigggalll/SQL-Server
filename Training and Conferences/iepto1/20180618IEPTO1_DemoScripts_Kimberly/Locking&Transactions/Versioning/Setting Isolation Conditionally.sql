USE [Credit];
GO

ALTER DATABASE Credit
	SET ALLOW_SNAPSHOT_ISOLATION OFF;
GO
	
DBCC USEROPTIONS;
GO

SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
GO
BEGIN TRANSACTION
SELECT * FROM member
DBCC USEROPTIONS
COMMIT TRAN;
GO  -- Errors, not set for the database
--Msg 3952, Level 16, State 1, Line 14
--Snapshot isolation transaction failed accessing database 'Credit' because snapshot isolation is not allowed in this database. Use ALTER DATABASE to allow snapshot isolation.

-- Need to go back to read committed
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
GO

ALTER DATABASE Credit
	SET ALLOW_SNAPSHOT_ISOLATION ON;
GO
	
DBCC USEROPTIONS;
GO

-- How about now?!
BEGIN TRAN
IF (SELECT snapshot_isolation_state 
	FROM sys.databases 
	WHERE name = db_name()) = 1
	BEGIN
		SET TRANSACTION ISOLATION LEVEL SNAPSHOT
	END
SELECT * FROM member
DBCC USEROPTIONS
COMMIT TRAN;
GO  -- Errors because you can't change isolation IN the transaction
--Msg 3951, Level 16, State 1, Line 41
--Transaction failed in database 'Credit' because the statement was run under snapshot isolation but the transaction did not start in snapshot isolation. You cannot change the isolation level of the transaction to snapshot after the transaction has started unless the transaction was originally started under snapshot isolation level.


-- You'll need to do this programmatically BEFORE
-- the transaction

IF (SELECT snapshot_isolation_state 
	FROM sys.databases 
	WHERE name = db_name()) = 1
	BEGIN
		SET TRANSACTION ISOLATION LEVEL SNAPSHOT
	END

BEGIN TRAN
SELECT * FROM member
DBCC USEROPTIONS
COMMIT TRAN;
GO

DBCC USEROPTIONS;
GO  -- snapshot

-- But, if it's changed INSIDE of a stored procedure
-- it will NOT be set after the execution

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
GO

DBCC USEROPTIONS;
GO  -- read committed

CREATE PROCEDURE TestSnapshotIsolation
AS
IF (SELECT snapshot_isolation_state 
	FROM sys.databases 
	WHERE name = db_name()) = 1
	BEGIN
		SET TRANSACTION ISOLATION LEVEL SNAPSHOT
	END

BEGIN TRAN
SELECT * FROM member
DBCC USEROPTIONS
COMMIT TRAN;
GO

EXEC TestSnapshotIsolation;
GO

DBCC USEROPTIONS;
GO  -- read committed