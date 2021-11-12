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
SQL_VLFS
SQL_JOBS
SQL_LOGS
SQL_TRACE_FLAGS
SQL_TRIGGERS


********************************************************************/



-- --------------------------------------------------------------
--
--			SQLSERVER_INFO
-- SQL Server version, start time, cpu, memory, etc
----------------------------------------------------------------

USE DynamicsPerf

SELECT *
FROM   SERVERINFO
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


/*********************************************************************
--RUN this code in any database to get DB specific data cache information

SELECT	
  db.name, OBJ.NAME ,index_id ,
  COUNT(*)AS CACHED_PAGES_COUNT

FROM sys.dm_os_buffer_descriptors AS BD 
    INNER JOIN 
    (
        SELECT obj.name AS NAME 
            ,index_id ,ALLOCATION_UNIT_ID
        FROM sys.allocation_units AS AU
            INNER JOIN sys.partitions AS P 
			
                ON AU.CONTAINER_ID = P.HOBT_ID 
                    AND (AU.type = 1 OR AU.type = 3)
			INNER JOIN sys.sysobjects AS obj
				 on obj.id = P.object_id
        UNION ALL
        SELECT obj.name AS NAME   
            ,index_id, ALLOCATION_UNIT_ID
        FROM sys.allocation_units as AU
            INNER JOIN sys.partitions AS P 
                ON AU.CONTAINER_ID = P.PARTITION_ID 
                    AND AU.type = 2
			INNER JOIN sys.sysobjects AS obj
				 on obj.id = P.object_id
    ) AS OBJ 
        ON BD.allocation_unit_id = OBJ.ALLOCATION_UNIT_ID
    INNER JOIN sys.databases db ON BD.database_id = db.database_id
WHERE db.name = DB_NAME() and db.state_desc = 'ONLINE'
GROUP BY db.database_id,db.name, OBJ.NAME, index_id
ORDER BY 4 DESC,db.database_id,db.name, OBJ.NAME, index_id

*********************************************************************/

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
-- Is there 1 TempDb file per CPU core 
----------------------------------------------------------------

SELECT *
FROM   SQL_DATABASEFILES_CURR_VW

-- --------------------------------------------------------------
--
--			SQL_VLFS
--
-- Investigate Virtual Log files for each database LOG file
--  VLF_Count > 10k requires attention
----------------------------------------------------------------

SELECT DATABASE_NAME,FILEID, 
COUNT(*) AS VLF_COUNT,
SUM(CASE WHEN STATUS = 0 THEN 1 ELSE 0 END) AS FREE, 
SUM(CASE WHEN STATUS != 0 THEN 1 ELSE 0 END) AS INUSE 
FROM LOGINFO
GROUP BY DATABASE_NAME,FILEID 
ORDER BY DATABASE_NAME,FILEID

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

-- --------------------------------------------------------------

--
--			SQL_TRACE_FLAGS
--
-- Investigate SQL Trace Flags that are configured


--  Recommended Trace Flags
--		1117 - Evenly grow database files
--		1224 - Override lock escalation, only enable on large memory systems
--		2371 - SQL 2008 R2 SP1 and later, auto-update statistics occurs more frequently
--		4199 - Enable all optimizer changes implmented since RTM, should almost always have this on

--  Informational Trace flags
--		1118 - Eliminate Mixed Extents (can increase performance at expense of disk space)
--		7646 - Trace Flag to reduce contention on Fulltext indexes 

-- NEVER turn on Trace Flags
--		4136 - Causes SQL Optimizer to use Density Vector instead of Histogram

----------------------------------------------------------------

SELECT *
FROM   TRACEFLAGS 
WHERE STATS_TIME = (SELECT MAX(STATS_TIME) FROM TRACEFLAGS)


-- -------------------------------------------------------------------
--
--			SQL_TRIGGERS
--
-- Investigate Database Triggers
-- Are there any custom triggers that could cause performance issues

---------------------------------------------------------------------

SELECT * FROM TRIGGER_TABLE




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









