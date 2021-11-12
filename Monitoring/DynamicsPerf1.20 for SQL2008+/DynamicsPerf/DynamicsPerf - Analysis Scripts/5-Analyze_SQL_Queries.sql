/*********************************************************************
Copy one of the following links and press Ctrl-F and click FIND NEXT
in order to go to that section of the scripts

EXPENSIVE_QUERIES
MISSING_INDEX_QUERIES
QUERIES_WITH_MULTIPLE_EXECUTION_PLANS
QUERIES_SCANNING_TABLES


********************************************************************/

USE DynamicsPerf

----------------------------------------------------------------
--
--		EXPENSIVE_QUERIES
--
-- List top 100 most expensive queries
----------------------------------------------------------------


SELECT TOP 100 *
FROM   QUERY_STATS_CURR_VW QS -- Queries from last data collection only
--FROM   QUERY_STATS_VW QS -- Review queries for all data collections

WHERE
  1=1
  --Remove queries with comments
  AND NOT EXISTS (SELECT QUERY_HASH
              FROM   COMMENTS C
              WHERE  C.QUERY_HASH = QS.QUERY_HASH) -- Remove queries that have comments
-- AND  QUERY_HASH = 0x35DBB41368AFED7C -- find a specific query
-- SQL_TEXT LIKE '%SQL_TEXT_HERE%'  -- find all SQL statements that contain a specific text i.e. table name
-- AND QUERY_PLAN_TEXT LIKE '%VALUE%'  -- find all SQL Plans that contain a specific text i.e. index name
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


SELECT DATABASE_NAME,
       QUERY_HASH,
       (SELECT SQL_TEXT
        FROM   QUERY_TEXT QT
        WHERE  QT.QUERY_HASH = A.QUERY_HASH)      AS SQL_TEXT,
       COUNT(QUERY_PLAN_HASH)                     AS NO_OF_PLANS,
       (SELECT MIN(AVG_TIME_ms)
        FROM   QUERY_STATS QS1
        WHERE  QS1.DATABASE_NAME = A.DATABASE_NAME
               AND QS1.QUERY_HASH = A.QUERY_HASH) AS MIN_AVG_TIME,
       (SELECT MAX(AVG_TIME_ms)
        FROM   QUERY_STATS QS1
        WHERE  QS1.DATABASE_NAME = A.DATABASE_NAME
               AND QS1.QUERY_HASH = A.QUERY_HASH) AS MAX_AVG_TIME,
       STUFF ((SELECT DISTINCT ', '
                               + CONVERT(VARCHAR(64), QUERY_PLAN_HASH, 1)
                               + ' time(ms)= '
                               + CAST((SELECT MAX(AVG_TIME_ms) FROM QUERY_STATS QS2 WHERE QS2.DATABASE_NAME = QV1.DATABASE_NAME AND QS2.QUERY_HASH = QV1.QUERY_HASH AND QS2.QUERY_PLAN_HASH = QV1.QUERY_PLAN_HASH) AS VARCHAR(20))
               FROM   QUERY_STATS_VW QV1
               WHERE  QV1.QUERY_HASH = A.QUERY_HASH
                      AND QV1.DATABASE_NAME = A.DATABASE_NAME
               FOR xml path('')), 1, 1, '''')     AS QUERY_PLAN_HASH
FROM   (SELECT DISTINCT DATABASE_NAME,
                        QUERY_HASH,
                        QUERY_PLAN_HASH
        FROM   QUERY_STATS_VW QV) AS A
GROUP  BY DATABASE_NAME,
          QUERY_HASH
HAVING COUNT(QUERY_PLAN_HASH) > 1
ORDER  BY 6 DESC 



--Read the query plan from previous query
SELECT *
FROM   QUERY_PLANS
WHERE  QUERY_PLAN_HASH = 0X0000000000000 





----------------------------------------------------------------
--
--			QUERIES_SCANNING_TABLES  
--
-- Find queries scanning a table
----------------------------------------------------------------

SELECT TOP 100 *
FROM   QUERY_STATS_CURR_VW
WHERE  ( QUERY_PLAN_TEXT LIKE '%TABLE SCAN%'
          OR QUERY_PLAN_TEXT LIKE '%INDEX SCAN%' )
--AND QUERY_PLAN_TEXT LIKE '%<Table Name>%'  -- Comment this line to return all tables
ORDER  BY TOTAL_LOGICAL_READS DESC 



