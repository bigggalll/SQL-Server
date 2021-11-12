USE ExecutionMemory;

DECLARE @CurrentValue NVARCHAR(100)
WHILE 1=1
BEGIN
	SELECT TOP(150) 
		@CurrentValue = CurrentValue
	FROM Test
	ORDER BY NEWID() DESC;
	
	--WAITFOR DELAY '00:00:05.000';
END