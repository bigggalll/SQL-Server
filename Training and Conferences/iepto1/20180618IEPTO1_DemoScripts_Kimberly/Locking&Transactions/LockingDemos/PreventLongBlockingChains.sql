-- This is not really a formal demo but some "sample" code related to
-- dealing with administrative blocking for things like sp_recompile.

-- The idea is two-fold: 

-- (1) Don't even try and get the lock IF
-- * anyone else holds a table-lock of any kind for more than XX amount of time
--   For example. from a potentially long running NOLOCK query.
--		NOTE: Since we're looking for long running operations you'll probably want to set
--		this fairly high. (E.G. 30 seconds or more)
--	WHERE TO SET: 
--		Change the number (in milliseconds) in the WHERE clause:
--		p.last_batch < dateadd(ms, -1000, SYSDATETIME()))

-- (2) don't create a blocking chain if we can't get the lock after XX amount of time
-- * if you can't get the lock then bail after xx seconds and try again?
--		NOTE: Depending on the system, you might not want to create blocking if you
--		can't get your lock quickly. This you might want to set fairly low.
--		(E.G. 5 seconds or less)
--	WHERE TO SET: 
--		Change the number (in milliseconds) of the LOCK_TIMEOUT statement:
--			SET LOCK_TIMEOUT 2000
--		Change the number of retries to do this again and again
--			, @Retries = 20
--		NOTE: It's best to have retries HIGH and lock_timeout low so that you
--		keep letting other transactions through but you keep trying for a certain
--		number of minutes?

-- One final safety setting is to give up after a certain number of total minutes
-- waiting to even get started OR if you reach the max during retries.
--	WHERE TO SET: 
--		Change the number (in MINUTEs) of the @MaxRunTime variable:
--			, @MaxRunTime = 1

--SELECT * FROM sys.dm_tran_locks 
--SELECT * FROM sys.sysprocesses

SET NOCOUNT ON
SET LOCK_TIMEOUT 2000

DECLARE @timeout	int
	, @Retries		tinyint
	, @CurrentRetry	tinyint
	, @CurrentTime	nvarchar(100)
	, @StartTime	datetime
	, @MaxRunTime	tinyint

-- The timeout variable is only used in the informational message
SELECT @timeout = 2000			-- milliseconds
	, @StartTime = getdate()	-- Don't need high precision
	, @MaxRunTime = 60			-- minutes
	, @Retries = 4				-- number of attempts just in case another operation has started
	, @CurrentRetry = 0
	
TryAgain:

IF (@@TRANCOUNT > 0)
	ROLLBACK TRAN

BEGIN TRY
	BEGIN
	WHILE (SELECT count(*) FROM sys.dm_tran_locks AS l
			JOIN sys.sysprocesses AS p
				ON l.request_session_id = p.spid
			WHERE l.resource_database_id = DB_ID() 
				AND l.resource_associated_entity_id = OBJECT_ID('dbo.TestLockWait')
				AND p.last_batch < dateadd(ms, -30000, SYSDATETIME())) > 0 
		BEGIN
			WAITFOR DELAY '00:00:00.001' -- this acts like a spin lock (how bout now, how bout now, etc.)
			IF dateadd(mi, @MaxRunTime, @StartTime) < getdate()
			BEGIN
				SELECT @CurrentTime = CONVERT(nvarchar, SYSDATETIME(), 109)
				RAISERROR ('Time: %s. Giving up. Could not gain access to the table in %d minute(s). Too many long running operations on the table. ', 10, 1, @CurrentTime, @MaxRunTime)
				GOTO GivingUp
			END
		END
	
	-- This won't even run until there are no locks from batches more than xx sec old
	-- This is where you execute the code that requires the code that requires the SCH_M lock
	EXEC sp_recompile 'dbo.TestLockWait'

	END
END TRY

BEGIN CATCH
BEGIN
	SELECT @CurrentRetry = @CurrentRetry + 1 
	SELECT @CurrentTime = CONVERT(nvarchar, SYSDATETIME(), 109)
	RAISERROR ('Time: %s. Could not obtain lock in a timely [%d ms] manner. Retry attempt %d of %d', 10, 1, @CurrentTime, @timeout, @CurrentRetry, @Retries)
	IF @CurrentRetry < @Retries
		GOTO TryAgain
	ELSE
		BEGIN
			SELECT @CurrentTime = CONVERT(varchar, SYSDATETIME(), 109)
			RAISERROR ('Time: %s. Could not obtain lock in a timely [%d ms] manner. Retries failed.', 10, 1, @CurrentTime, @timeout, @CurrentRetry, @Retries)
		END
END
END CATCH;

GivingUp:

IF (@@TRANCOUNT > 0)
	ROLLBACK TRAN
SET LOCK_TIMEOUT -1
go