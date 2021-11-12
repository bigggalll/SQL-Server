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
		@command=N'SP_SQLTRACE
	@FILE_PATH 		= ''C:\SQLTRACE'', -- Location to write trace files.  Note: directory must exist before start of trace
	@TRACE_NAME  		= ''DYNAMICS_DEFAULT'', -- Trace name - becomes base of trace file name
	@DATABASE_NAME	= NULL,			-- Name of database to trace; default (NULL) will trace all databases
	@TRACE_FILE_SIZE	= 10,			-- maximum trace file size - will rollover when reached
	@TRACE_FILE_COUNT	= 100,			-- maximum numer of trace files  - will delete oldest when reached
	@TRACE_STOP  		= ''N'',			-- When set to ''Y'' will stop the trace and exit
	@TRACE_RUN_HOURS  	= 25 			-- Number of hours to run trace

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
		@command=N'/****************  Stop the Trace ****************************/
EXEC SP_SQLTRACE @TRACE_NAME = ''DYNAMICS_DEFAULT'', -- Trace name - becomes base of trace file name
	@TRACE_STOP = ''Y'' -- When set to ''Y'' will stop the trace and exit', 
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

USE [msdb]
GO

/****** Object:  Job [DYNPERF_LONG_DURATION_TRACE]    Script Date: 04/26/2012 19:26:53 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_LONG_DURATION_TRACE')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_LONG_DURATION_TRACE', @delete_unused_schedule=1
GO

USE [msdb]
GO

/****** Object:  Job [DYNPERF_LONG_DURATION_TRACE]    Script Date: 04/26/2012 19:26:53 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 04/26/2012 19:26:53 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DYNPERF_LONG_DURATION_TRACE', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0,
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Records long duration SQL Statement events into a trace file C:\SQLTRACE\DYNAMICS_LONG_DURATION.TRC. You must edit the steps to change the location of this file. ', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Start Tracing]    Script Date: 04/26/2012 19:26:53 ******/
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
		@command=N'SP_SQLTRACE
	@FILE_PATH 		= ''C:\SQLTRACE'', -- Location to write trace files.  Note: directory must exist before start of trace
	@TRACE_NAME  		= ''DYNAMICS_LONG_DURATION'', -- Trace name - becomes base of trace file name
	@DATABASE_NAME	= NULL,			-- Name of database to trace; default (NULL) will trace all databases
	@TRACE_FILE_SIZE	= 10,			-- maximum trace file size - will rollover when reached
	@TRACE_FILE_COUNT	= 100,			-- maximum numer of trace files  - will delete oldest when reached
	@TRACE_STOP  		= ''N'',			-- When set to ''Y'' will stop the trace and exit
	@TRACE_RUN_HOURS  	= 25 ,			-- Number of hours to run trace
	@DURATION_SECS	        = 5  
-- DO NOT reduce this value without direction from Microsoft support. 
-- Could cause system performance issues.
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
		@active_start_time=0, 
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

/****** Object:  Job [DYNPERF_Log_Blocks_Option2_Polling]    Script Date: 10/10/2010 14:36:42 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_OPTIONAL_POLLING_FOR_BLOCKING')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_OPTIONAL_POLLING_FOR_BLOCKING', @delete_unused_schedule=1
GO

USE [msdb]
GO

/****** Object:  Job [DYNPERF_Log_Blocks_Option2_Polling]    Script Date: 10/10/2010 14:36:42 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 10/10/2010 14:36:42 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DYNPERF_OPTIONAL_POLLING_FOR_BLOCKING', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Records all blocking into a table called Blocks in the DynamicsPerfdb via polling.  This method can put stress on SQL Server if there are many processes getting blocked, but works well for a fast check of blocking or when there is a limited amount of blocking. Use Query Blocks - Investigate Blocks.sql in the Performance Analyzer 1.0 for Microsoft Dynamics to analyze this data.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Record Database Blocking]    Script Date: 10/10/2010 14:36:42 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Record Database Blocking', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=1, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SP_LOCKS_MS ''00:00:02''', 
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