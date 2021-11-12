/*********************************************************************
Copy one of the following links and press Ctrl-F and click FIND NEXT
in order to go to that section of the scripts

SQLTRACE_BLOCKING
OPTIONAL_BLOCKING_QUERIES


********************************************************************/






/*****************  SQLTRACE_BLOCKING **********************************
* 
*
*  NOTE:DYNPERF_Default_Trace_Start Job MUST be setup and running
*
*
**************************************************************************/


USE [DynamicsPerf]

/********* This view reads the Trace files direct 
***   from the @PATH parameter on the DYNPERF_Default_Trace_Start job  *******/


SELECT *
FROM   [BLOCKED_PROCESS_VW]
ORDER  BY END_TIME DESC 




--Run in the database to find a key lock

USE DYNAMICSDB   --<-----------------PUT YOUR DBNAME HERE
GO

SELECT o.NAME,
       i.NAME
FROM   sys.partitions p
       JOIN sys.objects o
         ON p.object_id = o.object_id
       JOIN sys.indexes i
         ON p.object_id = i.object_id
            AND p.index_id = i.index_id
WHERE  p.hobt_id = 72057709223149568  -- key: 15:72057709223149568(aldk9nn887)  as example


--Run in the database to find an object lock

USE DYNAMICSDB   --<-----------------PUT YOUR DBNAME HERE
GO

SELECT o.name,
       i.name
FROM   sys.partitions p
       JOIN sys.objects o
         ON p.object_id = o.object_id
       JOIN sys.indexes i
         ON p.object_id = i.object_id
            AND p.index_id = i.index_id
WHERE  o.object_id = 72057709223149568 -- object: 15:72057709223149568  as example


--Summarize blocks by resource

SELECT WAIT_RESOURCE,
       COUNT(WAIT_RESOURCE)
FROM   (SELECT WAIT_RESOURCE
        FROM   [BLOCKED_PROCESS_VW]) AS A
GROUP  BY WAIT_RESOURCE
ORDER  BY 2 DESC 



/******** Read the trace directly  *************/

SELECT E.NAME,
       F.*
--FROM fn_trace_gettable('C:\SQLTRACE\DYNAMICS_DEFAULT.trc', DEFAULT) F,
--sys.trace_events EXECUTE 
FROM   FN_TRACE_GETTABLE(ISNULL((SELECT TRACE_FULL_PATH_NAME
                                 FROM   DYNAMICSPERF_SETUP), (SELECT TOP 1 path
                                                              FROM   sys.traces
                                                              WHERE  path LIKE '%DYNAMICS_DEFAULT%')), DEFAULT) F,
       sys.trace_events E
WHERE  EventClass = trace_event_id
ORDER  BY StartTime DESC 

      
      


/**********************************************************************************************************
*
*		OPTIONAL_BLOCKING_QUERIES
*
*  NOTE: The DYNPERF_Optional_Polling_for_Blocking must be run for any of the following queries to 
*			have data.  This job is not intended to run full time but only optionally when more 
*			information is needed for api_cursorfetch sql statements in blocking conditions.
*
*
*
**********************************************************************************************************/




USE [DynamicsPerf]

/*************************************************************************
Find all lead blockers with a wait time > 2 seconds from most recent to oldest
*************************************************************************/

SELECT *
FROM   BLOCKS_VW
WHERE  BLOCKER_STATUS = 'Lead Blocker'
       AND WAIT_TIME > 2000
ORDER  BY BLOCKED_DTTM DESC


/*************************************************************************
Find all lead blockers from most recent to oldest
*************************************************************************/

SELECT *
FROM   BLOCKS_VW
--WHERE  BLOCKER_STATUS = 'Lead Blocker'
ORDER  BY BLOCKED_DTTM DESC



/*************************************************************************
Find all lead blockers with a wait time > 2 seconds on a specific date
  from most recent to oldest
*************************************************************************/

SELECT *
FROM   BLOCKS_VW
WHERE  BLOCKER_STATUS = 'Lead Blocker'
       AND WAIT_TIME > 2000
       AND BLOCKED_DTTM BETWEEN '5/20/2008' AND '5/21/2008'
ORDER  BY BLOCKED_DTTM DESC

/*************************************************************************
  Which applications are the Lead Blocker the most
  
*************************************************************************/

SELECT BLOCKER_PROGRAM,
       COUNT(*) AS NUMBER
FROM   BLOCKS_VW
WHERE  BLOCKER_STATUS = 'Lead Blocker'
GROUP  BY BLOCKER_PROGRAM
ORDER  BY NUMBER DESC

/*************************************************************************
  Which applications are Blocked the most
  
*************************************************************************/

SELECT BLOCKED_PROGRAM,
       COUNT(*) AS NUMBER
FROM   BLOCKS_VW
GROUP  BY BLOCKED_PROGRAM
ORDER  BY NUMBER DESC

/*************************************************************************
  Which applications are causing the most waiting
  
*************************************************************************/

SELECT BLOCKER_PROGRAM,
       SUM(WAIT_TIME) AS WAITTIME
FROM   BLOCKS_VW
GROUP  BY BLOCKER_PROGRAM
ORDER  BY WAITTIME DESC

/*************************************************************************
  Which applications are waiting the most 
  
*************************************************************************/

SELECT BLOCKED_PROGRAM,
       SUM(WAIT_TIME) AS WAITTIME
FROM   BLOCKS_VW
GROUP  BY BLOCKED_PROGRAM
ORDER  BY WAITTIME DESC

/*************************************************************************
  Which objects are waiting the most 
  
*************************************************************************/

SELECT OBJECT_NAME,
       SUM(WAIT_TIME) AS WAITTIME
FROM   BLOCKS_VW
GROUP  BY OBJECT_NAME
ORDER  BY WAITTIME DESC

/*************************************************************************
  Which databases are waiting the most 
  
*************************************************************************/

SELECT DATABASE_NAME,
       SUM(WAIT_TIME) AS WAITTIME
FROM   BLOCKS_VW
GROUP  BY DATABASE_NAME
ORDER  BY WAITTIME DESC


