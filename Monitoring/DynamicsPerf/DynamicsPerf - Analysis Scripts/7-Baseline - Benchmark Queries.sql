/*********************************************************************
Copy one of the following links and press Ctrl-F and click FIND NEXT
in order to go to that section of the scripts

INDEX_CHANGES_SINCE_BASELINE
QUERIES_SLOWER_THAN_BASELINE
QUERIES_FASTER_THAN_BASELINE
NEW_QUERIES_NOT_IN_BASELINE
QUERIES_IN_BASELINE_BUT_NOT_IN_CURRENT
QUERY_STATISTICS_BY_PERIOD
TRANSACTION_VOLUME_BY_HOUR
TRANSACTION_VOLUME_BY_HOUR_DETAIL
DISK_IO_BY_HOUR
BAD_SQL_WAIT_STATS
DB_GROWTH
TABLE_ACTIVITY_DAY



********************************************************************/




USE [DynamicsPerf]
GO


SELECT DISTINCT SERVER_NAME, DATABASE_NAME, DATE
FROM   QUERY_HISTORY
ORDER  BY SERVER_NAME, DATABASE_NAME, DATE DESC 

GO


----------------------------------------------------------------
--
--		INDEX_CHANGES_SINCE_BASELINE
--
--	 show index changes from BASELINE
----------------------------------------------------------------


EXEC SP_INDEX_CHANGES
  @START_DATE = '10/15/2016',
  @START_FLAG = 'D',-- D = DAY M = MONTH record in INDEX_HISTORY TABLE
  @END_DATE = '10/17/2016',
  @END_FLAG = 'D' 



----------------------------------------------------------------
--
--		QUERIES_SLOWER_THAN_BASELINE
--
--	 queries that got worse  from BASELINE
----------------------------------------------------------------

SELECT TOP 100 A.DATABASE_NAME,A.QUERY_HASH,A.EXECUTION_COUNT,A.BEFORE_AVG_TIME,A.CURRENT_AVG_TIME,A.[TIME_DIFF(ms)],A.[%DECREASE],A.SQL_TEXT,B.QUERY_PLAN AS BEFORE_PLAN,C.QUERY_PLAN AS AFTER_PLAN
FROM   (SELECT DISTINCT STARTING.SERVER_NAME,STARTING.DATABASE_NAME,STARTING.QUERY_HASH,STARTING.EXECUTION_COUNT,STARTING.AVG_ELAPSED_TIME AS BEFORE_AVG_TIME,ENDING.AVG_ELAPSED_TIME AS CURRENT_AVG_TIME,ENDING.AVG_ELAPSED_TIME - STARTING.AVG_ELAPSED_TIME AS 'TIME_DIFF(ms)',CAST(( ENDING.AVG_ELAPSED_TIME - STARTING.AVG_ELAPSED_TIME ) / CASE STARTING.AVG_ELAPSED_TIME
                                                                                                                                                                                                                                                                                                                                                  WHEN 0 THEN 1
                                                                                                                                                                                                                                                                                                                                                  ELSE STARTING.AVG_ELAPSED_TIME
                                                                                                                                                                                                                                                                                                                                                END * 100 AS DECIMAL(14, 3)) AS '%DECREASE',STARTING.SQL_TEXT,STARTING.QUERY_PLAN_HASH AS BEFORE_PLAN_HASH,ENDING.QUERY_PLAN_HASH AS AFTER_PLAN_HASH
        FROM   QUERY_HISTORY_VW STARTING
               INNER JOIN QUERY_HISTORY_VW ENDING
                       ON STARTING.QUERY_HASH = ENDING.QUERY_HASH
                          AND STARTING.DATABASE_NAME = ENDING.DATABASE_NAME
                          AND ENDING.SERVER_NAME = STARTING.SERVER_NAME
        WHERE  STARTING.DATE = '10/15/2016' AND STARTING.FLAG = 'D'
               AND ENDING.DATE = '10/17/2016' AND ENDING.FLAG = 'D'
               AND STARTING.AVG_ELAPSED_TIME < ENDING.AVG_ELAPSED_TIME
               AND STARTING.QUERY_HASH <> 0x0000000000000000) AS A
       CROSS APPLY (SELECT TOP 1 QUERY_PLAN
                    FROM   QUERY_PLANS W1
                    WHERE  W1.QUERY_PLAN_HASH = A.BEFORE_PLAN_HASH
                           AND W1.SERVER_NAME = A.SERVER_NAME
                           AND W1.DATABASE_NAME = A.DATABASE_NAME) AS B
       CROSS APPLY (SELECT TOP 1 QUERY_PLAN
                    FROM   QUERY_PLANS W2
                    WHERE  W2.QUERY_PLAN_HASH = A.AFTER_PLAN_HASH
                           AND W2.SERVER_NAME = A.SERVER_NAME
                           AND W2.DATABASE_NAME = A.DATABASE_NAME) AS C
ORDER  BY 7 DESC 





----------------------------------------------------------------
--
--		QUERIES_FASTER_THAN_BASELINE
--
--	 queries that got faster from BASELINE
----------------------------------------------------------------

SELECT TOP 100 A.DATABASE_NAME,A.QUERY_HASH,A.EXECUTION_COUNT,A.BEFORE_AVG_TIME,A.CURRENT_AVG_TIME,A.[TIME_DIFF(ms)],A.[%IMPROVEMENT],A.SQL_TEXT,B.QUERY_PLAN AS BEFORE_PLAN,C.QUERY_PLAN AS AFTER_PLAN
FROM   (SELECT DISTINCT STARTING.SERVER_NAME,STARTING.DATABASE_NAME,STARTING.QUERY_HASH,STARTING.EXECUTION_COUNT,STARTING.AVG_ELAPSED_TIME AS BEFORE_AVG_TIME,ENDING.AVG_ELAPSED_TIME AS CURRENT_AVG_TIME,STARTING.AVG_ELAPSED_TIME - ENDING.AVG_ELAPSED_TIME AS 'TIME_DIFF(ms)',CAST(( STARTING.AVG_ELAPSED_TIME - ENDING.AVG_ELAPSED_TIME ) / CASE ENDING.AVG_ELAPSED_TIME
                                                                                                                                                                                                                                                                                                                                                  WHEN 0 THEN 1
                                                                                                                                                                                                                                                                                                                                                  ELSE ENDING.AVG_ELAPSED_TIME
                                                                                                                                                                                                                                                                                                                                                END * 100 AS DECIMAL(14, 3)) AS '%IMPROVEMENT',STARTING.SQL_TEXT,STARTING.QUERY_PLAN_HASH AS BEFORE_PLAN_HASH,ENDING.QUERY_PLAN_HASH AS AFTER_PLAN_HASH
        FROM   QUERY_HISTORY_VW STARTING
               INNER JOIN QUERY_HISTORY_VW ENDING
                       ON STARTING.QUERY_HASH = ENDING.QUERY_HASH
                          AND STARTING.DATABASE_NAME = ENDING.DATABASE_NAME
                          AND ENDING.SERVER_NAME = STARTING.SERVER_NAME
        WHERE  STARTING.DATE = '10/15/2016' AND STARTING.FLAG = 'D'
               AND ENDING.DATE = '10/17/2016' AND ENDING.FLAG = 'D'
               AND STARTING.AVG_ELAPSED_TIME > ENDING.AVG_ELAPSED_TIME
               AND STARTING.QUERY_HASH <> 0x0000000000000000) AS A
       CROSS APPLY (SELECT TOP 1 QUERY_PLAN
                    FROM   QUERY_PLANS W1
                    WHERE  W1.QUERY_PLAN_HASH = A.BEFORE_PLAN_HASH
                           AND W1.SERVER_NAME = A.SERVER_NAME
                           AND W1.DATABASE_NAME = A.DATABASE_NAME) AS B
       CROSS APPLY (SELECT TOP 1 QUERY_PLAN
                    FROM   QUERY_PLANS W2
                    WHERE  W2.QUERY_PLAN_HASH = A.AFTER_PLAN_HASH
                           AND W2.SERVER_NAME = A.SERVER_NAME
                           AND W2.DATABASE_NAME = A.DATABASE_NAME) AS C
ORDER  BY 7 DESC 




----------------------------------------------------------------
--
--		NEW_QUERIES_NOT_IN_BASELINE
--
--	 NEW queries that are not in the BASELINE
----------------------------------------------------------------

SELECT A.SERVER_NAME,A.DATABASE_NAME,A.QUERY_HASH,A.BEFORE_AVG_TIME,A.SQL_TEXT,B.QUERY_PLAN AS BEFORE_PLAN
FROM   (SELECT DISTINCT ENDING.SERVER_NAME,ENDING.DATABASE_NAME,ENDING.QUERY_HASH,ENDING.AVG_ELAPSED_TIME AS BEFORE_AVG_TIME,ENDING.SQL_TEXT,ENDING.QUERY_PLAN_HASH AS BEFORE_PLAN_HASH
        FROM   QUERY_HISTORY_VW ENDING
        WHERE  ENDING.DATE = '10/17/2016' AND ENDING.FLAG = 'D'
               AND NOT EXISTS (SELECT QUERY_HASH
                               FROM   QUERY_HISTORY_VW STARTING
                               WHERE  ENDING.QUERY_HASH = STARTING.QUERY_HASH
                                      AND ENDING.DATABASE_NAME = STARTING.DATABASE_NAME
                                      AND ENDING.SERVER_NAME = STARTING.SERVER_NAME
                                      AND STARTING.DATE = '10/15/2016' AND STARTING.FLAG = 'D')
               AND ENDING.QUERY_HASH <> 0x0000000000000000) AS A
       CROSS APPLY (SELECT TOP 1 QUERY_PLAN
                    FROM   QUERY_PLANS W1
                    WHERE  W1.QUERY_PLAN_HASH = A.BEFORE_PLAN_HASH
                           AND W1.SERVER_NAME = A.SERVER_NAME
                           AND W1.DATABASE_NAME = A.DATABASE_NAME) AS B
ORDER  BY 3 DESC 



------------------------------------------------------------------------------
--
--		QUERIES_IN_BASELINE_BUT_NOT_IN_CURRENT
--
--	  queries that were in the BASELINE but not in the comparison capture
-------------------------------------------------------------------------------


SELECT A.QUERY_HASH,A.BEFORE_AVG_TIME,A.SQL_TEXT,B.QUERY_PLAN AS BEFORE_PLAN
FROM   (SELECT DISTINCT STARTING.SERVER_NAME,STARTING.DATABASE_NAME,STARTING.QUERY_HASH,STARTING.AVG_ELAPSED_TIME AS BEFORE_AVG_TIME,STARTING.SQL_TEXT,STARTING.QUERY_PLAN_HASH AS BEFORE_PLAN_HASH
        FROM   QUERY_HISTORY_VW STARTING
        WHERE  STARTING.DATE = '10/15/2016' AND STARTING.FLAG = 'D'
               AND NOT EXISTS (SELECT QUERY_HASH
                               FROM   QUERY_HISTORY_VW ENDING
                               WHERE  STARTING.QUERY_HASH = ENDING.QUERY_HASH
                                      AND STARTING.DATABASE_NAME = ENDING.DATABASE_NAME
                                      AND STARTING.SERVER_NAME = ENDING.SERVER_NAME
                                      AND ENDING.DATE = '10/17/2016' AND ENDING.FLAG = 'D')
               AND STARTING.QUERY_HASH <> 0x0000000000000000) AS A
       CROSS APPLY (SELECT TOP 1 QUERY_PLAN
                    FROM   QUERY_PLANS W1
                    WHERE  W1.QUERY_PLAN_HASH = A.BEFORE_PLAN_HASH
                           AND W1.SERVER_NAME = A.SERVER_NAME
                           AND W1.DATABASE_NAME = A.DATABASE_NAME) AS B
ORDER  BY 2 DESC 





---------------------------------------------------------------------------------------
--
--		QUERY_STATISTICS_BY_PERIOD
--
--	 Show EXECUTIONS and TIME per 5 min increments using QUERY_STATS
--		or by 1 hour increments
--
--		NOTE:  THIS CAN ONLY BE RUN ON SQL2012 OR GREATER, QUERY USES LEAD/LAG
----------------------------------------------------------------------------------------

--REH Per 5 min collection time

		SELECT SERVER_NAME,
			   DATABASE_NAME,
			   STATS_TIME,
			   Sum(Cast(TIME_THIS_PERIOD / 1000.000 AS DECIMAL(14, 3))) AS TOTAL_TIME_MS,
			   Sum(EXECUTIONS_THIS_PERIOD)                              AS TOTAL_EXECUTIONS,
			   SUM(CAST(WORKER_TIME_THIS_PERIOD / 1000.000 AS DECIMAL(14,3))) AS WORK_TIME,
			   SUM(CAST( (TIME_THIS_PERIOD - WORKER_TIME_THIS_PERIOD) / 1000.000 AS DECIMAL(14,3))) AS WAIT_TIME
		FROM   QUERY_STATS_CTE_VW CTE
		--WHERE  EXECUTIONS_THIS_PERIOD > 0
		GROUP  BY SERVER_NAME,
				  DATABASE_NAME,
				  STATS_TIME
		ORDER  BY SERVER_NAME,
				  DATABASE_NAME,
				  STATS_TIME DESC 


--REH Per Hour

		SELECT SERVER_NAME,
		       DATABASE_NAME,
		       DATEADD(HH, DATEDIFF(HH, 0, STATS_TIME), 0)               AS [DATE],
		       SUM(CAST(TIME_THIS_PERIOD / 60000.000 AS DECIMAL(14, 3))) AS TOTAL_MINUTES,
		       SUM(EXECUTIONS_THIS_PERIOD)                               AS TOTAL_EXECUTIONS,
				SUM(CAST(WORKER_TIME_THIS_PERIOD / 1000.000 AS DECIMAL(14,3))) AS WORK_TIME,
				SUM(CAST( (TIME_THIS_PERIOD - WORKER_TIME_THIS_PERIOD) / 1000.000 AS DECIMAL(14,3))) AS WAIT_TIME
		FROM   QUERY_STATS_CTE_VW CTE
		--WHERE  EXECUTIONS_THIS_PERIOD > 0
		GROUP  BY SERVER_NAME,
		          DATABASE_NAME,
		          DATEADD(HH, DATEDIFF(HH, 0, STATS_TIME), 0)
		ORDER  BY SERVER_NAME,
		          DATABASE_NAME,
		          DATEADD(HH, DATEDIFF(HH, 0, STATS_TIME), 0) DESC 


--REH Find queries getting potentially blocked (WAIT TIME jumped up significantly)

	SELECT QUERY_HASH,
		   QUERY_PLAN_HASH,
		   STATS_TIME,
		   Cast(( TIME_THIS_PERIOD - WORKER_TIME_THIS_PERIOD ) / 1000.000 AS DECIMAL (14, 3)) AS WAIT_TIME_THIS_PERIOD,
		   Cast(( TOTAL_ELAPSED_TIME - TOTAL_WORKER_TIME ) / 1000.000 AS DECIMAL (14, 3))     AS CURRENT_WAIT_TIME,
		   Cast(( PREV_ELAPSED_TIME - PREV_TOTAL_WORKER_TIME ) / 1000.000 AS DECIMAL (14, 3)) AS PREV_WAIT_TIME
	FROM   QUERY_STATS_CTE_VW CTE
	WHERE  ( TOTAL_ELAPSED_TIME - TOTAL_WORKER_TIME ) - ( ( PREV_ELAPSED_TIME - PREV_TOTAL_WORKER_TIME ) * 2 ) > 1 --REH MORE THEN DOUBLE THE LAST WAIT_TIME
		   AND ( TOTAL_ELAPSED_TIME - TOTAL_WORKER_TIME ) - ( PREV_ELAPSED_TIME - PREV_TOTAL_WORKER_TIME ) > 30000000 --REH 30 SEC OF WAITING TIME IN 5 MINS





----------------------------------------------------------------
--
--		TRANSACTION_VOLUME_BY_HOUR
--
--	 Show changes in row counts by hour
----------------------------------------------------------------

USE [DynamicsPerf]

--Hourly Totals BY Server/Database
SELECT SERVER_NAME,
       DATABASE_NAME,
       STATS_TIME,
       SUM(ROWS_DELTA) AS NET_CHANGE_ROWS
FROM   PERF_HOURLY_ROWDATA_VW
--WHERE  DATABASE_NAME = 'XXXXXXXX' AND SERVER_NAME = 'XXXXXXXXX'
GROUP  BY STATS_TIME,
          SERVER_NAME,
          DATABASE_NAME
HAVING SUM(ROWS_DELTA) <> 0
ORDER  BY STATS_TIME DESC,
          SERVER_NAME,
          DATABASE_NAME,
          ABS(SUM(ROWS_DELTA)) DESC 



----------------------------------------------------------------
--
--		TRANSACTION_VOLUME_BY_HOUR_DETAIL
--
--	 Show details for a specific hour
----------------------------------------------------------------


--Hourly Totals BY Server/Database/Table


SELECT SERVER_NAME,
       DATABASE_NAME,
       STATS_TIME,
       TABLE_NAME,
       SUM(ROWS_DELTA) AS NET_CHANGE_ROWS
FROM   PERF_HOURLY_ROWDATA_VW
--WHERE  STATS_TIME = '2016-10-18 08:00:00.587' -- AND  DATABASE_NAME = 'XXXXXXXX' AND SERVER_NAME = 'XXXXXXXXX'
GROUP  BY STATS_TIME,
          SERVER_NAME,
          DATABASE_NAME,
          TABLE_NAME
HAVING SUM(ROWS_DELTA) <> 0
ORDER  BY STATS_TIME DESC,
          SERVER_NAME,
          DATABASE_NAME,
          ABS(SUM(ROWS_DELTA)) DESC,
          TABLE_NAME 




----------------------------------------------------------------
--
--		DISK_IO_BY_HOUR
--
--	 Hourly Change in Disk IO Stats by File
----------------------------------------------------------------


SELECT *
FROM   PERF_HOURLY_DISKSTATS_VW
--WHERE DATABASE_NAME= 'Dynamics'
ORDER  BY STATS_TIME DESC,
          SERVER_NAME,
          DATABASE_NAME,
          FILE_ID 


----------------------------------------------------------------
--
--		BAD_SQL_WAIT_STATS
--
--	IO bottleneck : If Top 2 values for wait stats include IO, (ASYNCH_IO_COMPLETION,IO_COMPLETION,LOGMGR,,WRITELOG,PAGEIOLATCH_x_xxx) there is an IO bottleneck.
--	Blocking bottleneck: If top 2 wait_stats values include locking (LCK_M_BU, LCK_M_IS, LCK_M_IU, LCK_% …), there is a blocking bottleneck
--	Parallelism: Cxpacket waits > 5%
----------------------------------------------------------------


/*********************************************************************************************

************************************************************************************************/

SELECT STATS_TIME,RANK,WAIT_TYPE,WAITING_TASKS_LAST_HOUR,WAIT_TIME_MS_LAST_HOUR
FROM   PERF_HOURLY_WAITSTATS_VW
WHERE  ( WAIT_TYPE LIKE 'PAGEIOLATCH_%'
          OR WAIT_TYPE LIKE 'ASYNCH_IO_COMPLETION%'
          OR WAIT_TYPE LIKE 'IO_COMPLETION%'
          OR WAIT_TYPE LIKE 'LOGMGR%'
          OR WAIT_TYPE LIKE 'WRITELOG%' )
       AND RANK < 3
       AND WAIT_TIME_MS_LAST_HOUR > 0 




--Activity between 2 data collections to look at comparisons over a longer time period
--Find all run_names

SELECT DISTINCT DATE
FROM   INDEX_HISTORY
ORDER  BY DATE DESC 


----------------------------------------------------------------
--
--		DB_GROWTH
--


--Find record count and table size differences between the runs
--Can use this to accurately predict database growth
--NOTE only TOP 1000 tables are returned
--------------------------------------------------------------------------------



SELECT IH.DATABASE_NAME,
       IH.TABLE_NAME,
       IH.PAGE_COUNT                                  AS ORIGINAL_PAGECOUNT,
       PREV.PAGE_COUNT                                AS NEW_PAGECOUNT,
       IH.PAGE_COUNT * 8 / 1024                       AS ORIGINAL_SIZEMB,
       PREV.PAGE_COUNT * 8 / 1024                     AS NEW_SIZEMB,
       ( PREV.PAGE_COUNT - IH.PAGE_COUNT ) * 8 / 1024 AS DELTA_SIZEMB,
       PREV.ROW_COUNT - IH.ROW_COUNT                  AS DELTA_IN_ROWS,
       DATEDIFF(DD, PREV.DATE, IH.DATE)               AS DAYS
FROM   INDEX_HISTORY IH
       INNER JOIN INDEX_HISTORY PREV
               ON IH.SERVER_NAME = PREV.SERVER_NAME
                  AND IH.DATABASE_NAME = PREV.DATABASE_NAME
                  AND IH.TABLE_NAME = PREV.TABLE_NAME
                  AND IH.INDEX_NAME = PREV.INDEX_NAME
WHERE  IH.ROW_COUNT > 0 AND PREV.ROW_COUNT > 0
		AND (IH.INDEX_DESCRIPTION LIKE 'CLUSTERED%' OR IH.INDEX_DESCRIPTION LIKE 'HEAP')
       AND IH.DATE = '10/18/2016'  AND IH.FLAG = 'D'
       AND PREV.DATE = '10/15/2016' AND PREV.FLAG = 'D'
       --AND IH.DATABASE_NAME = 'XXXXXX' AND IH.SERVER_NAME = 'XXXXXXX'
ORDER  BY PREV.ROW_COUNT - IH.ROW_COUNT DESC,
          IH.TABLE_NAME 




----------------------------------------------------------------
--
--		TABLE_ACTIVITY_DAY
--


--Find record read/write and row count differences between the runs
-------------------------------------------------------------------


SELECT IH.DATABASE_NAME,
       IH.TABLE_NAME,
       IH.INDEX_NAME,
       IH.PAGE_COUNT_DELTA             AS PAGES_TODAY,
       IH.PAGE_COUNT_DELTA * 8 / 1024  AS MB_TODAY,
       IH.ROW_COUNT_DELTA              AS ROWS_TODAY,
       ISNULL(USER_SEEKS_DELTA + USER_SCANS_DELTA
              + USER_LOOKUPS_DELTA, 0) AS READS_TODAY,
       ISNULL(USER_UPDATES_DELTA, 0)   AS WRITES_TODAY
FROM   INDEX_HISTORY IH
WHERE  IH.ROW_COUNT_DELTA <> 0
       AND IH.DATE = '10/16/2016'
       AND IH.FLAG = 'D'
ORDER  BY ABS(IH.ROW_COUNT_DELTA) DESC,
          IH.TABLE_NAME




----------------------------------------------------------------
--
--		SQL_WAIT_STATS_BY_HOUR
--- Hourly Change in SQL Server Wait Stats 
----------------------------------------------------------------

SELECT *
FROM   PERF_HOURLY_WAITSTATS_VW 
WHERE  WAIT_TIME_MS_LAST_HOUR > 0 
ORDER BY STATS_TIME DESC, RANK



