
USE [msdb]
GO
--REH  Delete old jobs that we renamed

/****** Object:  Job [DYNPERF_Log_Blocks_Option1_Tracing]    Script Date: 10/10/2010 14:34:59 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_Log_Blocks_Option1_Tracing_Start')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_Log_Blocks_Option1_Tracing_Start', @delete_unused_schedule=1
GO
/****** Object:  Job [DYNPERF_Log_Blocks_Option1_Tracing_Stop]    Script Date: 10/10/2010 15:24:21 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_Log_Blocks_Option1_Tracing_Stop')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_Log_Blocks_Option1_Tracing_Stop', @delete_unused_schedule=1
GO
/****** Object:  Job [DYNPERF_Log_Blocks_Option1_Load_Blocked_Data]    Script Date: 12/16/2010 11:22:48 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_Log_Blocks_Option1_Load_Blocked_Data')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_Log_Blocks_Option1_Load_Blocked_Data', @delete_unused_schedule=1
GO
/****** Object:  Job [DYNPERF_Log_Blocks_Option2_Polling]    Script Date: 10/10/2010 14:36:42 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_Log_Blocks_Option2_Polling')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_Log_Blocks_Option2_Polling', @delete_unused_schedule=1
GO
/****** Object:  Job [DYNPERF_Option1_Tracing_Start]    Script Date: 10/19/2011 15:23:06 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_Option1_Tracing_Start')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_Option1_Tracing_Start', @delete_unused_schedule=1
GO
/****** Object:  Job [DYNPERF_Log_Blocks_Option1_Tracing_Stop]    Script Date: 10/10/2010 15:24:21 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_Option1_Tracing_Stop')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_Option1_Tracing_Stop', @delete_unused_schedule=1
GO
/****** Object:  Job [DYNPERF_Log_Blocks_Option1_Load_Blocked_Data]    Script Date: 12/16/2010 11:22:48 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_Option1_Load_Blocked_Data')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_Option1_Load_Blocked_Data', @delete_unused_schedule=1
GO
/****** Object:  Job [DYNPERF_Log_Blocks_Option2_Polling]    Script Date: 10/10/2010 14:36:42 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_Option2_Polling_for_Blocking')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_Option2_Polling_for_Blocking', @delete_unused_schedule=1
GO
/****** Object:  Job [DYNPERF_Log_Blocks_Option2_Polling]    Script Date: 10/10/2010 14:36:42 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_Option2_Polling_for_Blocking')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_Option2_Polling_for_Blocking', @delete_unused_schedule=1
GO
/****** Object:  Job [DYNPERF_PerfStats_Hourly]    Script Date: 03/13/2011 13:38:20 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_PerfStats_Hourly')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_PerfStats_Hourly', @delete_unused_schedule=1
GO
/****** Object:  Job [DYNPERF_Capture_Stats_Purge]    Script Date: 02/18/2010 11:38:53 ******/
IF EXISTS (SELECT job_id FROM   msdb.dbo.sysjobs_view WHERE  name = N'DYNPERF_Capture_Stats_Purge')
EXEC msdb.dbo.sp_delete_job  @job_name=N'DYNPERF_Capture_Stats_Purge',  @delete_unused_schedule=1 
GO
IF EXISTS (SELECT job_id FROM   msdb.dbo.sysjobs_view WHERE  name = N'DYNPERF_Compression_Analyzer')
  EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_Compression_Analyzer', @delete_unused_schedule=1
GO

/****** Object:  Job [DYNPERF_Purge_Stats]    Script Date: 10/10/2010 14:36:42 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_Purge_Stats')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_Purge_Stats', @delete_unused_schedule=1
GO

/****** Object:  Job [DYNPERF_Default_Trace_Start]    Script Date: 04/26/2012 19:26:53 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_Detailed_Trace')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_Detailed_Trace', @delete_unused_schedule=1
GO

IF EXISTS (SELECT job_id FROM   msdb.dbo.sysjobs_view  WHERE  name = N'DYNPERF_Purge_Blocks')
  EXEC msdb.dbo.sp_delete_job @job_name = N'DYNPERF_Purge_Blocks', @delete_unused_schedule=1
GO
IF EXISTS (SELECT job_id FROM   msdb.dbo.sysjobs_view WHERE  name = N'DYNPERF_Capture_Stats_Purge')
  EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_Capture_Stats_Purge', @delete_unused_schedule=1
GO
/****** Object:  Job [DYNPERF_Capture_Stats_Baseline]    Script Date: 03/18/2014 21:27:20 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_Capture_Stats_Baseline')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_Capture_Stats_Baseline', @delete_unused_schedule=1
GO


--REH deleting lowercased named ones on Case Sensitive systems
/****** Object:  Job [DYNPERF_Capture_Stats]    Script Date: 02/18/2010 11:38:20 ******/ --REH converted to UPPERCASE
IF EXISTS (SELECT job_id FROM   msdb.dbo.sysjobs_view   WHERE  name = N'DYNPERF_Capture_Stats')
EXEC msdb.dbo.sp_delete_job  @job_name=N'DYNPERF_Capture_Stats',  @delete_unused_schedule=1
GO
/****** Object:  Job [DYNPERF_Default_Trace_Start]    Script Date: 10/19/2011 15:23:06 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_Default_Trace_Start')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_Default_Trace_Start', @delete_unused_schedule=1
GO
/****** Object:  Job [DYNPERF_Default_Trace_Stop]    Script Date: 10/10/2010 15:24:21 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_Default_Trace_Stop')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_Default_Trace_Stop', @delete_unused_schedule=1
GO
/****** Object:  Job [DYNPERF_LONG_DURATION_TRACE]    Script Date: 04/26/2012 19:26:53 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_Long_Duration_Trace')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_Long_Duration_Trace', @delete_unused_schedule=1
GO
/****** Object:  Job [DYNPERF_Log_Blocks_Option2_Polling]    Script Date: 10/10/2010 14:36:42 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_Optional_Polling_for_Blocking')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_Optional_Polling_for_Blocking', @delete_unused_schedule=1
GO
/****** Object:  Job [DYNPERF_Purge_SYSTRACETABLESQL_AX]    Script Date: 10/19/2011 16:21:00 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_Purge_SYSTRACETABLESQL_AX')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_Purge_SYSTRACETABLESQL_AX', @delete_unused_schedule=1
GO
/****** Object:  Job [DYNPERF_Set_AX_User_Trace_on]    Script Date: 04/01/2014 08:20:00 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_Set_AX_User_Trace_on')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_Set_AX_User_Trace_on', @delete_unused_schedule=1
GO
/****** Object:  Job [DYNPERF_Set_AX_User_Trace_off]    Script Date: 04/01/2014 08:21:23 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_Set_AX_User_Trace_off')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_Set_AX_User_Trace_off', @delete_unused_schedule=1
GO
/****** Object:  Job [DYNPERF_SET_AX_USER_TRACE_ON]    Script Date: 04/01/2014 08:20:00 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_SET_AX_USER_TRACE_ON')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_SET_AX_USER_TRACE_ON', @delete_unused_schedule=1
GO
/****** Object:  Job [DYNPERF_SET_AX_USER_TRACE_OFF]    Script Date: 04/01/2014 08:21:23 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_SET_AX_USER_TRACE_OFF')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_SET_AX_USER_TRACE_OFF', @delete_unused_schedule=1
GO
/****** Object:  Job [DYNPERF_PURGE_SYSTRACETABLESQL_AX]    Script Date: 10/19/2011 16:21:00 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_PURGE_SYSTRACETABLESQL_AX')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_PURGE_SYSTRACETABLESQL_AX', @delete_unused_schedule=1
GO


/****** Object:  Job [DYNPERF_CAPTURE_STATS]    Script Date: 02/18/2010 11:38:20 ******/
IF EXISTS (SELECT job_id FROM   msdb.dbo.sysjobs_view  WHERE  name = N'DYNPERF_CAPTURE_STATS')
  EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_CAPTURE_STATS',  @delete_unused_schedule=1
GO

/****** Object:  Job [DYNPERF_PROCESS_TASKS]    Script Date: 02/18/2010 11:38:20 ******/
IF EXISTS (SELECT job_id FROM   msdb.dbo.sysjobs_view WHERE  name = N'DYNPERF_PROCESS_TASKS')
  EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_PROCESS_TASKS',  @delete_unused_schedule=1
GO 
/****** Object:  Job [DYNPERF_DEFAULT_TRACE_START]    Script Date: 10/19/2011 15:23:06 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_DEFAULT_TRACE_START')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_DEFAULT_TRACE_START', @delete_unused_schedule=1
GO
/****** Object:  Job [DYNPERF_DEFAULT_TRACE_STOP]    Script Date: 10/10/2010 15:24:21 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_DEFAULT_TRACE_STOP')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_DEFAULT_TRACE_STOP', @delete_unused_schedule=1
GO
/****** Object:  Job [DYNPERF_LONG_DURATION_TRACE]    Script Date: 04/26/2012 19:26:53 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_LONG_DURATION_TRACE')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_LONG_DURATION_TRACE', @delete_unused_schedule=1
GO
/****** Object:  Job [DYNPERF_Log_Blocks_Option2_Polling]    Script Date: 10/10/2010 14:36:42 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_OPTIONAL_POLLING_FOR_BLOCKING')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_OPTIONAL_POLLING_FOR_BLOCKING', @delete_unused_schedule=1
GO
/****** Object:  Job [DYNPERF_COLLECT_AOS_CONFIG]    Script Date: 09/19/2015 07:23:26 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_COLLECT_AOS_CONFIG')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_COLLECT_AOS_CONFIG', @delete_unused_schedule=1
GO

/****** Object:  Job [DYNPERF_CAPTURE_SRS]    Script Date: 09/19/2015 07:23:26 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_CAPTURE_SRS')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_CAPTURE_SRS', @delete_unused_schedule=1
GO
/****** Object:  Job [DYNPERF_CAPTURE_SSRS]    Script Date: 09/19/2015 07:23:26 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_CAPTURE_SSRS')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_CAPTURE_SSRS', @delete_unused_schedule=1
GO

/****** Object:  Job [DYNPERF_PROCESS_TASKS_LOW_PRIORITY]    Script Date: 02/18/2010 11:38:20 ******/
IF EXISTS (SELECT job_id FROM   msdb.dbo.sysjobs_view  WHERE  name = N'DYNPERF_PROCESS_TASKS_LOW_PRIORITY')
  EXEC msdb.dbo.sp_delete_job  @job_name=N'DYNPERF_PROCESS_TASKS_LOW_PRIORITY',
    @delete_unused_schedule=1

GO 



--REH Drop the extended events 

IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='DYNPERF_BLOCKING_DATA')
DROP EVENT SESSION DYNPERF_BLOCKING_DATA ON SERVER
 GO
 
 IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='DYNPERF_LONG_DURATION')
DROP EVENT SESSION DYNPERF_LONG_DURATION ON SERVER
 GO
 
 IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='DYNPERF_PERF_MONITOR')
DROP EVENT SESSION DYNPERF_PERF_MONITOR ON SERVER
 GO
 
 IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='DYNPERF_AX_CONTEXTINFO')
DROP EVENT SESSION DYNPERF_AX_CONTEXTINFO ON SERVER
 GO
 
 