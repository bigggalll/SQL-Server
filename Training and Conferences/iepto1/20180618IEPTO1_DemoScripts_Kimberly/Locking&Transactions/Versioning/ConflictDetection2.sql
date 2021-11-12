USE [Credit];
GO

SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
GO

BEGIN TRANSACTION

SELECT [m].* 
FROM [dbo].[member] AS [m] 
WHERE [m].[member_no] BETWEEN 1230 AND 1240;

UPDATE [dbo].[member] 
	SET [lastname] = 'Tripp' 
	WHERE [member_no] = 1234;

SELECT [m].* 
FROM [dbo].[member] AS [m] 
WHERE [m].[member_no] BETWEEN 1230 AND 1240;

COMMIT TRAN

-- ROLLBACK TRAN