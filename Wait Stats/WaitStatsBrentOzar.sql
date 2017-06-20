-- https://msdn.microsoft.com/en-us/library/ms179984.aspx liste des waits

/*
SQL Server Wait Information from sys.dm_os_wait_stats
Copyright (C) 2014, Brent Ozar Unlimited.
See http://BrentOzar.com/go/eula for the End User Licensing Agreement.
*/

/*********************************
Let's build a list of waits we can safely ignore.
*********************************/

IF OBJECT_ID('tempdb..#ignorable_waits') IS NOT NULL
    DROP TABLE #ignorable_waits;
GO
CREATE TABLE #ignorable_waits(wait_type NVARCHAR(256) PRIMARY KEY);
GO

/* We aren't using row constructors to be SQL 2005 compatible */

SET NOCOUNT ON;
INSERT INTO #ignorable_waits(wait_type)
VALUES('REQUEST_FOR_DEADLOCK_SEARCH');
INSERT INTO #ignorable_waits(wait_type)
VALUES('SQLTRACE_INCREMENTAL_FLUSH_SLEEP');
INSERT INTO #ignorable_waits(wait_type)
VALUES('SQLTRACE_BUFFER_FLUSH');
INSERT INTO #ignorable_waits(wait_type)
VALUES('LAZYWRITER_SLEEP');
INSERT INTO #ignorable_waits(wait_type)
VALUES('XE_TIMER_EVENT');
INSERT INTO #ignorable_waits(wait_type)
VALUES('XE_DISPATCHER_WAIT');
INSERT INTO #ignorable_waits(wait_type)
VALUES('FT_IFTS_SCHEDULER_IDLE_WAIT');
INSERT INTO #ignorable_waits(wait_type)
VALUES('LOGMGR_QUEUE');
INSERT INTO #ignorable_waits(wait_type)
VALUES('CHECKPOINT_QUEUE');
INSERT INTO #ignorable_waits(wait_type)
VALUES('BROKER_TO_FLUSH');
INSERT INTO #ignorable_waits(wait_type)
VALUES('BROKER_TASK_STOP');
INSERT INTO #ignorable_waits(wait_type)
VALUES('BROKER_EVENTHANDLER');
INSERT INTO #ignorable_waits(wait_type)
VALUES('SLEEP_TASK');
INSERT INTO #ignorable_waits(wait_type)
VALUES('WAITFOR');
INSERT INTO #ignorable_waits(wait_type)
VALUES('DBMIRROR_DBM_MUTEX');
INSERT INTO #ignorable_waits(wait_type)
VALUES('DBMIRROR_EVENTS_QUEUE');
INSERT INTO #ignorable_waits(wait_type)
VALUES('DBMIRRORING_CMD');
INSERT INTO #ignorable_waits(wait_type)
VALUES('DISPATCHER_QUEUE_SEMAPHORE');
INSERT INTO #ignorable_waits(wait_type)
VALUES('BROKER_RECEIVE_WAITFOR');
INSERT INTO #ignorable_waits(wait_type)
VALUES('CLR_AUTO_EVENT');
INSERT INTO #ignorable_waits(wait_type)
VALUES('DIRTY_PAGE_POLL');
INSERT INTO #ignorable_waits(wait_type)
VALUES('HADR_FILESTREAM_IOMGR_IOCOMPLETION');
INSERT INTO #ignorable_waits(wait_type)
VALUES('ONDEMAND_TASK_QUEUE');
INSERT INTO #ignorable_waits(wait_type)
VALUES('FT_IFTSHC_MUTEX');
INSERT INTO #ignorable_waits(wait_type)
VALUES('CLR_MANUAL_EVENT');
INSERT INTO #ignorable_waits(wait_type)
VALUES('SP_SERVER_DIAGNOSTICS_SLEEP');
INSERT INTO #ignorable_waits(wait_type)
VALUES('QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP');
INSERT INTO #ignorable_waits(wait_type)
VALUES('QDS_PERSIST_TASK_MAIN_LOOP_SLEEP');
GO

/* Want to manually exclude an event and recalculate?*/

/* insert #ignorable_waits (wait_type) VALUES (''); */

/*********************************
What are the highest overall waits since startup?
*********************************/

SELECT TOP 25 os.wait_type,
              SUM(os.wait_time_ms) OVER(PARTITION BY os.wait_type) AS sum_wait_time_ms,
              CAST(100. * SUM(os.wait_time_ms) OVER(PARTITION BY os.wait_type) / (1. * SUM(os.wait_time_ms) OVER()) AS NUMERIC(12, 1)) AS pct_wait_time,
              SUM(os.waiting_tasks_count) OVER(PARTITION BY os.wait_type) AS sum_waiting_tasks,
              CASE
                  WHEN SUM(os.waiting_tasks_count) OVER(PARTITION BY os.wait_type) > 0
                  THEN CAST(SUM(os.wait_time_ms) OVER(PARTITION BY os.wait_type) / (1. * SUM(os.waiting_tasks_count) OVER(PARTITION BY os.wait_type)) AS NUMERIC(12, 1))
                  ELSE 0
              END AS avg_wait_time_ms,
              CURRENT_TIMESTAMP AS sample_time
FROM sys.dm_os_wait_stats os
     LEFT JOIN #ignorable_waits iw ON os.wait_type = iw.wait_type
WHERE iw.wait_type IS NULL
ORDER BY sum_wait_time_ms DESC;
GO

/*********************************
What are the higest waits *right now*?
*********************************/

/* Note: this is dependent on the #ignorable_waits table created earlier. */

IF OBJECT_ID('tempdb..#wait_batches') IS NOT NULL
    DROP TABLE #wait_batches;
IF OBJECT_ID('tempdb..#wait_data') IS NOT NULL
    DROP TABLE #wait_data;
GO
CREATE TABLE #wait_batches
(batch_id    INT IDENTITY
                 PRIMARY KEY,
 sample_time DATETIME NOT NULL
);
CREATE TABLE #wait_data
(batch_id      INT NOT NULL,
 wait_type     NVARCHAR(256) NOT NULL,
 wait_time_ms  BIGINT NOT NULL,
 waiting_tasks BIGINT NOT NULL
);
CREATE CLUSTERED INDEX cx_wait_data ON #wait_data(batch_id);
GO

/*
This temporary procedure records wait data to a temp table.
*/

IF OBJECT_ID('tempdb..#get_wait_data') IS NOT NULL
    DROP PROCEDURE #get_wait_data;
GO
CREATE PROCEDURE #get_wait_data @intervals TINYINT  = 2,
                                @delay     CHAR(12) = '00:00:30.000' 

/* 30 seconds*/

AS
     DECLARE @batch_id INT, @current_interval TINYINT, @msg NVARCHAR(MAX);
     SET NOCOUNT ON;
     SET @current_interval = 1;
     WHILE @current_interval <= @intervals
         BEGIN
             INSERT INTO #wait_batches(sample_time)
                    SELECT CURRENT_TIMESTAMP;
             SELECT @batch_id = SCOPE_IDENTITY();
             INSERT INTO #wait_data
             (batch_id,
              wait_type,
              wait_time_ms,
              waiting_tasks
             )
                    SELECT @batch_id,
                           os.wait_type,
                           SUM(os.wait_time_ms) OVER(PARTITION BY os.wait_type) AS sum_wait_time_ms,
                           SUM(os.waiting_tasks_count) OVER(PARTITION BY os.wait_type) AS sum_waiting_tasks
                    FROM sys.dm_os_wait_stats os
                         LEFT JOIN #ignorable_waits iw ON os.wait_type = iw.wait_type
                    WHERE iw.wait_type IS NULL
                    ORDER BY sum_wait_time_ms DESC;
             SET @msg = CONVERT(CHAR(23), CURRENT_TIMESTAMP, 121)+N': Completed sample '+CAST(@current_interval AS NVARCHAR(4))+N' of '+CAST(@intervals AS NVARCHAR(4))+'.';
             RAISERROR(@msg, 0, 1) WITH NOWAIT;
             SET @current_interval = @current_interval + 1;
             IF @current_interval <= @intervals
                 WAITFOR DELAY @delay;
         END;
GO

/*
Let's take two samples 30 seconds apart
*/

EXEC #get_wait_data
     @intervals = 2,
     @delay = '00:00:10.000';
GO

/*
What were we waiting on?
This query compares the most recent two samples.
*/

WITH max_batch
     AS (SELECT TOP 1 batch_id,
                      sample_time
         FROM #wait_batches
         ORDER BY batch_id DESC)
     SELECT b.sample_time AS [Second Sample Time],
            DATEDIFF(ss, wb1.sample_time, b.sample_time) AS [Sample Duration in Seconds],
            wd1.wait_type,
            CAST((wd2.wait_time_ms - wd1.wait_time_ms) / 1000. AS NUMERIC(12, 1)) AS [Wait Time (Seconds)],
            (wd2.waiting_tasks - wd1.waiting_tasks) AS [Number of Waits],
            CASE
                WHEN(wd2.waiting_tasks - wd1.waiting_tasks) > 0
                THEN CAST((wd2.wait_time_ms - wd1.wait_time_ms) / (1.0 * (wd2.waiting_tasks - wd1.waiting_tasks)) AS NUMERIC(12, 1))
                ELSE 0
            END AS [Avg ms Per Wait]
     FROM max_batch b
          JOIN #wait_data wd2 ON wd2.batch_id = b.batch_id
          JOIN #wait_data wd1 ON wd1.wait_type = wd2.wait_type
                                 AND wd2.batch_id - 1 = wd1.batch_id
          JOIN #wait_batches wb1 ON wd1.batch_id = wb1.batch_id
     WHERE(wd2.waiting_tasks - wd1.waiting_tasks) > 0
     ORDER BY [Wait Time (Seconds)] DESC;
GO