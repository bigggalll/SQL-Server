
/*********************************************************************
Copy one of the following links and press Ctrl-F and click FIND NEXT
in order to go to that section of the scripts

INDEXES_BY_SIZE
INDEX_SIZE_BY_CONFIG
INDEX_ACTIVITY
INDEX_ACTIVITY_WITH_CACHE_LOOKUP
AX_INDEXES_BEING_LOCKED
INDEX_ACTIVITY_BY_CONFIG_KEY
INCLUDED_COLUMN_INDEXES
INDEXES_IN_DB_NOT_IN_AOT
INDEXES_WITH_RECVERSION
TABLES_WITHOUT_CLUSTERED_INDEX_AX
TABLES_WITHOUT_UNIQUE_INDEX


********************************************************************/



-- --------------------------------------------------------------
--
--			INDEXES_BY_SIZE
--
-- List top 100 Largest Tables, Investigate for data retention 
-- purposes or incorrect application configuration such as logging
--
----------------------------------------------------------------

USE DynamicsPerf

SELECT TOP 100 ISV.DATABASE_NAME,
               ISV.TABLE_NAME,
			   ATD.APPLAYER,
			   ATD.OCC_ENABLED,
			   ATD.CACHE_LOOKUP,
               SUM(CASE
                     WHEN ISV.INDEX_ID IN (0,1)  THEN PAGE_COUNT * 8 / 1024
                   END)   AS SIZEMB_DATA,
               SUM(CASE
                     WHEN ISV.INDEX_ID > 1 THEN PAGE_COUNT * 8 / 1024
                   END)   AS SIZEMB_INDEXES,
               COUNT(CASE
                       WHEN ISV.INDEX_ID > 1 THEN ISV.TABLE_NAME
                     END) AS NO_OF_INDEXES,
               MAX(CASE
                     WHEN ( DATA_COMPRESSION > 0 )
                          AND ( ISV.INDEX_ID IN (0,1)  ) THEN 'Y'
                     ELSE 'N'
                   END)   AS DATA_COMPRESSED,
               MAX(CASE
                     WHEN ( DATA_COMPRESSION > 0 )
                          AND ( ISV.INDEX_ID > 1) THEN 'Y'
                     ELSE 'N'
                   END)   AS INDEXES_COMPRESSED
FROM   INDEX_STATS_CURR_VW ISV
LEFT JOIN AX_TABLE_DETAIL ATD ON ISV.SERVER_NAME = ATD.SERVER_NAME AND ISV.DATABASE_NAME = ATD.DATABASE_NAME AND ISV.TABLE_NAME = ATD.TABLE_NAME
--WHERE DATABASE_NAME = 'XXXXXXXXXXXX' 
--	AND SERVER_NAME = 'XXXXXXXX'
GROUP  BY ISV.SERVER_NAME,
          ISV.DATABASE_NAME,
          ISV.TABLE_NAME,
          ATD.APPLAYER,
		  ATD.OCC_ENABLED,
		  ATD.CACHE_LOOKUP
ORDER  BY SIZEMB_DATA DESC 





-- --------------------------------------------------------------
--
--			INDEX_SIZE_BY_CONFIG
--
-- List TABLE sizes by AX Configuration Key
--
----------------------------------------------------------------

USE DynamicsPerf

SELECT ISV.DATABASE_NAME,
       IDV.CONFIG_KEY_NAME,
       SUM(CASE
             WHEN ISV.INDEX_ID IN ( 0, 1 ) THEN PAGE_COUNT * 8 / 1024
           END)   AS SIZEMB_DATA,
       SUM(CASE
             WHEN ISV.INDEX_ID > 1 THEN PAGE_COUNT * 8 / 1024
           END)   AS SIZEMB_INDEXES,
       COUNT(CASE
               WHEN ISV.INDEX_ID > 1 THEN ISV.TABLE_NAME
             END) AS NO_OF_INDEXES,
       MAX(CASE
             WHEN ( DATA_COMPRESSION > 0 )
                  AND ( ISV.INDEX_ID IN ( 0, 1 ) ) THEN 'Y'
             ELSE 'N'
           END)   AS DATA_COMPRESSED,
       MAX(CASE
             WHEN ( DATA_COMPRESSION > 0 )
                  AND ( ISV.INDEX_ID > 1 ) THEN 'Y'
             ELSE 'N'
           END)   AS INDEXES_COMPRESSED
FROM   INDEX_STATS_CURR_VW ISV
       INNER JOIN AX_INDEX_DETAIL_VW IDV
               ON ISV.SERVER_NAME = IDV.SERVER_NAME
                  AND ISV.DATABASE_NAME = IDV.DATABASE_NAME
                  AND ISV.TABLE_NAME = IDV.TABLE_NAME
                  AND ISV.INDEX_NAME = IDV.INDEX_NAME
--WHERE DATABASE_NAME = 'XXXXXXXXXXXX' 
--	AND SERVER_NAME = 'XXXXXXXX'
GROUP  BY ISV.SERVER_NAME,
          ISV.DATABASE_NAME,
          IDV.CONFIG_KEY_NAME
ORDER  BY 4 DESC 




-- --------------------------------------------------------------
--
--			INDEX_ACTIVITY
--
-- List READ/WRITE ratios by table, Investigate for activity 
-- in unusual places such as logging or alerts or unused modules
--
----------------------------------------------------------------

SELECT ISV.DATABASE_NAME,
       ISV.TABLE_NAME,
       ATD.APPLAYER,
       ATD.OCC_ENABLED,
	   ATD.CACHE_LOOKUP,
       CASE
         WHEN ( SUM(USER_UPDATES + USER_SEEKS + USER_SCANS
                    + USER_LOOKUPS) = 0 ) THEN NULL
         ELSE ( CAST(SUM(USER_SEEKS + USER_SCANS + USER_LOOKUPS) AS DECIMAL) / CAST(SUM(USER_UPDATES + USER_SEEKS + USER_SCANS + USER_LOOKUPS) AS DECIMAL) ) END   AS RATIOOFREADS,
       CASE
         WHEN ( SUM(USER_UPDATES + USER_SEEKS + USER_SCANS
                    + USER_LOOKUPS) = 0 ) THEN NULL
         ELSE ( CAST(SUM(USER_UPDATES) AS DECIMAL) / CAST(SUM(USER_UPDATES + USER_SEEKS + USER_SCANS + USER_LOOKUPS) AS DECIMAL) ) END       AS RATIOOFWRITES,
       SUM(USER_SEEKS + USER_SCANS + USER_LOOKUPS) AS TOTALREADOPERATIONS,
       SUM(USER_UPDATES)                           AS TOTALWRITEOPERATIONS,
       SUM(USER_UPDATES + USER_SEEKS + USER_SCANS
           + USER_LOOKUPS)                         AS TOTALOPERATIONS
FROM   INDEX_STATS_CURR_VW ISV /*sys.dm_db_index_usage_stats*/
LEFT JOIN AX_TABLE_DETAIL ATD ON ISV.SERVER_NAME = ATD.SERVER_NAME AND ISV.DATABASE_NAME = ATD.DATABASE_NAME AND ISV.TABLE_NAME = ATD.TABLE_NAME
--WHERE DATABASE_NAME = 'XXXXXXXXXXXX' 
--	AND SERVER_NAME = 'XXXXXXXX'
GROUP  BY ISV.SERVER_NAME,
         ISV.DATABASE_NAME,
          ISV.TABLE_NAME,
          ATD.APPLAYER,
          ATD.OCC_ENABLED,
		  ATD.CACHE_LOOKUP
--ORDER BY TOTALOPERATIONS DESC
--ORDER BY   DESC
ORDER  BY TOTALWRITEOPERATIONS DESC 



-- --------------------------------------------------------------
--
--			INDEX_ACTIVITY_WITH_CACHE_LOOKUP
--
-- List READ/WRITE ratios by AX Configuration Key
--
----------------------------------------------------------------


SELECT ISV.DATABASE_NAME,
		ISV.TABLE_NAME,
       ISNULL((SELECT TOP 1 CACHE_LOOKUP FROM AX_TABLE_DETAIL ATD WHERE
        ISV.SERVER_NAME = ATD.SERVER_NAME AND ISV.DATABASE_NAME = ATD.DATABASE_NAME
        AND ISV.TABLE_NAME = ATD.TABLE_NAME ),'') AS CACHE_LOOKUP,
       CASE
         WHEN ( SUM(USER_UPDATES + USER_SEEKS + USER_SCANS
                    + USER_LOOKUPS) = 0 ) THEN NULL
         ELSE ( CAST(SUM(USER_SEEKS + USER_SCANS + USER_LOOKUPS) AS DECIMAL) / CAST(SUM(USER_UPDATES + USER_SEEKS + USER_SCANS + USER_LOOKUPS) AS DECIMAL) )
       END                                         AS RATIOOFREADS,
       CASE
         WHEN ( SUM(USER_UPDATES + USER_SEEKS + USER_SCANS
                    + USER_LOOKUPS) = 0 ) THEN NULL
         ELSE ( CAST(SUM(USER_UPDATES) AS DECIMAL) / CAST(SUM(USER_UPDATES + USER_SEEKS + USER_SCANS + USER_LOOKUPS) AS DECIMAL) )
       END                                         AS RATIOOFWRITES,
       SUM(USER_SEEKS + USER_SCANS + USER_LOOKUPS) AS TOTALREADOPERATIONS,
       SUM(USER_UPDATES)                           AS TOTALWRITEOPERATIONS,
       SUM(USER_UPDATES + USER_SEEKS + USER_SCANS
           + USER_LOOKUPS)                         AS TOTALOPERATIONS
FROM   INDEX_STATS_CURR_VW ISV
       INNER JOIN AX_INDEX_DETAIL_VW IDV
               ON ISV.SERVER_NAME = IDV.SERVER_NAME
                  AND ISV.DATABASE_NAME = IDV.DATABASE_NAME
                  AND ISV.TABLE_NAME = IDV.TABLE_NAME
                  AND ISV.INDEX_NAME = IDV.INDEX_NAME
--WHERE DATABASE_NAME = 'XXXXXXXXXXXX' 
--	AND SERVER_NAME = 'XXXXXXXX'
GROUP  BY ISV.SERVER_NAME,
          ISV.DATABASE_NAME,
          ISV.TABLE_NAME
--ORDER BY TOTALOPERATIONS DESC
ORDER BY TOTALREADOPERATIONS DESC
--ORDER  BY TOTALWRITEOPERATIONS DESC 



-- --------------------------------------------------------------
--
--			AX_INDEXES_BEING_LOCKED
--
-- Find non-clustered indexes that are being LCOKED.  Generally  
-- this will indicate that key columns are out of order compared
-- to query predicates or LONG runninng Transactions
--
----------------------------------------------------------------

SELECT TOP 100  ROW_LOCK_WAIT_IN_MS + PAGE_LOCK_WAIT_IN_MS AS TOTAL_LOCK_TIME_MS,
ATD.CACHE_LOOKUP, ATD.OCC_ENABLED
	,ISV.*
FROM   INDEX_STATS_CURR_VW ISV
LEFT JOIN AX_TABLE_DETAIL ATD ON ISV.SERVER_NAME = ATD.SERVER_NAME AND ISV.DATABASE_NAME = ATD.DATABASE_NAME AND ISV.TABLE_NAME = ATD.TABLE_NAME

WHERE  ROW_LOCK_WAIT_IN_MS + PAGE_LOCK_WAIT_IN_MS > 0
ORDER  BY ROW_LOCK_WAIT_IN_MS + PAGE_LOCK_WAIT_IN_MS DESC 



-- --------------------------------------------------------------
--
--			INDEX_ACTIVITY_BY_CONFIG_KEY
--
-- List READ/WRITE ratios by AX Configuration Key
--
----------------------------------------------------------------


SELECT ISV.DATABASE_NAME,
       IDV.CONFIG_KEY_NAME,
       CASE
         WHEN ( SUM(USER_UPDATES + USER_SEEKS + USER_SCANS
                    + USER_LOOKUPS) = 0 ) THEN NULL
         ELSE ( CAST(SUM(USER_SEEKS + USER_SCANS + USER_LOOKUPS) AS DECIMAL) / CAST(SUM(USER_UPDATES + USER_SEEKS + USER_SCANS + USER_LOOKUPS) AS DECIMAL) )
       END                                         AS RATIOOFREADS,
       CASE
         WHEN ( SUM(USER_UPDATES + USER_SEEKS + USER_SCANS
                    + USER_LOOKUPS) = 0 ) THEN NULL
         ELSE ( CAST(SUM(USER_UPDATES) AS DECIMAL) / CAST(SUM(USER_UPDATES + USER_SEEKS + USER_SCANS + USER_LOOKUPS) AS DECIMAL) )
       END                                         AS RATIOOFWRITES,
       SUM(USER_SEEKS + USER_SCANS + USER_LOOKUPS) AS TOTALREADOPERATIONS,
       SUM(USER_UPDATES)                           AS TOTALWRITEOPERATIONS,
       SUM(USER_UPDATES + USER_SEEKS + USER_SCANS
           + USER_LOOKUPS)                         AS TOTALOPERATIONS
FROM   INDEX_STATS_CURR_VW ISV
       INNER JOIN AX_INDEX_DETAIL_VW IDV
               ON ISV.SERVER_NAME = IDV.SERVER_NAME
                  AND ISV.DATABASE_NAME = IDV.DATABASE_NAME
                  AND ISV.TABLE_NAME = IDV.TABLE_NAME
                  AND ISV.INDEX_NAME = IDV.INDEX_NAME
--WHERE DATABASE_NAME = 'XXXXXXXXXXXX' 
--	AND SERVER_NAME = 'XXXXXXXX'
GROUP  BY ISV.SERVER_NAME,
          ISV.DATABASE_NAME,
          IDV.CONFIG_KEY_NAME
--ORDER BY TOTALOPERATIONS DESC
--ORDER BY TOTALREADOPERATIONS DESC
ORDER  BY TOTALWRITEOPERATIONS DESC 



-- --------------------------------------------------------------
--
--			INCLUDED_COLUMN_INDEXES
--
-- Find indexes with high number of include columns 
-- This will cause table size BLOAT and potential blocking issues 
-- as SQL updates the included columns
-- 
-- It's recommended to have 4 or less columns in the included list
-- The columns should be static columns as updates to those columns
--  WILL cause poor database write performance 
----------------------------------------------------------------

SELECT TOP 100 ATD.APPLAYER, ISV.*
FROM   INDEX_STATS_CURR_VW ISV
LEFT JOIN AX_TABLE_DETAIL ATD ON ISV.SERVER_NAME = ATD.SERVER_NAME AND ISV.DATABASE_NAME = ATD.DATABASE_NAME AND ISV.TABLE_NAME = ATD.TABLE_NAME
WHERE  INCLUDED_COLUMNS <> 'N/A'
       AND PAGE_COUNT > 0
ORDER  BY len(INCLUDED_COLUMNS) DESC 




--
--			INDEXES_IN_DB_NOT_IN_AOT
--
-- --------------------------------------------------------------
-- Find INDEXES that are not defined in the AOT 
--
--  NOTE: Ignore System tables in this list. 
-- 
-- INDEXES should ALWAYS be defined in the AOT as synchronization
--   will remove them
--
-- This also violates Dynamics AX Best Practices to not have an 
-- index defined in the AOT !!
--
-- It's ok to add an index for testing purposes on the SQL side
--  as long as you add it to the AOT once you know you are going 
--  to keep the index
-----------------------------------------------------------------

/****************************************************************
NOTE: If no data here, it could be correct OR, it could be 
AOTEXPORT hasn't been run from inside DynamicsAX or
INDEX_STATS data hasn't collected yet
****************************************************************/

 /********************************************************************
 The AX system tables and DEL_ tables will show in this list but are ok
 *********************************************************************/

		SELECT *
		FROM   INDEX_STATS_CURR_VW I
		WHERE  INDEX_DESCRIPTION <> 'HEAP'
			   AND INDEX_DESCRIPTION NOT LIKE '%FILTERED%'
			   AND NOT EXISTS (SELECT *
							   FROM   AX_INDEX_DETAIL_VW A
							   WHERE  A.SERVER_NAME = I.SERVER_NAME
									  AND A.DATABASE_NAME = I.DATABASE_NAME
									  AND A.TABLE_NAME = I.TABLE_NAME
									  AND A.INDEX_NAME = I.INDEX_NAME)
		ORDER  BY SERVER_NAME,
				  DATABASE_NAME,
				  TABLE_NAME,
				  INDEX_NAME 



--
--			INDEXES_WITH_RECVERSION
--
-- --------------------------------------------------------------
-- Find INDEXES that have RECVERSION in the Key or Included list
--  RECVERSION should NOT be a part of AX Indexes due to the 
--  frequency of updates
-----------------------------------------------------------------



		SELECT *
		FROM   INDEX_STATS_CURR_VW I
		WHERE  INDEX_KEYS LIKE '%RECVERSION%'
				OR INCLUDED_COLUMNS LIKE '%RECVERSION%'
		ORDER  BY SERVER_NAME,
				  DATABASE_NAME,
				  TABLE_NAME,
				  INDEX_NAME 



-- --------------------------------------------------------------
--
--		TABLES_WITHOUT_CLUSTERED_INDEX_AX
--
-- Tables missing clustered indexes
-- Heaps with multiple non-clustered indexes.
-- Use the following script to identify a good clustered index
-- based solely on user activity
--
--  ALL TABLES SHOULD HAVE A CLUSTERED INDEX !!
--
----------------------------------------------------------------

SELECT RN = Row_number()
              OVER (
                PARTITION BY CLUS.DATABASE_NAME, CLUS.TABLE_NAME
                ORDER BY CLUS.DATABASE_NAME, CLUS.TABLE_NAME, ( NONCLUS.RANGE_SCAN_COUNT - CLUS.RANGE_SCAN_COUNT ) DESC),
       CLUS.SERVER_NAME,
       CLUS.DATABASE_NAME,
       CLUS.TABLE_NAME,
       ATD.APPLAYER											AS AX_APPLAYER,
       CLUS.INDEX_NAME                                      AS HEAP_TABLE,
       CLUS.INDEX_KEYS                                      AS CLUSTERED_KEYS,
       NONCLUS.INDEX_NAME                                   AS NONCLUSTERED_INDEX,
       NONCLUS.INDEX_KEYS,
       ( NONCLUS.RANGE_SCAN_COUNT - CLUS.RANGE_SCAN_COUNT ) AS NONCLUSTERED_VS_CLUSTERED_RANGE_COUNT,
       CLUS.USER_SEEKS                                      AS CLUSTERED_USER_SEEKS,
       CLUS.USER_SCANS                                      AS CLUSTERED_USER_SCANS,
       CLUS.SINGLETON_LOOKUP_COUNT                          AS CLUSTERED_SINGLE_LOOKUPS,
       CLUS.RANGE_SCAN_COUNT                                AS CLUSTERED_RANGE_SCAN,
       NONCLUS.USER_SEEKS                                   AS NONCLUSTERED_USER_SEEKS,
       NONCLUS.USER_SCANS                                   AS NONCLUSTERED_USER_SCANS,
       NONCLUS.SINGLETON_LOOKUP_COUNT                       AS NONCLUSTERED_SINGLE_LOOKUPS,
       NONCLUS.RANGE_SCAN_COUNT                             AS NONCLUSTERED_RANGE_SCANS,
       NONCLUS.USER_UPDATES                                 AS NONCLUSTERED_USER_UPDATES
FROM   INDEX_STATS_CURR_VW CLUS
       INNER JOIN INDEX_STATS_CURR_VW NONCLUS
               ON CLUS.TABLE_NAME = NONCLUS.TABLE_NAME
                  AND CLUS.DATABASE_NAME = NONCLUS.DATABASE_NAME
                  AND CLUS.SERVER_NAME = NONCLUS.SERVER_NAME
                  AND CLUS.INDEX_NAME <> NONCLUS.INDEX_NAME
       LEFT JOIN AX_TABLE_DETAIL ATD ON CLUS.SERVER_NAME = ATD.SERVER_NAME AND CLUS.DATABASE_NAME = ATD.DATABASE_NAME AND CLUS.TABLE_NAME = ATD.TABLE_NAME

WHERE  CLUS.INDEX_DESCRIPTION LIKE 'HEAP%'
       AND ( ( NONCLUS.RANGE_SCAN_COUNT > CLUS.RANGE_SCAN_COUNT )
              OR ( NONCLUS.SINGLETON_LOOKUP_COUNT > CLUS.SINGLETON_LOOKUP_COUNT ) )
       AND CLUS.PAGE_COUNT > 0
ORDER  BY CLUS.USER_LOOKUPS DESC,
          CLUS.TABLE_NAME,
          RN 



--
--			TABLES_WITHOUT_UNIQUE_INDEX
--
-- --------------------------------------------------------------
-- Find tables that don't have a unique key for AX record caching
--	Can't record cache w/o a unique index on the table
-- You must define a unique index and use that filter in X++ code
-----------------------------------------------------------------

	SELECT DISTINCT TABLE_NAME
	FROM   INDEX_STATS_CURR_VW V1
	WHERE  NOT EXISTS (SELECT 'X'
					   FROM   INDEX_STATS_CURR_VW V2
					   WHERE  V2.SERVER_NAME = V1.SERVER_NAME
							  AND V2.DATABASE_NAME = V1.DATABASE_NAME
							  AND V1.TABLE_NAME = V2.TABLE_NAME
							  AND V2.INDEX_DESCRIPTION LIKE '%UNIQUE%')
		   AND EXISTS (SELECT 'X'
					   FROM   AX_TABLE_DETAIL AD
					   WHERE  AD.SERVER_NAME = V1.SERVER_NAME
							  AND AD.DATABASE_NAME = V1.DATABASE_NAME
							  AND AD.TABLE_NAME = V1.TABLE_NAME
							  AND AD.CACHE_LOOKUP IN ( 'FOUND', 'FOUNDANDEMPTY', 'NOTINTTS' ))

        
-- TABLES YOU MIGHT CACHE LATER W/O UNIQUE INDEXES


		SELECT DISTINCT TABLE_NAME
		FROM   INDEX_STATS_CURR_VW V1
		WHERE  NOT EXISTS (SELECT 'X'
						   FROM   INDEX_STATS_CURR_VW V2
						   WHERE  V2.SERVER_NAME = V1.SERVER_NAME
								  AND V2.DATABASE_NAME = V1.DATABASE_NAME
								  AND V1.TABLE_NAME = V2.TABLE_NAME
								  AND V2.INDEX_DESCRIPTION LIKE '%UNIQUE%')
			   AND EXISTS (SELECT 'X'
						   FROM   AX_TABLE_DETAIL AD
						   WHERE  AD.SERVER_NAME = V1.SERVER_NAME
								  AND AD.DATABASE_NAME = V1.DATABASE_NAME
								  AND AD.TABLE_NAME = V1.TABLE_NAME
								  AND AD.CACHE_LOOKUP IN ( 'NONE' )) 


