USE Credit;
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'NCL_charge_charge_dt')
BEGIN
	DROP INDEX [dbo].[charge].[NCL_charge_charge_dt]
END
GO

DECLARE @MovingTarget datetime = GETDATE();
DECLARE @PowerItUp bigint;

WHILE DATEADD(second,20000, @MovingTarget)
	>GETDATE()
BEGIN
	EXEC sp_executesql 
	N'SELECT charge_no FROM dbo.charge
	WHERE charge_dt = @charge_dt',
	N'@charge_dt datetime',  
	@charge_dt = '1999-07-20 10:49:11.833';
END
