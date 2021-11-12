/*********************************************************************
Copy one of the following links and press Ctrl-F and click FIND NEXT
in order to go to that section of the scripts

SSRS_REPORTS_USAGE
SSRS_ANALYSIS
SSRS_HISTORICAL_USAGE


********************************************************************/

-------------------------------------------------------------------------------------------
--
--		SSRS_REPORTS_USAGE
--
--		Show SSRS Reports usages by report
--
-- NOTE: If no data here then be sure that you've run SSRS setup part of installation
--		for DynamicsPerf
--------------------------------------------------------------------------------------------

USE [DynamicsPerf]
GO

-- By Report

		SELECT REPORTPATH,
			   COUNT(*)              AS EXECUTIONS,
			   MIN(TIME_DATARETRIEVAL + TIME_PROCESSING
				   + TIME_RENDERING) AS MIN_TIME,
			   MAX(TIME_DATARETRIEVAL + TIME_PROCESSING
				   + TIME_RENDERING) AS MAX_TIME,
			   AVG(TIME_DATARETRIEVAL + TIME_PROCESSING
				   + TIME_RENDERING) AS AVG_TIME
		FROM   SSRS_EXECUTIONLOG
		GROUP  BY REPORTPATH
		ORDER  BY REPORTPATH 




-- Report count by hour


		SELECT DATEADD(HOUR, DATEDIFF(HOUR, 0, TIMEEND), 0) AS TIME_OF_DAY,
			   COUNT(*)                                     AS COUNT_OF_REPORTS,
			   SUM(( TIME_DATARETRIEVAL + TIME_PROCESSING
					 + TIME_RENDERING )) / 60000            AS TOTAL_REPORT_TIME_MINS
		FROM   SSRS_EXECUTIONLOG
		GROUP  BY DATEADD(HOUR, DATEDIFF(HOUR, 0, TIMEEND), 0)
		ORDER  BY DATEADD(HOUR, DATEDIFF(HOUR, 0, TIMEEND), 0) DESC 





-- Report Execution Times by hour


		SELECT DATEADD(HOUR, DATEDIFF(HOUR, 0, TIMEEND), 0) AS TIME_OF_DAY,
			   REPORTPATH                                   AS REPORT,
			   COUNT(*)                                     AS COUNT_OF_REPORTS,
			   SUM(( TIME_DATARETRIEVAL + TIME_PROCESSING
					 + TIME_RENDERING )) / 1000             AS TOTAL_REPORT_TIME_SECS
		FROM   SSRS_EXECUTIONLOG
		GROUP  BY DATEADD(HOUR, DATEDIFF(HOUR, 0, TIMEEND), 0),
				  REPORTPATH
		ORDER  BY DATEADD(HOUR, DATEDIFF(HOUR, 0, TIMEEND), 0) DESC,
				  4 DESC 



----------------------------------------------------------------
--
--			SSRS_ANALYSIS 
--
-- Multiple queries for analyzing SSRS EXECUTIONLOG2 data
-- 
----------------------------------------------------------------

	SELECT TOP 100 SERVER_NAME,
                   REPORTPATH,
                   REPORTNAME              AS REPORT_NAME,
                   AVG(TIME_DATARETRIEVAL + TIME_PROCESSING
                       + TIME_RENDERING)   AS AVG_REPORT_TIME_MS,
                   MAX(TIME_DATARETRIEVAL + TIME_PROCESSING
                       + TIME_RENDERING)   AS MAX_REPORT_TIME_MS,
                   MIN(TIME_DATARETRIEVAL + TIME_PROCESSING
                       + TIME_RENDERING)   AS MIN_REPORT_TIME_MS,
                   AVG(TIME_DATARETRIEVAL) AS AVG_TIME_DATARETRIEVAL_MS,
                   MAX(TIME_DATARETRIEVAL) AS MAX_TIME_DATARETRIEVAL_MS,
                   MIN(TIME_DATARETRIEVAL) AS MIN_TIME_DATARETRIEVAL_MS,
                   AVG(TIME_PROCESSING)    AS AVG_TIME_PROCESSING_MS,
                   MAX(TIME_PROCESSING)    AS MAX_TIME_PROCESSING_MS,
                   MIN(TIME_PROCESSING)    AS MIN_TIME_PROCESSING_MS,
                   AVG(TIME_RENDERING)     AS TIME_RENDERING_MS,
                   COUNT(REPORTPATH)       AS EXECUTION_COUNT,
                   AVG(BYTECOUNT)          AS AVG_SIZE_BYTES,
                   AVG([ROWCOUNT])         AS AVG_ROW_COUNT
    FROM   SSRS_EXECUTIONLOG
    --WHERE SERVER_NAME = 'XXXXXXXXX'
    GROUP  BY SERVER_NAME,
              REPORTPATH,
              REPORTNAME
    ORDER  BY AVG_REPORT_TIME_MS DESC 
    



-- INVESTIGATE details of specific reports


		SELECT *
		FROM   SSRS_EXECUTIONLOG
		WHERE  SERVER_NAME = 'XXXXXX'
			   AND REPORTNAME = 'XXXXXXXX'
		ORDER  BY TIME_DATARETRIEVAL + TIME_PROCESSING
				  + TIME_RENDERING DESC 


-- FIND SSRS reports that finished in a specific time range 
--		too match up to data from QUERY_STATS
--		based on last_execution_time or compiled_time


		SELECT *
		FROM   SSRS_EXECUTIONLOG
		WHERE  TIMEEND BETWEEN 'XXXXXXXXXXX' AND 'XXXXXXXXXXXXXXX'
		ORDER  BY TIMEEND 



-------------------------------------------------------------------------------------------
--
--		SSRS_HISTORICAL_USAGE
--
--		Show SSRS Reports usages by report
--
-- NOTE: If no data here then be sure that you've run SSRS setup part of installation
--		for DynamicsPerf
--------------------------------------------------------------------------------------------

--Sorted by most time desc

SELECT *
		FROM   SSRS_HISTORY
		WHERE  SERVER_NAME = 'XXXXXX'
			   AND REPORT_NAME = 'XXXXXXXX'
			   --AND FLAG = 'D' AND REPORT_DATE = '1/18/2016'
			   --AND FLAG = 'M' AND REPORT_DATE = '1/1/2016'  -- MONTH RECORD IS ALWAYS 1ST DAY OF MONTH
		ORDER  BY TOTAL_TIME_DATA + TOTAL_TIME_PROCESSING
				  + TOTAL_TIME_RENDERING DESC 