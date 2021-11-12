/*
Severity
1-9	Informational - Error number in black with error message
		@@ERROR is NOT set
		if logged - will show as INFORMATIONAL

10	Warning - ONLY the error message is returned
		@@ERROR is NOT set		
		if logged - will show as INFORMATIONAL

11-16	Error - USER defined error...default 16
		Error number in red with error message
		@@ERROR is set
		11-14 	if logged - will show as INFORMATIONAL
		15 	if logged - will show as Warning
		16	if logged - will show as ERROR

17-25	SQL Server ONLY

State
127 Kills client connection
Check out this article for more info...
http://www.itprotoday.com/software-development/all-about-raiserror
*/

USE master
go
--EXEC sp_dropmessage 900001, 'FRENCH' -- Once you add messages in additional langs you must drop them first to drop the english message.
--EXEC sp_dropmessage 900001
GO
exec sp_addmessage @msgnum = 900001, 
	@severity = 16, 
	@msgtext = 'Value %s is invalid. Procedure %s expected a value of TRUE or FALSE for parameter %s. The default is %s.' 
	, @lang =   'US_English'
	, @with_log =  'FALSE'
go
exec sp_addmessage @msgnum = 900001, 
	@severity = 16, 
	@msgtext = N'La valeur %!1 est inadmissible.  Le procédé %!2 s''est attendu à une valeur de TRUE (VRAI) ou de FALSE (FAUX) pour le paramètre %!4.  Le défaut est %!3.' 
		-- translation provided by www.babblefish.com
	, @lang =   'French'
	, @with_log =  'FALSE'
go
-- Quick Test
RAISERROR (900001, 1, 1, 'string', 'string', 'string', 'string') with log
SELECT @@Error AS 'Severity 1'
go
RAISERROR (900001, 10, 1, 'string', 'string', 'string', 'string') with log
SELECT @@Error AS 'Severity 10'
go
RAISERROR (900001, 11, 1, 'string', 'string', 'string', 'string') with log
SELECT @@Error AS 'Severity 11'
go
RAISERROR (900001, 15, 1, 'string', 'string', 'string', 'string') with log
SELECT @@Error AS 'Severity 15'
go
RAISERROR (900001, 16, 1, 'string', 'string', 'string', 'string') with log
SELECT @@Error AS 'Severity 16'
go
CREATE PROCEDURE TestProc
(
			@Param1	varchar(5) = 'FALSE'
)
as
SET NOCOUNT ON
IF @Param1 IS NULL
	SET @Param1 = 'FALSE'

DECLARE @ErrorNum	int

IF UPPER(@Param1) NOT IN ('TRUE', 'FALSE')
    BEGIN
	RAISERROR (900001, 16, -1, @Param1, 'TestProc', '@Param1', 'FALSE')
	RETURN @@ERROR
-- OR
	SET @ErrorNum = @@ERROR
	-- Do other stuff...
	RETURN @ErrorNum -- because by this statement @@ERROR = 0
    END

PRINT 'Stored Procedure completed successfully'
go
exec dbo.TestProc
-- default does kick in...

exec dbo.TestProc NULL
-- default does not kick in...
-- the IF at the beginning of the proc

exec dbo.TestProc foo
-- default does not kick in...

-- Now test it...
DECLARE @RetStat	int
exec @RetStat = dbo.TestProc
select @RetStat -- no error
	---default kicks in

DECLARE @RetStat	int
exec @RetStat = dbo.TestProc NULL
select @RetStat  -- no error
	-- default DOES NOT kick in! 
	-- You need the IF at the beginning of the proc

DECLARE @RetStat	int
EXEC @RetStat = dbo.TestProc 'foo'
IF @RetStat <> 0
BEGIN
	PRINT 'Stored Procedure failed...Please try again later!'
	-- Application Logic
END	

--Now you can even define an alert (administrative)
EXEC dbo.TestProc 'foo'