USE JunkDB;
GO

IF OBJECTPROPERTY(object_id('TestTxFailure'), 'IsTable') = 1
    DROP TABLE TestTxFailure;
GO

CREATE TABLE TestTxFailure
(
	col1	int				identity,
	col2	varchar(100)	default ('test')
							check (col2 in ('test', 'update')),
	col3	char(100)		default ('junk')
)
GO

-- Session settings that are ON for this session
dbcc useroptions
go

-- if you're an admin - how are the currently connected
-- sessions set
SELECT * 
FROM sys.dm_exec_sessions
--WHERE session_id = @@spid
WHERE is_user_process = 1;
GO

-- default - set xact_abort off

SET XACT_ABORT OFF
go

BEGIN TRAN
INSERT TestTxFailure DEFAULT VALUES -- won't be a problem
SELECT @@TRANCOUNT, @@IDENTITY
INSERT TestTxFailure (col2) VALUES ('fail') -- this will fail the constraint
SELECT @@TRANCOUNT
SELECT * FROM TestTxFailure
SELECT @@TRANCOUNT
ROLLBACK TRAN

-- Now, what happens with set xact_abort on
SET XACT_ABORT ON
go

BEGIN TRAN
INSERT TestTxFailure DEFAULT VALUES -- won't be a problem
SELECT @@TRANCOUNT, @@IDENTITY
INSERT TestTxFailure (col2) VALUES ('fail') -- this will fail the constraint
SELECT @@TRANCOUNT
SELECT * FROM TestTxFailure
SELECT @@TRANCOUNT
ROLLBACK TRAN

-- What can you control with xact_abort off:
SET XACT_ABORT OFF
go

DECLARE @ErrorNumber	int = 0	
BEGIN TRAN
INSERT TestTxFailure DEFAULT VALUES -- won't be a problem
SET @ErrorNumber = @@ERROR 
IF @ErrorNumber > 0
	SELECT 'Error encountered: ' + convert(varchar, @ErrorNumber)
SELECT @@TRANCOUNT
INSERT TestTxFailure (col2) VALUES ('fail') -- this will fail the constraint
SET @ErrorNumber = @@ERROR 
IF @ErrorNumber > 0
	SELECT 'Error encountered: ' + convert(varchar, @ErrorNumber)
SELECT @@TRANCOUNT
SELECT * FROM TestTxFailure
SELECT @@TRANCOUNT
ROLLBACK TRAN

-- What can you control with xact_abort on:
SET XACT_ABORT ON
go

DECLARE @ErrorNumber	int = 0	
BEGIN TRAN
INSERT TestTxFailure DEFAULT VALUES -- won't be a problem
SET @ErrorNumber = @@ERROR 
IF @ErrorNumber > 0
	SELECT 'Error encountered: ' + convert(varchar, @ErrorNumber)
SELECT @@TRANCOUNT
INSERT TestTxFailure (col2) VALUES ('fail') -- this will fail the constraint
SET @ErrorNumber = @@ERROR 
IF @ErrorNumber > 0
	SELECT 'Error encountered: ' + convert(varchar, @ErrorNumber)
SELECT @@TRANCOUNT
SELECT * FROM TestTxFailure
SELECT @@TRANCOUNT
ROLLBACK TRAN

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
--	
--  This is definitely a best practice - USE TRY/CATCH for error handling!
--
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

-- What about with TRY/CATCH:
-- What can you control with xact_abort off:
SET XACT_ABORT OFF
go

BEGIN TRAN
BEGIN TRY
	INSERT TestTxFailure DEFAULT VALUES -- won't be a problem
	SELECT @@TRANCOUNT
	INSERT TestTxFailure (col2) VALUES ('fail') -- this will fail the constraint
	SELECT @@TRANCOUNT
	SELECT * FROM TestTxFailure
	SELECT @@TRANCOUNT
    COMMIT TRANSACTION -- should be here
END TRY

BEGIN CATCH
	SELECT error_number()	AS ErrorNumber
		, error_message()	AS ErrorMessage
		, error_severity()	AS ErrorSeverity
		, error_state()		AS ErrorState
		, error_line()		AS ErrorLine
		, error_procedure() AS ProcedureName
	ROLLBACK TRAN
END CATCH


-- What can you control with xact_abort on:
SET XACT_ABORT ON
go

BEGIN TRAN
BEGIN TRY
	INSERT TestTxFailure DEFAULT VALUES -- won't be a problem
	SELECT @@TRANCOUNT
	INSERT TestTxFailure (col2) VALUES ('fail') -- this will fail the constraint
	SELECT @@TRANCOUNT
	SELECT * FROM TestTxFailure
	SELECT @@TRANCOUNT
    COMMIT TRANSACTION -- should be here
END TRY

BEGIN CATCH
	SELECT error_number()	AS ErrorNumber
		, error_message()	AS ErrorMessage
		, error_severity()	AS ErrorSeverity
		, error_state()		AS ErrorState
		, error_line()		AS ErrorLine
		, error_procedure() AS ProcedureName
	ROLLBACK TRAN
END CATCH