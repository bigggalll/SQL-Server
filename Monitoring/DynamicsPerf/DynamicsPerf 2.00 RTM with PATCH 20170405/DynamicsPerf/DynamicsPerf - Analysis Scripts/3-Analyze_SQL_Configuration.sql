/*********************************************************************
Copy one of the following links and press Ctrl-F and click FIND NEXT
in order to go to that section of the scripts


SQLSERVER_INFO
WINDOWS_VERSION
SQL_SERVICES
DISK_VOLUMES
SQL_REGISTRY
SQL_CONFIGURATION
DATA_BUFFER_CACHE
SQL_DATABASES
SQL_DATABASEFILES
MAX_TEMPDB_SIZE
LOGFILE_BIGGER_THAN_DATABASE
SQL_VLFS
SQL_JOBS
SQL_LOGS
SQL_TRACE_FLAGS
SQL_TRIGGERS
SQL_RECORD_SIZES
CHANGE_DATA_TRACKING
CHANGE_DATA_CONTROL
SQL_REPLICATION
SQL_PLAN_GUIDES


********************************************************************/



-- --------------------------------------------------------------
--
--			SQLSERVER_INFO
-- SQL Server version, start time, cpu, memory, etc
----------------------------------------------------------------

USE DynamicsPerf

SELECT *
FROM   SERVERINFO_CURR_VW
ORDER  BY STATS_TIME DESC 


-- --------------------------------------------------------------
--
--				WINDOWS_VERSION
--
-- Windows version information for this SQL Server instance
--		Current Service Pack?
-- NOTE: This will be blank if not SQL Server 2008R2 SP1 or later
----------------------------------------------------------------

SELECT *
FROM   SERVER_OS_VERSION_VW

-- --------------------------------------------------------------
--
--		SQL_SERVICES
--
-- SQL Server Services 
--		What account are the services running under?
-- NOTE: This will be blank if not SQL Server 2008R2 SP1 or later
----------------------------------------------------------------


SELECT servicename,
       startup_type_desc,
       status_desc,
       process_id,
       last_startup_time,
       service_account,
       is_clustered
FROM   sys.dm_server_services; 


-- --------------------------------------------------------------
--
--			DISK_VOLUMES
--
-- SQL Server Disk Volumes information for all drives that 
-- has a database located on it.  
-- Is free disk space low?
-- NOTE: This will be blank if not SQL Server 2008R2 SP1 or later
----------------------------------------------------------------

SELECT *
FROM   SERVER_DISKVOLUMES

-- --------------------------------------------------------------
--
--		SQL_REGISTRY
--
-- SQL Server Registry values
--		What Trace flags are set?
-- NOTE: This will be blank if not SQL Server 2008R2 SP1 or later
----------------------------------------------------------------

SELECT *
FROM   SERVER_REGISTRY
WHERE VALUE_NAME LIKE 'SQLArg%'

-- --------------------------------------------------------------
--
--			SQL_CONFIGURATION
--
-- SQL configuation issues
-- 1. Max Degree of Parallelism set to 1 ?
-- 2- Is %fillfactor 0  ?
-- 3- Is Max Server Memory set to something less than total server memory?
-----------------------------------------------------------------

SELECT *
FROM   SQL_CONFIGURATION_CURR_VW

-- --------------------------------------------------------------
--
--		DATA_BUFFER_CACHE
--
--   Data Buffer Cache
-- 1. Which database is consuming the largest amount of data cache ?
--      a-are we capturing perf data on that database?
----------------------------------------------------------------
-- By Database

SELECT *
FROM   BUFFER_DETAIL_CURR_VW
ORDER  BY SIZE_MB DESC 


-- --------------------------------------------------------------
--
--			SQL_DATABASES
--
-- Investigate databases on this SQL instance
--  
-- Are there multiple Dynamics production databases AX and CRM as an example
-- Is development or test databases on this SQL instance
----------------------------------------------------------------

SELECT *
FROM   SQL_DATABASES_CURR_VW

-- --------------------------------------------------------------
--
--		SQL_DATABASEFILES
--
-- Investigate database files
--  
-- Are the data and log files on the same drive
-- Is the database set to auto-grow
-- Is TempDb on a dedicated drive
-- Is there 1 TempDb file per CPU core up to  a max of 8
----------------------------------------------------------------

SELECT *
FROM   SQL_DATABASEFILES_CURR_VW


-- --------------------------------------------------------------
--
--		MAX_TEMPDB_SIZE
--
-- initial size for Tempdb should be close to this value or 
-- a minimum of 25% of the sum of all database sizes on the instance
-- 
----------------------------------------------------------------


SELECT SERVER_NAME,FILE_NAME,
       MAX([DB_SIZE(MB)]) AS MAX_SIZE
FROM   SQL_DATABASEFILES_CURR_VW
WHERE  DATABASE_NAME = 'tempdb'
GROUP  BY SERVER_NAME, FILE_NAME 



-- --------------------------------------------------------------
--
--		LOGFILE_BIGGER_THAN_DATABASE
--
-- Transaction log file is 50% or more of actual database size
-- Are Transaction Log backups setup?
--
----------------------------------------------------------------

SELECT SERVER_NAME,DATABASE_NAME,
       SUM([DB_SIZE(MB)]) AS SIZE
FROM   SQL_DATABASEFILES_CURR_VW V1
WHERE  FILE_TYPE = 'Data'
GROUP  BY SERVER_NAME,DATABASE_NAME
HAVING SUM([DB_SIZE(MB)]) / (SELECT DBSIZE
                             FROM   (SELECT DATABASE_NAME,
                                            SUM([DB_SIZE(MB)]) AS DBSIZE
                                     FROM   SQL_DATABASEFILES_CURR_VW V2
                                     WHERE  FILE_TYPE = 'Log'
                                            AND V1.DATABASE_NAME = V2.DATABASE_NAME
                                            AND V1.SERVER_NAME = V2.SERVER_NAME
                                     GROUP  BY DATABASE_NAME)AS ACTIVITY_MONITOR_VW) < 2 



-- --------------------------------------------------------------
--
--			SQL_VLFS
--
-- Investigate Virtual Log files for each database LOG file
--  VLF_Count > 10k requires attention
----------------------------------------------------------------

SELECT SERVER_NAME,
       DATABASE_NAME,
       FILEID,
       VLF_COUNT,
       FREE,
       INUSE
FROM   LOGINFO LI
WHERE  LI.STATS_TIME = (SELECT MAX(STATS_TIME)
                        FROM   LOGINFO L2
                        WHERE  L2.DATABASE_NAME = LI.DATABASE_NAME
                               AND L2.FILEID = LI.FILEID
                               AND L2.SERVER_NAME = LI.SERVER_NAME)
ORDER  BY SERVER_NAME,
          DATABASE_NAME,
          FILEID 





-- --------------------------------------------------------------
--
--			SQL_JOBS
--
-- Investigate SQL Jobs
--  
-- Is there a database backup job
-- Is there a database maintenance job to update statistics daily
-- Is there a database maintenance job to rebuild indexes weekly
-- Are there jobs that could stress the server
----------------------------------------------------------------

SELECT *
FROM   SQL_JOBS_CURR_VW

-- --------------------------------------------------------------
--
--		SQL_LOGS
--
-- Investigate SQL Error LOG
--  
-- Are there any failed entries?
--
--  NOTE:  If no data in this table, you need to install latest
--         SQL Server cumulative update
----------------------------------------------------------------

SELECT *
FROM   SQLErrorLog
WHERE  LOGTEXT LIKE '%error%' 
-- AND SERVER_NAME = 'XXXXXXXX'

-- --------------------------------------------------------------

--
--			SQL_TRACE_FLAGS
--
-- Investigate SQL Trace Flags that are configured


--  Recommended Trace Flags
--		1117 - Evenly grow database files
--		1224 - Override lock escalation, only enable on large memory systems
--		2371 - SQL 2008 R2 SP1 and later, auto-update statistics occurs more frequently
--		4139 - SQL 2012 SP1 CU1 and later, moves last data point in index_histogram
--		4199 - Enable all optimizer changes implmented since RTM, should almost always have this on

--  Informational Trace flags
--		1118 - Eliminate Mixed Extents (can increase performance at expense of disk space)
--		7646 - Trace Flag to reduce contention on Fulltext indexes 

-- NEVER turn on Trace Flags
--		4136 - Causes SQL Optimizer to use Density Vector instead of Histogram

----------------------------------------------------------------


;WITH MAX_STATS_CTE (SERVER_NAME, STATS_TIME)
     AS (SELECT SERVER_NAME,
                MAX(STATS_TIME)
         FROM   TRACEFLAGS
         GROUP  BY SERVER_NAME)
SELECT TF.*
FROM   TRACEFLAGS TF
       INNER JOIN MAX_STATS_CTE CTE
               ON TF.SERVER_NAME = CTE.SERVER_NAME
                  AND TF.STATS_TIME = CTE.STATS_TIME 





-- -------------------------------------------------------------------
--
--			SQL_TRIGGERS
--
-- Investigate Database Triggers
-- Are there any custom triggers that could cause performance issues

---------------------------------------------------------------------

SELECT * FROM TRIGGER_TABLE



-- -------------------------------------------------------------------
--
--			SQL_RECORD_SIZES
--
-- Investigate Database Record legnth sizes
-- Are there any tables too wide?

---------------------------------------------------------------------


SELECT DSO.RUN_NAME, DSO.DATABASE_NAME,
       DSO.NAME AS TABLE_NAME,
       DSI.NAME AS INDEX_NAME,
       DSI.MAX_ROW_SIZE,
       DSI.MAX_LOB_SIZE
FROM   DYNSYSINDEXES DSI
       INNER JOIN DYNSYSOBJECTS DSO
               ON DSI.OBJECT_ID = DSO.OBJECT_ID
--WHERE DATABASE_NAME = 'XXXXXXXXXX'
ORDER  BY 1,2,5 DESC




-- -------------------------------------------------------------------
--
--			CHANGE_DATA_TRACKING
--
-- Investigate Database with Change Data Tracking enabled
-- 

---------------------------------------------------------------------



SELECT *
FROM   SQL_CHANGETRACKING_DBS
ORDER  BY SERVER_NAME



SELECT *
FROM   SQL_CHANGETRACKING_TABLES
ORDER  BY SERVER_NAME,
          DATABASE_NAME 



-- -------------------------------------------------------------------
--
--			CHANGE_DATA_CONTROL
--
-- Investigate Database with Change Data Control enabled
-- 

---------------------------------------------------------------------


SELECT *
FROM   CDC
ORDER  BY SERVER_NAME,
          DATABASE_NAME,
          SOURCE_TABLE 


-- -------------------------------------------------------------------
--
--			SQL_REPLICATION
--
-- Investigate any SQL Replication
--
--  Are we replicating high transaction volume tables?
-- 

---------------------------------------------------------------------


SELECT * FROM SQL_REPLICATION



-- -------------------------------------------------------------------
--
--			SQL_PLAN_GUIDES
--
-- Investigate any SQL PLAN GUIDES
--
---------------------------------------------------------------------


SELECT * FROM SQL_PLAN_GUIDES SP1
WHERE STATS_TIME IN (SELECT MAX(STATS_TIME) FROM SQL_PLAN_GUIDES SP2 WHERE
SP1.SERVER_NAME = SP2.SERVER_NAME AND SP1.DATABASE_NAME = SP2.DATABASE_NAME)

--WHERE SERVER_NAME = 'XXXXXX' AND DATABASE_NAME = 'XXXXXXX'



-- --------------------------------------------------------------
--
-- Run the following from a command line on the SQL Server
--		Bytes per Cluster should be 64k
--
--		fsutil fsinfo ntfsinfo f:
--
-- Run the following from a command line on the SQL Server
--
--
--  WMIC /OUTPUT:C:\SQLTRACE\PARTALIGN.html PARTITION GET DeviceID, StartingOffset /FORMAT:htable
--
----------------------------------------------------------------









