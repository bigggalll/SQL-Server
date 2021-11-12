USE AdventureWorks
GO

/* prep 
--demo table
CREATE TABLE EvilNoLock(
	ID INT NOT NULL IDENTITY(1,1)
	,SomeData uniqueidentifier NOT NULL DEFAULT(NEWID())
)	

--load table
SET NOCOUNT ON 

DECLARE @i INT 
SET @i = 1
WHILE @i <= 100000
BEGIN
	INSERT dbo.EvilNoLock(SomeData) DEFAULT VALUES 
	SET @i = @i + 1	
END 

--index to ensure we will get page splits
CREATE UNIQUE CLUSTERED INDEX CX_EvilNoLock ON EvilNoLock(SomeData)

*/

--count rows 
SELECT COUNT(*) FROM dbo.EvilNoLock

SELECT TOP 1000 * FROM dbo.EvilNoLock

--monitor rowcount
DECLARE 
	@TableRows		INT 
	,@CurrentRows	INT

SET @TableRows = (SELECT COUNT(*) FROM dbo.EvilNoLock)

WHILE 1 = 1
BEGIN
    WAITFOR DELAY '00:00:00.300'

    SET @CurrentRows = (SELECT COUNT(*) FROM dbo.EvilNoLock WITH (NOLOCK))

    PRINT 'RowCount: ' + CONVERT(VARCHAR(50),@CurrentRows)
END



