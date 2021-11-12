USE [Credit];
GO

-- If it's not already on...
ALTER DATABASE Credit SET ALLOW_SNAPSHOT_ISOLATION ON;
GO

SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
GO

BEGIN TRANSACTION

SELECT [m].* 
FROM [dbo].[member] AS [m] 
WHERE [m].[member_no] BETWEEN 1230 AND 1240;

-- execute JUST up to here...
-- Now, go to ConflictDetection2 and execute the entire script

UPDATE [dbo].[member] 
	SET [firstname] = 'Kimberly' 
	WHERE [member_no] = 1234;

--Msg 3960, Level 16, State 2, Line 6
--Snapshot isolation transaction aborted due to update conflict. 

-- Are we still in a tran?
SELECT @@TRANCOUNT

-- What does the data look like?
SELECT [m].* 
FROM [dbo].[member] AS [m] 
WHERE [m].[member_no] BETWEEN 1230 AND 1240;