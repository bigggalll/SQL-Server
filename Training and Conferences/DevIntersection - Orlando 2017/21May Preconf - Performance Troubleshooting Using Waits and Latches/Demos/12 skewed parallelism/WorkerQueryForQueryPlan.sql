USE [ExecutionMemory];
GO

DECLARE @CurrentValue NVARCHAR (100);

SELECT TOP (150) 
	@CurrentValue = [CurrentValue]
FROM [Test]
ORDER BY NEWID () DESC;
GO

