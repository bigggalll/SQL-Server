CREATE VIEW [dbo].[INDEX_KEY_ORDER_VW]
AS
	 WITH CTE (SERVER_NAME, DATABASE_NAME, TABLENAME, INDEXNAME, ROWS, KEYCOLUMN, COLUMNS, PREV_COL)
       AS (SELECT IDV.SERVER_NAME,
                  IDV.DATABASE_NAME,
                  TABLENAME,
                  INDEXNAME,
                  Cast(1 / DENSITY AS BIGINT)                                        AS ROWS,
                  Replace(Replace(COLUMNS, Lag(COLUMNS, 1, '')
                                             OVER (
                                               PARTITION BY TABLENAME, INDEXNAME
                                               ORDER BY Len(COLUMNS)), ''), ',', '') AS KEYCOLUMN,
                  COLUMNS,
                  Lag(COLUMNS, 1, '')
                    OVER (
                      PARTITION BY TABLENAME, INDEXNAME
                      ORDER BY Len(COLUMNS))                                         AS PREV_COL
           FROM   INDEX_DENSITY_VECTOR IDV
                  INNER JOIN INDEX_STATS_CURR_VW CV
                          ON IDV.DATABASE_NAME = CV.DATABASE_NAME
                             AND IDV.TABLENAME = CV.TABLE_NAME
                             AND IDV.INDEXNAME = CV.INDEX_NAME
                             --WHERE  IDV.TABLENAME = 'INVENTTRANS'
                             AND Len(IDV.COLUMNS) <= Len(CV.INDEX_KEYS) --REH for places where SQL has added the clustered index columns to the density vector
                             AND INDEXNAME NOT LIKE '_wa%') --REH Auto Stats indexes
  SELECT SERVER_NAME,
         DATABASE_NAME,
         TABLENAME,
         INDEXNAME,
         ROWS,
         KEYCOLUMN,
         COLUMNS,
         CASE KEYCOLUMN
           WHEN 'PARTITION' THEN -2
           WHEN 'DATAAREAID' THEN -1
           ELSE Cast (ROWS - Lag(ROWS, 1, 0)
                               OVER (
                                 PARTITION BY TABLENAME, INDEXNAME
                                 ORDER BY Len(COLUMNS)) AS BIGINT)
         END AS TOTAL_ROWS
  FROM   CTE
--ORDER BY TABLENAME,INDEXNAME, TOTAL_ROWS DESC



GO


CREATE VIEW [dbo].[QUERY_STATS_CTE_VW]
	AS 
	
	

WITH CTE_STATS (SERVER_NAME, DATABASE_NAME, QUERY_HASH, QUERY_PLAN_HASH, CREATION_TIME, STATS_TIME, PREV_STATS_TIME, PREV_CREATION_TIME, PREV_ELAPSED_TIME, PREV_EXECUTION_COUNT, EXECUTION_COUNT, TOTAL_WORKER_TIME, TOTAL_ELAPSED_TIME, PREV_TOTAL_WORKER_TIME, TIME_THIS_PERIOD, WORKER_TIME_THIS_PERIOD, EXECUTIONS_THIS_PERIOD)
     AS (SELECT DISTINCT SERVER_NAME,
                         DATABASE_NAME,
                         QUERY_HASH,
                         QUERY_PLAN_HASH,
                         CREATION_TIME,
                         [STATS_TIME],
                         LAG(STATS_TIME, 1, 0)
                           OVER (
                             PARTITION BY SERVER_NAME, DATABASE_NAME, QUERY_HASH, QUERY_PLAN_HASH, CREATION_TIME
                             ORDER BY STATS_TIME )                      AS PREV_STATS_TIME,
                         LAG(CREATION_TIME, 1, 0)
                           OVER (
                             PARTITION BY SERVER_NAME, DATABASE_NAME, QUERY_HASH, QUERY_PLAN_HASH, CREATION_TIME
                             ORDER BY STATS_TIME )                      AS PREV_CREATION_TIME,
                         
                         LAG(TOTAL_ELAPSED_TIME, 1, 0)
                           OVER (
                             PARTITION BY SERVER_NAME, DATABASE_NAME, QUERY_HASH, QUERY_PLAN_HASH, CREATION_TIME
                             ORDER BY STATS_TIME )                      AS PREV_ELAPSED_TIME,
                         LAG(EXECUTION_COUNT, 1, 0)
                           OVER (
                             PARTITION BY SERVER_NAME, DATABASE_NAME, QUERY_HASH, QUERY_PLAN_HASH, CREATION_TIME
                             ORDER BY STATS_TIME )                      AS PREV_EXECUTION_COUNT,
                         EXECUTION_COUNT,
                         TOTAL_WORKER_TIME,
                         TOTAL_ELAPSED_TIME,
                         LAG(TOTAL_WORKER_TIME, 1, 0)
                           OVER (
                             PARTITION BY SERVER_NAME, DATABASE_NAME, QUERY_HASH, QUERY_PLAN_HASH, CREATION_TIME
                             ORDER BY STATS_TIME )                      AS PREV_TOTAL_WORKER_TIME,
                         TOTAL_ELAPSED_TIME - LAG(TOTAL_ELAPSED_TIME, 1, 0)
                                                OVER (
                                                  PARTITION BY SERVER_NAME, DATABASE_NAME, QUERY_HASH, QUERY_PLAN_HASH, CREATION_TIME
                                                  ORDER BY STATS_TIME ) AS TIME_THIS_PERIOD,
                         TOTAL_WORKER_TIME - LAG(TOTAL_WORKER_TIME, 1, 0)
                                               OVER (
                                                 PARTITION BY SERVER_NAME, DATABASE_NAME, QUERY_HASH, QUERY_PLAN_HASH, CREATION_TIME
                                                 ORDER BY STATS_TIME )  AS WORKER_TIME_THIS_PERIOD,
                         EXECUTION_COUNT - LAG(EXECUTION_COUNT, 1, 0)
                                             OVER (
                                               PARTITION BY SERVER_NAME, DATABASE_NAME, QUERY_HASH, QUERY_PLAN_HASH, CREATION_TIME
                                               ORDER BY STATS_TIME )    AS EXECUTIONS_THIS_PERIOD
         FROM   QUERY_STATS
         WHERE  QUERY_HASH <> 0x0000000000000000)
         
 SELECT * FROM CTE_STATS
