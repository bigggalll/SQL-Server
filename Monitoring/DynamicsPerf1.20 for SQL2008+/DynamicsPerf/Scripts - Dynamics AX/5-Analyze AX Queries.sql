
/*********************************************************************
Copy one of the following links and press Ctrl-F and click FIND NEXT
in order to go to that section of the scripts

AX_LONG_RUNNING_QUERY_TRACE
HIDDEN_SCANS_QUERIES
OPTION_FAST_QUERIES
USER_SCANS_QUERY


********************************************************************/


--
--			AX_LONG_RUNNING_QUERY_TRACE
--
-- --------------------------------------------------------------
-- Find long running queries from Dynamics AX with source code
-- requires client tracing being enabled on the AOS configuration
--
-- The AX Long running trace functionality must be enabled for 
-- ths table to populated.  Either run the DYNPERF_Set_AX_User_Trace_on
-- SQL Job or run the script in DynamicsAX Client Tracing.sql
-- 
--NOTE: Versions prior to AX2012 must enable AX client tracing on the AOS servers  

----------------------------------------------------------------
USE [DynamicsPerf]

SELECT TOP 100 [CREATED_DATETIME],[DATABASE_NAME],[ROW_NUM], [AX_USER_ID], [SQL_DURATION], [SQL_TEXT], [CALL_STACK], [TRACE_CATEGORY], [TRACE_EVENT_CODE], [TRACE_EVENT_DESC], [TRACE_EVENT_DETAILS], [CONNECTION_TYPE], [SQL_SESSION_ID], [AX_CONNECTION_ID], [IS_LOBS_INCLUDED], [IS_MORE_DATA_PENDING], [ROWS_AFFECTED], [ROW_SIZE], [ROWS_PER_FETCH], [IS_SELECTED_FOR_UPDATE], [IS_STARTED_WITHIN_TRANSACTION], [SQL_TYPE], [STATEMENT_ID], [STATEMENT_REUSE_COUNT], [DETAIL_TYPE], [STATS_TIME], [COMMENT]
FROM   [AX_SQLTRACE]
-- WHERE SQL_TEXT LIKE '%XXXXXXXXXXXXXXXX%'
ORDER  BY [CREATED_DATETIME] DESC 


--
--		HIDDEN_SCANS_QUERIES
--
-- --------------------------------------------------------------
-- Find Dynamics AX queries that only seek on DataAreaId
--  OR DataareadId and Partition 
-- NOT USEFUL for other products
-----------------------------------------------------------------


SELECT TOP 100 *
FROM   HIDDEN_SCANS_CURR_VW
ORDER  BY TOTAL_ELAPSED_TIME DESC 


--
--		OPTION_FAST_QUERIES
--
-------------------------------------------------------------------------
-- Find queries option(fast) set that have sort operations
--  Dynamics AX only query
--
-- Either we don't have an index to match the order by clause
--  or the query is potentially to complex for SQL to pick that index
--------------------------------------------------------------------------

SELECT TOP 100 *
FROM   QUERY_STATS_CURR_VW
WHERE  SQL_TEXT LIKE '%OPTION(FAST%'
       AND QUERY_PLAN_TEXT LIKE '%PhysicalOp="Sort"%'
ORDER  BY TOTAL_ELAPSED_TIME DESC 


--
--		USER_SCANS_QUERY
--
-- --------------------------------------------------------------
-- Find Dynamics queries that are scanning 
-----------------------------------------------------------------

SELECT TOP 100 *
FROM   USER_SCANS_CURR_VW
ORDER  BY TOTAL_ELAPSED_TIME DESC 

