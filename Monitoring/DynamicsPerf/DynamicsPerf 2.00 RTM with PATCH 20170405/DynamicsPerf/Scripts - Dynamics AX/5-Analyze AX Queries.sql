
/*********************************************************************
Copy one of the following links and press Ctrl-F and click FIND NEXT
in order to go to that section of the scripts

AX_LONG_RUNNING_QUERY_TRACE
HIDDEN_SCANS_QUERIES
OPTION_FAST_QUERIES
FIND_QUERY_HASH


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


SELECT TOP 100 [CREATED_DATETIME],[DATABASE_NAME],[ROW_NUM], [AX_USER_ID], [SQL_DURATION], [SQL_TEXT], [CALL_STACK], [QUERY_HASH], [TRACE_CATEGORY], [TRACE_EVENT_CODE], [TRACE_EVENT_DESC], [TRACE_EVENT_DETAILS], [CONNECTION_TYPE], [SQL_SESSION_ID], [AX_CONNECTION_ID], [IS_LOBS_INCLUDED], [IS_MORE_DATA_PENDING], [ROWS_AFFECTED], [ROW_SIZE], [ROWS_PER_FETCH], [IS_SELECTED_FOR_UPDATE], [IS_STARTED_WITHIN_TRANSACTION], [SQL_TYPE], [STATEMENT_ID], [STATEMENT_REUSE_COUNT], [DETAIL_TYPE], [STATS_TIME], [COMMENT]
FROM   [AX_SQLTRACE]
-- WHERE SQL_TEXT LIKE '%XXXXXXXXXXXXXXXX%'
-- WHERE CONTAINS(SQL_TEXT, 'SELECT')
ORDER  BY [CREATED_DATETIME] DESC 



--list expensive queries grouped by SQL text and call stack:

SELECT TOP 25 SQL_TEXT,
              CAST(CALL_STACK AS NVARCHAR(4000)) AS CALL_STACK,
              COUNT(SQL_TEXT)                    AS EXECUTION_COUNT,
              AVG(SQL_DURATION)                  AS AVG_DURATION_MS,
              AVG(ROWS_AFFECTED)                 AS AVG_ROWS_AFFECTED
	FROM   AX_SQLTRACE_VW
	--WHERE CREATED_DATETIME > = '20150101'
	GROUP  BY SQL_TEXT,
			  CAST(CALL_STACK AS NVARCHAR(4000))
	ORDER  BY 4 DESC 


--get an overview how frequently expensive queries are being logged by day and hour:

SELECT CONVERT(NVARCHAR, CREATED_DATETIME, 101) AS [CREATED DATE],
       DATEPART (hh, CREATED_DATETIME)          AS [HOUR OF DAY],
       COUNT (CREATED_DATETIME)                 AS [EXECUTION COUNT],
       SUM (SQL_DURATION)                       AS [TOTAL DURATION (milliseconds)],
       AVG (SQL_DURATION)                       AS [AVERAGE DURATION (milliseconds)]
FROM   AX_SQLTRACE_VW
WHERE  SQL_DURATION > 1000
-- AND CREATED_DATETIME > = '20170201'
GROUP  BY CONVERT(NVARCHAR, CREATED_DATETIME, 101),
          DATEPART (hh, CREATED_DATETIME)
ORDER  BY [CREATED DATE],
          [HOUR OF DAY] 
 


--get an overview of expensive queries by user id.

SELECT AX_USER_ID,
       COUNT (AX_USER_ID) AS EXECUTION_COUNT,
       AVG(SQL_DURATION)  AS AVG_DURATION_MS,
       SUM(SQL_DURATION)  AS TOTAL_DURATION_MS
FROM   AX_SQLTRACE
--WHERE CREATED_DATETIME > = '20170201'
GROUP  BY AX_USER_ID
ORDER  BY TOTAL_DURATION_MS DESC 






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

--;WITH FT_CTE2 (QUERY_PLAN_HASH)
--AS

--(
--    SELECT QUERY_PLAN_HASH
--    FROM QUERY_PLANS
--	WHERE CONTAINS (C_QUERY_PLAN, '%PhysicalOp="Sort"%')  -- find all SQL statements that contain a specific index 
--    AND CONTAINS (C_QUERY_PLAN, '%OPTION(FAST%')
--)

SELECT TOP 100 *
FROM   QUERY_STATS_CURR_VW QS
-- INNER JOIN FT_CTE2 FT2 ON QS.QUERY_PLAN_HASH = FT2.QUERY_PLAN_HASH
WHERE  QS.SQL_TEXT LIKE '%OPTION(FAST%'
       AND QS.QUERY_PLAN_TEXT LIKE '%PhysicalOp="Sort"%'
ORDER  BY QS.TOTAL_ELAPSED_TIME DESC 




/*************************************************************
		FIND_QUERY_HASH

Find query hash from Trace Parser Query
**************************************************************/

SET QUOTED_IDENTIFIER OFF

CREATE TABLE #STMT (SQL_TEXT NVARCHAR(max) COLLATE database_default)

INSERT #STMT VALUES("SELECT SUM(T1.ACCOUNTINGCURRENCYAMOUNT) FROM GENERALJOURNALACCOUNTENTRY T1 CROSS JOIN GENERALJOURNALENTRY T2 WHERE (T1.PARTITION=?) AND ((T2.PARTITION=?) AND ((((T2.POSTINGLAYER=?) AND (T2.LEDGER=?)) AND ((T2.ACCOUNTINGDATE>=?) AND (T2.ACCOUNTINGDATE<=?))) AND (T1.GENERALJOURNALENTRY=T2.RECID))) AND (EXISTS (SELECT 'x' FROM DIMENSIONATTRIBUTELEVELVALUEVIEW T3 WHERE ((((T3.PARTITION=?) AND (T3.PARTITION#2=?)) AND (T3.PARTITION#3=?)) AND (((T3.DIMENSIONATTRIBUTE=?) AND (T3.DISPLAYVALUE=?)) AND (T1.LEDGERDIMENSION=T3.VALUECOMBINATIONRECID))))) AND (EXISTS (SELECT 'x' FROM DIMENSIONATTRIBUTELEVELVALUEVIEW T4 WHERE ((((T4.PARTITION=?) AND (T4.PARTITION#2=?)) AND (T4.PARTITION#3=?)) AND (((T4.DIMENSIONATTRIBUTE=?) AND (T4.DISPLAYVALUE=?)) AND (T1.LEDGERDIMENSION=T4.VALUECOMBINATIONRECID))))) AND (EXISTS (SELECT 'x' FROM DIMENSIONATTRIBUTELEVELVALUEVIEW T5 WHERE ((((T5.PARTITION=?) AND (T5.PARTITION#2=?)) AND (T5.PARTITION#3=?)) AND (((T5.DIMENSIONATTRIBUTE=?) AND (T5.DISPLAYVALUE=?)) AND (T1.LEDGERDIMENSION=T5.VALUECOMBINATIONRECID)))))" )



SELECT QUERY_HASH FROM QUERY_TEXT QT , #STMT S WHERE QT.SQL_TEXT LIKE REPLACE(S.SQL_TEXT,'?','%')

DROP TABLE #STMT