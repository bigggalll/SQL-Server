/*********************************************************************
Copy one of the following links and press Ctrl-F and click FIND NEXT
in order to go to that section of the scripts

EXPENSIVE_QUERIES_BY_TIME_PERIOD
EXPENSIVE_QUERIES_HISTORICAL
SEARCH_BY_QUERY_PLANS
SEARCH_BY_QUERY_TEXT
EXPENSIVE_QUERIES_BY_LAST_COLLECTION   (CURR_VW)
MISSING_INDEX_QUERIES
QUERIES_WITH_MULTIPLE_EXECUTION_PLANS

********************************************************************/

USE DynamicsPerf
GO


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
               QUERY_HASH,
               QUERY_PLAN_HASH,
               SUM(CAST(TIME_THIS_PERIOD / 1000.000 AS DECIMAL(20, 3)))                               AS TOTAL_TIME_MS,
               SUM(EXECUTIONS_THIS_PERIOD)                                                            AS TOTAL_EXECUTIONS,
               CASE SUM(EXECUTIONS_THIS_PERIOD)
                 WHEN 0 THEN 0
                 ELSE ( SUM(CAST(TIME_THIS_PERIOD / 1000.000 AS DECIMAL(20, 3))) / SUM(EXECUTIONS_THIS_PERIOD) )
               END                                                                                    AS AVG_TIME_MS,
               (SELECT TOP 1 QUERY_PLAN_PARSED FROM QUERY_PLANS_PARSED_VW V2 
               WHERE  V2.SERVER_NAME = CTE.SERVER_NAME
                       AND V2.DATABASE_NAME = CTE.DATABASE_NAME
                       AND V2.QUERY_HASH = CTE.QUERY_HASH AND V2.QUERY_PLAN_HASH = CTE.QUERY_PLAN_HASH) AS QUERY_PLAN_PARSED,
               (SELECT SQL_TEXT FROM   QUERY_TEXT V2
                WHERE  V2.SERVER_NAME = CTE.SERVER_NAME
                       AND V2.DATABASE_NAME = CTE.DATABASE_NAME
                       AND V2.QUERY_HASH = CTE.QUERY_HASH)                                            AS SQL_TEXT,
               (SELECT QUERY_PLAN FROM   QUERY_PLANS V2
                WHERE  V2.SERVER_NAME = CTE.SERVER_NAME
                       AND V2.DATABASE_NAME = CTE.DATABASE_NAME
                       AND V2.QUERY_PLAN_HASH = CTE.QUERY_PLAN_HASH)                                  AS QEURY_PLAN,
               SUM(CAST(WORKER_TIME_THIS_PERIOD / 1000.000 AS DECIMAL(20, 3)))                        AS WORK_TIME,
               SUM(CAST(( TIME_THIS_PERIOD - WORKER_TIME_THIS_PERIOD ) / 1000.000 AS DECIMAL(14, 3))) AS WAIT_TIME
FROM   QUERY_STATS_CTE_VW CTE
WHERE  STATS_TIME BETWEEN '2017-03-01 07:15:00.307' AND '2017-03-10 07:25:00.307'
--AND DATABASE_NAME = 'XXXXXXXXXXXXXX'
--AND QUERY_HASH = 0x020C200A1715926C
--AND SQL_TEXT like '%TABLE_NAME%'
GROUP  BY SERVER_NAME,
          DATABASE_NAME,
          QUERY_HASH,
          QUERY_PLAN_HASH
ORDER  BY TOTAL_TIME_MS DESC 



----------------------------------------------------------------
--
--		EXPENSIVE_QUERIES_HISTORICAL
--
-- List top 100 most expensive queries
----------------------------------------------------------------


SELECT TOP 100 *
FROM   QUERY_HISTORY_VW QS -- Queries from last data collection only
WHERE  1 = 1
       AND FLAG = 'M' AND DATE = '2/1/2017' -- 1ST DAY OF MONTH REPRESENTS THAT MONTH
--AND FLAG = 'D' AND DATE = '2/20/2017'
-- AND  QUERY_HASH = 0x35DBB41368AFED7C -- find a specific query
-- AND SQL_TEXT LIKE '%SQL_TEXT_HERE%'  -- find all SQL statements that contain a specific text i.e. table name
ORDER  BY TOTAL_ELAPSED_TIME DESC -- Queries consuming most TOTAL time on SQL 

-- ORDER  BY AVG_LOGICAL_READS DESC  -- Queries potentially causing large disk i/o
-- ORDER  BY EXECUTION_COUNT DESC  -- High execution count could be loops in application code
-- ORDER  BY TOTAL_LOGICAL_READS DESC  -- Queries to review to potentially reduce disk i/o



/** NOTE MUST HAVE INSTALLED FULLTEXT INDEXES FOR THIS QUERIES **/

/*********** SEARCH_BY_QUERY_PLANS *******************/

	;WITH FT_CTE2 (QUERY_PLAN_HASH, QUERY_PLAN)
		 AS (SELECT QUERY_PLAN_HASH,
					QUERY_PLAN
			 FROM   QUERY_PLANS
			 WHERE  CONTAINS (C_QUERY_PLAN, '"INVENTDIM" AND "INDEX SCAN"')
			--WHERE  CONTAINS (C_QUERY_PLAN, '"I_6143RECID"') 
			)
	SELECT TOP 100 *
	FROM   QUERY_HISTORY_VW QS -- Queries from last data collection only
		   INNER JOIN FT_CTE2 FT2
				   ON QS.QUERY_PLAN_HASH = FT2.QUERY_PLAN_HASH
	WHERE  1 = 1
		   --AND FLAG = 'M' --AND DATE = '2/1/2017'  -- 1ST DAY OF MONTH REPRESENTS THAT MONTH
		   AND FLAG = 'D' AND DATE = '2/20/2017'
	ORDER  BY TOTAL_ELAPSED_TIME DESC 


   
   

/*********** SEARCH_BY_QUERY_TEXT *******************/

	;WITH FT_CTE (QUERY_HASH)
		 AS (SELECT QUERY_HASH
			 FROM   QUERY_TEXT
			 ---- find all SQL statements that contain a specific text i.e. table name
			 WHERE  CONTAINS (SQL_TEXT, 'SELECT') 
			 ---- find all SQL statements that is an UPDATE and contains a specific table
			--  WHERE  CONTAINS (SQL_TEXT, '"INVENTDIM" AND "UPDATE "') 
			)
	SELECT TOP 100 *
	FROM   QUERY_HISTORY_VW QS -- Queries from last data collection only
		   INNER JOIN FT_CTE FT
				   ON QS.QUERY_HASH = FT.QUERY_HASH
	WHERE  1 = 1
		   --AND FLAG = 'M' --AND DATE = '2/1/2017'  -- 1ST DAY OF MONTH REPRESENTS THAT MONTH
		   AND FLAG = 'D' AND DATE = '2/20/2017'
	ORDER  BY TOTAL_ELAPSED_TIME DESC 




-- Show all queries who's avg is GREATER then then monthly avg for that query/plan

SELECT A.MONTHLY_AVG_TIME, A.DELTA_TIME, B.*
 FROM (
		SELECT TOP 100 QM.AVG_TIME_TODAY_MS AS MONTHLY_AVG_TIME,
					   QS.AVG_TIME_TODAY_MS  - QM.AVG_TIME_TODAY_MS AS DELTA_TIME,
					   QS.*
		FROM   QUERY_HISTORY QS -- Queries from last data collection only
			   INNER JOIN QUERY_HISTORY QM
					   ON QS.SERVER_NAME = QM.SERVER_NAME
					      AND QS.DATABASE_NAME = QM.DATABASE_NAME					   
						  AND QS.QUERY_HASH = QM.QUERY_HASH
						  AND QS.QUERY_PLAN_HASH = QM.QUERY_PLAN_HASH
						  AND QM.DATE = '2/1/2017'  -- Month to compare too
						  AND QM.FLAG = 'M'
						  AND QS.AVG_TIME_TODAY_MS > QM.AVG_TIME_TODAY_MS
		WHERE  QS.FLAG = 'D' AND QS.DATE = '2/5/2017'  --Day to review
		ORDER  BY QS.ELAPSED_TIME_TODAY DESC ) AS A
		CROSS APPLY( SELECT TOP 1 * FROM  QUERY_HISTORY_VW QHV WHERE A.SERVER_NAME = QHV.SERVER_NAME AND A.DATABASE_NAME = QHV.DATABASE_NAME 
		AND A.QUERY_HASH = QHV.QUERY_HASH AND A.QUERY_PLAN_HASH = QHV.QUERY_PLAN_HASH AND A.DATE = QHV.DATE AND A.FLAG = QHV.FLAG ) AS B

-- Show all queries who's avg is greater then previous month

SELECT A.MONTHLY_AVG_TIME, A.DELTA_TIME, B.*
 FROM (
		SELECT TOP 100 QM.AVG_TIME_TODAY_MS AS MONTHLY_AVG_TIME,
					   QS.AVG_TIME_TODAY_MS  - QM.AVG_TIME_TODAY_MS AS DELTA_TIME,
					   QS.*
		FROM   QUERY_HISTORY QS -- Queries from last data collection only
			   INNER JOIN QUERY_HISTORY QM
					   ON QS.SERVER_NAME = QM.SERVER_NAME
					      AND QS.DATABASE_NAME = QM.DATABASE_NAME					   
						  AND QS.QUERY_HASH = QM.QUERY_HASH
						  AND QS.QUERY_PLAN_HASH = QM.QUERY_PLAN_HASH
						  AND QM.DATE = '1/1/2017'  -- Previous Month to compare too
						  AND QM.FLAG = 'M'
						  AND QS.AVG_TIME_TODAY_MS > QM.AVG_TIME_TODAY_MS
		WHERE  QS.FLAG = 'M' AND QS.DATE = '2/1/2017'  --Current Month to compare to
		ORDER  BY QS.ELAPSED_TIME_TODAY DESC ) AS A
		CROSS APPLY( SELECT TOP 1 * FROM  QUERY_HISTORY_VW QHV WHERE A.SERVER_NAME = QHV.SERVER_NAME AND A.DATABASE_NAME = QHV.DATABASE_NAME 
		AND A.QUERY_HASH = QHV.QUERY_HASH AND A.QUERY_PLAN_HASH = QHV.QUERY_PLAN_HASH AND A.DATE = QHV.DATE AND A.FLAG = QHV.FLAG ) AS B

		

-- Show queries that have new plans this month


SELECT B.* FROM (
		SELECT TOP 100 QS.*
		FROM   QUERY_HISTORY QS -- Queries from last data collection only
			   LEFT JOIN QUERY_HISTORY QM
					  ON QS.SERVER_NAME = QM.SERVER_NAME
						 AND QS.DATABASE_NAME = QM.DATABASE_NAME
						 AND QS.QUERY_HASH = QM.QUERY_HASH
						 AND QS.QUERY_PLAN_HASH = QM.QUERY_PLAN_HASH
						 AND QM.DATE = '2/1/2017' -- Prior Month to compare too
						 AND QM.FLAG = 'M'
						 AND QS.AVG_TIME_TODAY_MS > QM.AVG_TIME_TODAY_MS
		WHERE  QS.FLAG = 'M' AND QS.DATE = '1/1/2017'--Current Month
			   AND QM.QUERY_HASH IS NULL			   
		ORDER  BY QS.ELAPSED_TIME_TODAY DESC ) AS A
		CROSS APPLY( SELECT TOP 1 * FROM  QUERY_HISTORY_VW QHV WHERE A.SERVER_NAME = QHV.SERVER_NAME AND A.DATABASE_NAME = QHV.DATABASE_NAME 
		AND A.QUERY_HASH = QHV.QUERY_HASH AND A.QUERY_PLAN_HASH = QHV.QUERY_PLAN_HASH AND A.DATE = QHV.DATE AND A.FLAG = QHV.FLAG ) AS B


----------------------------------------------------------------
--
--		EXPENSIVE_QUERIES_BY_LAST_COLLECTION
--
-- List top 100 most expensive queries
--
----------------------------------------------------------------

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

-- Data from QUERY_HISTORY tables

	SELECT TOP 100 *
	FROM   MISSING_INDEXES_HISTORY_VW
	WHERE  FLAG = 'M'
		   AND DATE = '2/1/2017'
		   AND NOT EXISTS (SELECT QUERY_HASH
						   FROM   COMMENTS C
						   WHERE  C.QUERY_HASH = MISSING_INDEXES_HISTORY_VW.QUERY_HASH) -- Remove queries that have comments
		   AND INDEX_IMPACT > 75
		   AND EXECUTION_COUNT > 100 --In Dev/Test/QA lower this value to 1
		   AND AVG_ELAPSED_TIME > 20
		   AND AVG_LOGICAL_READS > 1000
	ORDER  BY TOTAL_ELAPSED_TIME DESC 


-- Data from QUERY_STATS tables

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
                              + ' Date collected = ' + CAST(QH1.DATE_UPDATED AS VARCHAR(50))
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
                        MIN(AVG_TIME_TODAY_MS)  AS MIN_TIME,
                        MAX(AVG_TIME_TODAY_MS)  AS MAX_TIME
        FROM   QUERY_HISTORY QV
        WHERE  QV.FLAG = 'M'
               AND DATE = '2/1/2017'
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




