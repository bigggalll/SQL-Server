/*********************************************************************
Copy one of the following links and press Ctrl-F and click FIND NEXT
in order to go to that section of the scripts

EXPENSIVE_QUERIES
EXPENSIVE_QUERIES_BY_TIME_PERIOD
MISSING_INDEX_QUERIES
QUERIES_WITH_MULTIPLE_EXECUTION_PLANS

********************************************************************/

USE DynamicsPerf
GO


----------------------------------------------------------------
--
--		EXPENSIVE_QUERIES
--
-- List top 100 most expensive queries
----------------------------------------------------------------


SELECT TOP 100 *
FROM   QUERY_HISTORY_VW QS -- Queries from last data collection only
WHERE
  1=1
  --AND FLAG = 'M' --AND DATE = '9/1/2016'  -- 1ST DAY OF MONTH REPRESENTS THAT MONTH
   AND FLAG = 'D' AND DATE = '3/30/2016'
-- AND  QUERY_HASH = 0x35DBB41368AFED7C -- find a specific query
-- AND SQL_TEXT LIKE '%SQL_TEXT_HERE%'  -- find all SQL statements that contain a specific text i.e. table name
 
ORDER  BY TOTAL_ELAPSED_TIME DESC  -- Queries consuming most TOTAL time on SQL 

-- ORDER  BY AVG_LOGICAL_READS DESC  -- Queries potentially causing large disk i/o
-- ORDER  BY EXECUTION_COUNT DESC  -- High execution count could be loops in application code
-- ORDER  BY TOTAL_LOGICAL_READS DESC  -- Queries to review to potentially reduce disk i/o



SELECT TOP 100 *
FROM   QUERY_STATS_CURR_VW QS -- Review queries for all data collections
WHERE
  1=1
-- AND  QUERY_HASH = 0x35DBB41368AFED7C -- find a specific query
-- AND SQL_TEXT LIKE '%SQL_TEXT_HERE%'  -- find all SQL statements that contain a specific text i.e. table name
-- AND LAST_EXECUTION_TIME > 'XXXXXXX'   -- find all queries that have executed after a specific time
-- AND DATABASE_NAME = 'XXXXXXXXX'       -- find all queries for a specific database
-- AND MAX_ELAPSED_TIME /10 > AVG_ELAPSED_TIME  -- Find all queries potentially getting blocked or paramater sniffing issues

ORDER  BY TOTAL_ELAPSED_TIME DESC  -- Queries consuming most TOTAL time on SQL 

-- ORDER  BY AVG_LOGICAL_READS DESC  -- Queries potentially causing large disk i/o
-- ORDER  BY EXECUTION_COUNT DESC  -- High execution count could be loops in application code
-- ORDER  BY TOTAL_LOGICAL_READS DESC  -- Queries to review to potentially reduce disk i/o



/** NOTE MUST HAVE INSTALLED FULLTEXT INDEXES FOR THIS QUERY **/

--;WITH FT_CTE (QUERY_HASH)
--AS

--(SELECT QUERY_HASH
-- FROM   QUERY_TEXT
-- WHERE  CONTAINS (SQL_TEXT, 'SELECT') -- find all SQL statements that contain a specific text i.e. table name
--)


;WITH FT_CTE2 (QUERY_PLAN_HASH, QUERY_PLAN)
AS

(SELECT QUERY_PLAN_HASH, QUERY_PLAN
 FROM   QUERY_PLANS
 WHERE  CONTAINS (C_QUERY_PLAN, '"INVENTDIM" AND "INDEX SCAN"') -- find all statements scanning a specific table
--WHERE  CONTAINS (C_QUERY_PLAN, '"I_6143RECID"') -- find all SQL statements that contain a specific index 
) 

SELECT TOP 100 *
FROM   QUERY_HISTORY QS -- Queries from last data collection only
 --INNER JOIN FT_CTE FT ON QS.QUERY_HASH = FT.QUERY_HASH
 INNER JOIN FT_CTE2 FT2 ON QS.QUERY_PLAN_HASH = FT2.QUERY_PLAN_HASH
WHERE
  1=1
  --AND FLAG = 'M' --AND DATE = '1/1/2016'  -- 1ST DAY OF MONTH REPRESENTS THAT MONTH
   AND FLAG = 'D' AND DATE = '3/20/2016'
   ORDER BY ELAPSED_TIME_TODAY DESC


-- Show all queries who's avg is GREATER then then monthly avg for that query/plan


		SELECT TOP 100 QM.AVG_ELAPSED_TIME AS MONTHLY_AVG_TIME,
					   QS.AVG_ELAPSED_TIME  - QM.AVG_ELAPSED_TIME AS DELTA_TIME,
					   QS.*
		FROM   QUERY_HISTORY_VW QS -- Queries from last data collection only
			   INNER JOIN QUERY_HISTORY_VW QM
					   ON QS.SERVER_NAME = QM.SERVER_NAME
					      AND QS.DATABASE_NAME = QM.DATABASE_NAME					   
						  AND QS.QUERY_HASH = QM.QUERY_HASH
						  AND QS.QUERY_PLAN_HASH = QM.QUERY_PLAN_HASH
						  AND QM.DATE = '3/1/2016'  -- MONTHLY records are 1st day of month
						  AND QM.FLAG = 'M'
						  AND QS.AVG_ELAPSED_TIME > QM.AVG_ELAPSED_TIME
		WHERE  QS.FLAG = 'D' AND QS.DATE = '3/20/2016'
		ORDER  BY QS.TOTAL_ELAPSED_TIME DESC 


-- Show all queries who's avg is greater then previous month


		SELECT TOP 100 QM.AVG_ELAPSED_TIME AS PREV_MONTHLY_AVG_TIME,
					   QS.AVG_ELAPSED_TIME  - QM.AVG_ELAPSED_TIME AS DELTA_TIME,
					   QS.*
		FROM   QUERY_HISTORY_VW QS -- Queries from last data collection only
			   INNER JOIN QUERY_HISTORY_VW QM
					   ON QS.SERVER_NAME = QM.SERVER_NAME
					      AND QS.DATABASE_NAME = QM.DATABASE_NAME
					      AND QS.QUERY_HASH = QM.QUERY_HASH
						  AND QS.QUERY_PLAN_HASH = QM.QUERY_PLAN_HASH
						  AND QM.DATE = '2/1/2016'  -- MONTHLY records are 1st day of month
						  AND QM.FLAG = 'M'
						  AND QS.AVG_ELAPSED_TIME > QM.AVG_ELAPSED_TIME
		WHERE  QS.FLAG = 'M' AND QS.DATE = '3/1/2016'
		ORDER  BY QS.TOTAL_ELAPSED_TIME DESC 
		

-- Show queries that have new plans this month


		SELECT TOP 100 QS.*
		FROM   QUERY_HISTORY_VW QS -- Queries from last data collection only
			   LEFT JOIN QUERY_HISTORY_VW QM
					   ON QS.SERVER_NAME = QM.SERVER_NAME
					      AND QS.DATABASE_NAME = QM.DATABASE_NAME
					      AND QS.QUERY_HASH = QM.QUERY_HASH
						  AND QS.QUERY_PLAN_HASH = QM.QUERY_PLAN_HASH
						  AND QM.DATE = '2/1/2016'  -- MONTHLY records are 1st day of month
						  AND QM.FLAG = 'M'
						  AND QS.AVG_ELAPSED_TIME > QM.AVG_ELAPSED_TIME
		WHERE  QS.FLAG = 'M' AND QM.QUERY_HASH IS NULL  AND QS.DATE = '3/1/2016'  -- MONTHLY records are 1st day of month
		ORDER  BY QS.TOTAL_ELAPSED_TIME DESC 



----------------------------------------------------------------
--
--		EXPENSIVE_QUERIES_BY_TIME_PERIOD
--
-- List top 100 most expensive queries
--
-- NOTE: REQUIRES SQL 2012 to run this query
----------------------------------------------------------------

--REH Per 5 min collection time

SELECT TOP 100 SERVER_NAME,
               DATABASE_NAME,
               --STATS_TIME,
               QUERY_HASH,
               QUERY_PLAN_HASH,
               (SELECT SQL_TEXT
                FROM   QUERY_TEXT QT
                WHERE  CTE.QUERY_HASH = QT.QUERY_HASH
                AND CTE.SERVER_NAME = QT.SERVER_NAME
                AND CTE.DATABASE_NAME = QT.DATABASE_NAME)                                                AS SQL_TEXT,
               SUM(CAST(TIME_THIS_PERIOD / 1000.000 AS DECIMAL(20, 3)))                               AS TOTAL_TIME_MS,
               SUM(EXECUTIONS_THIS_PERIOD)                                                            AS TOTAL_EXECUTIONS,
               CASE SUM(EXECUTIONS_THIS_PERIOD)
                 WHEN 0 THEN 0
                 ELSE ( SUM(CAST(TIME_THIS_PERIOD / 1000.000 AS DECIMAL(20, 3))) / SUM(EXECUTIONS_THIS_PERIOD) )
               END                                                                                    AS AVG_TIME_MS,
               SUM(CAST(WORKER_TIME_THIS_PERIOD / 1000.000 AS DECIMAL(20, 3)))                        AS WORK_TIME,
               SUM(CAST(( TIME_THIS_PERIOD - WORKER_TIME_THIS_PERIOD ) / 1000.000 AS DECIMAL(14, 3))) AS WAIT_TIME
FROM   QUERY_STATS_CTE_VW CTE
WHERE  STATS_TIME BETWEEN '2016-10-13 16:15:00.307' AND '2016-10-13 16:25:00.307'
--AND QUERY_HASH = 0x24A42A762C8879C3
GROUP  BY SERVER_NAME,
          DATABASE_NAME,
 --         STATS_TIME,
          QUERY_HASH,
          QUERY_PLAN_HASH
ORDER  BY 7 DESC 



----------------------------------------------------------------------------------------
--
--				MISSING_INDEX_QUERIES
--
-- Identify queries that the optimizer suspects can be optimized 
-- by new or changed indexes:
--
-- NOTE: DO NOT add these indexes verbatim without deep analysis.  
--  Large INCLUDED Column lists are NOT recommended for ERP solutions
-- 
-- 1-Make sure the index isn't creating a subset duplicate of another index
-- 2-Make sure that the Application code is written correctly 
-- 3-Make sure the query actually matches a business process
-- 4-Make sure it's not a one off exception 
-- 5-Make sure the Reads you save is less than the Writes you'll cause
--		by adding the index
--
--  SQL Server doesn't know that the code isn't correct, or forgot 
--   to pass criteria to the database
--
--  YOU CAN'T FIX CHALLENGES IN CODE OR BUSINESS PROCESSES WITH ONLY INDEXES !!
--
--  If you have more then 30 indexes on a Dynamics Table you should reevaluate the indexes on that table
--
-- *CAUTION*
--
--•The missing index DMVs don't take into account the overhead that new indexes can create (extra disk space, slight impact on insert/delete perf, etc). 
--•It's probable that the DMVs may not recommend the ideal column order for multi-column indexes. 
--•The missing index DMVs don't make recommendation about whether an index should be clustered or nonclustered.  
--*A bug in SQL 2008/R2 that recommends an index that already exists
--*No guarantee that the SQL Optimizer will actually use the suggested index.  You need to verify usage.

------------------------------------------------------------------------------------------


SELECT TOP 100 *
FROM   MISSING_INDEXES_CURR_VW
WHERE  NOT EXISTS (SELECT QUERY_HASH
                   FROM   COMMENTS C
                   WHERE  C.QUERY_HASH = MISSING_INDEXES_CURR_VW.QUERY_HASH) -- Remove queries that have comments
       AND INDEX_IMPACT > 75
       AND EXECUTION_COUNT > 100 --In Dev/Test/QA lower this value to 1
       AND AVG_ELAPSED_TIME > 20
       AND AVG_LOGICAL_READS > 1000
ORDER  BY TOTAL_LOGICAL_READS DESC 




----------------------------------------------------------------
--
--			QUERIES_WITH_MULTIPLE_EXECUTION_PLANS 
--
-- List queries that have more than 1 execution plans
-- Is a strong indicator of parameter sniffing issues
----------------------------------------------------------------



SELECT TOP 100 SERVER_NAME,
               DATABASE_NAME,
               QUERY_HASH,
               (SELECT SQL_TEXT
                FROM   QUERY_TEXT QT
                WHERE  QT.QUERY_HASH = A.QUERY_HASH
                       AND QT.DATABASE_NAME = A.DATABASE_NAME
                       AND QT.SERVER_NAME = A.SERVER_NAME) AS SQL_TEXT,
               NUM_PLANS                                   AS NO_OF_PLANS,
               MIN_TIME                                    AS MIN_AVG_TIME,
               MAX_TIME                                    AS MAX_AVG_TIME,
               STUFF ((SELECT ', '
                              + CONVERT(VARCHAR(64), QH1.QUERY_PLAN_HASH, 1)
                              + ' time(ms)= '
                              + CAST(QH1.AVG_ELAPSED_TIME AS VARCHAR(20))
                              + CHAR(10)
                       FROM   QUERY_HISTORY_VW QH1
                       WHERE  QH1.QUERY_HASH = A.QUERY_HASH
                              AND QH1.DATABASE_NAME = A.DATABASE_NAME
                              AND QH1.SERVER_NAME = A.SERVER_NAME
                              AND QH1.FLAG = 'M'
                              AND QH1.DATE = A.DATE
                       ORDER  BY QH1.AVG_ELAPSED_TIME
                       FOR xml path('')), 1, 1, '''')      AS QUERY_PLAN_HASH
FROM   (SELECT DISTINCT SERVER_NAME,
                        DATABASE_NAME,
                        DATE,
                        QUERY_HASH,
                        COUNT(QUERY_PLAN_HASH) AS NUM_PLANS,
                        MIN(AVG_ELAPSED_TIME)  AS MIN_TIME,
                        MAX(AVG_ELAPSED_TIME)  AS MAX_TIME
        FROM   QUERY_HISTORY_VW QV
        WHERE  QV.FLAG = 'M'
               AND DATE = '3/1/2016'
        GROUP  BY SERVER_NAME,
                  DATABASE_NAME,
                  QUERY_HASH,
                  DATE
        HAVING COUNT(QUERY_PLAN_HASH) > 1) AS A
ORDER  BY 6 DESC 


--Read the query plan from previous query
SELECT *
FROM   QUERY_PLANS
WHERE  QUERY_PLAN_HASH = 0X0000000000000 




