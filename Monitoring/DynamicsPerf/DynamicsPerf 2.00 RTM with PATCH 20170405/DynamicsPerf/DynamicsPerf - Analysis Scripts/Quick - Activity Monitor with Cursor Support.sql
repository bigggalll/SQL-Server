/* This is a current activity query used to identify what processes are 
   currently running on the processors.  Use this query to find what user
   is running a large report or process and consuming system resources.  This 
   is a snapshot view of current activity.  You should execute the query several times
   to identify if a query is increasing it's I/O or CPU time.    
   
   explanation of TempDb usage columns:  http://technet.microsoft.com/en-us/library/ms190288.aspx
   
*/


--		NOTE:		RUN ALL QUERIES AT THE SAME TIME



USE DynamicsPerf

--*****************  CURRENTLY EXECUTING SQL STATEMENTS ***********************
-- Use this script to display queries currently executiing on the CPUs

EXEC DYNPERF_SERVER_ACTIVITY 
	/**** THIS IS FOR REMOTE SERVER AND NO AX DATABASE *****/
--@SERVER_NAME = 'MY_REMOTE_SERVER'

	/**** THIS IS FOR REMOTE SERVER AND AX DATABASE *****/
--@SERVER_NAME = 'MY_REMOTE_SERVER' ,@AX_DATABASE_NAME = 'MY_AX_DATABASENAME' '
	/**** THIS IS FOR LOCAL SERVER AND AX DATABASE *****/
--@AX_DATABASE_NAME = 'MY_AX_DATABASENAME' 



------------------------------------------------------------------------------------------------
--
--   SQL Server Performance Counters for last 30 minutes
--
------------------------------------------------------------------------------------------------


SELECT *
FROM   PERF_COUNTER_VW
WHERE  STATS_TIME > DATEADD(MI, -30, GETDATE())
ORDER  BY STATS_TIME DESC,
          OBJECT_NAME 
