/*********************************************************************
Copy one of the following links and press Ctrl-F and click FIND NEXT
in order to go to that section of the scripts

INDEX_CHANGES_SINCE_BASELINE
QUERIES_SLOWER_THAN_BASELINE
QUERIES_FASTER_THAN_BASELINE
NEW_QUERIES_NOT_IN_BASELINE
QUERIES_IN_BASELINE_BUT_NOT_IN_CURRENT
TRANSACTION_VOLUME_BY_HOUR
TRANSACTION_VOLUME_BY_HOUR_DETAIL
DISK_IO_BY_HOUR
BAD_SQL_WAIT_STATS
DB_GROWTH
TABLE_ACTIVITY
ACTIVITY_COMPARISON_BETWEEN_RUNS


********************************************************************/




USE [DynamicsPerf]
GO
SELECT *
FROM   STATS_COLLECTION_SUMMARY
ORDER  BY STATS_TIME DESC 

GO


----------------------------------------------------------------
--
--		INDEX_CHANGES_SINCE_BASELINE
--
--	 show index changes from BASELINE
----------------------------------------------------------------


EXEC SP_INDEX_CHANGES
  @BASELINE = 'BASE_to_compare_to',
  @COMPARISON_RUN_NAME = 'Feb_26_2020_804AM' 


----------------------------------------------------------------
--
--		QUERIES_SLOWER_THAN_BASELINE
--
--	 queries that got worse  from BASELINE
----------------------------------------------------------------


SELECT A.DATABASE_NAME,
	   A.QUERY_HASH,
       A.EXECUTION_COUNT,
       A.BEFORE_AVG_TIME,
       A.CURRENT_AVG_TIME,
       A.[TIME_DIFF(ms)],
       A.[%DECREASE],
       A.SQL_TEXT,
       B.QUERY_PLAN AS BEFORE_PLAN,
       C.QUERY_PLAN AS AFTER_PLAN
FROM   (SELECT DISTINCT V1.DATABASE_NAME,V1.QUERY_HASH,
                        V1.EXECUTION_COUNT,
                        V1.AVG_ELAPSED_TIME                                                               AS BEFORE_AVG_TIME,
                        V2.AVG_ELAPSED_TIME                                                               AS CURRENT_AVG_TIME,
                        V2.AVG_ELAPSED_TIME - V1.AVG_ELAPSED_TIME                                         AS 'TIME_DIFF(ms)',
                        Cast(( V2.AVG_ELAPSED_TIME - V1.AVG_ELAPSED_TIME ) / CASE V1.AVG_ELAPSED_TIME
                                                                               WHEN 0 THEN 1
                                                                               ELSE V1.AVG_ELAPSED_TIME
                                                                             END * 100 AS DECIMAL(14, 3)) AS '%DECREASE',
                        V1.SQL_TEXT,
                        V1.QUERY_PLAN_HASH                                                                AS BEFORE_PLAN_HASH,
                        V2.QUERY_PLAN_HASH                                                                AS AFTER_PLAN_HASH
        FROM   QUERY_STATS_HASH_VW V1
               INNER JOIN QUERY_STATS_HASH_VW V2
                       ON V1.QUERY_HASH = V2.QUERY_HASH AND V1.DATABASE_NAME = V2.DATABASE_NAME
                       
        WHERE  V1.RUN_NAME = 'BASE_to_compare_to'
               AND V2.RUN_NAME = 'Feb_26_2020_804AM'
               
               AND V1.AVG_ELAPSED_TIME < V2.AVG_ELAPSED_TIME
               AND V1.QUERY_HASH <> 0x0000000000000000) AS A
       CROSS APPLY (SELECT TOP 1 QUERY_PLAN
                    FROM   QUERY_PLANS W1
                    WHERE  W1.QUERY_PLAN_HASH = A.BEFORE_PLAN_HASH) AS B
       CROSS APPLY (SELECT TOP 1 QUERY_PLAN
                    FROM   QUERY_PLANS W2
                    WHERE  W2.QUERY_PLAN_HASH = A.AFTER_PLAN_HASH) AS C
ORDER  BY 7 DESC 


----------------------------------------------------------------
--
--		QUERIES_FASTER_THAN_BASELINE
--
--	 queries that got faster from BASELINE
----------------------------------------------------------------

SELECT A.DATABASE_NAME,
	   A.QUERY_HASH,
       A.EXECUTION_COUNT,
       A.BEFORE_AVG_TIME,
       A.CURRENT_AVG_TIME,
       A.[TIME_DIFF(ms)],
       A.[%IMPROVEMENT],
       A.SQL_TEXT,
       B.QUERY_PLAN AS BEFORE_PLAN,
       C.QUERY_PLAN AS AFTER_PLAN
FROM   (SELECT DISTINCT V1.DATABASE_NAME,
					    V1.QUERY_HASH,
                        V1.EXECUTION_COUNT,
                        V1.AVG_ELAPSED_TIME                                                               AS BEFORE_AVG_TIME,
                        V2.AVG_ELAPSED_TIME                                                               AS CURRENT_AVG_TIME,
                        V1.AVG_ELAPSED_TIME - V2.AVG_ELAPSED_TIME                                         AS 'TIME_DIFF(ms)',
                        Cast(( V1.AVG_ELAPSED_TIME - V2.AVG_ELAPSED_TIME ) / CASE V2.AVG_ELAPSED_TIME
                                                                               WHEN 0 THEN 1
                                                                               ELSE V2.AVG_ELAPSED_TIME
                                                                             END * 100 AS DECIMAL(14, 3)) AS '%IMPROVEMENT',
                        V1.SQL_TEXT,
                        V1.QUERY_PLAN_HASH                                                                AS BEFORE_PLAN_HASH,
                        V2.QUERY_PLAN_HASH                                                                AS AFTER_PLAN_HASH
        FROM   QUERY_STATS_HASH_VW V1
               INNER JOIN QUERY_STATS_HASH_VW V2
                       ON V1.QUERY_HASH = V2.QUERY_HASH AND V1.DATABASE_NAME=V2.DATABASE_NAME
                       
        WHERE  V1.RUN_NAME = 'BASE_to_compare_to'
               AND V2.RUN_NAME = 'Feb_26_2020_804AM'
               
               AND V1.AVG_ELAPSED_TIME > V2.AVG_ELAPSED_TIME
               AND V1.QUERY_HASH <> 0x0000000000000000) AS A
       CROSS APPLY (SELECT TOP 1 QUERY_PLAN
                    FROM   QUERY_PLANS W1
                    WHERE  W1.QUERY_PLAN_HASH = A.BEFORE_PLAN_HASH) AS B
       CROSS APPLY (SELECT TOP 1 QUERY_PLAN
                    FROM   QUERY_PLANS W2
                    WHERE  W2.QUERY_PLAN_HASH = A.AFTER_PLAN_HASH) AS C
ORDER  BY 7 DESC 



----------------------------------------------------------------
--
--		NEW_QUERIES_NOT_IN_BASELINE
--
--	 NEW queries that are not in the BASELINE
----------------------------------------------------------------

SELECT A.DATABASE_NAME,
	   A.QUERY_HASH,
       A.BEFORE_AVG_TIME,
       A.SQL_TEXT,
       B.QUERY_PLAN AS BEFORE_PLAN
FROM   (SELECT DISTINCT V1.DATABASE_NAME,
					    V1.QUERY_HASH,
                        V1.AVG_ELAPSED_TIME AS BEFORE_AVG_TIME,
                        V1.SQL_TEXT,
                        V1.QUERY_PLAN_HASH  AS BEFORE_PLAN_HASH
        FROM   QUERY_STATS_HASH_VW V1
        
        WHERE  V1.RUN_NAME = 'Feb_26_2020_804AM'
        
               AND NOT EXISTS (SELECT QUERY_HASH
                               FROM   QUERY_STATS_HASH_VW V2
                               WHERE  V1.QUERY_HASH = V2.QUERY_HASH 
									  AND V1.DATABASE_NAME = V2.DATABASE_NAME
									  
                                      AND V2.RUN_NAME = 'BASE_to_compare_to')
                                      
               AND V1.QUERY_HASH <> 0x0000000000000000) AS A
       CROSS APPLY (SELECT TOP 1 QUERY_PLAN
                    FROM   QUERY_PLANS W1
                    WHERE  W1.QUERY_PLAN_HASH = A.BEFORE_PLAN_HASH) AS B
ORDER  BY 3 DESC 

------------------------------------------------------------------------------
--
--		QUERIES_IN_BASELINE_BUT_NOT_IN_CURRENT
--
--	  queries that were in the BASELINE but not in the comparison capture
-------------------------------------------------------------------------------

SELECT A.QUERY_HASH,
       A.BEFORE_AVG_TIME,
       A.SQL_TEXT,
       B.QUERY_PLAN AS BEFORE_PLAN
FROM   (SELECT DISTINCT V1.DATABASE_NAME,
					    V1.QUERY_HASH,
                        V1.AVG_ELAPSED_TIME AS BEFORE_AVG_TIME,
                        V1.SQL_TEXT,
                        V1.QUERY_PLAN_HASH  AS BEFORE_PLAN_HASH
        FROM   QUERY_STATS_HASH_VW V1
        
        WHERE  V1.RUN_NAME = 'BASE_to_compare_to'
        
               AND NOT EXISTS (SELECT QUERY_HASH
                               FROM   QUERY_STATS_HASH_VW V2
                               WHERE  V1.QUERY_HASH = V2.QUERY_HASH
									  AND V1.DATABASE_NAME = V2.DATABASE_NAME
									  
                                      AND V2.RUN_NAME = 'Feb_26_2020_804AM')
                                      
               AND V1.QUERY_HASH <> 0x0000000000000000) AS A
       CROSS APPLY (SELECT TOP 1 QUERY_PLAN
                    FROM   QUERY_PLANS W1
                    WHERE  W1.QUERY_PLAN_HASH = A.BEFORE_PLAN_HASH) AS B
ORDER  BY 2 DESC 




----------------------------------------------------------------
--
--		TRANSACTION_VOLUME_BY_HOUR
--
--	 Show changes in row counts by hour
----------------------------------------------------------------

USE [DynamicsPerf]

--Hourly Totals
SELECT *
FROM   PERF_HOURLY_ROWDATA_VW
WHERE  ROWRANK = 9999
       AND DATABASE_NAME <> 'NULL'
ORDER  BY STATS_TIME DESC 


----------------------------------------------------------------
--
--		TRANSACTION_VOLUME_BY_HOUR_DETAIL
--
--	 Show details for a specific hour
----------------------------------------------------------------


SELECT *
FROM   PERF_HOURLY_ROWDATA_VW
WHERE  STATS_TIME = 'ENTER_STATS_TIME_HERE_FROM_PREVIOUS_QUERY'
       AND TABLE_NAME <> 'NULL'
ORDER  BY ROWRANK 


----------------------------------------------------------------
--
--		DISK_IO_BY_HOUR
--
--	 Hourly Change in Disk IO Stats by File
----------------------------------------------------------------


SELECT *
FROM   PERF_HOURLY_IOSTATS_VW 
WHERE DATABASE_NAME= 'Dynamics'
ORDER BY STATS_TIME DESC, DATABASE_NAME, FILE_ID


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


SELECT STATS_TIME,
       RANK,
       WAIT_TYPE,
       WAITING_TASKS_LAST_HOUR,
       WAIT_TIME_MS_LAST_HOUR
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

SELECT RUN_NAME
FROM   STATS_COLLECTION_SUMMARY
ORDER  BY STATS_TIME DESC 


----------------------------------------------------------------
--
--		DB_GROWTH
--


--Find record count and table size differences between the runs
--Can use this to accurately predict database growth
--NOTE only TOP 1000 tables are returned
--------------------------------------------------------------------------------
SELECT *
FROM   fn_dbstats('STARTING_RUN_NAME', 'ENDING_RUN_NAME')
ORDER  BY DELTA_SIZEMB DESC 



----------------------------------------------------------------
--
--		TABLE_ACTIVITY
--


--Find record read/write and row count differences between the runs
-------------------------------------------------------------------

SELECT A.TABLE_NAME,
       B.ROW_COUNT - A.ROW_COUNT                       AS DELTA_IN_ROWS,
       B.TOTALREADOPERATIONS - A.TOTALREADOPERATIONS   AS DELTA_IN_READS,
       B.TOTALWRITEOPERATIONS - A.TOTALWRITEOPERATIONS AS DELTA_IN_WRITES
FROM   INDEX_OPS_VW A
       INNER JOIN INDEX_OPS_VW B
               ON A.TABLE_NAME = B.TABLE_NAME
                  AND A.DATABASE_NAME = B.DATABASE_NAME
                  AND A.RUN_NAME = 'STARTING_RUN_NAME'
                  AND B.RUN_NAME = 'ENDING_RUN_NAME'
ORDER  BY 2 DESC 


----------------------------------------------------------------
--
--		SQL_WAIT_STATS_BY_HOUR
--- Hourly Change in SQL Server Wait Stats 
----------------------------------------------------------------

SELECT *
FROM   PERF_HOURLY_WAITSTATS_VW 
ORDER BY STATS_TIME DESC, RANK



----------------------------------------------------------------
--
--		ACTIVITY_COMPARISON_BETWEEN_RUNS
--
--
--  Comparison queries between different data captures 
-----------------------------------------------------------------

SELECT D1.RUN_NAME           AS RUN1,
       D2.RUN_NAME           AS RUN2,
       D1.SQL_TEXT,
       D1.QUERY_PLAN,
       D1.AVG_ELAPSED_TIME   AS RUN1_AVG_TIME,
       D2.AVG_ELAPSED_TIME   AS RUN2_AVG_TIME,
       D2.AVG_ELAPSED_TIME-D1.AVG_ELAPSED_TIME AS TIME_DIFF,
       D1.AVG_LOGICAL_READS  AS RUN1_READS,
       D2.AVG_LOGICAL_READS  AS RUN2_READS,
       D2.AVG_LOGICAL_READS-D1.AVG_LOGICAL_READS AS READS_DIFF,
       D1.AVG_LOGICAL_WRITES AS RUN1_WRITES,
       D2.AVG_LOGICAL_WRITES AS RUN2_WRITES,
       D2.AVG_LOGICAL_WRITES-D1.AVG_LOGICAL_WRITES AS WRITES_DIFF,
       D1.QUERY_HASH
FROM   QUERY_STATS_VW D1
       INNER JOIN QUERY_STATS_VW D2
         ON D1.QUERY_HASH = D2.QUERY_HASH
        AND D1.DATABASE_NAME = D2.DATABASE_NAME
WHERE  D1.QUERY_HASH <> 0x0000000000000000
       AND D1.RUN_NAME = 'STARTING_RUN_NAME'
       AND D2.RUN_NAME = 'ENDING_RUN_NAME'
ORDER  BY D2.AVG_ELAPSED_TIME - D1.AVG_ELAPSED_TIME 




