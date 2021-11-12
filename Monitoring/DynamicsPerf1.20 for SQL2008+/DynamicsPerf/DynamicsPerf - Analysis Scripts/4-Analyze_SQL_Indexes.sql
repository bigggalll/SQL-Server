/*********************************************************************
Copy one of the following links and press Ctrl-F and click FIND NEXT
in order to go to that section of the scripts

INDEXES_BY_SIZE
INDEX_ACTIVITY
HIGH_COST_INDEXES
COMPRESSED_INDEXES
EXACT_DUPLICATE_INDEXES
SUBSET_DUPLICATE_INDEXES
INCLUDED_COLUMN_INDEXES
UNUSED_INDEXES
TABLES_WITHOUT_CLUSTERED_INDEX
ADJUST_CLUSTERED_INDEXES
INDEXES_BEING_SCANNED
SEARCH_QUERY_PLANS_FOR_INDEX_USAGE


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

SELECT TOP 100 DATABASE_NAME,
               TABLE_NAME,
               SUM(CASE
                     WHEN INDEX_DESCRIPTION LIKE 'CLUSTERED%'
                           OR INDEX_DESCRIPTION LIKE 'HEAP%' THEN PAGE_COUNT * 8 / 1024
                   END)   AS SIZEMB_DATA,
               SUM(CASE
                     WHEN INDEX_DESCRIPTION LIKE 'NONCLUSTERED%' THEN PAGE_COUNT * 8 / 1024
                   END)   AS SIZEMB_INDEXES,
               COUNT(CASE
                       WHEN INDEX_DESCRIPTION LIKE 'NONCLUSTERED%' THEN TABLE_NAME
                     END) AS NO_OF_INDEXES,
               MAX(CASE
                     WHEN ( DATA_COMPRESSION > 0 )
                          AND ( INDEX_DESCRIPTION LIKE 'CLUSTERED%'
                                 OR INDEX_DESCRIPTION LIKE 'HEAP%' ) THEN 'Y'
                     ELSE 'N'
                   END)   AS DATA_COMPRESSED,
               MAX(CASE
                     WHEN ( DATA_COMPRESSION > 0 )
                          AND ( INDEX_DESCRIPTION LIKE 'NONCLUSTERED%' ) THEN 'Y'
                     ELSE 'N'
                   END)   AS INDEXES_COMPRESSED
FROM   INDEX_STATS_CURR_VW
GROUP  BY DATABASE_NAME,
          TABLE_NAME
ORDER  BY 3 DESC 



-- --------------------------------------------------------------
--
--			INDEX_ACTIVITY
--
-- List READ/WRITE ratios by table, Investigate for activity 
-- in unusual places such as logging or alerts or unused modules
--
----------------------------------------------------------------


SELECT DATABASE_NAME,
       TABLE_NAME,
       CASE
         WHEN ( SUM(USER_UPDATES + USER_SEEKS + USER_SCANS
                    + USER_LOOKUPS) = 0 ) THEN NULL
         ELSE ( CAST(SUM(USER_SEEKS + USER_SCANS + USER_LOOKUPS) AS DECIMAL) / CAST(SUM(USER_UPDATES + USER_SEEKS + USER_SCANS
                                                                                        + USER_LOOKUPS) AS DECIMAL) )
       END                                         AS RatioOfReads,
       CASE
         WHEN ( SUM(USER_UPDATES + USER_SEEKS + USER_SCANS
                    + USER_LOOKUPS) = 0 ) THEN NULL
         ELSE ( CAST(SUM(USER_UPDATES) AS DECIMAL) / CAST(SUM(USER_UPDATES + USER_SEEKS + USER_SCANS
                                                              + USER_LOOKUPS) AS DECIMAL) )
       END                                         AS RatioOfWrites,
       SUM(USER_SEEKS + USER_SCANS + USER_LOOKUPS) AS TotalReadOperations,
       SUM(USER_UPDATES)                           AS TotalWriteOperations,
       SUM(USER_UPDATES + USER_SEEKS + USER_SCANS
           + USER_LOOKUPS)                         AS TotalOperations
FROM   INDEX_STATS_CURR_VW /*sys.dm_db_index_usage_stats*/
GROUP  BY DATABASE_NAME,
          TABLE_NAME
--ORDER BY TotalOperations DESC
--ORDER BY TotalReadOperations DESC
ORDER  BY TotalWriteOperations DESC 




-- --------------------------------------------------------------
--
--			HIGH_COST_INDEXES
--
-- Investigate indexes that have more writes than reads 
--   for possible over indexing
--
-- NOTE: Do adequate testing in Dev/Test before removing the index
-- from production
----------------------------------------------------------------


SELECT DATABASE_NAME,
       TABLE_NAME,
       INDEX_NAME,
       PAGE_COUNT*8/1024 AS SIZE_MB,
       CASE
         WHEN ( SUM(USER_UPDATES + USER_SEEKS + USER_SCANS
                    + USER_LOOKUPS) = 0 ) THEN NULL
         ELSE ( CAST(SUM(USER_SEEKS + USER_SCANS + USER_LOOKUPS) AS DECIMAL) / CAST(SUM(USER_UPDATES + USER_SEEKS + USER_SCANS
                                                                                        + USER_LOOKUPS) AS DECIMAL) )
       END                                         AS RatioOfReads,
       CASE
         WHEN ( SUM(USER_UPDATES + USER_SEEKS + USER_SCANS
                    + USER_LOOKUPS) = 0 ) THEN NULL
         ELSE ( CAST(SUM(USER_UPDATES) AS DECIMAL) / CAST(SUM(USER_UPDATES + USER_SEEKS + USER_SCANS
                                                              + USER_LOOKUPS) AS DECIMAL) )
       END                                         AS RatioOfWrites,
       SUM(USER_SEEKS + USER_SCANS + USER_LOOKUPS) AS TotalReadOperations,
       SUM(USER_UPDATES)                           AS TotalWriteOperations,
       SUM(USER_UPDATES + USER_SEEKS + USER_SCANS
           + USER_LOOKUPS)                         AS TotalOperations
FROM   INDEX_STATS_CURR_VW /*sys.dm_db_index_usage_stats*/
WHERE   USER_UPDATES > (USER_SEEKS + USER_SCANS + USER_LOOKUPS)
GROUP  BY DATABASE_NAME,
          TABLE_NAME,
          INDEX_NAME, 
          PAGE_COUNT
--ORDER BY TotalOperations DESC
--ORDER BY TotalReadOperations DESC
ORDER  BY TotalWriteOperations DESC 



-- --------------------------------------------------------------
--
--		COMPRESSED_INDEXES
--
-- Find indexes that are compressed.  
-- Compressing the database reduces the size of the db on disk
-- and keeps the data compressed in memory as well.  This can 
-- reduce Disk I/O and improve performance. 
-- Compression will increase CPU time ono the SQL Server
----------------------------------------------------------------

SELECT *
FROM   INDEX_STATS_CURR_VW
WHERE  DATA_COMPRESSION > 0
ORDER  BY USER_UPDATES DESC 



-- --------------------------------------------------------------
--
--				EXACT_DUPLICATE_INDEXES
--
-- Tables that have 2 or more indexes with the exact same key
-- Trust me, this happens.
--
--  NOTE:  The indexes could be duplicate on the keys but have unique set of included columns 
--   in that case they should be combined into a singular index
--   for performance reasons 
--
----------------------------------------------------------------

SELECT DATABASE_NAME,
       TABLE_NAME,
       INDEX_KEYS,
       COUNT(*)
FROM   INDEX_STATS_CURR_VW
GROUP  BY DATABASE_NAME,
          TABLE_NAME,
          INDEX_KEYS
HAVING COUNT(INDEX_KEYS) > 1
ORDER  BY TABLE_NAME 



-- --------------------------------------------------------------
--
--				SUBSET_DUPLICATE_INDEXES
--
--   Just as bad (and even more common) are indexes that are a left key
--   subset of another index on same table.  Unless the subsset key is
--   unique, its usefulness is subsumed of the superset key.
--   EXAMPLE:
--		1-INDEX A, B, C
--		2-INDEX A, B
--
--   In this case index 2 is a subset of index 1 on the keys
--
--  NOTE:  The indexes could be subset duplicate on the keys but have unique set of included columns 
--   in that case they should be combined into a singular index
--   for performance reasons 
----------------------------------------------------------------


SELECT O.DATABASE_NAME,
       O.TABLE_NAME,
       O.INDEX_NAME            AS SUBSET_INDEX,
       O.INDEX_KEYS            AS SUBSET_INDEX_KEYS,
       O.INDEX_DESCRIPTION     AS SUBSET_INDEX_DESCRIPTION,
       O.PAGE_COUNT * 8 / 1024 AS SUBSET_SIZE_MB,
       I.INDEX_NAME            AS SUPERSET_INDEX,
       I.INDEX_KEYS            AS SUPERSET_KEYS
FROM   INDEX_STATS_CURR_VW O
       LEFT JOIN INDEX_STATS_CURR_VW I
              ON I.RUN_NAME = O.RUN_NAME
                 AND I.DATABASE_NAME = O.DATABASE_NAME
                 AND I.TABLE_NAME = O.TABLE_NAME
                 AND I.INDEX_KEYS <> O.INDEX_KEYS
                 AND I.INDEX_KEYS LIKE O.INDEX_KEYS + ',%'
WHERE  O.INDEX_DESCRIPTION NOT LIKE '%UNIQUE%'
       AND I.INDEX_NAME IS NOT NULL
       AND O.PAGE_COUNT > 0
ORDER  BY O.DATABASE_NAME,
          I.TABLE_NAME,
          I.INDEX_KEYS 



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

SELECT TOP 100 *
FROM   INDEX_STATS_CURR_VW
WHERE  INCLUDED_COLUMNS <> 'N/A'
       AND PAGE_COUNT > 0
ORDER  BY LEN(INCLUDED_COLUMNS) DESC 




-- --------------------------------------------------------------
--
--				UNUSED_INDEXES
--
-- Find indexes that are not being used.  If an index enforces
-- a uniqueness constraint, we must retain it.
--
--**************************************************************
-- DO NOT DELETE THESE INDEXES UNLESS YOU ARE SURE YOU HAVE RUN 
-- EVERY PROCESS IN YOUR DYNAMICS DATABASE INCLUDING YEAR END !!
--**************************************************************
----------------------------------------------------------------

SELECT PAGE_COUNT * 8 / 1024 AS SIZE_MB,
       *
FROM   INDEX_HISTORICAL_VW
WHERE
  -- criteria for never been used indexes
  USER_SEEKS = 0
  AND USER_SCANS = 0
  -- uncomment next 2 lines if you want to see indexes with very low usages
  --AND USER_SEEKS < 100
  --AND USER_SCANS < 100
  AND INDEX_DESCRIPTION NOT LIKE '%UNIQUE%'
  AND INDEX_DESCRIPTION NOT LIKE '%HEAP%'
  AND (PAGE_COUNT * 8 / 1024) > 0  -- only show indexes consuming space
ORDER  BY 1 DESC 



-- --------------------------------------------------------------
--
--		TABLES_WITHOUT_CLUSTERED_INDEX
--
-- Tables missing clustered indexes
-- Heaps with multiple non-clustered indexes.
-- Use the following script to identify a good clustered index
-- based solely on user activity
--
--  ALL TABLES SHOULD HAVE A CLUSTERED INDEX !!
--
----------------------------------------------------------------

SELECT CLUS.TABLE_NAME,
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
                  AND CLUS.INDEX_NAME <> NONCLUS.INDEX_NAME
WHERE  CLUS.INDEX_DESCRIPTION LIKE 'HEAP%'
       AND ( ( NONCLUS.RANGE_SCAN_COUNT > CLUS.RANGE_SCAN_COUNT )
              OR ( NONCLUS.SINGLETON_LOOKUP_COUNT > CLUS.SINGLETON_LOOKUP_COUNT ) )
       AND CLUS.PAGE_COUNT > 0
ORDER  BY CLUS.USER_LOOKUPS DESC,
          CLUS.TABLE_NAME,
          ( NONCLUS.RANGE_SCAN_COUNT - CLUS.RANGE_SCAN_COUNT ) DESC 




-- ----------------------------------------------------------------------------------------
--
--				ADJUST_CLUSTERED_INDEXES
--
--
-- Find clustered indexes that could be changed 
-- to 1 of the non-clustered indexes that has more usage than the clustered index
-- Use the following script to identify the non-clustered index
-- that could be the clustered index based solely on user activity
-- This should be the LAST activty done in a performance tuning session
--
-- The index should be narrow with few, narrow columns
--
--NOTE - CHANGING CLUSTERED INDEXES WILL TAKE LONG TIME TO DO
--  AND REQUIRES DOWNTIME TO IMPLEMENT
--------------------------------------------------------------------------------------------


SELECT CLUS.TABLE_NAME,
       CLUS.INDEX_NAME                                      AS CLUSTERED_INDEX,
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
            AND CLUS.INDEX_NAME <> NONCLUS.INDEX_NAME
WHERE   CLUS.INDEX_DESCRIPTION LIKE 'CLUSTERED%' AND (( NONCLUS.RANGE_SCAN_COUNT > CLUS.RANGE_SCAN_COUNT ) 
        OR ( NONCLUS.SINGLETON_LOOKUP_COUNT > CLUS.SINGLETON_LOOKUP_COUNT ))
ORDER  BY CLUS.USER_LOOKUPS DESC, CLUS.TABLE_NAME,
          ( NONCLUS.RANGE_SCAN_COUNT - CLUS.RANGE_SCAN_COUNT ) DESC 
          
          

-- --------------------------------------------------------------
--
--			INDEXES_BEING_SCANNED
--
-- Find non-clustered indexes that are being scanned.  Generally  
-- this will indicate that key columns are out of order compared
-- to query predicates
--
----------------------------------------------------------------

SELECT TOP 100 *
FROM   INDEX_STATS_CURR_VW
WHERE  USER_SCANS > 0
       AND INDEX_DESCRIPTION LIKE 'NONCLUSTERED%'
ORDER  BY USER_SCANS DESC 


-- --------------------------------------------------------------
--
--				SEARCH_QUERY_PLANS_FOR_INDEX_USAGE
--
-- Using indexes identifies in the previous query, list queries 
-- whose execution plan references a specific index; order by 
-- most expensive (logical reads)
--
----------------------------------------------------------------

SELECT TOP 100 *
FROM   QUERY_STATS_CURR_VW
WHERE  QUERY_PLAN_TEXT LIKE '%Index_Name%'
ORDER  BY TOTAL_LOGICAL_READS DESC

