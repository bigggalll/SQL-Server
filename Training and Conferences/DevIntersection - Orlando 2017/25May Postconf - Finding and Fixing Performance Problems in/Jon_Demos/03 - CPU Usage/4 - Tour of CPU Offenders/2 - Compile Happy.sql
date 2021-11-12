USE Credit;
GO

-- Start by creating the procedure
CREATE PROCEDURE dbo.compile_happy
AS

SET ANSI_NULLS OFF

SELECT TOP 1 *
FROM dbo.category
OPTION (RECOMPILE);

CREATE TABLE #T1 
	(col01 int NOT NULL)

ALTER TABLE #T1
ADD col02 int NOT NULL

INSERT #T1
VALUES (1,1)

SELECT col01, col02
FROM #T1

INSERT #T1
VALUES (2,2)

DROP TABLE #T1

GO


USE Credit;
GO

EXEC dbo.compile_happy;
GO 2000000000

--DECLARE @MovingTarget datetime = GETDATE();
--DECLARE @PowerItUp bigint;

--WHILE DATEADD(second,20000, @MovingTarget)
--	>GETDATE()
--BEGIN
--	BEGIN TRAN
--	EXEC dbo.compile_happy
--	COMMIT TRAN
--END
