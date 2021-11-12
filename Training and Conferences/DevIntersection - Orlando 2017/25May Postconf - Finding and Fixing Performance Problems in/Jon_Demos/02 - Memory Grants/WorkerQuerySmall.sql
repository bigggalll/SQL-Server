USE ExecutionMemory;

DECLARE @CurrentValue NVARCHAR(100)
WHILE 1=1
BEGIN
	SELECT TOP(150) 
		@CurrentValue = CurrentValue
	FROM Test2
	ORDER BY NEWID() DESC;
END