:r "\\pjc.ca\gjc\Centre Rx\Gestion BD\who_is_active_v11_32.sql"

IF NOT EXISTS (SELECT * FROM sys.databases WHERE UPPER(name) = 'DBA_LOG') CREATE DATABASE [DBA_log]
GO

USE [msdb]
GO

/****** Object:  Job [Qj##WhoIsActive]    Script Date: 2018-10-03 16:33:55 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Qj##]    Script Date: 2018-10-03 16:33:55 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Qj##' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Qj##'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Qj##WhoIsActive', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Logger les de l''information sur les sessions actives avec l''aide de la sp sp_WhoIsActive. Les informations sont conservés dans la table DBA_log.dbo.WhoIsActive.', 
		@category_name=N'Qj##', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Creation de la table de destination]    Script Date: 2018-10-03 16:33:56 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Creation de la table de destination', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @destination_table VARCHAR(4000) ;
SET @destination_table = ''WhoIsActive''

DECLARE @schema VARCHAR(4000) ;
EXEC dbo.sp_WhoIsActive 
	@get_transaction_info = 1, 
	@get_plans = 1,
	@find_block_leaders = 1, 
	@get_full_inner_text = 0,
	@get_task_info=2,
	@get_locks=1,
	@get_avg_time=1,
	@get_outer_command=1,
	@get_additional_info = 1,
	@delta_interval = 2,
	@show_own_spid = 1,
	@show_sleeping_spids = 2,
	@return_schema = 1,
	@schema = @schema OUTPUT ;

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @destination_table)
BEGIN
    SET @schema = REPLACE(@schema, ''<table_name>'', @destination_table) ;
    PRINT @schema
    EXEC(@schema) ;
END;
GO
', 
		@database_name=N'DBA_log', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [GradData]    Script Date: 2018-10-03 16:33:56 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'GradData', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE
    @destination_table VARCHAR(4000) ,
    @msg NVARCHAR(1000) ;
SET @destination_table = ''WhoIsActive'' ;

DECLARE @numberOfRuns INT ;
SET @numberOfRuns = 1;

WHILE @numberOfRuns > 0
    BEGIN;
	EXEC dbo.sp_WhoIsActive 
		@get_transaction_info = 1, 
		@get_plans = 1,
		@find_block_leaders = 1,
		@get_full_inner_text = 0,
		@get_task_info=2,
		@get_locks=1,
		@get_avg_time=1,
		@get_outer_command=1,
		@get_additional_info = 1,
		@delta_interval = 2,
		@show_own_spid = 1,
		@show_sleeping_spids = 2,
		@destination_table = @destination_table ;

        SET @numberOfRuns = @numberOfRuns - 1 ;

        IF @numberOfRuns > 0
            BEGIN
                SET @msg = CONVERT(CHAR(19), GETDATE(), 121) + '': '' +
                 ''Logged info. Waiting...''
                RAISERROR(@msg,0,0) WITH nowait ;

                WAITFOR DELAY ''00:00:05''
            END
        ELSE
            BEGIN
                SET @msg = CONVERT(CHAR(19), GETDATE(), 121) + '': '' + ''Done.''
                RAISERROR(@msg,0,0) WITH nowait ;
            END

    END ;
GO
', 
		@database_name=N'DBA_log', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Purge data]    Script Date: 2018-10-03 16:33:56 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Purge data', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'delete from  [dbo].[WhoIsActive] where [collection_time] < getdate() - 14', 
		@database_name=N'DBA_log', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Purge historique de la job]    Script Date: 2018-10-03 16:33:56 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Purge historique de la job', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @Date DATETIME= GETDATE() - 15;
EXEC msdb.dbo.sp_purge_jobhistory
     @job_name = ''Qj##WhoIsActive'',
     @oldest_date = @Date;
GO', 
		@database_name=N'msdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'quotidien', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=2, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20160210, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'37f32fbf-e58d-4338-b7f2-071cad18c9d1'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO



USE msdb ;  
GO  
EXEC dbo.sp_start_job N'Qj##WhoIsActive' ;  
GO



USE [DBA_log]
GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20181003-163415] ON [dbo].[WhoIsActive]
(
	[session_id] ASC,
	[collection_time] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

