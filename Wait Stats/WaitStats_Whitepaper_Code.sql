/*Listing 1: Investigating blocking using the sys.dm_os_waiting_tasks DMV*/
SELECT  blocking.session_id AS blocking_session_id ,
        blocked.session_id AS blocked_session_id ,
        waitstats.wait_type AS blocking_resource ,
        waitstats.wait_duration_ms ,
        waitstats.resource_description ,
        blocked_cache.text AS blocked_text ,
        blocking_cache.text AS blocking_text
FROM    sys.dm_exec_connections AS blocking
        INNER JOIN sys.dm_exec_requests blocked
                    ON blocking.session_id = blocked.blocking_session_id
        CROSS APPLY sys.dm_exec_sql_text(blocked.sql_handle)
                                                      blocked_cache
        CROSS APPLY sys.dm_exec_sql_text(blocking.most_recent_sql_handle)
                                                      blocking_cache
        INNER JOIN sys.dm_os_waiting_tasks waitstats
                    ON waitstats.session_id = blocked.session_id;
GO

/*Listing 2: Resetting the wait statistics*/
DBCC SQLPERF ('sys.dm_os_wait_stats', CLEAR);
GO

/*Listing 3: Identifying possible CPU pressure via signal wait time*/
SELECT  SUM(signal_wait_time_ms) AS TotalSignalWaitTime ,
        ( SUM(CAST(signal_wait_time_ms AS NUMERIC(20, 2)))
          / SUM(CAST(wait_time_ms AS NUMERIC(20, 2))) * 100 )
                         AS PercentageSignalWaitsOfTotalTime
FROM    sys.dm_os_wait_stats;
GO

/*Listing 4: Investigating Scheduler queues*/
SELECT  scheduler_id ,
        current_tasks_count ,
        runnable_tasks_count
FROM    sys.dm_os_schedulers
WHERE   scheduler_id < 255
GO

/*Listing 5: Report on top resource waits*/
WITH    [Waits]
          AS ( SELECT   [wait_type] ,
                        [wait_time_ms] / 1000.0 AS [WaitS] ,
                        ( [wait_time_ms] - [signal_wait_time_ms] ) / 1000.0 AS [ResourceS] ,
                        [signal_wait_time_ms] / 1000.0 AS [SignalS] ,
                        [waiting_tasks_count] AS [WaitCount] ,
                        100.0 * [wait_time_ms] / SUM([wait_time_ms]) OVER ( ) AS [Percentage] ,
                        ROW_NUMBER() OVER ( ORDER BY [wait_time_ms] DESC ) AS [RowNum]
               FROM     sys.dm_os_wait_stats
               WHERE    [wait_type] NOT IN ( N'BROKER_EVENTHANDLER',
                                             N'BROKER_RECEIVE_WAITFOR',
                                             N'BROKER_TASK_STOP',
                                             N'BROKER_TO_FLUSH',
                                             N'BROKER_TRANSMITTER',
                                             N'CHECKPOINT_QUEUE', N'CHKPT',
                                             N'CLR_AUTO_EVENT',
                                             N'CLR_MANUAL_EVENT',
                                             N'CLR_SEMAPHORE',
                                             N'DBMIRROR_DBM_EVENT',
                                             N'DBMIRROR_EVENTS_QUEUE',
                                             N'DBMIRROR_WORKER_QUEUE',
                                             N'DBMIRRORING_CMD',
                                             N'DIRTY_PAGE_POLL',
                                             N'DISPATCHER_QUEUE_SEMAPHORE',
                                             N'EXECSYNC', N'FSAGENT',
                                             N'FT_IFTS_SCHEDULER_IDLE_WAIT',
                                             N'FT_IFTSHC_MUTEX',
                                             N'HADR_CLUSAPI_CALL',
                                             N'HADR_FILESTREAM_IOMGR_IOCOMPLETION',
                                             N'HADR_LOGCAPTURE_WAIT',
                                             N'HADR_NOTIFICATION_DEQUEUE',
                                             N'HADR_TIMER_TASK',
                                             N'HADR_WORK_QUEUE',
                                             N'KSOURCE_WAKEUP',
                                             N'LAZYWRITER_SLEEP',
                                             N'LOGMGR_QUEUE',
                                             N'ONDEMAND_TASK_QUEUE',
                                             N'PWAIT_ALL_COMPONENTS_INITIALIZED',
                                             N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP',
                                             N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP',
                                             N'REQUEST_FOR_DEADLOCK_SEARCH',
                                             N'RESOURCE_QUEUE',
                                             N'SERVER_IDLE_CHECK',
                                             N'SLEEP_BPOOL_FLUSH',
                                             N'SLEEP_DBSTARTUP',
                                             N'SLEEP_DCOMSTARTUP',
                                             N'SLEEP_MASTERDBREADY',
                                             N'SLEEP_MASTERMDREADY',
                                             N'SLEEP_MASTERUPGRADED',
                                             N'SLEEP_MSDBSTARTUP',
                                             N'SLEEP_SYSTEMTASK',
                                             N'SLEEP_TASK',
                                             N'SLEEP_TEMPDBSTARTUP',
                                             N'SNI_HTTP_ACCEPT',
                                             N'SP_SERVER_DIAGNOSTICS_SLEEP',
                                             N'SQLTRACE_BUFFER_FLUSH',
                                             N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
                                             N'SQLTRACE_WAIT_ENTRIES',
                                             N'WAIT_FOR_RESULTS', N'WAITFOR',
                                             N'WAITFOR_TASKSHUTDOWN',
                                             N'WAIT_XTP_HOST_WAIT',
                                             N'WAIT_XTP_OFFLINE_CKPT_NEW_LOG',
                                             N'WAIT_XTP_CKPT_CLOSE',
                                             N'XE_DISPATCHER_JOIN',
                                             N'XE_DISPATCHER_WAIT',
                                             N'XE_TIMER_EVENT' )
             )
    SELECT  [W1].[wait_type] AS [WaitType] ,
            CAST ([W1].[WaitS] AS DECIMAL(16, 2)) AS [Wait_S] ,
            CAST ([W1].[ResourceS] AS DECIMAL(16, 2)) AS [Resource_S] ,
            CAST ([W1].[SignalS] AS DECIMAL(16, 2)) AS [Signal_S] ,
            [W1].[WaitCount] AS [WaitCount] ,
            CAST ([W1].[Percentage] AS DECIMAL(5, 2)) AS [Percentage] ,
            CAST (( [W1].[WaitS] / [W1].[WaitCount] ) AS DECIMAL(16, 4)) AS [AvgWait_S] ,
            CAST (( [W1].[ResourceS] / [W1].[WaitCount] ) AS DECIMAL(16, 4)) AS [AvgRes_S] ,
            CAST (( [W1].[SignalS] / [W1].[WaitCount] ) AS DECIMAL(16, 4)) AS [AvgSig_S]
    FROM    [Waits] AS [W1]
            INNER JOIN [Waits] AS [W2] ON [W2].[RowNum] <= [W1].[RowNum]
    GROUP BY [W1].[RowNum] ,
            [W1].[wait_type] ,
            [W1].[WaitS] ,
            [W1].[ResourceS] ,
            [W1].[SignalS] ,
            [W1].[WaitCount] ,
            [W1].[Percentage]
    HAVING  SUM([W2].[Percentage]) - [W1].[Percentage] < 95; -- percentage threshold

GO

/*Listing 6: Virtual File Statistics*/
SELECT  DB_NAME(vfs.database_id) AS database_name ,
        vfs.database_id ,
        vfs.file_id ,
        io_stall_read_ms / NULLIF(num_of_reads, 0) AS avg_read_latency ,
        io_stall_write_ms / NULLIF(num_of_writes, 0)
                                               AS avg_write_latency ,
        io_stall_write_ms / NULLIF(num_of_writes + num_of_writes, 0)
                                               AS avg_total_latency ,
        num_of_bytes_read / NULLIF(num_of_reads, 0)
                                               AS avg_bytes_per_read ,
        num_of_bytes_written / NULLIF(num_of_writes, 0)
                                               AS avg_bytes_per_write ,
        vfs.io_stall ,
        vfs.num_of_reads ,
        vfs.num_of_bytes_read ,
        vfs.io_stall_read_ms ,
        vfs.num_of_writes ,
        vfs.num_of_bytes_written ,
        vfs.io_stall_write_ms ,
        size_on_disk_bytes / 1024 / 1024. AS size_on_disk_mbytes ,
        physical_name
FROM    sys.dm_io_virtual_file_stats(NULL, NULL) AS vfs
        JOIN sys.master_files AS mf ON vfs.database_id = mf.database_id
                                       AND vfs.file_id = mf.file_id
ORDER BY avg_total_latency DESC
GO

/*Listing 7: When were waits stats last cleared, either manually or by a restart?*/
SELECT  [wait_type] ,
        [wait_time_ms] ,
        DATEADD(SS, -[wait_time_ms] / 1000, GETDATE())
                                             AS "Date/TimeCleared" ,
        CASE WHEN [wait_time_ms] < 1000
             THEN CAST([wait_time_ms] AS VARCHAR(15)) + ' ms'
             WHEN [wait_time_ms] BETWEEN 1000 AND 60000
             THEN CAST(( [wait_time_ms] / 1000 )
                                             AS VARCHAR(15)) + ' seconds'
             WHEN [wait_time_ms] BETWEEN 60001 AND 3600000
             THEN CAST(( [wait_time_ms] / 60000 )
                                             AS VARCHAR(15)) + ' minutes'
             WHEN [wait_time_ms] BETWEEN 3600001 AND 86400000
             THEN CAST(( [wait_time_ms] / 3600000 )
                                             AS VARCHAR(15)) + ' hours'
             WHEN [wait_time_ms] > 86400000
             THEN CAST(( [wait_time_ms] / 86400000 )
                                             AS VARCHAR(15)) + ' days'
        END AS "TimeSinceCleared"
FROM    [sys].[dm_os_wait_stats]
WHERE   [wait_type] = 'SQLTRACE_INCREMENTAL_FLUSH_SLEEP';

/*
   check SQL Server start time - 2008 and higher
*/
SELECT  [sqlserver_start_time]
FROM    [sys].[dm_os_sys_info];


/*
   check SQL Server start time - 2005 and higher   
*/
SELECT  [create_date]
FROM    [sys].[databases]
WHERE   [database_id] = 2;
GO

/*Listing 8: Database to store baseline performance data*/
USE [master];
GO

CREATE DATABASE [BaselineData] ON PRIMARY 
( NAME = N'BaselineData', 
  FILENAME = N'M:\UserDBs\BaselineData.mdf', 
  SIZE = 512MB, 
  FILEGROWTH = 512MB
) LOG ON 
( NAME = N'BaselineData_log', 
  FILENAME = N'M:\UserDBs\BaselineData_log.ldf', 
  SIZE = 128MB, 
  FILEGROWTH = 512MB
);

ALTER DATABASE [BaselineData] SET RECOVERY SIMPLE;
GO

/*Listing 9: Creating the dbo.WaitStats table*/
USE [BaselineData];
GO

IF NOT EXISTS ( SELECT  *
                FROM    [sys].[tables]
                WHERE   [name] = N'WaitStats'
                        AND [type] = N'U' ) 
    CREATE TABLE [dbo].[WaitStats]
        (
          [RowNum] [BIGINT] IDENTITY(1, 1) ,
          [CaptureDate] [DATETIME] ,
          [WaitType] [NVARCHAR](120) ,
          [Wait_S] [DECIMAL](14, 2) ,
          [Resource_S] [DECIMAL](14, 2) ,
          [Signal_S] [DECIMAL](14, 2) ,
          [WaitCount] [BIGINT] ,
          [Percentage] [DECIMAL](4, 2) ,
          [AvgWait_S] [DECIMAL](14, 2) ,
          [AvgRes_S] [DECIMAL](14, 2) ,
          [AvgSig_S] [DECIMAL](14, 2)
        );
GO

CREATE CLUSTERED INDEX CI_WaitStats 
  ON [dbo].[WaitStats] ([RowNum], [CaptureDate]);
GO

/*Listing 10: Capturing wait stats data for analysis*/
USE [BaselineData];
GO

INSERT  INTO dbo.WaitStats
        ( [WaitType]
        )
VALUES  ( 'Wait Statistics for ' + CAST(GETDATE() AS NVARCHAR(19))
        );

INSERT  INTO dbo.WaitStats
        ( [CaptureDate] ,
          [WaitType] ,
          [Wait_S] ,
          [Resource_S] ,
          [Signal_S] ,
          [WaitCount] ,
          [Percentage] ,
          [AvgWait_S] ,
          [AvgRes_S] ,
          [AvgSig_S] 
        )
        EXEC
            ( '
      WITH [Waits] AS
         (SELECT
            [wait_type],
            [wait_time_ms] / 1000.0 AS [WaitS],
            ([wait_time_ms] - [signal_wait_time_ms]) / 1000.0
                                         AS [ResourceS],
            [signal_wait_time_ms] / 1000.0 AS [SignalS],
            [waiting_tasks_count] AS [WaitCount],
            100.0 * [wait_time_ms] / SUM ([wait_time_ms]) OVER()
                                         AS [Percentage],
            ROW_NUMBER() OVER(ORDER BY [wait_time_ms] DESC) AS [RowNum]
         FROM sys.dm_os_wait_stats
         WHERE [wait_type] NOT IN (
N''BROKER_EVENTHANDLER'',         N''BROKER_RECEIVE_WAITFOR'',
        N''BROKER_TASK_STOP'',            N''BROKER_TO_FLUSH'',
        N''BROKER_TRANSMITTER'',          N''CHECKPOINT_QUEUE'',
        N''CHKPT'',                       N''CLR_AUTO_EVENT'',
        N''CLR_MANUAL_EVENT'',            N''CLR_SEMAPHORE'',
        N''DBMIRROR_DBM_EVENT'',          N''DBMIRROR_EVENTS_QUEUE'',
        N''DBMIRROR_WORKER_QUEUE'',       N''DBMIRRORING_CMD'',
        N''DIRTY_PAGE_POLL'',             N''DISPATCHER_QUEUE_SEMAPHORE'',
        N''EXECSYNC'',                    N''FSAGENT'',
        N''FT_IFTS_SCHEDULER_IDLE_WAIT'', N''FT_IFTSHC_MUTEX'',
        N''HADR_CLUSAPI_CALL'',           N''HADR_FILESTREAM_IOMGR_IOCOMPLETION'',
        N''HADR_LOGCAPTURE_WAIT'',        N''HADR_NOTIFICATION_DEQUEUE'',
        N''HADR_TIMER_TASK'',             N''HADR_WORK_QUEUE'',
        N''KSOURCE_WAKEUP'',              N''LAZYWRITER_SLEEP'',
        N''LOGMGR_QUEUE'',                N''ONDEMAND_TASK_QUEUE'',
        N''PWAIT_ALL_COMPONENTS_INITIALIZED'',
        N''QDS_PERSIST_TASK_MAIN_LOOP_SLEEP'',
        N''QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP'',
        N''REQUEST_FOR_DEADLOCK_SEARCH'', N''RESOURCE_QUEUE'',
        N''SERVER_IDLE_CHECK'',           N''SLEEP_BPOOL_FLUSH'',
        N''SLEEP_DBSTARTUP'',             N''SLEEP_DCOMSTARTUP'',
        N''SLEEP_MASTERDBREADY'',         N''SLEEP_MASTERMDREADY'',
        N''SLEEP_MASTERUPGRADED'',        N''SLEEP_MSDBSTARTUP'',
        N''SLEEP_SYSTEMTASK'',            N''SLEEP_TASK'',
        N''SLEEP_TEMPDBSTARTUP'',         N''SNI_HTTP_ACCEPT'',
        N''SP_SERVER_DIAGNOSTICS_SLEEP'', N''SQLTRACE_BUFFER_FLUSH'',
        N''SQLTRACE_INCREMENTAL_FLUSH_SLEEP'',
        N''SQLTRACE_WAIT_ENTRIES'',       N''WAIT_FOR_RESULTS'',
        N''WAITFOR'',                     N''WAITFOR_TASKSHUTDOWN'',
        N''WAIT_XTP_HOST_WAIT'',          N''WAIT_XTP_OFFLINE_CKPT_NEW_LOG'',
        N''WAIT_XTP_CKPT_CLOSE'',         N''XE_DISPATCHER_JOIN'',
        N''XE_DISPATCHER_WAIT'',          N''XE_TIMER_EVENT''
)
         )
      SELECT
         GETDATE(),
         [W1].[wait_type] AS [WaitType], 
         CAST ([W1].[WaitS] AS DECIMAL(14, 2)) AS [Wait_S],
         CAST ([W1].[ResourceS] AS DECIMAL(14, 2)) AS [Resource_S],
         CAST ([W1].[SignalS] AS DECIMAL(14, 2)) AS [Signal_S],
         [W1].[WaitCount] AS [WaitCount],
         CAST ([W1].[Percentage] AS DECIMAL(4, 2)) AS [Percentage],
         CAST (([W1].[WaitS] / [W1].[WaitCount]) AS DECIMAL (14, 4))
                                                       AS [AvgWait_S],
         CAST (([W1].[ResourceS] / [W1].[WaitCount]) AS DECIMAL (14, 4))
                                                        AS [AvgRes_S],
         CAST (([W1].[SignalS] / [W1].[WaitCount]) AS DECIMAL (14, 4))
                                                      AS [AvgSig_S]
      FROM [Waits] AS [W1]
      INNER JOIN [Waits] AS [W2]
         ON [W2].[RowNum] <= [W1].[RowNum]
      GROUP BY [W1].[RowNum], [W1].[wait_type], [W1].[WaitS], 
         [W1].[ResourceS], [W1].[SignalS], [W1].[WaitCount],
          [W1].[Percentage]
      HAVING SUM ([W2].[Percentage]) - [W1].[Percentage] < 95;'
            );
GO

/*Listing 11: Reviewing the last 30 days data*/
SELECT  *
FROM    [dbo].[WaitStats]
WHERE   [CaptureDate] > GETDATE() - 30
ORDER BY [RowNum];
GO

/*Listing 12: Reviewing the top wait for each collected data set*/
SELECT  [w].[CaptureDate] ,
        [w].[WaitType] ,
        [w].[Percentage] ,
        [w].[Wait_S] ,
        [w].[WaitCount] ,
        [w].[AvgWait_S]
FROM    [dbo].[WaitStats] w
        JOIN ( SELECT   MIN([RowNum]) AS [RowNumber] ,
                        [CaptureDate]
               FROM     [dbo].[WaitStats]
               WHERE    [CaptureDate] IS NOT NULL
                        AND [CaptureDate] > GETDATE() - 30
               GROUP BY [CaptureDate]
             ) m ON [w].[RowNum] = [m].[RowNumber]
ORDER BY [w].[CaptureDate];
GO

/*Listing 13: Purging data over 90 days old*/

DELETE  FROM [dbo].[WaitStats]
WHERE   [CaptureDate] < GETDATE() – 90;
GO

/*Listing 14: The dbo.usp_PurgeOldData stored procedure*/
IF OBJECTPROPERTY(OBJECT_ID(N'usp_PurgeOldData'), 'IsProcedure') = 1 
    DROP PROCEDURE usp_PurgeOldData;
GO

CREATE PROCEDURE dbo.usp_PurgeOldData
    (
      @PurgeWaits SMALLINT
      
    )
AS 
    BEGIN;
        IF @ PurgeWaits IS NULL
            BEGIN;
               RAISERROR(N'Input parameters cannot be NULL', 16, 1);
               RETURN;
            END;
        
        DELETE  FROM [dbo].[WaitStats]
        WHERE   [CaptureDate] < GETDATE() - @PurgeWaits;
    END;


