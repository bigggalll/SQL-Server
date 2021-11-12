/*******************************************************************************

NOTE:  These will only work if DynamicsPerf is installed locally to your Dynamics
Application database.

These are the old blocking jobs which have been replace by extended events
*******************************************************************************/



USE [msdb]
GO

/****** Object:  Job [DYNPERF_DEFAULT_TRACE_START]    Script Date: 10/19/2011 15:23:06 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_DEFAULT_TRACE_START')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_DEFAULT_TRACE_START', @delete_unused_schedule=1
GO

USE [msdb]
GO

/****** Object:  Job [DYNPERF_DEFAULT_TRACE_START]    Script Date: 10/19/2011 15:23:06 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 10/19/2011 15:23:06 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DYNPERF_DEFAULT_TRACE_START', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Records all blocking information into a trace file C:\SQLTRACE\DYNAMICS_DEFAULT.TRC. You must edit the steps to change the location of this file. Use Query Blocks - Investigate Blocks.sql in the Performance Analyzer 1.16 for Microsoft Dynamics to analyze this data. If the path is changed, you must edit the definition of BLOCKED_PROCESS_VW to the new path.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Start Tracing]    Script Date: 10/19/2011 15:23:06 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Start Tracing', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
DECLARE

	@FILE_PATH 			NVARCHAR(200)	= ''C:\SQLTRACE'',-- Location to write trace files.  Note: directory must exist before start of trace
	@TRACE_NAME  		NVARCHAR(40)	= ''DYNAMICS_DEFAULT'', -- Trace name - becomes base of trace file name
	@TRACE_FILE_SIZE	BIGINT			= 10,			-- maximum trace file size - will rollover when reached
	@TRACE_FILE_COUNT	INT				= 100,			-- maximum numer of trace files  - will delete oldest when reached
	@TRACE_RUN_HOURS  	SMALLINT		= 48 			-- Number of hours to run trace



--Optional parms

DECLARE

	@DATABASE_NAME		NVARCHAR(128)	= NULL,			-- Name of database to trace; default (NULL) will trace all databases
	@TRACE_STOP  		NVARCHAR(1)		= ''N'',			-- When set to ''Y'' will stop the trace and exit
	@HOSTNAME			NVARCHAR(128)	= NULL,			--Hostname filter for trace		
	@DURATION_SECS			BIGINT			= 0				-- enables statment, rpc, batch trace by specified duration			




SET NOCOUNT ON
SET DATEFORMAT MDY

-- -----------------------------------------------------------------------
-- Declare variables
-- -----------------------------------------------------------------------
DECLARE	@CMD			NVARCHAR(1000),	-- Used for command or sql strings
		@RC				INT,			-- Return status for stored procedures
		@ON				BIT,			-- Used as on bit for set event
		@TRACEID 		INT, 			-- Queue handle running trace queue
		@DATABASE_ID 	INT, 			-- DB ID to filter trace
		@EVENT_ID 		INT, 			-- Trace Event
		@COLUMN_ID 		INT, 			-- Trace Event Column
		@TRACE_STOPTIME	DATETIME, 		-- Trace will be set to stop 25 hours after starting
		@FILE_NAME 		NVARCHAR(245)	-- Trace file name
DECLARE	@EVENTS_VAR		TABLE(EVENT_ID INT PRIMARY KEY(EVENT_ID))

SET @ON				= 1
SET @TRACE_STOPTIME = DATEADD(HH, @TRACE_RUN_HOURS, GETDATE())

-- -----------------------------------------------------------------------
-- Edit parameters
-- -----------------------------------------------------------------------

IF @FILE_PATH LIKE ''%\''
    BEGIN
		PRINT ''OMIT TRAILING \ FROM PATH NAME''
		SET @RC = 1
		GOTO ERROR
    END


IF @DATABASE_NAME IS NOT NULL
    BEGIN
		SELECT	@DATABASE_ID = database_id 
		FROM	sys.databases
		WHERE	name =  @DATABASE_NAME
		IF @@ROWCOUNT = 0
			BEGIN
				PRINT @DATABASE_NAME + '' DOES NOT EXIST''
				SET @RC = 1
				GOTO ERROR
			END
    END


-- -----------------------------------------------------------------------
-- Stop the trace queue if running
-- -----------------------------------------------------------------------
IF EXISTS	
	(
	SELECT	*
	FROM 	fn_trace_getinfo(DEFAULT)
	WHERE 	property = 2	-- TRACE FILE NAME
	AND		CONVERT(NVARCHAR(245),value)  LIKE ''%\''+@TRACE_NAME+''%''
	)
    BEGIN
		SELECT	@TRACEID = traceid
		FROM 	fn_trace_getinfo(DEFAULT)
		WHERE 	property = 2	-- TRACE FILE NAME
		AND		CONVERT(VARCHAR(240),value)  LIKE ''%\''+@TRACE_NAME+''%''
		EXEC @RC = sp_trace_setstatus @TRACEID, 0	-- STOPS SPECIFIED TRACE
		IF @RC = 0  PRINT ''SP_TRACE_SETSTATUS: STOPPED TRACE ID '' + STR(@TRACEID )
		IF @RC = 1  PRINT ''SP_TRACE_SETSTATUS: - UNKNOWN ERROR''
		IF @RC = 8  PRINT ''SP_TRACE_SETSTATUS: THE SPECIFIED STATUS IS NOT VALID''
		IF @RC = 9  PRINT ''SP_TRACE_SETSTATUS: THE SPECIFIED TRACE HANDLE IS NOT VALID''
		IF @RC = 13 PRINT ''SP_TRACE_SETSTATUS: OUT OF MEMORY''
		IF @RC <> 0 GOTO ERROR

		EXEC sp_trace_setstatus @TRACEID, 2 -- DELETE SPECIFIED TRACE

		IF @RC = 0  PRINT ''SP_TRACE_SETSTATUS: DELETED TRACE ID '' + STR(@TRACEID)
		IF @RC = 1  PRINT ''SP_TRACE_SETSTATUS: - UNKNOWN ERROR''
		IF @RC = 8  PRINT ''SP_TRACE_SETSTATUS: THE SPECIFIED STATUS IS NOT VALID''
		IF @RC = 9  PRINT ''SP_TRACE_SETSTATUS: THE SPECIFIED TRACE HANDLE IS NOT VALID''
		IF @RC = 13 PRINT ''SP_TRACE_SETSTATUS: OUT OF MEMORY''
		IF @RC <> 0 GOTO ERROR
    END


-- -----------------------------------------------------------------------
-- Stop trace and leave if requested via   @TRACE_STOP
-- -----------------------------------------------------------------------
IF @TRACE_STOP = ''Y'' GOTO ENDPROC


-- -----------------------------------------------------------------------
-- Build the trace file name 
-- -----------------------------------------------------------------------

SELECT 	@FILE_NAME = 	@FILE_PATH 	+ ''\'' + @TRACE_NAME 				
PRINT ''FILE NAME = '' + @FILE_NAME+''.trc''

-- Convert @DURATION_SECS to appropriate time for sp_trace
IF @DURATION_SECS > 0
BEGIN
SET @DURATION_SECS = @DURATION_SECS * 1000000   -- convert to microseconds
END
-- -----------------------------------------------------------------------
-- Create trace
-- -----------------------------------------------------------------------


EXEC @RC = sp_trace_create
	@TRACEID OUTPUT, 	--	TRACE HANDLE - NEEDED FOR SUBSEQUENT TRACE OPERATIONS
	2, 					--	2 INDICATES FILE ROLLOVER
	@FILE_NAME,			--	FULL TRACE FILE NAME
	@TRACE_FILE_SIZE, 	--	MAXIMUM TRACE FILE SIZE BEFORE ROLLOVER
	@TRACE_STOPTIME,	--	TRACE STOP TIME
	@TRACE_FILE_COUNT	--	MAXIMUM TRACE FILE COUNT BEFORE OLDEST DELETED

IF @RC = 0  PRINT ''SP_TRACE_CREATE: CREATED TRACE ID '' + STR(@TRACEID )
IF @RC = 1  PRINT ''SP_TRACE_CREATE: - UNKNOWN ERROR''
IF @RC = 10 PRINT ''SP_TRACE_CREATE: INVALID OPTIONS''
IF @RC = 12 PRINT ''SP_TRACE_CREATE: FILE NAME ALREADY EXISTS; NEW TRACE NOT CREATED''
IF @RC = 13 PRINT ''SP_TRACE_CREATE: OUT OF MEMORY''
IF @RC = 14 PRINT ''SP_TRACE_CREATE: INVALID STOP TIME''
IF @RC = 15 PRINT ''SP_TRACE_CREATE: INVALID PARAMETERS''
IF @RC <> 0 
	BEGIN
		PRINT ''SP_TRACE_CREATE: Confirm that directory ''+@FILE_PATH+ '' exists''
		GOTO ERROR
	END


-- -----------------------------------------------------------------------
-- Set trace events to capture
-- -----------------------------------------------------------------------
IF @DURATION_SECS > 0
	BEGIN
		INSERT INTO @EVENTS_VAR VALUES(10) --  Stored Procedures: RPC:Completed
		INSERT INTO @EVENTS_VAR VALUES(45) --  Stored Procedures: SP:StmtCompleted
		INSERT INTO @EVENTS_VAR VALUES(12) --  TSQL: SQL:BatchCompleted
		INSERT INTO @EVENTS_VAR VALUES(41) --  TSQL: SQL:StmtCompleted
		INSERT INTO @EVENTS_VAR VALUES(43) --  Stored Procedures: SP:Completed  
	END
ELSE
	BEGIN
		--INSERT INTO @EVENTS_VAR VALUES(55)	-- Hash Warning
		-- INSERT INTO @EVENTS_VAR VALUES(58)	-- Auto Stats
		INSERT INTO @EVENTS_VAR VALUES(60)	-- Lock Escalation
		INSERT INTO @EVENTS_VAR VALUES(67)	-- Execution Warnings
		--INSERT INTO @EVENTS_VAR VALUES(80)	-- Missing Join Predicate
		INSERT INTO @EVENTS_VAR VALUES(92)	-- Data File Grow
		INSERT INTO @EVENTS_VAR VALUES(93)	-- Log File Grow
		INSERT INTO @EVENTS_VAR VALUES(137)	-- Blocked Process Report
		INSERT INTO @EVENTS_VAR VALUES(148)	-- Deadlock Graph
		--REH added these in 1.10
		INSERT INTO @EVENTS_VAR VALUES(94) --  Database: Data File Auto Shrink
		INSERT INTO @EVENTS_VAR VALUES(95) --  Database: Log File Auto Shrink
		INSERT INTO @EVENTS_VAR VALUES(155) --  Full text: FT:Crawl Started
		INSERT INTO @EVENTS_VAR VALUES(156) --  Full text: FT:Crawl Stopped
		INSERT INTO @EVENTS_VAR VALUES(157) --  Full text: FT:Crawl Aborted
		INSERT INTO @EVENTS_VAR VALUES(115) --  Security Audit: Audit Backup/Restore Event
	END

-- -----------------------------------------------------------------------
-- Set the events and columns to capture.  
-- Join the list of events (@EVENTS_VAR) 
-- to their valid columns (from sys.trace_event_bindings) 
-- and execute sp_trace_setevent for each event/column combination
-- -----------------------------------------------------------------------
DECLARE SETEVENTS CURSOR FOR
	SELECT	trace_event_id, trace_column_id
	FROM	@EVENTS_VAR, sys.trace_event_bindings
	WHERE	EVENT_ID = trace_event_id
	ORDER BY 1,2

OPEN	SETEVENTS
FETCH	SETEVENTS INTO @EVENT_ID, @COLUMN_ID
WHILE	@@FETCH_STATUS = 0
	BEGIN
		exec sp_trace_setevent @TRACEID, @EVENT_ID, @COLUMN_ID, @ON
		FETCH	SETEVENTS INTO @EVENT_ID, @COLUMN_ID
	END
DEALLOCATE SETEVENTS


-- -----------------------------------------------------------------------
-- Set filters
-- -----------------------------------------------------------------------
IF @HOSTNAME IS NOT NULL
	EXEC sp_trace_setfilter @TRACEID, 7,0,6, @HOSTNAME
-- -----------------------------------------------------------------------
--  Filter on Database ID if Database Name is supplied
-- -----------------------------------------------------------------------

IF @DATABASE_NAME IS NOT NULL
	EXEC sp_trace_setfilter @TRACEID,  3, 0, 0, @DATABASE_ID

-- -----------------------------------------------------------------------
--   Applicationname not like ''sql profiler''
-- -----------------------------------------------------------------------
EXEC sp_trace_setfilter @TRACEID, 10, 0, 7, N''SQL PROFILER''


-- -----------------------------------------------------------------------
--   Database name not like ''DynamicsPerf''
-- -----------------------------------------------------------------------
EXEC sp_trace_setfilter @TRACEID, 35, 0, 7, N''DynamicsPerf%''

--  If@DURATION_SECS is specified, add events and set duration filter

IF @DURATION_SECS > 0
	BEGIN
		EXEC sp_trace_setfilter @TRACEID, 13, 0, 4, @DURATION_SECS
	END

-- -----------------------------------------------------------------------
--   Objectid >= 100 (excludes system objects)
-- -----------------------------------------------------------------------
--EXEC sp_trace_setfilter @TRACEID, 22, 0, 4, 100

-- -----------------------------------------------------------------------
-- Start the trace
-- -----------------------------------------------------------------------

EXEC @RC = sp_trace_setstatus @TRACEID, 1

IF @RC = 0  PRINT ''SP_TRACE_SETSTATUS: STARTED TRACE ID  '' + STR(@TRACEID )
IF @RC = 1  PRINT ''SP_TRACE_SETSTATUS: - UNKNOWN ERROR''
IF @RC = 8  PRINT ''SP_TRACE_SETSTATUS: THE SPECIFIED STATUS IS NOT VALID''
IF @RC = 9  PRINT ''SP_TRACE_SETSTATUS: THE SPECIFIED TRACE HANDLE IS NOT VALID''
IF @RC = 13 PRINT ''SP_TRACE_SETSTATUS: OUT OF MEMORY''

IF @DURATION_SECS > 0
	BEGIN
	PRINT ''''
	--Don''t update the trace file path as this is not our default trace we are creating
	END
ELSE
	BEGIN
		UPDATE DynamicsPerf..DYNAMICSPERF_SETUP SET TRACE_FULL_PATH_NAME = @FILE_PATH 	+ ''\'' + @TRACE_NAME +''.trc''
	END

ENDPROC:




ERROR:


', 
		@database_name=N'DynamicsPerf', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20110313, 
		@active_end_date=99991231, 
		@active_start_time=000000, 
		@active_end_time=235959

IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Startup', 
		@enabled=1, 
		@freq_type=64, 
		@freq_interval=0, 
		@freq_subday_type=0, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20111019, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959

IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO




USE [msdb]
GO

/****** Object:  Job [DYNPERF_DEFAULT_TRACE_STOP]    Script Date: 10/10/2010 15:24:21 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_DEFAULT_TRACE_STOP')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_DEFAULT_TRACE_STOP', @delete_unused_schedule=1
GO

USE [msdb]
GO

/****** Object:  Job [DYNPERF_Default_Trace_Stop]    Script Date: 10/10/2010 15:24:21 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 10/10/2010 15:24:21 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DYNPERF_DEFAULT_TRACE_STOP', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'This job stops the tracing started by the DYNPERF_Option1_Tracing job.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Stop Tracing]    Script Date: 10/10/2010 15:24:21 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Stop Tracing', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
DECLARE
	@TRACE_NAME  		NVARCHAR(40)	= ''DYNAMICS_DEFAULT'' -- Trace name - becomes base of trace file name
 

-- -----------------------------------------------------------------------
-- Declare variables
-- -----------------------------------------------------------------------
DECLARE	@CMD			NVARCHAR(1000),	-- Used for command or sql strings
		@RC				INT,			-- Return status for stored procedures
		@ON				BIT,			-- Used as on bit for set event
		@TRACEID 		INT, 			-- Queue handle running trace queue
		@DATABASE_ID 	INT, 			-- DB ID to filter trace
		@EVENT_ID 		INT, 			-- Trace Event
		@COLUMN_ID 		INT, 			-- Trace Event Column
		@TRACE_STOPTIME	DATETIME, 		-- Trace will be set to stop 25 hours after starting
		@FILE_NAME 		NVARCHAR(245)	-- Trace file name
DECLARE	@EVENTS_VAR		TABLE(EVENT_ID INT PRIMARY KEY(EVENT_ID))

-- -----------------------------------------------------------------------
-- Stop the trace queue if running
-- -----------------------------------------------------------------------
IF EXISTS	
	(
	SELECT	*
	FROM 	fn_trace_getinfo(DEFAULT)
	WHERE 	property = 2	-- TRACE FILE NAME
	AND		CONVERT(NVARCHAR(245),value)  LIKE ''%\''+@TRACE_NAME+''%''
	)
    BEGIN
		SELECT	@TRACEID = traceid
		FROM 	fn_trace_getinfo(DEFAULT)
		WHERE 	property = 2	-- TRACE FILE NAME
		AND		CONVERT(VARCHAR(240),value)  LIKE ''%\''+@TRACE_NAME+''%''
		EXEC @RC = sp_trace_setstatus @TRACEID, 0	-- STOPS SPECIFIED TRACE
		IF @RC = 0  PRINT ''SP_TRACE_SETSTATUS: STOPPED TRACE ID '' + STR(@TRACEID )
		IF @RC = 1  PRINT ''SP_TRACE_SETSTATUS: - UNKNOWN ERROR''
		IF @RC = 8  PRINT ''SP_TRACE_SETSTATUS: THE SPECIFIED STATUS IS NOT VALID''
		IF @RC = 9  PRINT ''SP_TRACE_SETSTATUS: THE SPECIFIED TRACE HANDLE IS NOT VALID''
		IF @RC = 13 PRINT ''SP_TRACE_SETSTATUS: OUT OF MEMORY''


		EXEC sp_trace_setstatus @TRACEID, 2 -- DELETE SPECIFIED TRACE

		IF @RC = 0  PRINT ''SP_TRACE_SETSTATUS: DELETED TRACE ID '' + STR(@TRACEID)
		IF @RC = 1  PRINT ''SP_TRACE_SETSTATUS: - UNKNOWN ERROR''
		IF @RC = 8  PRINT ''SP_TRACE_SETSTATUS: THE SPECIFIED STATUS IS NOT VALID''
		IF @RC = 9  PRINT ''SP_TRACE_SETSTATUS: THE SPECIFIED TRACE HANDLE IS NOT VALID''
		IF @RC = 13 PRINT ''SP_TRACE_SETSTATUS: OUT OF MEMORY''

    END

', 
		@database_name=N'DynamicsPerf', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO