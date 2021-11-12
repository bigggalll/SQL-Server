/*********************************************************************
Copy one of the following links and press Ctrl-F and click FIND NEXT
in order to go to that section of the scripts


QUERY_ALERTS_BY_TIME_DESC
QUERY_ALERTS_BY_QUERY_BY_COUNT
QUERY_ALERTS_BY_DAY
QUERY_ALERTS_BY_HOUR


********************************************************************/


--NOTE:  you must have configred the QUERY_ALERTS in Step 4 of the 
--			installation steps

SELECT * FROM QUERY_ALERTS_CONFIG


-- --------------------------------------------------------------
--
--			QUERY_ALERTS_BY_TIME_DESC
-- Query Alerts sorted by TIME desc
----------------------------------------------------------------

SELECT TOP 100 *
FROM   QUERY_ALERTS_VW QA
WHERE  1 = 1

--AND QA.SERVER_NAME = 'XXXXXXX'
--AND QA.DATABASE_NAME = 'XXXXXXX'
-- AND QA.SQL_TEXT LIKE '%VALUE%'

ORDER  BY QA.ALERT_TIME DESC 



-- --------------------------------------------------------------
--
--			QUERY_ALERTS_BY_QUERY_BY_COUNT
-- Query Alerts sorted by COUNT desc
----------------------------------------------------------------


SELECT SERVER_NAME,
       DATABASE_NAME,
       QUERY_HASH,
       QUERY_PLAN_HASH,
       COUNT(*)      AS NUM,
       MAX(SQL_TEXT) AS SQL_TEXT
FROM   QUERY_ALERTS_VW
GROUP  BY SERVER_NAME,
          DATABASE_NAME,
          QUERY_HASH,
          QUERY_PLAN_HASH
ORDER  BY COUNT(*) DESC 


-- --------------------------------------------------------------
--
--			QUERY_ALERTS_BY_DAY
-- Query Alerts sorted by TIME desc
----------------------------------------------------------------


SELECT DATEADD(day, DATEDIFF(day, 0, ALERT_TIME), 0) AS DATE,
       COUNT(*)                                      AS NUM
FROM   QUERY_ALERTS_VW
GROUP  BY DATEADD(day, DATEDIFF(day, 0, ALERT_TIME), 0)
ORDER  BY 1 DESC 


-- --------------------------------------------------------------
--
--			QUERY_ALERTS_BY_HOUR
-- Query Alerts sorted by TIME desc
----------------------------------------------------------------


SELECT DATEADD(HOUR, DATEDIFF(HOUR, 0, ALERT_TIME), 0) AS DATE,
       COUNT(*)                                      AS NUM
FROM   QUERY_ALERTS_VW
GROUP  BY DATEADD(HOUR, DATEDIFF(HOUR, 0, ALERT_TIME), 0)
ORDER  BY 1 DESC 
