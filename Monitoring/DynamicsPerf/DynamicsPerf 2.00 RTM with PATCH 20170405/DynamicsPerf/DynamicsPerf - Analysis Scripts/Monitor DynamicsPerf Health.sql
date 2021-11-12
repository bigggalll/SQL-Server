USE [DynamicsPerf]
GO

/************************************************************************
Check the CAPTURE_LOG table for events
*************************************************************************/

SELECT * FROM CAPTURE_LOG 
WHERE TEXT LIKE '%FAILED%'
ORDER BY STATS_TIME DESC

		  
		  

/************************************************************************
Check the Databased to be collected
*************************************************************************/		  
		  
SELECT * FROM DATABASES_2_COLLECT	


/************************************************************************
Check the SSRS Report Servers to be collected
*************************************************************************/		  
		  
SELECT * FROM SSRS_CONFIG	



/************************************************************************
Check to see if AX Long running Trace functionality is setup
*************************************************************************/

SELECT * FROM AX_SQLTRACE_CONFIG


	  
/************************************************************************
Check when and how long tasks have been taking
*************************************************************************/

SELECT DTS.TASK_DESCRIPTION,
       DTH.*,
       DTS.*
FROM   DYNPERF_TASK_HISTORY DTH
       INNER JOIN DYNPERF_TASK_SCHEDULER DTS
               ON DTH.TASK_ID = DTS.TASK_ID
ORDER  BY DTH.TASK_ID 




