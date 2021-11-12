--USE [DynamicsPerf]
GO
UPDATE DYNAMICSPERF_SETUP SET VERSION = '1.20', INSTALLED_DATE = (SELECT MIN(STATS_TIME) FROM STATS_COLLECTION_SUMMARY)

GO

/***************************************************************************
*
* 3/2/2012  REH   Turn on row compression for all DynamicsPerf indexes
*                   if compression is supported
*
*
****************************************************************************/
IF  (cast(serverproperty('Edition') as varchar(100)) like 'Enterprise%' or cast(serverproperty('Edition') as varchar(100)) like 'Developer%')
BEGIN
		DECLARE @INDEX_NAME SYSNAME
		DECLARE @TABLE_NAME SYSNAME
		DECLARE @SQL VARCHAR(MAX)


		DECLARE INDEXCURSOR CURSOR FOR
			SELECT	
					si.name, 
					so.name
			FROM	DynamicsPerf.sys.indexes si
			JOIN	DynamicsPerf.sys.sysindexes ii on si.object_id = ii.id and si.index_id = ii.indid
			JOIN	DynamicsPerf.sys.objects so on so.object_id = si.object_id
			JOIN	DynamicsPerf.sys.schemas ss on ss.schema_id = so.schema_id
			WHERE	so.type = 'U'
			AND		si.type > 0  --other than heap tables
			
			OPEN INDEXCURSOR

		FETCH INDEXCURSOR INTO 
			@INDEX_NAME		,
			@TABLE_NAME		
			
			
		WHILE @@FETCH_STATUS = 0
			BEGIN
			
			--Need page compression on this table to get maximum space savings
			IF @TABLE_NAME = 'SQLErrorLog'
			BEGIN
			SELECT @SQL = 'ALTER INDEX ' + @INDEX_NAME + ' ON ' + @TABLE_NAME + 
			' REBUILD WITH (DATA_COMPRESSION = PAGE)'
			END
			ELSE
			BEGIN
			SELECT @SQL = 'ALTER INDEX ' + @INDEX_NAME + ' ON ' + @TABLE_NAME + 
			' REBUILD WITH (DATA_COMPRESSION = ROW)'
			END
			
			EXEC (@SQL)
			
			FETCH NEXT FROM INDEXCURSOR INTO @INDEX_NAME,@TABLE_NAME
			END
			
			CLOSE INDEXCURSOR
			DEALLOCATE INDEXCURSOR
			
			
			--REH Compress the QUERY_PLANS table that we removed the clustered index on
			ALTER TABLE dbo.QUERY_PLANS  REBUILD WITH ( DATA_COMPRESSION = ROW )
END

GO


PRINT N'Altering [dbo].[AX_NUM_SEQUENCES]...';

GO

ALTER TABLE [dbo].[AX_NUM_SEQUENCES]
ADD  FORMAT  [NVARCHAR](80) NULL;



GO
ALTER TABLE [dbo].[AX_NUM_SEQUENCES] ALTER COLUMN [COMPANYID] NVARCHAR (8) NULL;

ALTER TABLE [dbo].[AX_NUM_SEQUENCES] ALTER COLUMN [NUMBERSEQUENCE] NVARCHAR (40) NULL;

ALTER TABLE [dbo].[AX_NUM_SEQUENCES] ALTER COLUMN [RUN_NAME] NVARCHAR (60) NOT NULL;

ALTER TABLE [dbo].[AX_NUM_SEQUENCES] ALTER COLUMN [STATS_TIME] DATETIME NOT NULL;

ALTER TABLE [dbo].[AX_NUM_SEQUENCES] ALTER COLUMN [TEXT] NVARCHAR (120) NULL;


GO
PRINT N'Refreshing [dbo].[AX_NUM_SEQUENCES_CURR_VW]...';


GO
EXECUTE sp_refreshsqlmodule N'[dbo].[AX_NUM_SEQUENCES_CURR_VW]';


GO
PRINT N'Refreshing [dbo].[AX_NUM_SEQUENCES_VW]...';


GO
EXECUTE sp_refreshsqlmodule N'[dbo].[AX_NUM_SEQUENCES_VW]';


GO
PRINT N'Refreshing [dbo].[SP_PURGESTATS]...';


GO
EXECUTE sp_refreshsqlmodule N'[dbo].[SP_PURGESTATS]';


GO




GO

/****** Object:  View [dbo].[INDEX_HISTORICAL_VW]    Script Date: 02/19/2014 13:09:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[INDEX_HISTORICAL_VW] 
AS
SELECT DATEDIFF(DD, MIN(S.SQL_SERVER_STARTTIME), MAX(S.STATS_TIME)  ) AS HISTORICAL_DAYS,
       S.DATABASE_NAME,
       D.TABLE_NAME,
       D.INDEX_NAME,
       max(INDEX_DESCRIPTION)                              AS INDEX_DESCRIPTION,
       max(D.DATA_COMPRESSION)                             AS DATA_COMPRESSION,
       max(INDEX_KEYS)                                     AS INDEX_KEYS,
       max(INCLUDED_COLUMNS)                               AS INCLUDED_COLUMNS,
       sum(USER_SEEKS)                                     AS USER_SEEKS,
       sum(USER_SCANS)                                     AS USER_SCANS,
       sum(USER_LOOKUPS)                                   AS USER_LOOKUPS,
       sum(USER_UPDATES)                                   AS USER_UPDATES,
       sum(RANGE_SCAN_COUNT)                               AS RANGE_SCAN_COUNT,
       max(PAGE_COUNT)                                     AS PAGE_COUNT,
       max(ROW_COUNT)                                      AS ROW_COUNT,
       sum(SINGLETON_LOOKUP_COUNT)                         AS SINGLETON_LOOKUP_COUNT,
       sum(FORWARDED_FETCH_COUNT)                          AS FORWARDED_FETCH_COUNT,
       max(INDEX_DEPTH)                                    AS INDEX_DEPTH,
       avg(AVG_FRAGMENTATION_IN_PERCENT)                   AS AVG_FRAGMENTATION_IN_PERCENT,
       max(FRAGMENT_COUNT)                                 AS FRAGMENT_COUNT,
       sum(ROW_LOCK_WAIT_IN_MS)                            AS ROW_LOCK_WAIT_IN_MS,
       sum(PAGE_LOCK_WAIT_IN_MS)                           AS PAGE_LOCK_WAIT_IN_MS,
       sum(INDEX_LOCK_PROMOTION_ATTEMPT_COUNT)             AS INDEX_LOCK_PROMOTION_ATTEMPT_COUNT,
       sum(INDEX_LOCK_PROMOTION_COUNT)                     AS INDEX_LOCK_PROMOTION_COUNT,
       sum(PAGE_LATCH_WAIT_IN_MS)                          AS PAGE_LATCH_WAIT_IN_MS,
       sum(PAGE_IO_LATCH_WAIT_IN_MS)                       AS PAGE_IO_LATCH_WAIT_IN_MS,
       sum(LEAF_INSERT_COUNT)                              AS LEAF_INSERT_COUNT,
       sum(LEAF_DELETE_COUNT)                              AS LEAF_DELETE_COUNT,
       sum(LEAF_UPDATE_COUNT)                              AS LEAF_UPDATE_COUNT,
       sum(LEAF_GHOST_COUNT)                               AS LEAF_GHOST_COUNT,
       sum(NONLEAF_INSERT_COUNT)                           AS NONLEAF_INSERT_COUNT,
       sum(NONLEAF_DELETE_COUNT)                           AS NONLEAF_DELETE_COUNT,
       sum(NONLEAF_UPDATE_COUNT)                           AS NONLEAF_UPDATE_COUNT,
       sum(LEAF_ALLOCATION_COUNT)                          AS LEAF_ALLOCATION_COUNT,
       sum(NONLEAF_ALLOCATION_COUNT)                       AS NONLEAF_ALLOCATION_COUNT,
       sum(LEAF_PAGE_MERGE_COUNT)                          AS LEAF_PAGE_MERGE_COUNT,
       sum(NONLEAF_PAGE_MERGE_COUNT)                       AS NONLEAF_PAGE_MERGE_COUNT,
       sum(LOB_FETCH_IN_PAGES)                             AS LOB_FETCH_IN_PAGES,
       sum(LOB_FETCH_IN_BYTES)                             AS LOB_FETCH_IN_BYTES,
       sum(LOB_ORPHAN_CREATE_COUNT)                        AS LOB_ORPHAN_CREATE_COUNT,
       sum(LOB_ORPHAN_INSERT_COUNT)                        AS LOB_ORPHAN_INSERT_COUNT,
       sum(ROW_OVERFLOW_FETCH_IN_PAGES)                    AS ROW_OVERFLOW_FETCH_IN_PAGES,
       sum(ROW_OVERFLOW_FETCH_IN_BYTES)                    AS ROW_OVERFLOW_FETCH_IN_BYTES,
       sum(COLUMN_VALUE_PUSH_OFF_ROW_COUNT)                AS COLUMN_VALUE_PUSH_OFF_ROW_COUNT,
       sum(COLUMN_VALUE_PULL_IN_ROW_COUNT)                 AS COLUMN_VALUE_PULL_IN_ROW_COUNT,
       sum(ROW_LOCK_COUNT)                                 AS ROW_LOCK_COUNT,
       sum(ROW_LOCK_WAIT_COUNT)                            AS ROW_LOCK_WAIT_COUNT,
       sum(PAGE_LOCK_COUNT)                                AS PAGE_LOCK_COUNT,
       sum(PAGE_LOCK_WAIT_COUNT)                           AS PAGE_LOCK_WAIT_COUNT,
       sum(PAGE_LATCH_WAIT_COUNT)                          AS PAGE_LATCH_WAIT_COUNT,
       sum(PAGE_IO_LATCH_WAIT_COUNT)                       AS PAGE_IO_LATCH_WAIT_COUNT,
       max(S.STATS_TIME)                                   AS LAST_STATS_TIME,
       min(S.STATS_TIME)                                   AS MIN_STATS_TIME,
       DS.INSTALLED_DATE
FROM   (SELECT min(SQL_SERVER_STARTTIME) AS SQL_SERVER_STARTTIME ,
               DATABASE_NAME,
               max(STATS_TIME) AS STATS_TIME
        FROM   STATS_COLLECTION_SUMMARY SS
        GROUP  BY SQL_SERVER_STARTTIME,
                  DATABASE_NAME) AS S
       JOIN INDEX_DETAIL D WITH (NOLOCK)
         ON S.STATS_TIME = D.STATS_TIME
            AND S.DATABASE_NAME = D.DATABASE_NAME
       LEFT JOIN INDEX_USAGE_STATS U WITH (NOLOCK)
              ON U.STATS_TIME = D.STATS_TIME
                 AND U.DATABASE_NAME = D.DATABASE_NAME
                 AND U.OBJECT_ID = D.OBJECT_ID
                 AND U.INDEX_ID = D.INDEX_ID
       LEFT JOIN INDEX_PHYSICAL_STATS P WITH (NOLOCK)
              ON D.STATS_TIME = P.STATS_TIME
                 AND D.DATABASE_NAME = P.DATABASE_NAME
                 AND D.OBJECT_ID = P.OBJECT_ID
                 AND D.INDEX_ID = P.INDEX_ID
       LEFT JOIN INDEX_OPERATIONAL_STATS O WITH (NOLOCK)
              ON D.STATS_TIME = O.STATS_TIME
                 AND D.DATABASE_NAME = O.DATABASE_NAME
                 AND D.OBJECT_ID = O.OBJECT_ID
                 AND D.INDEX_ID = O.INDEX_ID
       CROSS APPLY DYNAMICSPERF_SETUP DS
GROUP  BY S.DATABASE_NAME,
          D.TABLE_NAME,
          D.INDEX_NAME,
          DS.INSTALLED_DATE 

GO





/****** Object:  StoredProcedure [dbo].[SP_PURGESTATS]    Script Date: 08/29/2014 18:35:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





ALTER	PROCEDURE [dbo].[SP_PURGESTATS] 
		@PURGE_DAYS		INT = 14,
		@DATABASE_NAME sysname = NULL
AS

SET NOCOUNT ON
SET DATEFORMAT MDY
DECLARE @PURGE_DATE smalldatetime

SET @PURGE_DAYS = @PURGE_DAYS * -1  --set to negative so we go back in time not forward in time


SET @PURGE_DATE = DATEADD(DD,@PURGE_DAYS,GETDATE())

IF @DATABASE_NAME IS NOT NULL
BEGIN
DELETE FROM INDEX_OPERATIONAL_STATS
WHERE  DATABASE_NAME = @DATABASE_NAME


DELETE FROM INDEX_PHYSICAL_STATS
WHERE  DATABASE_NAME = @DATABASE_NAME

DELETE FROM INDEX_OPERATIONAL_STATS
WHERE  DATABASE_NAME = @DATABASE_NAME

DELETE FROM QUERY_STATS
WHERE  DATABASE_NAME = @DATABASE_NAME


DELETE QT FROM QUERY_TEXT QT
WHERE NOT EXISTS (SELECT QUERY_HASH FROM QUERY_STATS QS 
	WHERE QS.QUERY_HASH = QT.QUERY_HASH)
	
DELETE QP FROM QUERY_PLANS QP
WHERE  NOT EXISTS (SELECT PLAN_HANDLE FROM QUERY_STATS QS 
	WHERE  QS.QUERY_PLAN_HASH=QP.QUERY_PLAN_HASH)
	


DELETE FROM STATS_COLLECTION_SUMMARY
WHERE  DATABASE_NAME = @DATABASE_NAME

DELETE FROM SERVERINFO
WHERE  NOT EXISTS (SELECT RUN_NAME FROM STATS_COLLECTION_SUMMARY SCS WHERE SCS.RUN_NAME = SERVERINFO.RUN_NAME)


DELETE FROM TRACEFLAGS
WHERE  NOT EXISTS (SELECT STATS_TIME FROM STATS_COLLECTION_SUMMARY SCS WHERE SCS.STATS_TIME = TRACEFLAGS.STATS_TIME)

DELETE FROM BUFFER_DETAIL
WHERE  NOT EXISTS (SELECT RUN_NAME FROM STATS_COLLECTION_SUMMARY SCS WHERE SCS.RUN_NAME = BUFFER_DETAIL.RUN_NAME)


DELETE FROM DISKSTATS
WHERE  DATABASE_NAME = @DATABASE_NAME

DELETE FROM PERF_DISKSTATS
WHERE  DATABASE_NAME = @DATABASE_NAME

DELETE FROM PERF_INDEX_DETAIL
WHERE  DATABASE_NAME = @DATABASE_NAME

DELETE FROM PERF_INDEX_USAGE_STATS
WHERE  DATABASE_NAME = @DATABASE_NAME



IF EXISTS (SELECT *
               FROM   sys.objects
               WHERE  object_id = Object_id(N'[dbo].[AX_INDEX_DETAIL]')
                      AND type IN ( N'U' )) 
BEGIN

DELETE FROM AX_INDEX_DETAIL
WHERE  DATABASE_NAME = @DATABASE_NAME

DELETE FROM AX_SQLTRACE
WHERE  DATABASE_NAME = @DATABASE_NAME

DELETE FROM AX_TABLE_DETAIL
WHERE  DATABASE_NAME = @DATABASE_NAME

DELETE FROM AX_NUM_SEQUENCES
WHERE  DATABASE_NAME = @DATABASE_NAME
END




END
ELSE
BEGIN

DELETE IO FROM INDEX_OPERATIONAL_STATS IO
WHERE  STATS_TIME <= @PURGE_DATE
AND STATS_TIME IN (SELECT STATS_TIME FROM STATS_COLLECTION_SUMMARY STATS WHERE STATS.STATS_TIME = IO.STATS_TIME AND STATS.RUN_NAME NOT LIKE 'BASE%')

AND NOT EXISTS(
SELECT DATABASE_NAME,
       SQL_SERVER_STARTTIME,
       max(STATS_TIME) as STATS_TIME
FROM   STATS_COLLECTION_SUMMARY SCS
WHERE  EXISTS (SELECT DISTINCT DATABASE_NAME,
                               SQL_SERVER_STARTTIME
               FROM   STATS_COLLECTION_SUMMARY SCS2
               WHERE  SCS2.DATABASE_NAME = SCS.DATABASE_NAME
                      AND SCS2.SQL_SERVER_STARTTIME = SCS.SQL_SERVER_STARTTIME)
GROUP  BY DATABASE_NAME,
          SQL_SERVER_STARTTIME
HAVING MAX(STATS_TIME) = IO.STATS_TIME
       AND DATABASE_NAME = IO.DATABASE_NAME   )
       
       

DELETE IPS FROM INDEX_PHYSICAL_STATS IPS
WHERE  STATS_TIME <= @PURGE_DATE
AND STATS_TIME IN (SELECT STATS_TIME FROM STATS_COLLECTION_SUMMARY STATS WHERE STATS.STATS_TIME = IPS.STATS_TIME AND STATS.RUN_NAME NOT LIKE 'BASE%')

AND NOT EXISTS(
SELECT DATABASE_NAME,
       SQL_SERVER_STARTTIME,
       max(STATS_TIME) as STATS_TIME
FROM   STATS_COLLECTION_SUMMARY SCS
WHERE  EXISTS (SELECT DISTINCT DATABASE_NAME,
                               SQL_SERVER_STARTTIME
               FROM   STATS_COLLECTION_SUMMARY SCS2
               WHERE  SCS2.DATABASE_NAME = SCS.DATABASE_NAME
                      AND SCS2.SQL_SERVER_STARTTIME = SCS.SQL_SERVER_STARTTIME)
      
GROUP  BY DATABASE_NAME,
          SQL_SERVER_STARTTIME
HAVING MAX(STATS_TIME) = IPS.STATS_TIME
       AND DATABASE_NAME = IPS.DATABASE_NAME   )
       
          
          
          

DELETE IUS FROM INDEX_USAGE_STATS IUS
WHERE STATS_TIME <= @PURGE_DATE
AND STATS_TIME IN (SELECT STATS_TIME FROM STATS_COLLECTION_SUMMARY STATS WHERE STATS.STATS_TIME = IUS.STATS_TIME AND STATS.RUN_NAME NOT LIKE 'BASE%')

AND NOT EXISTS(
SELECT DATABASE_NAME,
       SQL_SERVER_STARTTIME,
       max(STATS_TIME) as STATS_TIME
FROM   STATS_COLLECTION_SUMMARY SCS
WHERE  EXISTS (SELECT DISTINCT DATABASE_NAME,
                               SQL_SERVER_STARTTIME
               FROM   STATS_COLLECTION_SUMMARY SCS2
               WHERE  SCS2.DATABASE_NAME = SCS.DATABASE_NAME
                      AND SCS2.SQL_SERVER_STARTTIME = SCS.SQL_SERVER_STARTTIME)
      
GROUP  BY DATABASE_NAME,
          SQL_SERVER_STARTTIME
HAVING MAX(STATS_TIME) = IUS.STATS_TIME
       AND DATABASE_NAME = IUS.DATABASE_NAME  ) 
       
DELETE IOS FROM INDEX_OPERATIONAL_STATS IOS
WHERE STATS_TIME <= @PURGE_DATE
AND STATS_TIME IN (SELECT STATS_TIME FROM STATS_COLLECTION_SUMMARY STATS WHERE STATS.STATS_TIME = IOS.STATS_TIME AND STATS.RUN_NAME NOT LIKE 'BASE%')

AND NOT EXISTS(
SELECT DATABASE_NAME,
       SQL_SERVER_STARTTIME,
       max(STATS_TIME) as STATS_TIME
FROM   STATS_COLLECTION_SUMMARY SCS
WHERE  EXISTS (SELECT DISTINCT DATABASE_NAME,
                               SQL_SERVER_STARTTIME
               FROM   STATS_COLLECTION_SUMMARY SCS2
               WHERE  SCS2.DATABASE_NAME = SCS.DATABASE_NAME
                      AND SCS2.SQL_SERVER_STARTTIME = SCS.SQL_SERVER_STARTTIME)
       
GROUP  BY DATABASE_NAME,
          SQL_SERVER_STARTTIME
HAVING MAX(STATS_TIME) = IOS.STATS_TIME
       AND DATABASE_NAME = IOS.DATABASE_NAME  ) 
       
         

DELETE QS FROM QUERY_STATS QS
WHERE  STATS_TIME <= @PURGE_DATE
AND STATS_TIME IN (SELECT STATS_TIME FROM STATS_COLLECTION_SUMMARY STATS WHERE STATS.STATS_TIME = QS.STATS_TIME AND STATS.RUN_NAME NOT LIKE 'BASE%')

AND NOT EXISTS(
SELECT DATABASE_NAME,
       SQL_SERVER_STARTTIME,
       max(STATS_TIME) as STATS_TIME
FROM   STATS_COLLECTION_SUMMARY SCS
WHERE  EXISTS (SELECT DISTINCT DATABASE_NAME,
                               SQL_SERVER_STARTTIME
               FROM   STATS_COLLECTION_SUMMARY SCS2
               WHERE  SCS2.DATABASE_NAME = SCS.DATABASE_NAME
                      AND SCS2.SQL_SERVER_STARTTIME = SCS.SQL_SERVER_STARTTIME)
		
GROUP  BY DATABASE_NAME,
          SQL_SERVER_STARTTIME
HAVING MAX(STATS_TIME) = QS.STATS_TIME
       AND DATABASE_NAME = QS.DATABASE_NAME   )
       


DELETE QT FROM QUERY_TEXT QT
WHERE NOT EXISTS (SELECT QUERY_HASH FROM QUERY_STATS QS 
	WHERE QS.QUERY_HASH = QT.QUERY_HASH)
	

--REH Ver 1.1 Only remove the QUERY Plan once we have removed the QUERY STAT
--This allows us to keep only 1 copy of the Plan Handle and reduce our DB size if we are agressively collecting
DELETE QP FROM QUERY_PLANS QP
WHERE  NOT EXISTS (SELECT PLAN_HANDLE FROM QUERY_STATS QS 
	WHERE  QS.QUERY_PLAN_HASH=QP.QUERY_PLAN_HASH)

DELETE FROM WAIT_STATS
WHERE  STATS_TIME <= @PURGE_DATE
AND STATS_TIME IN (SELECT STATS_TIME FROM STATS_COLLECTION_SUMMARY STATS WHERE STATS.STATS_TIME = WAIT_STATS.STATS_TIME AND STATS.RUN_NAME NOT LIKE 'BASE%')


DELETE FROM BUFFER_DETAIL
WHERE  STATS_TIME <= @PURGE_DATE
AND STATS_TIME IN (SELECT STATS_TIME FROM STATS_COLLECTION_SUMMARY STATS WHERE STATS.STATS_TIME = BUFFER_DETAIL.STATS_TIME AND STATS.RUN_NAME NOT LIKE 'BASE%')


DELETE SC FROM SQL_CONFIGURATION SC
WHERE  STATS_TIME <= @PURGE_DATE
AND STATS_TIME IN (SELECT STATS_TIME FROM STATS_COLLECTION_SUMMARY STATS WHERE STATS.STATS_TIME = SC.STATS_TIME AND STATS.RUN_NAME NOT LIKE 'BASE%')

AND NOT EXISTS(
SELECT DATABASE_NAME,
       SQL_SERVER_STARTTIME,
       max(STATS_TIME) as STATS_TIME
FROM   STATS_COLLECTION_SUMMARY SCS
WHERE  EXISTS (SELECT DISTINCT DATABASE_NAME,
                               SQL_SERVER_STARTTIME
               FROM   STATS_COLLECTION_SUMMARY SCS2
               WHERE  SCS2.DATABASE_NAME = SCS.DATABASE_NAME
                      AND SCS2.SQL_SERVER_STARTTIME = SCS.SQL_SERVER_STARTTIME)
        
GROUP  BY DATABASE_NAME,
          SQL_SERVER_STARTTIME
HAVING MAX(STATS_TIME) = SC.STATS_TIME
          )
       
       

DELETE SD FROM SQL_DATABASEFILES SD
WHERE  STATS_TIME <= @PURGE_DATE
AND STATS_TIME IN (SELECT STATS_TIME FROM STATS_COLLECTION_SUMMARY STATS WHERE STATS.STATS_TIME = SD.STATS_TIME AND STATS.RUN_NAME NOT LIKE 'BASE%')

AND NOT EXISTS(
SELECT DATABASE_NAME,
       SQL_SERVER_STARTTIME,
       max(STATS_TIME) as STATS_TIME
FROM   STATS_COLLECTION_SUMMARY SCS
WHERE  EXISTS (SELECT DISTINCT DATABASE_NAME,
                               SQL_SERVER_STARTTIME
               FROM   STATS_COLLECTION_SUMMARY SCS2
               WHERE  SCS2.DATABASE_NAME = SCS.DATABASE_NAME
                      AND SCS2.SQL_SERVER_STARTTIME = SCS.SQL_SERVER_STARTTIME)
        
GROUP  BY DATABASE_NAME,
          SQL_SERVER_STARTTIME
HAVING MAX(STATS_TIME) = SD.STATS_TIME
       AND DATABASE_NAME = SD.DATABASE_NAME  ) 
       
       
       

DELETE SD FROM SQL_DATABASES SD
WHERE  STATS_TIME <= @PURGE_DATE
AND STATS_TIME IN (SELECT STATS_TIME FROM STATS_COLLECTION_SUMMARY STATS WHERE STATS.STATS_TIME = SD.STATS_TIME AND STATS.RUN_NAME NOT LIKE 'BASE%')

AND NOT EXISTS(
SELECT DATABASE_NAME,
       SQL_SERVER_STARTTIME,
       max(STATS_TIME) as STATS_TIME
FROM   STATS_COLLECTION_SUMMARY SCS
WHERE  EXISTS (SELECT DISTINCT DATABASE_NAME,
                               SQL_SERVER_STARTTIME
               FROM   STATS_COLLECTION_SUMMARY SCS2
               WHERE  SCS2.DATABASE_NAME = SCS.DATABASE_NAME
                      AND SCS2.SQL_SERVER_STARTTIME = SCS.SQL_SERVER_STARTTIME)
		
GROUP  BY DATABASE_NAME,
          SQL_SERVER_STARTTIME
HAVING MAX(STATS_TIME) = SD.STATS_TIME
       AND DATABASE_NAME = SD.DATABASE_NAME   )
       
          
          

DELETE SJ FROM SQL_JOBS SJ
WHERE  STATS_TIME <= @PURGE_DATE
AND STATS_TIME IN (SELECT STATS_TIME FROM STATS_COLLECTION_SUMMARY STATS WHERE STATS.STATS_TIME = SJ.STATS_TIME AND STATS.RUN_NAME NOT LIKE 'BASE%')

AND NOT EXISTS(
SELECT DATABASE_NAME,
       SQL_SERVER_STARTTIME,
       max(STATS_TIME) as STATS_TIME
FROM   STATS_COLLECTION_SUMMARY SCS
WHERE  EXISTS (SELECT DISTINCT DATABASE_NAME,
                               SQL_SERVER_STARTTIME
               FROM   STATS_COLLECTION_SUMMARY SCS2
               WHERE  SCS2.DATABASE_NAME = SCS.DATABASE_NAME
                      AND SCS2.SQL_SERVER_STARTTIME = SCS.SQL_SERVER_STARTTIME)
        
GROUP  BY DATABASE_NAME,
          SQL_SERVER_STARTTIME
HAVING MAX(STATS_TIME) = SJ.STATS_TIME
         )
       
       
DELETE SEL FROM SQLErrorLog SEL
WHERE  LOGDATE <= @PURGE_DATE



DELETE SS FROM STATS_COLLECTION_SUMMARY SS
WHERE  STATS_TIME <= @PURGE_DATE 
AND STATS_TIME IN (SELECT STATS_TIME FROM STATS_COLLECTION_SUMMARY STATS WHERE STATS.STATS_TIME = SS.STATS_TIME AND STATS.RUN_NAME NOT LIKE 'BASE%')

AND NOT EXISTS(
SELECT DATABASE_NAME,
       SQL_SERVER_STARTTIME,
       max(STATS_TIME) as STATS_TIME
FROM   STATS_COLLECTION_SUMMARY SCS
WHERE  EXISTS (SELECT DISTINCT DATABASE_NAME,
                               SQL_SERVER_STARTTIME
               FROM   STATS_COLLECTION_SUMMARY SCS2
               WHERE  SCS2.DATABASE_NAME = SCS.DATABASE_NAME
                      AND SCS2.SQL_SERVER_STARTTIME = SCS.SQL_SERVER_STARTTIME)
        
GROUP  BY DATABASE_NAME,
          SQL_SERVER_STARTTIME
HAVING MAX(STATS_TIME) = SS.STATS_TIME
       AND DATABASE_NAME = SS.DATABASE_NAME   )
       

DELETE FROM SERVERINFO
WHERE  NOT EXISTS (SELECT RUN_NAME FROM STATS_COLLECTION_SUMMARY SCS WHERE SCS.RUN_NAME = SERVERINFO.RUN_NAME AND SCS.RUN_NAME NOT LIKE 'BASE%')


       

DELETE FROM CAPTURE_LOG WHERE STATS_TIME <= @PURGE_DATE

DELETE TF FROM TRACEFLAGS TF
WHERE  STATS_TIME <= @PURGE_DATE
AND STATS_TIME IN (SELECT STATS_TIME FROM STATS_COLLECTION_SUMMARY STATS WHERE STATS.STATS_TIME = TF.STATS_TIME AND STATS.RUN_NAME NOT LIKE 'BASE%')

AND NOT EXISTS(
SELECT DATABASE_NAME,
       SQL_SERVER_STARTTIME,
       max(STATS_TIME) as STATS_TIME
FROM   STATS_COLLECTION_SUMMARY SCS
WHERE  EXISTS (SELECT DISTINCT DATABASE_NAME,
                               SQL_SERVER_STARTTIME
               FROM   STATS_COLLECTION_SUMMARY SCS2
               WHERE  SCS2.DATABASE_NAME = SCS.DATABASE_NAME
                      AND SCS2.SQL_SERVER_STARTTIME = SCS.SQL_SERVER_STARTTIME)
        
GROUP  BY DATABASE_NAME,
          SQL_SERVER_STARTTIME
HAVING MAX(STATS_TIME) = TF.STATS_TIME
         )
       

DELETE FROM DISKSTATS
WHERE  STATS_TIME <= @PURGE_DATE


DELETE PD FROM PERF_DISKSTATS PD
WHERE  STATS_TIME <= @PURGE_DATE
AND NOT EXISTS(
SELECT DATABASE_NAME,
       SQL_SERVER_STARTTIME,
       max(STATS_TIME) as STATS_TIME
FROM   STATS_COLLECTION_SUMMARY SCS
WHERE  EXISTS (SELECT DISTINCT DATABASE_NAME,
                               SQL_SERVER_STARTTIME
               FROM   STATS_COLLECTION_SUMMARY SCS2
               WHERE  SCS2.DATABASE_NAME = SCS.DATABASE_NAME
                      AND SCS2.SQL_SERVER_STARTTIME = SCS.SQL_SERVER_STARTTIME)
GROUP  BY DATABASE_NAME,
          SQL_SERVER_STARTTIME
HAVING MAX(STATS_TIME) = PD.STATS_TIME
       AND DATABASE_NAME = PD.DATABASE_NAME   )
       
       

DELETE FROM PERF_INDEX_DETAIL
WHERE  STATS_TIME <= DATEADD(DD,-730,@PURGE_DATE)

DELETE FROM PERF_INDEX_USAGE_STATS
WHERE  STATS_TIME <= DATEADD(DD,-730,@PURGE_DATE)

DELETE FROM PERF_WAIT_STATS
WHERE  STATS_TIME <= DATEADD(DD,-730,@PURGE_DATE)


IF EXISTS (SELECT *
               FROM   sys.objects
               WHERE  object_id = Object_id(N'[dbo].[AX_INDEX_DETAIL]')
                      AND type IN ( N'U' )) 
BEGIN

DELETE AD FROM AX_INDEX_DETAIL AD
WHERE  STATS_TIME <= @PURGE_DATE
AND STATS_TIME IN (SELECT STATS_TIME FROM STATS_COLLECTION_SUMMARY STATS WHERE STATS.STATS_TIME = AD.STATS_TIME AND STATS.RUN_NAME NOT LIKE 'BASE%')

AND NOT EXISTS(
SELECT DATABASE_NAME,
       SQL_SERVER_STARTTIME,
       max(STATS_TIME) as STATS_TIME
FROM   STATS_COLLECTION_SUMMARY SCS
WHERE  EXISTS (SELECT DISTINCT DATABASE_NAME,
                               SQL_SERVER_STARTTIME
               FROM   STATS_COLLECTION_SUMMARY SCS2
               WHERE  SCS2.DATABASE_NAME = SCS.DATABASE_NAME
                      AND SCS2.SQL_SERVER_STARTTIME = SCS.SQL_SERVER_STARTTIME)
        
GROUP  BY DATABASE_NAME,
          SQL_SERVER_STARTTIME
HAVING MAX(STATS_TIME) = AD.STATS_TIME
       AND DATABASE_NAME = AD.DATABASE_NAME   )
       
       

DELETE AXS FROM AX_SQLTRACE AXS
WHERE  STATS_TIME <= @PURGE_DATE

AND NOT EXISTS(
SELECT DATABASE_NAME,
       SQL_SERVER_STARTTIME,
       max(STATS_TIME) as STATS_TIME
FROM   STATS_COLLECTION_SUMMARY SCS
WHERE  EXISTS (SELECT DISTINCT DATABASE_NAME,
                               SQL_SERVER_STARTTIME
               FROM   STATS_COLLECTION_SUMMARY SCS2
               WHERE  SCS2.DATABASE_NAME = SCS.DATABASE_NAME
                      AND SCS2.SQL_SERVER_STARTTIME = SCS.SQL_SERVER_STARTTIME)
        
GROUP  BY DATABASE_NAME,
          SQL_SERVER_STARTTIME
HAVING MAX(STATS_TIME) = AXS.STATS_TIME
       AND DATABASE_NAME = AXS.DATABASE_NAME   )
       
       

DELETE AD FROM AX_TABLE_DETAIL AD
WHERE  STATS_TIME <= @PURGE_DATE
AND STATS_TIME IN (SELECT STATS_TIME FROM STATS_COLLECTION_SUMMARY STATS WHERE STATS.STATS_TIME = AD.STATS_TIME AND STATS.RUN_NAME NOT LIKE 'BASE%')

AND NOT EXISTS(
SELECT DATABASE_NAME,
       SQL_SERVER_STARTTIME,
       max(STATS_TIME) as STATS_TIME
FROM   STATS_COLLECTION_SUMMARY SCS
WHERE  EXISTS (SELECT DISTINCT DATABASE_NAME,
                               SQL_SERVER_STARTTIME
               FROM   STATS_COLLECTION_SUMMARY SCS2
               WHERE  SCS2.DATABASE_NAME = SCS.DATABASE_NAME
                      AND SCS2.SQL_SERVER_STARTTIME = SCS.SQL_SERVER_STARTTIME)
       
GROUP  BY DATABASE_NAME,
          SQL_SERVER_STARTTIME
HAVING MAX(STATS_TIME) = AD.STATS_TIME
       AND DATABASE_NAME = AD.DATABASE_NAME   )
       
       

DELETE ANS FROM AX_NUM_SEQUENCES ANS
WHERE  STATS_TIME <= @PURGE_DATE
AND STATS_TIME IN (SELECT STATS_TIME FROM STATS_COLLECTION_SUMMARY STATS WHERE STATS.STATS_TIME = ANS.STATS_TIME AND STATS.RUN_NAME NOT LIKE 'BASE%')

AND NOT EXISTS(
SELECT DATABASE_NAME,
       SQL_SERVER_STARTTIME,
       max(STATS_TIME) as STATS_TIME
FROM   STATS_COLLECTION_SUMMARY SCS
WHERE  EXISTS (SELECT DISTINCT DATABASE_NAME,
                               SQL_SERVER_STARTTIME
               FROM   STATS_COLLECTION_SUMMARY SCS2
               WHERE  SCS2.DATABASE_NAME = SCS.DATABASE_NAME
                      AND SCS2.SQL_SERVER_STARTTIME = SCS.SQL_SERVER_STARTTIME)
		
GROUP  BY DATABASE_NAME,
          SQL_SERVER_STARTTIME
HAVING MAX(STATS_TIME) = ANS.STATS_TIME
       AND DATABASE_NAME = ANS.DATABASE_NAME  ) 
       
       
       
END


END
ENDPROC:



GO





GO

/****** Object:  StoredProcedure [dbo].[SP_CAPTURESTATS_PERF]    Script Date: 08/29/2014 18:33:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

 


ALTER	PROCEDURE [dbo].[SP_CAPTURESTATS_PERF]
		@DATABASE_NAME	NVARCHAR(128),	
		@DEBUG			NVARCHAR(1)= 'N'  
AS

SET NOCOUNT ON
SET DATEFORMAT MDY


DECLARE @STATS_DATE SMALLDATETIME ,
		@DATABASE_ID INT,
		@SQL  NVARCHAR(MAX)
		
SET @STATS_DATE  = GETDATE()


TRUNCATE TABLE COLLECTIONDATABASES_PERF

IF @DATABASE_NAME IS NULL
BEGIN
INSERT COLLECTIONDATABASES_PERF SELECT * FROM DATABASES_2_COLLECT
END
ELSE
BEGIN
INSERT COLLECTIONDATABASES_PERF VALUES(@DATABASE_NAME)
END


DECLARE db_cursor CURSOR  LOCAL
FOR

SELECT DATABASENAME
FROM   DynamicsPerf..COLLECTIONDATABASES_PERF
ORDER  BY DATABASENAME 


/* Open the cursor */
/*if the cursor isn't open you will get an error when you fetch the record*/
OPEN db_cursor 

/* Get the first record */
/* you can FETCH NEXT, FIRST, LAST, PREVIOUS */
FETCH NEXT FROM db_cursor INTO @DATABASE_NAME

/* Verify that we got a record*/
/* status 0 means we got a good record*/

WHILE @@fetch_status = 0  /* no errors */
BEGIN /* Top of Loop */


		
SELECT @DATABASE_ID = database_id FROM sys.databases WITH (NOLOCK) WHERE name = @DATABASE_NAME


BEGIN TRY
PRINT 'STEP Insert PERF_INDEX_STATS for Database ' + @DATABASE_NAME

SET @SQL = '
	INSERT INTO PERF_INDEX_DETAIL WITH (TABLOCK) 
	SELECT	''' + CONVERT(NVARCHAR(50), @STATS_DATE, 121) + ''',''' + @DATABASE_NAME + ''',

			si.object_id,
			si.index_id,
			so.name, 
			si.name,  
			PS.DATA_SIZE AS PAGE_COUNT,
			PS.ROW_COUNT AS ROW_COUNT,
			0


	FROM	[' + @DATABASE_NAME + '].sys.indexes si
	JOIN	[' + @DATABASE_NAME + '].sys.sysindexes ii on si.object_id = ii.id and si.index_id = ii.indid
	JOIN	[' + @DATABASE_NAME + '].sys.objects so on so.object_id = si.object_id
	JOIN	[' + @DATABASE_NAME + '].sys.schemas ss on ss.schema_id = so.schema_id
	INNER JOIN  (SELECT object_id, index_id,SUM(row_count) AS ROW_COUNT,SUM(in_row_data_page_count + lob_used_page_count + row_overflow_used_page_count) AS DATA_SIZE	FROM [' + @DATABASE_NAME + '].sys.dm_db_partition_stats GROUP BY  object_id, index_id) as PS ON PS.index_id = si.index_id and PS.object_id = si.object_id

	WHERE	so.type = ''U''
	AND		si.type = 1  --CLUSTERED INDEXES ONLY
	UNION ALL 
	SELECT	''' + CONVERT(NVARCHAR(50), @STATS_DATE, 121) + ''',''' + @DATABASE_NAME + ''',
			si.object_id,
			si.index_id,
			so.name, 
			so.name, 
			PS.DATA_SIZE AS PAGE_COUNT,
			PS.ROW_COUNT AS ROW_COUNT,
			0
	FROM	[' + @DATABASE_NAME + '].sys.indexes si
	JOIN	[' + @DATABASE_NAME + '].sys.sysindexes ii on si.object_id = ii.id and si.index_id = ii.indid
	JOIN	[' + @DATABASE_NAME + '].sys.objects so on so.object_id = si.object_id
	JOIN	[' + @DATABASE_NAME + '].sys.schemas ss on ss.schema_id = so.schema_id
	INNER JOIN  (SELECT object_id, index_id,SUM(row_count) AS ROW_COUNT,SUM(in_row_data_page_count + lob_used_page_count + row_overflow_used_page_count) AS DATA_SIZE	FROM [' + @DATABASE_NAME + '].sys.dm_db_partition_stats GROUP BY  object_id, index_id) as PS ON PS.index_id = si.index_id and PS.object_id = si.object_id

	WHERE	so.type = ''U''
	AND		si.type = 0  --HEAP TABLE
	ORDER BY 1,2'

IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
END

EXECUTE (@SQL) 

PRINT 'Completed Successfully'
             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'
END CATCH




BEGIN TRY
PRINT 'STEP Insert PERF_INDEX_USAGE_STATS for Database ' + @DATABASE_NAME
INSERT INTO PERF_INDEX_USAGE_STATS WITH (TABLOCK)
SELECT	@STATS_DATE,
		@DATABASE_NAME,
		object_id,
		index_id,
		user_seeks,
		user_scans,
		user_lookups,
		user_updates
FROM	sys.dm_db_index_usage_stats
WHERE 	database_id = @DATABASE_ID
AND 	object_id > 99

PRINT 'Completed Successfully'
             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'
END CATCH



FETCH NEXT FROM db_cursor INTO @DATABASE_NAME
END  /*End of the loop */
CLOSE db_cursor  /*close the cursor to free memory in SQL*/
DEALLOCATE db_cursor /*Must deallocate the cursor to destroy it and free SQL resources*/
 

BEGIN TRY
PRINT 'STEP Insert Virtual I/O Stats'

INSERT PERF_DISKSTATS
SELECT  @STATS_DATE AS STATS_TIME ,
DB_NAME(database_id) AS DATABASENAME, 
database_id,file_id, sample_ms, num_of_reads,num_of_bytes_read, io_stall_read_ms, num_of_writes, num_of_bytes_written,io_stall_write_ms, io_stall, size_on_disk_bytes, file_handle
    FROM sys.dm_io_virtual_file_stats (NULL, NULL)

PRINT 'Completed Successfully'
             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'
END CATCH

BEGIN TRY 
PRINT 'STEP Insert WAIT_STATS'

INSERT 	INTO PERF_WAIT_STATS WITH (TABLOCK)
SELECT 	@STATS_DATE, *
FROM 	sys.dm_os_wait_stats

PRINT 'Completed Successfully'
             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'
END CATCH



GO



GO
/****** Object:  StoredProcedure [dbo].[SP_CAPTURESTATS_CORE]    Script Date: 09/16/2014 22:55:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER	PROCEDURE [dbo].[SP_CAPTURESTATS_CORE]
		@DATABASE_NAME	NVARCHAR(128),	
		@TOP_ROWS		INT = 0,
		@TOP_COLUMN		NVARCHAR(128) = 'total_elapsed_time',
		@RUN_NAME		NVARCHAR(60) = NULL,
		@INDEX_PHYSICAL_STATS 	NVARCHAR(1)= 'N',
		@STATS_DATE		DATETIME,
		@DEBUG			NVARCHAR(1) = 'N',
		@SKIP_STATS NVARCHAR(1) = 'Y'
AS

SET NOCOUNT ON
SET DATEFORMAT MDY

DECLARE 
		@LAST_STATS_DATE DATETIME,
		@SQL_VERSION	NVARCHAR(1000), 
		@DYNAMICS_VERSION NVARCHAR(MAX),
		@DATABASE_ID	INT,
		@RETURN_CODE	INT ,
		@SQL			NVARCHAR(MAX),
		@RUN_DESCRIPTION NVARCHAR(1000),
		@SQL_TOP_CLAUSE	NVARCHAR(128),
		@SQL_ORDERBY_CLAUSE	NVARCHAR(128),
		@PARM			NVARCHAR(500),
		@SQL_SERVER_STARTTIME DATETIME   

SET @RETURN_CODE = 0
SET @DYNAMICS_VERSION = 'Not a Dynamics Database'
SET @SQL_VERSION = @@VERSION




-- -----------------------------------------------------------------------------------------
-- Establish the clauses for the SQL that will collect data from the query stats DMV
-- If both TOP row count and a valid column to order by have been requested 
-- then we we will build TOP  and ORDER BY DESC clauses for the query on sys.dm_exec_query_stats.
-- -----------------------------------------------------------------------------------------
IF @TOP_ROWS	IS NULL SET @TOP_ROWS = 0
IF @TOP_COLUMN	IS NULL SET @TOP_COLUMN = ''

IF	@TOP_ROWS = 0 OR @TOP_COLUMN = ''
	BEGIN
		SET @SQL_TOP_CLAUSE = 'SELECT '
		SET @RUN_DESCRIPTION = 'N/A'
	END
ELSE
	SET	@SQL_TOP_CLAUSE = 'SELECT TOP '+STR(@TOP_ROWS)+' '
IF @TOP_ROWS = 0
    OR @TOP_COLUMN = ''
  SET @SQL_ORDERBY_CLAUSE = ' '
ELSE
  BEGIN
      IF @TOP_COLUMN NOT IN ( 'execution_count', 'total_worker_time', 'last_worker_time', 'min_worker_time',
                              'max_worker_time', 'total_physical_reads', 'last_physical_reads', 'min_physical_reads',
                              'max_physical_reads', 'total_logical_writes', 'last_logical_writes', 'min_logical_writes',
                              'max_logical_writes', 'total_logical_reads', 'last_logical_reads', 'min_logical_reads',
                              'max_logical_reads', 'total_clr_time', 'last_clr_time', 'min_clr_time',
                              'max_clr_time', 'total_elapsed_time', 'last_elapsed_time', 'min_elapsed_time', 'max_elapsed_time' )
        BEGIN
            PRINT @TOP_COLUMN + ' Is not valid as top column from sys.dm_exec_query_stats'

            GOTO ENDPROC
        END
      ELSE
        BEGIN
            SET @SQL_ORDERBY_CLAUSE = ' ORDER BY ' + @TOP_COLUMN + ' DESC  '
            SET @RUN_DESCRIPTION = @SQL_TOP_CLAUSE + 'sys.dm_exec_query_stats' + @SQL_ORDERBY_CLAUSE
        END
  END 

-- -----------------------------------------------------------------------------------------
-- If @RUN_NAME is not specified, just use current date/time
-- -----------------------------------------------------------------------------------------

If @RUN_NAME IS NULL
	SET @RUN_NAME = CONVERT(VARCHAR, @STATS_DATE,101)

SELECT @SQL_SERVER_STARTTIME = MIN(login_time) FROM sys.sysprocesses

IF @DEBUG = 'Y' 
BEGIN
PRINT '@STATS_DATE= ' + cast(@STATS_DATE as nvarchar(50))
PRINT '@RUN_NAME= ' + @RUN_NAME
PRINT '@DATABASE_NAME= ' + @DATABASE_NAME
PRINT '@SQL_SERVER_STARTTIME= ' + cast(@SQL_SERVER_STARTTIME as nvarchar(50))
END

--PRINT @STATS_DATE
--PRINT @RUN_NAME
--PRINT @DATABASE_NAME

--BEGIN TRANSACTION
-- -----------------------------------------------------------------------------------------
-- STATS_COLLECTION_SUMMARY will have one row for each time we execute SP_CAPTURESTATS
-- -----------------------------------------------------------------------------------------
BEGIN TRY
PRINT 'STEP Insert STATS_COLLECTION_SUMMARY record' + ' at ' + CONVERT(VARCHAR, GETDATE(),109)

DECLARE db_cursor CURSOR  LOCAL
FOR

SELECT DATABASENAME
FROM   DynamicsPerf..COLLECTIONDATABASES
ORDER  BY DATABASENAME 


/* Open the cursor */
/*if the cursor isn't open you will get an error when you fetch the record*/
OPEN db_cursor 

/* Get the first record */
/* you can FETCH NEXT, FIRST, LAST, PREVIOUS */
FETCH NEXT FROM db_cursor INTO @DATABASE_NAME

/* Verify that we got a record*/
/* status 0 means we got a good record*/

WHILE @@fetch_status = 0  /* no errors */
BEGIN /* Top of Loop */

INSERT INTO STATS_COLLECTION_SUMMARY
VALUES     ( @STATS_DATE,
             @RUN_NAME,
             @DATABASE_NAME,
             @SQL_VERSION,
             @DYNAMICS_VERSION,
             @RUN_DESCRIPTION,
             @SQL_SERVER_STARTTIME,
             'N') 
            
            
FETCH NEXT FROM db_cursor INTO @DATABASE_NAME
END  /*End of the loop */
CLOSE db_cursor  /*close the cursor to free memory in SQL*/
DEALLOCATE db_cursor /*Must deallocate the cursor to destroy it and free SQL resources*/
 
PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted STATS_COLLECTION_SUMMARY SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!' + ' at ' + CONVERT(VARCHAR, GETDATE(),109)
UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert STATS_COLLECTION_SUMMARY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
END CATCH


BEGIN TRY
PRINT 'STEP Insert INDEX_OPERATIONAL_STATS'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

DECLARE db_cursor CURSOR  LOCAL
FOR

SELECT DATABASENAME
FROM   DynamicsPerf..COLLECTIONDATABASES
ORDER  BY DATABASENAME 


/* Open the cursor */
/*if the cursor isn't open you will get an error when you fetch the record*/
OPEN db_cursor 

/* Get the first record */
/* you can FETCH NEXT, FIRST, LAST, PREVIOUS */
FETCH NEXT FROM db_cursor INTO @DATABASE_NAME

/* Verify that we got a record*/
/* status 0 means we got a good record*/

WHILE @@fetch_status = 0  /* no errors */
BEGIN /* Top of Loop */


SELECT @DATABASE_ID = database_id FROM sys.databases WITH (NOLOCK) WHERE name = @DATABASE_NAME

INSERT INTO INDEX_OPERATIONAL_STATS WITH (TABLOCK)
SELECT
	 @STATS_DATE AS current_datetime
	,@DATABASE_NAME
	,object_id
	,index_id
	,leaf_insert_count
	,leaf_delete_count
	,leaf_update_count
	,leaf_ghost_count
	,nonleaf_insert_count
	,nonleaf_delete_count
	,nonleaf_update_count
	,leaf_allocation_count
	,nonleaf_allocation_count
	,leaf_page_merge_count
	,nonleaf_page_merge_count
	,range_scan_count
	,singleton_lookup_count
	,forwarded_fetch_count
	,lob_fetch_in_pages
	,lob_fetch_in_bytes
	,lob_orphan_create_count
	,lob_orphan_insert_count
	,row_overflow_fetch_in_pages
	,row_overflow_fetch_in_bytes
	,column_value_push_off_row_count
	,column_value_pull_in_row_count
	,row_lock_count
	,row_lock_wait_count
	,row_lock_wait_in_ms
	,page_lock_count
	,page_lock_wait_count
	,page_lock_wait_in_ms
	,index_lock_promotion_attempt_count
	,index_lock_promotion_count
	,page_latch_wait_count
	,page_latch_wait_in_ms
	,page_io_latch_wait_count
	,page_io_latch_wait_in_ms
FROM sys.dm_db_index_operational_stats(@DATABASE_ID, NULL, NULL, NULL)
WHERE object_id > 99




FETCH NEXT FROM db_cursor INTO @DATABASE_NAME
END  /*End of the loop */
CLOSE db_cursor  /*close the cursor to free memory in SQL*/
DEALLOCATE db_cursor /*Must deallocate the cursor to destroy it and free SQL resources*/
 
			
			
PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)
UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted INDEX_OPERATIONAL_STATS SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)
UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert INDEX_OPERATIONAL_STATS at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE

END CATCH

-- -----------------------------------------------------------------------------------------
-- Because sys.dm_db_index_physical_stats is more expensive to collect, it is enabled
-- by @INDEX_PHYSICAL_STATS set to 'Y'.  The default is 'N' which bypassed.
-- -----------------------------------------------------------------------------------------
IF @INDEX_PHYSICAL_STATS = 'Y'

BEGIN TRY
PRINT 'STEP Insert INDEX_PHYSICAL_STATS'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)


DECLARE db_cursor CURSOR  LOCAL
FOR

SELECT DATABASENAME
FROM   DynamicsPerf..COLLECTIONDATABASES
ORDER  BY DATABASENAME 


/* Open the cursor */
/*if the cursor isn't open you will get an error when you fetch the record*/
OPEN db_cursor 

/* Get the first record */
/* you can FETCH NEXT, FIRST, LAST, PREVIOUS */
FETCH NEXT FROM db_cursor INTO @DATABASE_NAME

/* Verify that we got a record*/
/* status 0 means we got a good record*/

WHILE @@fetch_status = 0  /* no errors */
BEGIN /* Top of Loop */

SELECT @DATABASE_ID = database_id FROM sys.databases WITH (NOLOCK) WHERE name = @DATABASE_NAME


	INSERT INTO INDEX_PHYSICAL_STATS WITH (TABLOCK)
	SELECT
		 @STATS_DATE
		,@DATABASE_NAME
		, object_id
		, index_id
		,partition_number
		,index_type_desc
		,alloc_unit_type_desc
		,index_depth
		,avg_fragmentation_in_percent
		,fragment_count
		,avg_fragment_size_in_pages
	FROM sys.dm_db_index_physical_stats(@DATABASE_ID, NULL, NULL, NULL,NULL)
	WHERE object_id > 99



FETCH NEXT FROM db_cursor INTO @DATABASE_NAME
END  /*End of the loop */
CLOSE db_cursor  /*close the cursor to free memory in SQL*/
DEALLOCATE db_cursor /*Must deallocate the cursor to destroy it and free SQL resources*/
 
			
PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)
UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted INDEX_PHYSICAL_STATS SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
             
             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)
UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert INDEX_PHYSICAL_STATS at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE

END CATCH
	
	

IF @LAST_STATS_DATE IS NULL 
	SET @LAST_STATS_DATE = '1900-01-01'
-- -----------------------------------------------------------------------------------------
-- Dynamicaly build the SQL to retreive data from sys.dm_exec_query_stats.  This is needed due
-- sdue to the variability in what we need to do: the parameterized TOP and ORDER BY clauses 
-- plus establishing the date /time from which stats are to be collected. 
-- -----------------------------------------------------------------------------------------

DECLARE @SQLversion VARCHAR(30)
SELECT @SQLversion = cast(SERVERPROPERTY('ProductVersion') as varchar(30))


DECLARE db_cursor CURSOR  LOCAL
FOR

SELECT DATABASENAME
FROM   DynamicsPerf..COLLECTIONDATABASES
ORDER  BY DATABASENAME 


/* Open the cursor */
/*if the cursor isn't open you will get an error when you fetch the record*/
OPEN db_cursor 

/* Get the first record */
/* you can FETCH NEXT, FIRST, LAST, PREVIOUS */
FETCH NEXT FROM db_cursor INTO @DATABASE_NAME

/* Verify that we got a record*/
/* status 0 means we got a good record*/

WHILE @@fetch_status = 0  /* no errors */
BEGIN /* Top of Loop */
--PRINT 'DATABASE ='+@DATABASE_NAME

--REH    Deal with LAST_STATS_DATE for each database, moved the code from sp_capturestats to here to support multiple database captures
									
									
SET @LAST_STATS_DATE = '1/1/1900' 									
									
SELECT TOP 1 @LAST_STATS_DATE = STATS_TIME
FROM   STATS_COLLECTION_SUMMARY WITH (NOLOCK)
WHERE  STATS_TIME < @STATS_DATE
       AND DATABASE_NAME = @DATABASE_NAME
ORDER  BY STATS_TIME DESC

--REH if we are doing a baseline capture @RUN_NAME like 'BASE%' then use 1/1/1900
IF @RUN_NAME LIKE 'BASE%' 
BEGIN 
SET @LAST_STATS_DATE = '1/1/1900' 	
END

IF @DEBUG = 'Y'
  BEGIN
      PRINT '@LAST_STATS_DATE='

      PRINT @LAST_STATS_DATE
  END 

SET @SQL = 'INSERT INTO QUERY_STATS WITH (TABLOCK) ' 
	+ @SQL_TOP_CLAUSE + 'min(''' + CONVERT(NVARCHAR(24), @STATS_DATE, 121) + '''),' 
	+ 'min(''' + @DATABASE_NAME + ''')' +
	+ ',
	min(sql_handle),
	min(plan_handle),max(plan_generation_num), min(creation_time),max(last_execution_time),
	sum(execution_count), 
	sum(total_worker_time), 
	avg(last_worker_time), 
	min(min_worker_time), 
	max(max_worker_time), 
	sum(total_physical_reads), 
	avg(last_physical_reads), 
	min(min_physical_reads), 
	max(max_physical_reads), 
	sum(total_logical_writes), 
	avg(last_logical_writes), 
	min(min_logical_writes), 
	max(max_logical_writes), 
	sum(total_logical_reads), 
	avg(last_logical_reads), 
	min(min_logical_reads), 
	max(max_logical_reads), 
	sum(total_clr_time), 
	avg(last_clr_time), 
	min(min_clr_time), 
	max(max_clr_time), 
	sum(total_elapsed_time), 
	avg(last_elapsed_time), 
	min(min_elapsed_time), 
	max(max_elapsed_time),
	query_hash,
	query_plan_hash,
	sum(0)' --SQL2008 this column should be 0 for plan_handle_internal, so we join internally only on query_plan_hash

  
  --REH SQL2008R2 SP1 and above added the rows columns to this dmv
IF Serverproperty('ProductVersion') >= '10.50.2500'
  BEGIN
      SELECT @SQL = @SQL + ',sum(total_rows), avg(last_rows), max(max_rows), min(min_rows)'
  END
ELSE
  BEGIN
      SELECT @SQL = @SQL + ',sum(0),sum(0),sum(0),sum(0)'
  END 

SELECT @SQL = @SQL + '  
FROM	sys.dm_exec_query_stats
OUTER	APPLY sys.dm_exec_plan_attributes (plan_handle)
WHERE	attribute = N''dbid'' 
AND		dB_name(CONVERT(INT,value)) = ''' + @DATABASE_NAME + '''' + ' AND last_execution_time >= ' + '''' + CONVERT(NVARCHAR(24), @LAST_STATS_DATE, 121) + '''' 
+ ' group by query_hash, query_plan_hash

' + @SQL_ORDERBY_CLAUSE



IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
END


BEGIN TRY
PRINT 'STEP Insert QUERY_STATS for Database ' + @DATABASE_NAME
EXEC (@SQL) 
PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted QUERY_STATS SUCCESSFULLY for Database ' + @DATABASE_NAME + ' at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
             
END TRY



BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert QUERY_STATS for Database ' + @DATABASE_NAME + ' at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE

END CATCH

--REH Insert the SQL_TEXT statements


SET @SQL = '
CREATE TABLE [#QUERY_TEXT]
  (
	 [ROW_NUM]				[INT] identity(1,1),
     [QUERY_HASH]             [BINARY](8) NOT NULL,
     [SQL_TEXT]            [NVARCHAR](MAX) NULL,
  
  )
  
INSERT INTO #QUERY_TEXT  WITH (TABLOCK) ' +'
SELECT  qs.query_hash,
SUBSTRING(st.text, (qs.statement_start_offset/2)+1, 
        ((CASE qs.statement_end_offset
          WHEN -1 THEN DATALENGTH(st.text)
         ELSE qs.statement_end_offset
         END - qs.statement_start_offset)/2) + 1)'

SELECT @SQL = @SQL + ' 
FROM	sys.dm_exec_query_stats AS qs
OUTER	APPLY sys.dm_exec_plan_attributes (qs.PLAN_HANDLE)
CROSS APPLY sys.dm_exec_sql_text(qs.SQL_HANDLE) AS st
WHERE	attribute = N''dbid'' 
AND		dB_name(CONVERT(INT,value)) = ''' + @DATABASE_NAME + '''' + ' AND last_execution_time >= ' + '''' + CONVERT(NVARCHAR(24), @LAST_STATS_DATE, 121) + '''' 
+ ' AND NOT EXISTS (SELECT QUERY_HASH FROM QUERY_TEXT qt WHERE qt.QUERY_HASH = qs.query_hash)'


SELECT @SQL = @SQL + ' 

DELETE QT FROM  #QUERY_TEXT QT WHERE ROW_NUM NOT IN
 (SELECT MIN(ROW_NUM) FROM #QUERY_TEXT GROUP BY QUERY_HASH)

INSERT QUERY_TEXT SELECT QUERY_HASH, SQL_TEXT FROM #QUERY_TEXT


DROP TABLE #QUERY_TEXT'



IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
END



BEGIN TRY
PRINT 'STEP Insert SQL_TEXT for Database ' + @DATABASE_NAME
EXEC (@SQL) 
PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted SQL_TEXT SUCCESSFULLY for Database ' + @DATABASE_NAME + ' at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
             
END TRY



BEGIN CATCH

PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert SQL_TEXT for Database ' + @DATABASE_NAME + ' at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE

END CATCH




FETCH NEXT FROM db_cursor INTO @DATABASE_NAME
END  /*End of the loop */
CLOSE db_cursor  /*close the cursor to free memory in SQL*/
DEALLOCATE db_cursor /*Must deallocate the cursor to destroy it and free SQL resources*/
 
						

BEGIN TRY
PRINT 'STEP Insert QUERY_PLANS'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

/******************************************************************************************
*
* We are using the PLAN_HANDLE_INTERNAL column for the join between Query_Stats
*    and QUERY_Plans.  This field should be 0x000 on SQL2008+ because we only 
*	 want to join on QUERY_PLAN_HASH so we keep unique copies of plans to reduce 
*	 database size.  We can't just 0 out the plan_handle in the insert of query_stats
*	 because we need that column in this query so we can actually look up the plan
*	 to insert it.
*
******************************************************************************************/

CREATE TABLE [dbo].[#QUERY_PLANS_TEMP]
  (
     [STATS_TIME]      [DATETIME]  NULL,
     [DATABASE_NAME]   [NVARCHAR](128)  NULL,
     [PLAN_HANDLE]     [BINARY](64)  NULL,
     [QUERY_PLAN_HASH] [BINARY](8)  NULL,
     [QUERY_PLAN]      [XML] NULL
  )



;WITH Query_Stats_CTE ( QUERY_PLAN_HASH)
AS
-- Define the CTE query.
(
    SELECT DISTINCT  QUERY_PLAN_HASH
    FROM QUERY_STATS as QS WHERE STATS_TIME = @STATS_DATE
                     AND     NOT EXISTS (SELECT 'X'
                                  FROM   QUERY_PLANS QP
                                  WHERE  QP.QUERY_PLAN_HASH = QS.QUERY_PLAN_HASH) 
)
INSERT [#QUERY_PLANS_TEMP]
SELECT @STATS_DATE,@DATABASE_NAME, 0X00, QUERY_PLAN_HASH,''  FROM Query_Stats_CTE

--print 'step 1'
--SELECT TOP 1 QS.PLAN_HANDLE, PLNS.plan_handle
--                       FROM   --QUERY_STATS QS
--							sys.dm_exec_cached_plans PLNS   --REH removed this code since we weren't using any columns from the PLNS table, this was a perf change 
--                              INNER JOIN QUERY_STATS QS
--                                ON QS.PLAN_HANDLE = PLNS.plan_handle
--                              OUTER APPLY sys.dm_exec_query_plan(PLNS.PLAN_HANDLE)
--                       WHERE
                       
--                       QS.STATS_TIME = @STATS_DATE  




UPDATE [#QUERY_PLANS_TEMP]
SET    [QUERY_PLAN] = (SELECT TOP 1 QUERY_PLAN
                       FROM   QUERY_STATS QS
							--sys.dm_exec_cached_plans PLNS   --REH removed this code since we weren't using any columns from the PLNS table, this was a perf change 
       --                       INNER JOIN QUERY_STATS QS
       --                         ON QS.PLAN_HANDLE = PLNS.plan_handle
                              OUTER APPLY sys.dm_exec_query_plan(QS.PLAN_HANDLE)
                       WHERE
                       T1.QUERY_PLAN_HASH = QS.QUERY_PLAN_HASH AND
                       QS.STATS_TIME = @STATS_DATE  )
                      --REH if the plan already exists dont insert a new one, only keep 1 copy of the plan

FROM [#QUERY_PLANS_TEMP] T1

DELETE FROM [#QUERY_PLANS_TEMP] WHERE QUERY_PLAN IS NULL

BEGIN TRY

;WITH XMLNAMESPACES ('http://schemas.microsoft.com/sqlserver/2004/07/showplan' AS sp)
INSERT INTO QUERY_PLANS WITH (TABLOCK)
SELECT * FROM (
SELECT     QT.[QUERY_PLAN_HASH],QT.[QUERY_PLAN],
 CONVERT (NVARCHAR(MAX), index_node.query('for $qplan in //sp:QueryPlan, $plist in $qplan/sp:ParameterList, $colref in $plist/sp:ColumnReference  return concat(string($colref/@Column),":",string($colref/@ParameterCompiledValue),",   "),"  "')) as SQL_PARAMS,
 CASE WHEN CAST(QT.QUERY_PLAN AS NVARCHAR(MAX)) LIKE '%MissingIndex%' THEN 1 ELSE 0 END as MI_FLAG
 
  FROM [#QUERY_PLANS_TEMP] QT
      OUTER APPLY QUERY_PLAN.nodes('//sp:Batch') AS Batch(index_node)
     
 ) as A;
END TRY


--REH if this fails then the parsing of the SQL_PARMS failed, just insert the plans again w/o the SQL_PARMS parsing

BEGIN CATCH

PRINT 'ERROR ON PARSING SQL PARMS'

;WITH XMLNAMESPACES ('http://schemas.microsoft.com/sqlserver/2004/07/showplan' AS sp)
INSERT INTO QUERY_PLANS WITH (TABLOCK)
SELECT * FROM (
SELECT      QT.[STATS_TIME],QT.[DATABASE_NAME],QT.[PLAN_HANDLE],QT.[QUERY_PLAN_HASH],QT.[QUERY_PLAN],
 '' as SQL_PARAMS,
 CASE WHEN CAST(QT.QUERY_PLAN AS NVARCHAR(MAX)) LIKE '%MissingIndex%' THEN 1 ELSE 0 END as MI_FLAG
  FROM [#QUERY_PLANS_TEMP] QT
       OUTER APPLY QUERY_PLAN.nodes('//sp:Batch') AS Batch(index_node)
     
WHERE QT.[QUERY_PLAN] IS NOT NULL ) as A;
END CATCH


DROP TABLE [#QUERY_PLANS_TEMP]
--(
--SELECT @STATS_DATE,
--		@DATABASE_NAME,
--		QS.PLAN_HANDLE_INTERNAL,
--		QS.QUERY_PLAN_HASH, 
--		query_plan
--FROM	sys.dm_exec_cached_plans PLNS
--INNER JOIN Query_Stats_CTE QS ON QS.PLAN_HANDLE = PLNS.plan_handle
--OUTER	APPLY sys.dm_exec_query_plan(PLNS.plan_handle)
--WHERE	
--		--REH if the plan already exists dont insert a new one, only keep 1 copy of the plan
--		 NOT EXISTS ( SELECT 'X'  FROM QUERY_PLANS QP WHERE  QP.PLAN_HANDLE = QS.PLAN_HANDLE_INTERNAL
--		AND QP.QUERY_PLAN_HASH = QS.QUERY_PLAN_HASH))
		
		





PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted QUERY_PLANS SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert QUERY_PLANS at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
    
END CATCH






BEGIN TRY
PRINT 'STEP Insert INDEX_USAGE_STATS'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)


DECLARE db_cursor CURSOR  LOCAL
FOR

SELECT DATABASENAME
FROM   DynamicsPerf..COLLECTIONDATABASES
ORDER  BY DATABASENAME 


/* Open the cursor */
/*if the cursor isn't open you will get an error when you fetch the record*/
OPEN db_cursor 

/* Get the first record */
/* you can FETCH NEXT, FIRST, LAST, PREVIOUS */
FETCH NEXT FROM db_cursor INTO @DATABASE_NAME

/* Verify that we got a record*/
/* status 0 means we got a good record*/

WHILE @@fetch_status = 0  /* no errors */
BEGIN /* Top of Loop */


SELECT @DATABASE_ID = database_id FROM sys.databases WITH (NOLOCK) WHERE name = @DATABASE_NAME

INSERT INTO INDEX_USAGE_STATS WITH (TABLOCK)
SELECT	@STATS_DATE,
		@DATABASE_NAME,
		object_id,
		index_id,
		user_seeks,
		user_scans,
		user_lookups,
		user_updates,
		last_user_seek,
		last_user_scan,
		last_user_lookup,
		last_user_update,
		system_seeks,
		system_scans,
		system_lookups,
		system_updates,
		last_system_seek,
		last_system_scan,
		last_system_lookup,
		last_system_update
FROM	sys.dm_db_index_usage_stats
WHERE 	database_id = @DATABASE_ID
AND 	object_id > 99

PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)
  UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted INDEX_USAGE_STATS SUCCESSFULLY for ' +@DATABASE_NAME + ' at ' + CONVERT(VARCHAR, GETDATE(),109)+ ', ' 
WHERE STATS_TIME = @STATS_DATE

FETCH NEXT FROM db_cursor INTO @DATABASE_NAME
END  /*End of the loop */
CLOSE db_cursor  /*close the cursor to free memory in SQL*/
DEALLOCATE db_cursor /*Must deallocate the cursor to destroy it and free SQL resources*/
 
					             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)
UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert INDEX_USAGE_STATS at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE

END CATCH












BEGIN TRY
PRINT 'STEP Insert SYSOBJECTS tables'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)


DECLARE db_cursor CURSOR  LOCAL
FOR

SELECT DATABASENAME
FROM   DynamicsPerf..COLLECTIONDATABASES
ORDER  BY DATABASENAME 


/* Open the cursor */
/*if the cursor isn't open you will get an error when you fetch the record*/
OPEN db_cursor 

/* Get the first record */
/* you can FETCH NEXT, FIRST, LAST, PREVIOUS */
FETCH NEXT FROM db_cursor INTO @DATABASE_NAME

/* Verify that we got a record*/
/* status 0 means we got a good record*/

WHILE @@fetch_status = 0  /* no errors */
BEGIN /* Top of Loop */

		SET @SQL = 'DELETE FROM DYNSYSINDEXES WHERE DATABASE_NAME = ' + '''' + @DATABASE_NAME + '''' + ' INSERT INTO DYNSYSINDEXES 
		SELECT '+''''+ @DATABASE_NAME+''''+ ',[object_id],[name],[index_id],[type],[type_desc],[is_unique],[data_space_id]
			  ,[ignore_dup_key],[is_primary_key],[is_unique_constraint],[fill_factor],[is_padded]
			  ,[is_disabled],[is_hypothetical],[allow_row_locks],[allow_page_locks],[has_filter],[filter_definition]'

			SELECT @SQL = @SQL+'FROM	[' + @DATABASE_NAME + '].sys.indexes si'
			
		IF @DEBUG = 'Y' 
		BEGIN
		PRINT '@SQL= ' + @SQL
		END

		EXECUTE (@SQL) 


		SET @SQL = 'DELETE FROM DYNSYSOBJECTS WHERE DATABASE_NAME = ' + '''' + @DATABASE_NAME + '''' +'  INSERT INTO DYNSYSOBJECTS 
		SELECT '+''''+ @DATABASE_NAME+''''+ ',[name],[object_id] ,[principal_id],[schema_id],[parent_object_id]
      ,[type],[type_desc],[create_date],[modify_date],[is_ms_shipped],[is_published],[is_schema_published]'
			SELECT @SQL = @SQL+'FROM	[' + @DATABASE_NAME + '].sys.objects so'
			
		IF @DEBUG = 'Y' 
		BEGIN
		PRINT '@SQL= ' + @SQL
		END

		EXECUTE (@SQL) 

		SET @SQL = 'DELETE FROM DYNSYSPARTITIONS WHERE DATABASE_NAME = ' + '''' + @DATABASE_NAME + '''' +'  INSERT INTO DYNSYSPARTITIONS 
		SELECT '+''''+ @DATABASE_NAME+''''+ ',[partition_id],[object_id],[index_id],[partition_number]
      ,[hobt_id],[rows],[filestream_filegroup_id],[data_compression],[data_compression_desc]'
			SELECT @SQL = @SQL+'FROM	[' + @DATABASE_NAME + '].sys.partitions sp'
			
		IF @DEBUG = 'Y' 
		BEGIN
		PRINT '@SQL= ' + @SQL
		END

		EXECUTE (@SQL) 






PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)
  UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted DYNSYSOBJECTS SUCCESSFULLY for ' +@DATABASE_NAME + ' at ' + CONVERT(VARCHAR, GETDATE(),109)+ ', ' 
WHERE STATS_TIME = @STATS_DATE

FETCH NEXT FROM db_cursor INTO @DATABASE_NAME
END  /*End of the loop */
CLOSE db_cursor  /*close the cursor to free memory in SQL*/
DEALLOCATE db_cursor /*Must deallocate the cursor to destroy it and free SQL resources*/
 
					             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)
UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert SYSOBJECTS at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE

END CATCH













BEGIN TRY 
PRINT 'STEP Insert WAIT_STATS'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

INSERT 	INTO WAIT_STATS WITH (TABLOCK)
SELECT 	@STATS_DATE, *
FROM 	sys.dm_os_wait_stats

PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted WAIT_STATS SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
 
             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert WAIT_STATS at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
END CATCH


BEGIN TRY
PRINT 'STEP Insert INDEX_DETAIL'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)


DECLARE db_cursor CURSOR  LOCAL
FOR

SELECT DATABASENAME
FROM   DynamicsPerf..COLLECTIONDATABASES
ORDER  BY DATABASENAME 


/* Open the cursor */
/*if the cursor isn't open you will get an error when you fetch the record*/
OPEN db_cursor 

/* Get the first record */
/* you can FETCH NEXT, FIRST, LAST, PREVIOUS */
FETCH NEXT FROM db_cursor INTO @DATABASE_NAME

/* Verify that we got a record*/
/* status 0 means we got a good record*/

WHILE @@fetch_status = 0  /* no errors */
BEGIN /* Top of Loop */


SET @SQL = '
	INSERT INTO INDEX_DETAIL WITH (TABLOCK) 
	SELECT	''' + CONVERT(NVARCHAR(50), @STATS_DATE, 121) + ''',''' + @DATABASE_NAME + ''',

			si.object_id,
			si.index_id,
			so.name, 
			si.name,  
			si.type_desc+
			CASE
				WHEN is_unique = 1 THEN '', UNIQUE''
				ELSE ''''
			END
			+	
			CASE
				WHEN is_primary_key = 1 THEN '', PRIMARY KEY''
				ELSE ''''
			END
			+
			CASE
				WHEN has_filter = 1 THEN '', FILTERED''
				ELSE ''''
			END			
			
			,
	stuff	
		(
				
			(	
			SELECT '', '' + sc.name FROM	[' + @DATABASE_NAME + '].sys.index_columns sic
			JOIN	[' + @DATABASE_NAME + '].sys.columns sc on sc.column_id = sic.column_id
			WHERE	so.object_id = sic.object_id
			AND		sic.index_id = si.index_id
			AND		sc.object_id = so.object_id
			AND		sic.is_included_column=0
			order	by sic.key_ordinal
			for		xml path('''')
			)
		,1,1,''''
		)  AS key_columns,
	stuff
		(
			(
			SELECT	'', '' + sc.name FROM [' + @DATABASE_NAME + '].sys.index_columns sic
			JOIN	[' + @DATABASE_NAME + '].sys.columns sc on sc.column_id = sic.column_id
			WHERE	so.object_id = sic.object_id
			AND		sic.index_id = si.index_id
			AND		sc.object_id = so.object_id
			AND		sic.is_included_column=1
			ORDER BY sic.key_ordinal
			FOR XML path('''')
			)
		,1,1,''''
		)  AS included_columns,
	PS.DATA_SIZE AS PAGE_COUNT,
	PS.ROW_COUNT AS ROW_COUNT,
	sp.data_compression '
	

	SELECT @SQL = @SQL+'FROM	[' + @DATABASE_NAME + '].sys.indexes si
	JOIN	[' + @DATABASE_NAME + '].sys.sysindexes ii on si.object_id = ii.id and si.index_id = ii.indid
	JOIN	[' + @DATABASE_NAME + '].sys.objects so on so.object_id = si.object_id
	JOIN	[' + @DATABASE_NAME + '].sys.schemas ss on ss.schema_id = so.schema_id
	JOIN	[' + @DATABASE_NAME + '].sys.partitions sp on so.object_id = sp.object_id and sp.index_id = ii.indid
	INNER JOIN  (SELECT object_id, index_id,SUM(row_count) AS ROW_COUNT,SUM(in_row_data_page_count + lob_used_page_count + row_overflow_used_page_count) AS DATA_SIZE	FROM [' + @DATABASE_NAME + '].sys.dm_db_partition_stats GROUP BY  object_id, index_id) as PS ON PS.index_id = si.index_id and PS.object_id = si.object_id
	
	WHERE	so.type = ''U''
	AND		si.type > 0  --other than heap tables
	AND     sp.partition_number = 1  -- fix issue with partiioned tables multiplying the number or records we return
	UNION ALL 
	SELECT	''' + CONVERT(NVARCHAR(50), @STATS_DATE, 121) + ''',''' + @DATABASE_NAME + ''',
			si.object_id,
			si.index_id,
			so.name, 
			so.name, 
			''HEAP'',
			''N/A'', 
			''N/A'',
	PS.DATA_SIZE AS PAGE_COUNT,
	PS.ROW_COUNT AS ROW_COUNT,
	sp.data_compression '


	SELECT @SQL = @SQL+'		
	FROM	[' + @DATABASE_NAME + '].sys.indexes si
	JOIN	[' + @DATABASE_NAME + '].sys.sysindexes ii on si.object_id = ii.id and si.index_id = ii.indid
	JOIN	[' + @DATABASE_NAME + '].sys.objects so on so.object_id = si.object_id
	JOIN	[' + @DATABASE_NAME + '].sys.schemas ss on ss.schema_id = so.schema_id
	JOIN	[' + @DATABASE_NAME + '].sys.partitions sp on so.object_id = sp.object_id and sp.index_id = ii.indid
	INNER JOIN  (SELECT object_id, index_id,SUM(row_count) AS ROW_COUNT,SUM(in_row_data_page_count + lob_used_page_count + row_overflow_used_page_count) AS DATA_SIZE	FROM [' + @DATABASE_NAME + '].sys.dm_db_partition_stats GROUP BY  object_id, index_id) as PS ON PS.index_id = si.index_id and PS.object_id = si.object_id
	

	WHERE	so.type = ''U''
	AND		si.type = 0  
	AND     sp.partition_number = 1  -- fix issue with partiioned tables multiplying the number or records we return
	ORDER BY 1,2'

IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
END

EXECUTE (@SQL) 



FETCH NEXT FROM db_cursor INTO @DATABASE_NAME
END  /*End of the loop */
CLOSE db_cursor  /*close the cursor to free memory in SQL*/
DEALLOCATE db_cursor /*Must deallocate the cursor to destroy it and free SQL resources*/
 
PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)
UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted INDEX_DETAIL SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
 
             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert INDEX_DETAIL at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
 
  
END CATCH

BEGIN TRY
PRINT 'STEP Insert SQL data cache buffer'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)
--Insert Buffer information
;
INSERT INTO [DynamicsPerf]..BUFFER_DETAIL

SELECT @RUN_NAME,
       CONVERT(NVARCHAR(50), @STATS_DATE, 121),
       CASE
         WHEN database_id = 32767 THEN 'resourceDb'
         ELSE Cast(Db_name(database_id) AS NVARCHAR(128))
       END,

        COUNT(*)*8/1024 
FROM   sys.dm_os_buffer_descriptors WITH(nolock)
GROUP BY database_id


PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted BUFFER_DETAIL SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
 
      
             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert BUFFER_DETAIL at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
 
    
END CATCH


--Insert Database information

BEGIN TRY
PRINT 'STEP Insert SQL Databases information'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)
SET @SQL = '
	INSERT INTO [DynamicsPerf]..SQL_DATABASES SELECT ''' + @RUN_NAME + ''',
	''' + CONVERT(NVARCHAR(50), @STATS_DATE, 121) + ''',
	[name]
      ,[database_id]
      ,[source_database_id]
      ,[owner_sid]
      ,[create_date]
      ,[compatibility_level]
      ,[collation_name]
      ,[user_access]
      ,[user_access_desc]
      ,[is_read_only]
      ,[is_auto_close_on]
      ,[is_auto_shrink_on]
      ,[state]
      ,[state_desc]
      ,[is_in_standby]
      ,[is_cleanly_shutdown]
      ,[is_supplemental_logging_enabled]
      ,[snapshot_isolation_state]
      ,[snapshot_isolation_state_desc]
      ,[is_read_committed_snapshot_on]
      ,[recovery_model]
      ,[recovery_model_desc]
      ,[page_verify_option]
      ,[page_verify_option_desc]
      ,[is_auto_create_stats_on]
      ,[is_auto_update_stats_on]
      ,[is_auto_update_stats_async_on]
      ,[is_ansi_null_default_on]
      ,[is_ansi_nulls_on]
      ,[is_ansi_padding_on]
      ,[is_ansi_warnings_on]
      ,[is_arithabort_on]
      ,[is_concat_null_yields_null_on]
      ,[is_numeric_roundabort_on]
      ,[is_quoted_identifier_on]
      ,[is_recursive_triggers_on]
      ,[is_cursor_close_on_commit_on]
      ,[is_local_cursor_default]
      ,[is_fulltext_enabled]
      ,[is_trustworthy_on]
      ,[is_db_chaining_on]
      ,[is_parameterization_forced]
      ,[is_master_key_encrypted_by_server]
      ,[is_published]
      ,[is_subscribed]
      ,[is_merge_published]
      ,[is_distributor]
      ,[is_sync_with_backup]
      ,[service_broker_guid]
      ,[is_broker_enabled]
      ,[log_reuse_wait]
      ,[log_reuse_wait_desc]
      ,[is_date_correlation_on]
	FROM sys.databases '

IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
END

EXECUTE (@SQL) 
PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted SQL_DATABASES SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
 
 
             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert SQL_DATABASES SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
 
END CATCH

--Insert SQL configuration

BEGIN TRY
PRINT 'STEP Insert SQL Configurations'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

SET @SQL = '
	INSERT INTO [DynamicsPerf]..SQL_CONFIGURATION SELECT ''' + @RUN_NAME + ''',
	''' + CONVERT(NVARCHAR(50), @STATS_DATE, 121) + ''', 
      name,
      convert(int, minimum) as minimum,
      convert(int, maximum) as maximum,
      convert(int, isnull(value, value_in_use)) as config_value,
      convert(int, value_in_use) as run_value
from  sys.configurations
order by lower(name)'

IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
END

EXECUTE (@SQL) 
PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted SQL_CONFIGURATION SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
 
 
             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert SQL_CONFIGURATION at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
 
END CATCH



BEGIN TRY
PRINT 'STEP Insert SQL Database File Information'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

IF EXISTS (SELECT name FROM tempdb..sysobjects WHERE name = '##Results')  
   BEGIN  
       DROP TABLE ##Results  
   END 
    
CREATE TABLE ##Results
  (
     [Database Name]         SYSNAME,
     [File Name]             SYSNAME,
     [Physical Name]         NVARCHAR(260),
     [File Type]             VARCHAR(4),
     [Total Size in Mb]      INT,
     [Available Space in Mb] INT,
     [Growth Units]          VARCHAR(15),
     [max File Size in Mb]   INT,
     [file_id]				 INT
  ) 

SELECT @SQL =  
'USE [?] INSERT INTO ##Results([Database Name], [File Name], [Physical Name],  
[File Type], [Total Size in Mb], [Available Space in Mb],  
[Growth Units], [max File Size in Mb], [file_id])  
SELECT DB_NAME(), 
[name] AS [File Name],  
physical_name AS [Physical Name],  
[File Type] =  
CASE type 
WHEN 0 THEN ''Data'''  
+ 
           'WHEN 1 THEN ''Log''' 
+ 
       'END, 
[Total Size in Mb] = 
CASE ceiling([size]/128)  
WHEN 0 THEN 1 
ELSE ceiling([size]/128) 
END, 
[Available Space in Mb] =  
CASE ceiling([size]/128) 
WHEN 0 THEN (1 - CAST(FILEPROPERTY([name], ''SpaceUsed''' + ') as int) /128) 
ELSE (([size]/128) - CAST(FILEPROPERTY([name], ''SpaceUsed''' + ') as int) /128) 
END, 
[Growth Units]  =  
CASE [is_percent_growth]  
WHEN 1 THEN CAST(growth AS varchar(20)) + ''%''' 
+ 
           'ELSE CAST(growth/128 AS varchar(20)) + ''Mb''' 
+ 
       'END, 
[max File Size in Mb] =  
CASE [max_size] 
WHEN -1 THEN NULL 
WHEN 268435456 THEN NULL 
ELSE [max_size] 
END ,
[file_id]
FROM sys.database_files
ORDER BY [File Type], [file_id]' 

--Print the command to be issued against all databases 
--PRINT @SQL 

IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
END

--Run the command against each database 
EXEC sp_MSforeachdb @SQL 
--PRINT @SQL
--UPDATE ##Results SET [Free Space %] = [Available Space in Mb]/[Total Size in Mb] * 100 
--print 'Results Table'
--select * from ##Results

INSERT INTO [DynamicsPerf]..SQL_DATABASEFILES
SELECT @RUN_NAME                                                                           AS [RUN_NAME],
       CONVERT(NVARCHAR(50), @STATS_DATE, 121)                                             AS [STATS_TIME],
       [Database Name],
       [file_id],
       [File Name],
       [Physical Name],
       [File Type],
       [Total Size in Mb]                                                                  AS [DB Size (Mb)],
       [Available Space in Mb]                                                             AS [DB Free (Mb)],
       Ceiling(CAST([Available Space in Mb] AS DECIMAL(10, 1)) / [Total Size in Mb] * 100) AS [Free Space %],
       [Growth Units],
       [max File Size in Mb]                                                               AS [Grow max Size (Mb)]
FROM   ##Results
--Return the Results  

DROP TABLE ##Results

PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted SQL_DATABASES SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
 
             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert SQL_DATABASES at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
 
      
END CATCH


BEGIN TRY
PRINT 'STEP Insert SQL Virtual Log Files Information'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

DECLARE @ADHOC INT


IF Substring(@SQLversion, 1, 3) = '10.'
BEGIN
SET @ADHOC = (SELECT cast(value as int) FROM sys.configurations WHERE name = 'Ad Hoc Distributed Queries');

exec sp_configure 'Ad Hoc Distributed Queries',1
RECONFIGURE WITH OVERRIDE

TRUNCATE TABLE LOGINFO  -- Clear the table out each time we collect

SELECT @SQL =  
'USE [?]



INSERT  DynamicsPerf..LOGINFO
SELECT ''?'', FileId,FileSize,StartOffset,FSeqNo,Status,Parity,CreateLSN FROM 
OPENROWSET('+QUOTENAME('SQLNCLI','''')+', '
+QUOTENAME('Server=' + cast(Serverproperty('MachineName') as varchar(128))+ISNULL('\'+cast(Serverproperty('InstanceName')as varchar(128)),'')
       +';Database='+'?'+';Trusted_Connection=yes;','''')+','

+
'''set fmtonly OFF;exec(''''DBCC LOGINFO WITH NO_INFOMSGS'''')'''+ ') AS a'



--Print the command to be issued against all databases 
--PRINT @SQL 

IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
END



--Run the command against each database 
EXEC sp_MSforeachdb  @command1=@SQL 
                    --,@command2=@SQL2

					
exec sp_configure 'Ad Hoc Distributed Queries',@ADHOC
RECONFIGURE WITH OVERRIDE

END

ELSE
BEGIN
SET @ADHOC = (SELECT cast(value as int) FROM sys.configurations WHERE name = 'Ad Hoc Distributed Queries');

exec sp_configure 'Ad Hoc Distributed Queries',1
RECONFIGURE WITH OVERRIDE

TRUNCATE TABLE LOGINFO  -- Clear the table out each time we collect

SELECT @SQL =  
'
INSERT  DynamicsPerf..LOGINFO
SELECT ''?'', FileId,FileSize,StartOffset,FSeqNo,Status,Parity,CreateLSN FROM 
OPENROWSET('+QUOTENAME('SQLNCLI','''')+', '
+QUOTENAME('Server=' + cast(serverproperty('MachineName') as varchar(128))+ISNULL('\'+cast(serverproperty('InstanceName') as varchar(128)),'')
       +';Database='+'?'+';Trusted_Connection=yes;','''')+','

+
'''exec(''''DBCC LOGINFO'''') 
with result sets ((q char, FileId int, FileSize bigint, StartOffset bigint, FSeqNo int, Status tinyint, Parity tinyint, CreateLSN numeric(25,0) ))
'''+ ') AS a'


--Print the command to be issued against all databases 
--PRINT @SQL 

IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
END



--Run the command against each database 
EXEC sp_MSforeachdb  @command1=@SQL 
                    --,@command2=@SQL2

					
exec sp_configure 'Ad Hoc Distributed Queries',@ADHOC
RECONFIGURE WITH OVERRIDE

END

PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted VLF LOG SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
 
             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

--REH set this back so we dont leave it in incorrect state
exec sp_configure 'Ad Hoc Distributed Queries',@ADHOC
RECONFIGURE WITH OVERRIDE

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert VLF LOG at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
 
    
END CATCH


BEGIN TRY
PRINT 'STEP Insert SQL Job(s) Information'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

DECLARE @weekDay TABLE (
  mask      INT,
  maskValue VARCHAR(32)); 

INSERT INTO @weekDay
SELECT 1, 'Sunday'  UNION All
SELECT 2, 'Monday'  UNION All
SELECT 4, 'Tuesday'  UNION All
SELECT 8, 'Wednesday'  UNION All
SELECT 16, 'Thursday'  UNION All
SELECT 32, 'Friday'  UNION All
SELECT 64, 'Saturday';
 
WITH myCTE
AS(
 SELECT sched.name                                                                                     AS 'scheduleName',
        sched.schedule_id,
        jobsched.job_id,
        CASE
          WHEN sched.freq_type = 1 THEN 'Once'
          WHEN sched.freq_type = 4
               AND sched.freq_interval = 1 THEN 'Daily'
          WHEN sched.freq_type = 4 THEN 'Every ' + CAST(sched.freq_interval AS VARCHAR(5)) + ' days'
          WHEN sched.freq_type = 8 THEN REPLACE(REPLACE(REPLACE((SELECT maskValue
                                                                 FROM   @weekDay AS x
                                                                 WHERE  sched.freq_interval & x.mask <> 0
                                                                 ORDER  BY mask
                                                                 FOR XML RAW), '"/><row maskValue="', ', '), '<row maskValue="', ''), '"/>', '') + CASE
                                                                                                                                                     WHEN sched.freq_recurrence_factor <> 0
                                                                                                                                                          AND sched.freq_recurrence_factor = 1 THEN '; weekly'
                                                                                                                                                     WHEN sched.freq_recurrence_factor <> 0 THEN '; every ' + CAST(sched.freq_recurrence_factor AS VARCHAR(10)) + ' weeks'
                                                                                                                                                   END
          WHEN sched.freq_type = 16 THEN 'On day ' + CAST(sched.freq_interval AS VARCHAR(10)) + ' of every ' + CAST(sched.freq_recurrence_factor AS VARCHAR(10)) + ' months'
          WHEN sched.freq_type = 32 THEN CASE
                                           WHEN sched.freq_relative_interval = 1 THEN 'First'
                                           WHEN sched.freq_relative_interval = 2 THEN 'Second'
                                           WHEN sched.freq_relative_interval = 4 THEN 'Third'
                                           WHEN sched.freq_relative_interval = 8 THEN 'Fourth'
                                           WHEN sched.freq_relative_interval = 16 THEN 'Last'
                                         END + CASE
                                                 WHEN sched.freq_interval = 1 THEN ' Sunday'
                                                 WHEN sched.freq_interval = 2 THEN ' Monday'
                                                 WHEN sched.freq_interval = 3 THEN ' Tuesday'
                                                 WHEN sched.freq_interval = 4 THEN ' Wednesday'
                                                 WHEN sched.freq_interval = 5 THEN ' Thursday'
                                                 WHEN sched.freq_interval = 6 THEN ' Friday'
                                                 WHEN sched.freq_interval = 7 THEN ' Saturday'
                                                 WHEN sched.freq_interval = 8 THEN ' Day'
                                                 WHEN sched.freq_interval = 9 THEN ' Weekday'
                                                 WHEN sched.freq_interval = 10 THEN ' Weekend'
                                               END + CASE
                                                       WHEN sched.freq_recurrence_factor <> 0
                                                            AND sched.freq_recurrence_factor = 1 THEN '; monthly'
                                                       WHEN sched.freq_recurrence_factor <> 0 THEN '; every ' + CAST(sched.freq_recurrence_factor AS VARCHAR(10)) + ' months'
                                                     END
          WHEN sched.freq_type = 64 THEN 'StartUp'
          WHEN sched.freq_type = 128 THEN 'Idle'
        END                                                                                            AS 'frequency',
        Isnull('Every ' + CAST(sched.freq_subday_interval AS VARCHAR(10)) + CASE
                                                                              WHEN sched.freq_subday_type = 2 THEN ' seconds'
                                                                              WHEN sched.freq_subday_type = 4 THEN ' minutes'
                                                                              WHEN sched.freq_subday_type = 8 THEN ' hours'
                                                                            END, 'Once')               AS 'subFrequency',
        Replicate('0', 6 - Len(sched.active_start_time)) + CAST(sched.active_start_time AS VARCHAR(6)) AS 'startTime',
        Replicate('0', 6 - Len(sched.active_end_time)) + CAST(sched.active_end_time AS VARCHAR(6))     AS 'endTime',
        Replicate('0', 6 - Len(jobsched.next_run_time)) + CAST(jobsched.next_run_time AS VARCHAR(6))   AS 'nextRunTime',
        CAST(jobsched.next_run_date AS CHAR(8))                                                        AS 'nextRunDate'
 FROM   msdb.dbo.sysschedules AS sched
        JOIN msdb.dbo.sysjobschedules AS jobsched
          ON sched.schedule_id = jobsched.schedule_id
 WHERE  sched.enabled = 1 
 
)

INSERT INTO SQL_JOBS
SELECT @RUN_NAME                                                                                                                                                                                                      AS [RUN_NAME],
       CONVERT(NVARCHAR(50), @STATS_DATE, 121)                                                                                                                                                                        AS [STATS_TIME],
       job.name                                                                                                                                                                                                       AS 'jobName',
       sched.scheduleName,
       sched.frequency,
       sched.subFrequency,
       Substring(sched.startTime, 1, 2) + ':' + Substring(sched.startTime, 3, 2) + ' - ' + Substring(sched.endTime, 1, 2) + ':' + Substring(sched.endTime, 3, 2)                                                      AS 'scheduleTime' -- HH:MM
       ,
       Substring(sched.nextRunDate, 1, 4) + '/' + Substring(sched.nextRunDate, 5, 2) + '/' + Substring(sched.nextRunDate, 7, 2) + ' ' + Substring(sched.nextRunTime, 1, 2) + ':' + Substring(sched.nextRunTime, 3, 2) AS 'nextRunDate'
       /* Note: the sysjobschedules table refreshes every 20 min, 
         so nextRunDate may be out of date */
       ,
       steps.step_id,
       steps.step_name,
       steps.subsystem,
       steps.command
FROM   msdb.dbo.sysjobs AS job
       JOIN myCTE AS sched
         ON job.job_id = sched.job_id
       INNER JOIN msdb.dbo.sysjobsteps steps
         ON steps.job_id = job.job_id
WHERE  job.enabled = 1 -- do not display disabled jobs
ORDER  BY nextRunDate 

PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted SQL_JOBS SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
 
             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO inserted SQL_JOBS at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
 
END CATCH

--Insert Server Information
--Needs updating to support SQL 2005

BEGIN TRY
PRINT 'STEP Insert SERVERINFO table'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)


SELECT @SQL = '

INSERT INTO SERVERINFO WITH (TABLOCK)
SELECT '+QUOTENAME(@RUN_NAME,'''')

SELECT @SQL = @SQL + ',
       '+ QUOTENAME(CONVERT(NVARCHAR(50), @STATS_DATE, 121),'''') +',
       '+QUOTENAME(@SQL_SERVER_STARTTIME,'''')+',
       Serverproperty(''ComputerNamePhysicalNetBIOS'') AS PhysicalComputerName,
       Serverproperty(''IsClustered'')                 AS IsClustered,
       Serverproperty(''MachineName'')                 AS MachineName,
       Serverproperty(''InstanceName'')                AS InstanceName,
       Serverproperty(''ProductVersion'')              AS ProductVersion,
       Serverproperty(''ProductLevel'')                AS ProductLevel,
       Serverproperty(''Edition'')                     AS Edition,
       Serverproperty(''EngineEdition'')               AS EngineEdition,
       Serverproperty(''SqlCharSet'')                  AS SqlCharSet,
       Serverproperty(''SqlCharSetName'')              AS SqlCharSetName,
       Serverproperty(''SqlSortOrder'')                AS SqlSortOrder,
       Serverproperty(''SqlSortOrderName'')            AS SqlSortOrderName,
       cpu_count,
       hyperthread_ratio,'

	   IF Serverproperty('ProductVersion') >= '11.0'
	   BEGIN
	   SELECT @SQL = @SQL +'
       committed_kb / 1024                     AS Bpool_Committed_MB,
       committed_target_kb / 1024                 AS Bpool_Commit_Target_MB,
       visible_target_kb / 1024                       AS Bpool_Visible_MB,
       cntr_value                                    AS Page_Life_Expectancy,
       (SELECT SUM(pages_kb) FROM sys.dm_os_memory_clerks WHERE name = ''TokenAndPermUserStore'') AS [CurrentSizeOfTokenCache(kb)]
	   '
		END
		ELSE
		BEGIN
		SELECT  @SQL = @SQL + 'bpool_committed / 1024 * 8                    AS Bpool_Committed_MB,
       bpool_commit_target / 1024 * 8                AS Bpool_Commit_Target_MB,
       bpool_visible / 1024 * 8                      AS Bpool_Visible_MB,
       cntr_value                                    AS Page_Life_Expectancy,
       (SELECT SUM(single_pages_kb + multi_pages_kb) FROM sys.dm_os_memory_clerks WHERE name = ''TokenAndPermUserStore'') AS [CurrentSizeOfTokenCache(kb)]
	   '
		END

SELECT @SQL = @SQL + '
FROM   sys.dm_os_sys_info,
       sys.dm_os_performance_counters
WHERE  counter_name = ''Page life expectancy''
       AND ( object_name = ''SQLServer:Buffer Manager''
              OR object_name LIKE ''%'' + CAST(Serverproperty(''InstanceName'') AS VARCHAR(50)) + '':Buffer Manager%'' ) '



IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
END

EXEC( @SQL)

PRINT 'Completed Successfully at ' + CONVERT(VARCHAR, GETDATE(),109)



UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted SERVERINFO SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
 
             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert SERVERINFO at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
 
END CATCH


BEGIN TRY
PRINT 'STEP Insert SERVER_REGISTRY table'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)


IF Serverproperty('ProductVersion') >= '10.50.2500'
BEGIN
TRUNCATE TABLE SERVER_REGISTRY
INSERT SERVER_REGISTRY
SELECT registry_key,
       value_name,
       value_data FROM sys.dm_server_registry; 
END

       
PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted SERVER_REGISTRY SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
 
             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert SERVER_REGISTRY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
 
END CATCH



BEGIN TRY
PRINT 'STEP Insert SERVER_DISKVOLUMES table'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

TRUNCATE TABLE SERVER_DISKVOLUMES

IF Serverproperty('ProductVersion') >= '10.50.2500'
BEGIN
INSERT SERVER_DISKVOLUMES
SELECT DISTINCT vs.volume_mount_point,-- e.g. C:\   
                vs.volume_id,
                vs.logical_volume_name,
                vs.file_system_type,-- e.g. NTFS
                vs.total_bytes / 1024 / 1024,
                vs.available_bytes / 1024 / 1024,
                CONVERT(DECIMAL(5, 2), vs.available_bytes * 100.0 / vs.total_bytes),
                vs.supports_compression,
                vs.supports_alternate_streams,
                vs.supports_sparse_files,
                vs.is_read_only,
                vs.is_compressed
FROM   sys.sysaltfiles AS f
       CROSS APPLY sys.dm_os_volume_stats(f.dbid, f.fileid) AS vs
WHERE  f.dbid < 32767
ORDER  BY 7 DESC 
END

PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)
UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted SERVER_DISKVOLUMES SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
 
             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert SERVER_DISKVOLUMES at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
 
END CATCH




--BEGIN TRY
--PRINT 'STEP Insert SERVER_SERVICES table'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)
--TRUNCATE TABLE SERVER_SERVICES

--IF Serverproperty('ProductVersion') >= '10.50.2500'
--BEGIN
--INSERT SERVER_SERVICES
--SELECT servicename,
--       startup_type_desc,
--       status_desc,
--       process_id,
--       last_startup_time,
--       service_account,
--       is_clustered
--FROM   sys.dm_server_services; 
--END
          

--PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

--UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted SERVER_SERVICES SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
--WHERE STATS_TIME = @STATS_DATE
 
             
--END TRY

--BEGIN CATCH
--PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

--UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert SERVER_SERVICES at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
--WHERE STATS_TIME = @STATS_DATE
 
--END CATCH



BEGIN TRY
PRINT 'STEP Insert SERVER_OS_VERSION table'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)
TRUNCATE TABLE SERVER_OS_VERSION

IF Serverproperty('ProductVersion') >= '10.50.2500'
BEGIN
INSERT SERVER_OS_VERSION

SELECT windows_release,
       windows_service_pack_level,
       windows_sku,
       os_language_version  FROM sys.dm_os_windows_info; 
END
          

PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted SERVER_OS_VERSION SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE

             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert SERVER_OS_VERSION at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE
 
END CATCH

--Insert Database Triggers information

BEGIN TRY
PRINT 'STEP Insert Databases Triggers information'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)


DECLARE db_cursor CURSOR  LOCAL
FOR

SELECT DATABASENAME
FROM   DynamicsPerf..COLLECTIONDATABASES
ORDER  BY DATABASENAME 


/* Open the cursor */
/*if the cursor isn't open you will get an error when you fetch the record*/
OPEN db_cursor 

/* Get the first record */
/* you can FETCH NEXT, FIRST, LAST, PREVIOUS */
FETCH NEXT FROM db_cursor INTO @DATABASE_NAME

/* Verify that we got a record*/
/* status 0 means we got a good record*/

WHILE @@fetch_status = 0  /* no errors */
BEGIN /* Top of Loop */


SET @SQL = '
USE '+@DATABASE_NAME+'
DELETE FROM [DynamicsPerf]..TRIGGER_TABLE WHERE DATABASE_NAME = '''+@DATABASE_NAME+'''
DECLARE @triggername NVARCHAR(128)
DECLARE @triggertable NVARCHAR(128) 
DECLARE @schemaname NVARCHAR(128) 


CREATE TABLE #TempTrigger
  (
     TRIGGER_TEXT VARCHAR(max)
  ) 

DECLARE tnames_cursor CURSOR FOR
  SELECT t.name, SCH.name,
         p.name AS tablename
  FROM   ['+@DATABASE_NAME+']..sysobjects t
         INNER JOIN ['+@DATABASE_NAME+']..sysobjects p
           ON t.parent_obj = p.id
			 INNER JOIN ['+@DATABASE_NAME+'].sys.schemas SCH
           ON t.uid = SCH.schema_id
  WHERE  t.type = ''TR''

OPEN tnames_cursor

FETCH NEXT FROM tnames_cursor INTO @triggername,@schemaname, @triggertable

WHILE ( @@FETCH_STATUS <> -1 )
  BEGIN
      IF ( @@FETCH_STATUS <> -2 )
        BEGIN
        SELECT @schemaname = @schemaname + ''.''
            INSERT #TempTrigger
            EXEC (''sp_helptext [''  + @schemaname + @triggername +'']'' )

            INSERT [DynamicsPerf]..TRIGGER_TABLE
            SELECT '''+@DATABASE_NAME+''',
                   @triggertable ,
                   @triggername  ,
                   *
            FROM   #TempTrigger

            TRUNCATE TABLE #TempTrigger
        END

      FETCH NEXT FROM tnames_cursor INTO @triggername, @schemaname, @triggertable
  END

DEALLOCATE tnames_cursor 
DROP TABLE #TempTrigger



	'

IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
END

EXECUTE (@SQL) 
PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

FETCH NEXT FROM db_cursor INTO @DATABASE_NAME
END  /*End of the loop */
CLOSE db_cursor  /*close the cursor to free memory in SQL*/
DEALLOCATE db_cursor /*Must deallocate the cursor to destroy it and free SQL resources*/
 
 
 
UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted TRIGGERS SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE

									             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert TRIGGERS at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE

END CATCH


 -- Capture Statistics Information
 
 --Delete any existing records, we are only keeping 1 set of stats per database
 
 BEGIN TRY
 PRINT 'STEP Insert SQL Statistics information'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)
 IF @SKIP_STATS='Y'  GOTO SKIPSTATS
 
--REH added check so we dont collect stats more then 1 time per day to reduce time to collect data

DECLARE @LAST_STATS_COLLECTION_DATE DATETIME 



IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[#TableStats]'))
BEGIN 
DROP TABLE #TableStats
END


CREATE TABLE #TableStats
  (
     Density FLOAT,
     Length  INT NULL,
     columns NVARCHAR(2078)
  ) 
  


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[##TableHistogram]'))
 BEGIN
DROP TABLE #TableHistogram
END

CREATE TABLE #TableHistogram
  (
     Range_HI_Key        SQL_VARIANT,
     Range_Rows          BIGINT NULL,
     EQ_Rows             BIGINT,
     Distinct_Range_Rows BIGINT,
     Avg_Range_Rows      BIGINT
  ) 



DECLARE db_cursor CURSOR  LOCAL
FOR

SELECT DATABASENAME
FROM   DynamicsPerf..COLLECTIONDATABASES
ORDER  BY DATABASENAME 


/* Open the cursor */
/*if the cursor isn't open you will get an error when you fetch the record*/
OPEN db_cursor 

/* Get the first record */
/* you can FETCH NEXT, FIRST, LAST, PREVIOUS */
FETCH NEXT FROM db_cursor INTO @DATABASE_NAME

/* Verify that we got a record*/
/* status 0 means we got a good record*/

WHILE @@fetch_status = 0  /* no errors */
BEGIN /* Top of Loop */



TRUNCATE TABLE #TableStats
TRUNCATE TABLE #TableHistogram

SET @LAST_STATS_COLLECTION_DATE = NULL

SET @LAST_STATS_COLLECTION_DATE =
	 ISNULL((SELECT MAX(STATS_TIME) FROM STATS_COLLECTION_SUMMARY WHERE DATABASE_NAME = @DATABASE_NAME AND STATS_COLLECTED = 'Y'),'1/1/1900')



IF @DEBUG = 'Y'
BEGIN
PRINT 'DATABASE = ' + @DATABASE_NAME
PRINT '@LAST_STATS_COLLECTION_DATE = ' + CAST(@LAST_STATS_COLLECTION_DATE AS VARCHAR(50))
END

--reh We only want to collect stats on Sunday or if we have never collected them
IF (DATEPART(DW, GETDATE()) = 1 AND DATEDIFF(DD,@LAST_STATS_COLLECTION_DATE, GETDATE()) >0)
OR @LAST_STATS_COLLECTION_DATE = '1/1/1900'
BEGIN
 
 DELETE FROM INDEX_DENSITY_VECTOR WHERE DATABASE_NAME = @DATABASE_NAME
 DELETE FROM INDEX_HISTOGRAM WHERE DATABASE_NAME = @DATABASE_NAME

DECLARE @tablename sysname
DECLARE @indexname sysname
DECLARE @colname sysname
DECLARE @schemaname sysname


--Create synonyms for the database
SET @SQL = '
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N' + Quotename('DYN_SYSOBJECTS', '''') + ')
DROP SYNONYM [dbo].[DYN_SYSOBJECTS]

CREATE SYNONYM DYN_SYSOBJECTS
FOR [' + @DATABASE_NAME + '].sys.sysobjects;'

IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
END

EXEC(@SQL) 


SET @SQL = '
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N' + Quotename('DYN_SYSSTATS', '''') + ')
DROP SYNONYM [dbo].[DYN_SYSSTATS]

CREATE SYNONYM DYN_SYSSTATS
FOR [' + @DATABASE_NAME + '].sys.stats;'

IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
END

EXEC(@SQL) 

SET @SQL = '
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N' + Quotename('DYN_SYSSTATSCOL', '''') + ')
DROP SYNONYM [dbo].[DYN_SYSSTATSCOL]

CREATE SYNONYM DYN_SYSSTATSCOL
FOR [' + @DATABASE_NAME + '].sys.stats_columns;'

IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
END

EXEC(@SQL) 

SET @SQL = '
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N' + Quotename('DYN_SYSCOLS', '''') + ')
DROP SYNONYM [dbo].[DYN_SYSCOLS]

CREATE SYNONYM DYN_SYSCOLS
FOR [' + @DATABASE_NAME + '].sys.columns;'

IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
END

EXEC(@SQL)

SET @SQL = '
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N' + Quotename('DYN_SYSSCHEMA', '''') + ')
DROP SYNONYM [dbo].[DYN_SYSSCHEMA]

CREATE SYNONYM DYN_SYSSCHEMA
FOR [' + @DATABASE_NAME + '].sys.schemas;'

IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
END

EXEC(@SQL) 

SET @SQL = '
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N' + Quotename('DYN_SYSINDEXES', '''') + ')
DROP SYNONYM [dbo].[DYN_SYSINDEXES]

CREATE SYNONYM DYN_SYSINDEXES
FOR [' + @DATABASE_NAME + '].sys.indexes;'

IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
END

EXEC(@SQL) 

SET @SQL = '
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N' + Quotename('DYN_SYSINDEXCOLS', '''') + ')
DROP SYNONYM [dbo].[DYN_SYSINDEXCOLS]

CREATE SYNONYM DYN_SYSINDEXCOLS
FOR [' + @DATABASE_NAME + '].sys.index_columns;'

IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
END

EXEC(@SQL) 

DECLARE table_cursor CURSOR
   FOR SELECT O.name,
              ST.name,
              C.name,
              SCH.name
       FROM   DYN_SYSOBJECTS O
              INNER JOIN DYN_SYSSTATS ST
                      ON O.id = ST.object_id
              INNER JOIN DYN_SYSSTATSCOL AS SC
                      ON ST.object_id = SC.object_id
                         AND ST.stats_id = SC.stats_id
              INNER JOIN DYN_SYSCOLS AS C
                      ON SC.object_id = C.object_id
                         AND C.column_id = SC.column_id
              INNER JOIN DYN_SYSSCHEMA AS SCH
                      ON O.uid = SCH.schema_id
       WHERE  O.xtype = 'u'
              AND SC.stats_column_id = 1
              AND C.system_type_id <> 189
              AND SCH.name <> 'sys' --remove timestamps, incompatiable with sql_variant datatype we used
              AND ( ST.auto_created = 1
               OR ST.user_created = 1)
       UNION ALL
       SELECT O.name,
              ST.name,
              C.name,
              SCH.name
       FROM   DYN_SYSOBJECTS O
              INNER JOIN DYN_SYSSTATS ST
                      ON O.id = ST.object_id
              INNER JOIN DYN_SYSSTATSCOL AS SC
                      ON ST.object_id = SC.object_id
                         AND ST.stats_id = SC.stats_id
              INNER JOIN DYN_SYSCOLS AS C
                      ON SC.object_id = C.object_id
                         AND C.column_id = SC.column_id
              INNER JOIN DYN_SYSSCHEMA AS SCH
                      ON O.uid = SCH.schema_id
       WHERE  O.xtype = 'u'
              AND SC.stats_column_id = 1
              AND C.system_type_id <> 189
              AND SCH.name <> 'sys' --remove timestamps, incompatiable with sql_variant datatype we used
              AND (ST.auto_created = 0
              AND ST.user_created = 0 )
       

/* Open the cursor */
/*if the cursor isn't open you will get an error when you fetch the record*/
OPEN table_cursor 

/* Get the first record */
/* you can FETCH NEXT, FIRST, LAST, PREVIOUS */
FETCH NEXT FROM table_cursor INTO @tablename, @indexname, @colname, @schemaname

/* Verify that we got a record*/
/* status 0 means we got a good record*/



WHILE @@fetch_status = 0  /* no errors */
BEGIN /* Top of Loop */
--	print @tablename + '    ' + @indexname
	SELECT @SQL = 'DBCC SHOW_STATISTICS('+'''' +@DATABASE_NAME +'.'+@schemaname+'.' +@tablename + '''' +',' +QUOTENAME(@indexname,'''')+') WITH DENSITY_VECTOR, NO_INFOMSGS'
		
		IF @DEBUG = 'Y' 
		BEGIN
		PRINT '@SQL= ' + @SQL
		END
		
	Begin Try
	INSERT  #TableStats	
	EXEC  (@SQL	) --DBCC SHOW_STATISTICS DENSITY VECTOR
	
	End Try
	Begin Catch
	 --ignore the error
	End catch
	
	insert  INDEX_DENSITY_VECTOR SELECT @DATABASE_NAME,@tablename,@indexname,* FROM #TableStats
	truncate table #TableStats
	
	SELECT @SQL = 'DBCC SHOW_STATISTICS('+'''' +@DATABASE_NAME +'.'+@schemaname+'.' +@tablename + '''' +',' +QUOTENAME(@indexname,'''')+') WITH HISTOGRAM, NO_INFOMSGS'
		
		IF @DEBUG = 'Y' 
		BEGIN
		PRINT '@SQL= ' + @SQL
		END
	
	Begin Try

	INSERT  #TableHistogram	
	EXEC  (@SQL	) --DBCC SHOW_STATISTICS HISTOGRAM
	
	End Try
	Begin Catch
	 --ignore the error
	End catch

	
	INSERT  INDEX_HISTOGRAM SELECT @DATABASE_NAME,@tablename,@indexname,@colname,* FROM #TableHistogram
	TRUNCATE TABLE #TableHistogram
	/* Get the next record */
	FETCH NEXT FROM table_cursor INTO @tablename,@indexname,@colname,@schemaname
END  /*End of the loop */
CLOSE table_cursor  /*close the cursor to free memory in SQL*/
DEALLOCATE table_cursor /*Must deallocate the cursor to destroy it and free SQL resources*/

UPDATE STATS_COLLECTION_SUMMARY SET STATS_COLLECTED = 'Y' WHERE RUN_NAME = @RUN_NAME AND DATABASE_NAME = @DATABASE_NAME


END


PRINT 'Completed Collecting Statistics Successfully for ' +@DATABASE_NAME+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted STATISTICS SUCCESSFULLY for ' + @DATABASE_NAME + ' at ' + CONVERT(VARCHAR, GETDATE(),109)+ ', ' 
WHERE STATS_TIME = @STATS_DATE



FETCH NEXT FROM db_cursor INTO @DATABASE_NAME
END  /*End of the loop */
CLOSE db_cursor  /*close the cursor to free memory in SQL*/
DEALLOCATE db_cursor /*Must deallocate the cursor to destroy it and free SQL resources*/


SKIPSTATS:
PRINT 'Completed Collecting Statistics Successfully '

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted STATISTICS SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+ ', ' 
WHERE STATS_TIME = @STATS_DATE
              
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert STATISTICS at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE

END CATCH

--REH Added 11/9/2010  Capture Trace flag information

BEGIN TRY
PRINT 'STEP Insert SQL Trace Flag Options'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)
CREATE TABLE #TRACEFLAGS
  (
     TRACEFLAG    INT,
     STATUS       BIT,
     GLOBAL       BIT,
     SESSIONS     BIT
  ) 
SET @SQL = 'DBCC TRACESTATUS(-1) WITH NO_INFOMSGS '

IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
END


INSERT  #TRACEFLAGS
EXEC (@SQL)

INSERT TRACEFLAGS 
SELECT @STATS_DATE,*  FROM #TRACEFLAGS

PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted TRACE_FLAGS SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE

             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert TRACE_FLAGS at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE

END CATCH


BEGIN TRY
PRINT 'STEP Insert Virtual I/O Stats'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

INSERT DISKSTATS
SELECT  @STATS_DATE AS STATS_TIME ,
DB_NAME(database_id) AS DATABASENAME, 
database_id,file_id, sample_ms, num_of_reads,num_of_bytes_read, io_stall_read_ms, num_of_writes, num_of_bytes_written,io_stall_write_ms, io_stall, size_on_disk_bytes, file_handle
    FROM sys.dm_io_virtual_file_stats (NULL, NULL)

PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted VIRTUAL_I/O SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE

             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO Insert VIRTUAL_I/O at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE


END CATCH



--Capture SQL Error LOG


BEGIN TRY
PRINT 'STEP Insert SQL Error Logs'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

DECLARE @version VARCHAR(30)
SELECT @version = cast(SERVERPROPERTY('ProductVersion') as varchar(30))

IF @DEBUG = 'Y' 
BEGIN
PRINT '@VERSION= ' + @version
END


IF Substring(@version, 1, 2) = '9.'
  BEGIN --Check SQL2005 build
      IF @version < '9.00.4230'
        GOTO ENDERRORLOG --xp_readerrorlog might fail, skip this step
  END 
IF Substring(@version, 1, 2) = '10'
  BEGIN --Check SQL2008 build
      IF @version < '10.0.2734'
        GOTO ENDERRORLOG --xp_readerrorlog might fail, skip this step
  END 

--REH  Figure out the last time we captured for any database and use the newest capture
SET @LAST_STATS_DATE = '1/1/1900' 									
									
SELECT TOP 1 @LAST_STATS_DATE = STATS_TIME
FROM   STATS_COLLECTION_SUMMARY WITH (NOLOCK)
WHERE STATS_TIME < @STATS_DATE  --Not the current collection or it won't grab anything
ORDER  BY STATS_TIME DESC

DECLARE @STARTDATE VARCHAR(30), @ENDDATE VARCHAR(30)
SELECT @STARTDATE = CONVERT(varchar(30),@LAST_STATS_DATE,25)
SELECT @ENDDATE = CONVERT(varchar(30),@STATS_DATE,25)

IF CAST(@STARTDATE AS SMALLDATETIME) < DATEADD(D,-14, GETDATE()) 
BEGIN
SELECT @STARTDATE = CONVERT(varchar(30),DATEADD(D,-14,GETDATE()),25)

END



CREATE TABLE #ErrorLog
  (
     LogDate     DATETIME,
     ProcessInfo NVARCHAR(255),
     LogText     NVARCHAR(MAX)
  ); 


INSERT INTO #ErrorLog (
   [LogDate],
   [ProcessInfo],
   [LogText]
)

EXEC xp_readerrorlog 0,1,NULL,NULL,@STARTDATE, @ENDDATE, 'ASC'

INSERT INTO SQLErrorLog 
SELECT * FROM #ErrorLog 
DROP TABLE #ErrorLog;  

ENDERRORLOG:
PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted SQL_ERROR_LOG SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE

             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO Insert SQL_ERROR_LOG at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE

END CATCH
ENDPROC:



RETURN @RETURN_CODE



GO



GO

/****** Object:  StoredProcedure [dbo].[SP_CAPTURESTATS_AX]    Script Date: 09/23/2014 09:59:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER	PROCEDURE [dbo].[SP_CAPTURESTATS_AX]
		@DATABASE_NAME	NVARCHAR(128),	
		@RUN_NAME		NVARCHAR(60) = NULL,
		@STATS_DATE		DATETIME,
		@LAST_STATS_DATE DATETIME,
		@DEBUG			NVARCHAR(1)='N'
 
AS

SET NOCOUNT ON
SET DATEFORMAT MDY

DECLARE
		@APP_BUILD		NVARCHAR(120),
		@KERNEL_BUILD	NVARCHAR(20),
		@RETURN_CODE	INT,
		@SQL			NVARCHAR(MAX),
		@PARM			NVARCHAR(500)		
		
		
SET @RETURN_CODE = 0
-- -----------------------------------------------------------------------------------------
-- Get kernel version information.
-- If used with prodcts other than  Dynamics AX, remove or comment the SP_EXEXCUTESQL below
-- -----------------------------------------------------------------------------------------

SET @SQL= 'SELECT TOP 1 @KERNEL_BUILD_OUT = KERNELBUILD FROM [' + @DATABASE_NAME + ']..SYSSETUPLOG WITH (NOLOCK) ORDER BY RECID DESC'
SET @PARM = '@KERNEL_BUILD_OUT NVARCHAR(20) OUTPUT' 

IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
PRINT '@PARM= ' + @PARM
END

BEGIN TRY
    EXEC sp_executesql
      @SQL,
      @PARM,
      @KERNEL_BUILD_OUT = @KERNEL_BUILD OUTPUT
END TRY 

BEGIN CATCH
PRINT 'NOT A DYNAMICS AX DATABASE'
RETURN (0);
END CATCH

SET @RETURN_CODE = 0
-- -----------------------------------------------------------------------------------------
-- Get application version information.
-- If used with prodcts other than  Dynamics AX, remove or comment the SP_EXEXCUTESQL below
-- -----------------------------------------------------------------------------------------

SET @SQL= 'SELECT TOP 1 @APP_BUILD_OUT = VALUE FROM [' + @DATABASE_NAME + ']..SYSCONFIG WITH (NOLOCK) WHERE CONFIGTYPE = 4 AND ID = 6'
SET @PARM = '@APP_BUILD_OUT NVARCHAR(120) OUTPUT' 

IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
PRINT '@PARM= ' + @PARM
END

BEGIN TRY
    EXEC sp_executesql
      @SQL,
      @PARM,
      @APP_BUILD_OUT = @APP_BUILD OUTPUT
END TRY 

BEGIN CATCH
PRINT 'NOT A DYNAMICS AX DATABASE'
RETURN (0);
END CATCH

UPDATE STATS_COLLECTION_SUMMARY SET DYNAMICS_VERSION = 'Appbuild = ' + @APP_BUILD + ' Kernel Build = ' + @KERNEL_BUILD  
WHERE RUN_NAME = @RUN_NAME AND DATABASE_NAME=@DATABASE_NAME


IF Substring(@APP_BUILD, 1, 1) BETWEEN N'3' AND N'4'

BEGIN TRY
PRINT 'STEP Insert AX3 SQL Trace table'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)
  BEGIN
      SET @SQL = 'SET DATEFORMAT MDY;
		INSERT INTO AX_SQLTRACE WITH (TABLOCK) 
		   (STATS_TIME
		   ,DATABASE_NAME
		   ,SQL_DURATION
		   ,TRACE_CATEGORY
		   ,SQL_TEXT
		   ,CALL_STACK
		   ,TRACE_EVENT_CODE
		   ,TRACE_EVENT_DESC
		   ,TRACE_EVENT_DETAILS
		   ,CONNECTION_TYPE
		   ,SQL_SESSION_ID
		   ,AX_CONNECTION_ID
		   ,IS_LOBS_INCLUDED
		   ,IS_MORE_DATA_PENDING
		   ,ROWS_AFFECTED
		   ,ROW_SIZE
		   ,ROWS_PER_FETCH
		   ,IS_SELECTED_FOR_UPDATE
		   ,IS_STARTED_WITHIN_TRANSACTION
		   ,SQL_TYPE
		   ,STATEMENT_ID
		   ,STATEMENT_REUSE_COUNT
		   ,DETAIL_TYPE
		   ,CREATED_DATETIME
		   ,AX_USER_ID)
		SELECT 
			''' + CONVERT(NVARCHAR(50), @STATS_DATE, 121) + ''',''' + @DATABASE_NAME + '''
			,TRACETIME
			,CATEGORY
			,STATEMENT
			,CALLSTACK
			,CODE
			,TEXT
			,TEXTDETAILS
			,CONNECTIONTYPE
			,CONNECTIONSPID
			,CONNECTIONID
			,ISLOBSINCLUDED
			,ISMOREDATAPENDING
			,ROWSAFFECTED
			,ROWSIZE
			,ROWSPERFETCH
			,ISSELECTEDFORUPDATE
			,ISSTARTEDWITHINTRANSACTION
			,STATEMENTTYPE
			,STATEMENTID
			,STATEMENTREUSECOUNT
			,DETAILTYPE
			,DATEADD(minute, DATEDIFF(minute,getutcdate(),getdate()), DATEADD(S, CREATEDTIME, CREATEDDATE))
			,CREATEDBY

		  
		FROM [' + @DATABASE_NAME + '].DBO.SYSTRACETABLESQL  WITH (NOLOCK)
		WHERE DATEADD(minute, DATEDIFF(minute,getutcdate(),getdate()), CREATEDDATETIME) >= ''' + CONVERT(NVARCHAR(24), @LAST_STATS_DATE, 121) + ''''
	+ ' AND DATEADD(D, 14, CREATEDDATE) >= ''' + CONVERT(NVARCHAR(24), GETDATE(), 121) + ''''
		IF @DEBUG = 'Y' 
		BEGIN
		PRINT '@SQL= ' + @SQL
		END

      EXEC (@SQL)

  END
  
            PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)
            
            
UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted AX3/4 AX_SQLTRACE SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE

             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert AX3/4 AX_SQLTRACE at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE

END CATCH

ELSE

BEGIN TRY
PRINT 'STEP Insert AX2009 SQL Trace and Batch Tables'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

  IF Substring(@APP_BUILD, 1, 2) = N'5.'  OR Substring(@APP_BUILD, 1, 2) = N'6.'
    BEGIN
        SET @SQL = 'SET DATEFORMAT MDY;
		INSERT INTO AX_SQLTRACE WITH (TABLOCK) 
		   (STATS_TIME
		   ,DATABASE_NAME
		   ,SQL_DURATION
		   ,TRACE_CATEGORY
		   ,SQL_TEXT
		   ,CALL_STACK
		   ,TRACE_EVENT_CODE
		   ,TRACE_EVENT_DESC
		   ,TRACE_EVENT_DETAILS
		   ,CONNECTION_TYPE
		   ,SQL_SESSION_ID
		   ,AX_CONNECTION_ID
		   ,IS_LOBS_INCLUDED
		   ,IS_MORE_DATA_PENDING
		   ,ROWS_AFFECTED
		   ,ROW_SIZE
		   ,ROWS_PER_FETCH
		   ,IS_SELECTED_FOR_UPDATE
		   ,IS_STARTED_WITHIN_TRANSACTION
		   ,SQL_TYPE
		   ,STATEMENT_ID
		   ,STATEMENT_REUSE_COUNT
		   ,DETAIL_TYPE
		   ,CREATED_DATETIME
		   ,AX_USER_ID)
		SELECT 
			''' + CONVERT(NVARCHAR(50), @STATS_DATE, 121) + ''',''' + @DATABASE_NAME + '''
			,TRACETIME
			,CATEGORY
			,STATEMENT
			,CALLSTACK
			,CODE
			,TEXT
			,TEXTDETAILS
			,CONNECTIONTYPE
			,CONNECTIONSPID
			,CONNECTIONID
			,ISLOBSINCLUDED
			,ISMOREDATAPENDING
			,ROWSAFFECTED
			,ROWSIZE
			,ROWSPERFETCH
			,ISSELECTEDFORUPDATE
			,ISSTARTEDWITHINTRANSACTION
			,STATEMENTTYPE
			,STATEMENTID
			,STATEMENTREUSECOUNT
			,DETAILTYPE
			,DATEADD(minute, DATEDIFF(minute,getutcdate(),getdate()), CREATEDDATETIME)
			,CREATEDBY

		  
			FROM [' + @DATABASE_NAME + '].DBO.SYSTRACETABLESQL WITH (NOLOCK)
			WHERE DATEADD(minute, DATEDIFF(minute,getutcdate(),getdate()), CREATEDDATETIME) >= ''' + CONVERT(NVARCHAR(24), @LAST_STATS_DATE, 121) + ''''
			+ ' AND DATEADD(D, 14, CREATEDDATETIME) >= ''' + CONVERT(NVARCHAR(24), GETDATE(), 121) + ''''
	
		IF @DEBUG = 'Y' 
		BEGIN
		PRINT '@SQL= ' + @SQL
		END
		
		EXEC (@SQL)

        --Insert AX BATCH AND Server Configurations
                SET @SQL = '
					TRUNCATE TABLE AX_BATCHSERVER_CONFIGURATION                
					INSERT AX_BATCHSERVER_CONFIGURATION
						   SELECT SYSCLUSTERCONFIG.CLUSTERNAME,
							   SYSCLUSTERCONFIG.CLUSTERDESCRIPTION,
							   SYSSERVERCONFIG.SERVERID,
							   SYSSERVERCONFIG.MAXSESSIONS,
							   SYSSERVERCONFIG.ENABLEBATCH,
							   Dateadd(SECOND, BATCHSERVERCONFIG.STARTTIME, Dateadd(DAY, Datediff(DAY, 0, Getdate()), 0)),
							   Dateadd(SECOND, BATCHSERVERCONFIG.ENDTIME, Dateadd(DAY, Datediff(DAY, 0, Getdate()), 0))   ,
							   BATCHSERVERCONFIG.MAXBATCHSESSIONS,
							   BATCHSERVERGROUP.GROUPID,
							   BATCHJOB.COMPANY,
							   BATCHJOB.CAPTION,
							   BATCH.CAPTION,
							   CASE BATCH.RUNTYPE
								 WHEN 1 THEN '+quotename('Server','''')+'
								 ELSE '+quotename('Client','''')+'
							   END                                                                  
						FROM   [' + @DATABASE_NAME + '].DBO.SYSCLUSTERCONFIG
							   INNER JOIN [' + @DATABASE_NAME + '].DBO.SYSSERVERCONFIG
								 ON SYSSERVERCONFIG.CLUSTERREFRECID = SYSCLUSTERCONFIG.RECID
							   LEFT OUTER JOIN [' + @DATABASE_NAME + '].DBO.BATCHSERVERCONFIG
								 ON SYSSERVERCONFIG.SERVERID = BATCHSERVERCONFIG.SERVERID
							   LEFT OUTER JOIN [' + @DATABASE_NAME + '].DBO.BATCHSERVERGROUP
								 ON BATCHSERVERGROUP.SERVERID = SYSSERVERCONFIG.SERVERID
							   LEFT OUTER JOIN [' + @DATABASE_NAME + '].DBO.BATCH
								 ON BATCH.GROUPID = BATCHSERVERGROUP.GROUPID
							   LEFT OUTER JOIN [' + @DATABASE_NAME + '].DBO.BATCHJOB
								 ON BATCHJOB.RECID = BATCH.BATCHJOBID 
					 '
				IF @DEBUG = 'Y' 
				BEGIN
				PRINT '@SQL= ' + @SQL
				END
				
                EXEC (@SQL)
        --Insert AX SQLTRACE 
                SET @SQL = '
					TRUNCATE TABLE AX_SQLSTORAGE               
					INSERT AX_SQLSTORAGE
						   SELECT *                                                                
						FROM   [' + @DATABASE_NAME + '].DBO.SQLSTORAGE
							  
					 '
				IF @DEBUG = 'Y' 
				BEGIN
				PRINT '@SQL= ' + @SQL
				END
				
                EXEC (@SQL)
                                
             
                    
    END 
    
PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted AX_SQLTRACE SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE

             
END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO Insert AX_SQLTRACE at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE



END CATCH 

-- -----------------------------------------------------------------------------------------
-- Dynamicaly build the SQL to retreive data from NUMBERSEQUENCE table.  
-- -----------------------------------------------------------------------------------------

BEGIN TRY
PRINT 'STEP Dynamics AX Number Sequences'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)


SET @SQL = '
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N' + Quotename('DYN_SYSTABLES', '''') + ')
DROP SYNONYM [dbo].[DYN_SYSTABLES]

CREATE SYNONYM DYN_SYSTABLES
FOR [' + @DATABASE_NAME + '].sys.tables;'

IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
END

EXEC(@SQL) 
SET @SQL = '
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N' + Quotename('DYN_SYSCOLS', '''') + ')
DROP SYNONYM [dbo].[DYN_SYSCOLS]

CREATE SYNONYM DYN_SYSCOLS
FOR [' + @DATABASE_NAME + '].sys.columns;'

IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
END

EXEC(@SQL)


IF EXISTS (SELECT * FROM DYN_SYSTABLES t INNER JOIN DYN_SYSCOLS c
ON t.object_id=c.object_id
WHERE t.name = 'NUMBERSEQUENCETABLE')

BEGIN


IF Substring(@APP_BUILD, 1, 1) BETWEEN N'4' AND N'5'
BEGIN 
		IF EXISTS (SELECT * FROM DYN_SYSTABLES t INNER JOIN DYN_SYSCOLS c
		ON t.object_id=c.object_id
		WHERE t.name = 'NUMBERSEQUENCETABLE' AND c.name = 'DATAAREAID') 
		BEGIN



			SET @SQL ='	 
				SET ANSI_WARNINGS OFF 
				INSERT INTO AX_NUM_SEQUENCES WITH (TABLOCK) '
				  + ' SELECT ''' + @RUN_NAME  + '''' + ','+'''' + CONVERT(NVARCHAR(24), @STATS_DATE, 121) + ''',' + '''' + @DATABASE_NAME + '''' 
			 + ',0, 
			 NUMBERSEQUENCE,
				   TXT,
				   LOWEST,
				   HIGHEST,
				   NEXTREC,
				   0,
				   0,
					CASE CONTINUOUS     WHEN 0 THEN ''No''
				 WHEN 1 THEN ''Yes'' END  ,
				   FETCHAHEAD,
				   FETCHAHEADQTY,
				   0,
				   0,
				   NULL,
				   NULL,
				   DATAAREAID,
				   NULL,
				   NULL,
				   NULL,
				   NULL,
				   NULL,
				   NULL,
				   NULL,
				   NULL,
				   FORMAT
			 FROM   [' + @DATABASE_NAME + ']..NUMBERSEQUENCETABLE (NOLOCK)'
			 END
			ELSE
			BEGIN
			SET @SQL ='	 INSERT INTO AX_NUM_SEQUENCES WITH (TABLOCK) '
				  + ' SELECT ''' + @RUN_NAME  + '''' + ','+'''' + CONVERT(NVARCHAR(24), @STATS_DATE, 121) + ''',' + '''' + @DATABASE_NAME + '''' 
			 + ',0, 
			 NUMBERSEQUENCE,
				   TXT,
				   LOWEST,
				   HIGHEST,
				   NEXTREC,
				   0,
				   0,
					CASE CONTINUOUS     WHEN 0 THEN ''No''
				 WHEN 1 THEN ''Yes'' END ,
				   FETCHAHEAD,
				   FETCHAHEADQTY,
				   0,
				   0,
				   NULL,
				   NULL,
				   DATAAREAID,
				   NULL,
				   NULL,
				   NULL,
				   NULL,
				   NULL,
				   NULL,
				   NULL,
				   NULL,
				   	NST.FORMAT
			 FROM   [' + @DATABASE_NAME + ']..NUMBERSEQUENCETABLE (NOLOCK)'
				END


END



IF Substring(@APP_BUILD, 1, 3) = '6.0'
BEGIN 
			SET @SQL ='	 INSERT INTO AX_NUM_SEQUENCES WITH (TABLOCK) '
			  + ' SELECT ''' + @RUN_NAME  + '''' + ','+'''' + CONVERT(NVARCHAR(24), @STATS_DATE, 121) + ''',' + '''' + @DATABASE_NAME + '''' 

			  +', NST.RecId
   , NST.NUMBERSEQUENCE AS [NumberSequence]
            , NST.TXT AS [Text]
			,NST.LOWEST
			,NST.HIGHEST
			,NST.NEXTREC
            , CAST ((CAST((NST.HIGHEST - NST.NEXTREC) AS DECIMAL(20,2))/(CAST((NST.HIGHEST - NST.LOWEST) AS DECIMAL(20,2))) * 100) AS DECIMAL(5,2)) AS [PercentRemaining]
            , NST.HIGHEST - NST.NEXTREC AS [NumbersRemaining]

   , CASE NST.CONTINUOUS
     WHEN 0 THEN ''No''
     WHEN 1 THEN ''Yes''       
    END [Continuous]
   , NST.FETCHAHEAD AS FetchAhead
   , NST.FETCHAHEADQTY AS FetchAheadQty
   , NST.CLEANINTERVAL AS CleanInterval
   , NST.CLEANATACCESS AS CleanAtAccess
            , ''N/A'' AS [PartitionName]
            , NST.NUMBERSEQUENCESCOPE
            , DA.ID [CompanyId]
            , DA.NAME [CompanyName]            
            , CASE DA.ISVIRTUAL
                        WHEN 0 THEN ''No''
                        WHEN 1 THEN ''Yes''       
                    END [Shared]
            , CI.DATAAREA [LegalEntityName]            
            , CASE OU.OMOPERATINGUNITTYPE
                        WHEN 0 THEN ''None''
                        WHEN 1 THEN ''Department''
                        WHEN 2 THEN ''Cost center''           
                        WHEN 3 THEN ''Value stream''
                        WHEN 4 THEN ''Business unit''
                        WHEN 5 THEN ''All operating units''
                        WHEN 6 THEN ''Retail channel''             
                    END [OperatingUnitType]
            , OU.OMOPERATINGUNITNUMBER [OperatingUnitNumber]
            , FC.CALENDARID [FiscalCalendar]
            , FCY.NAME [FiscalCalendarYear]
            , FCP.NAME [Period]
            ,NST.FORMAT
			FROM [' + @DATABASE_NAME + ']..NUMBERSEQUENCETABLE NST
        JOIN [' + @DATABASE_NAME + ']..NUMBERSEQUENCESCOPE NSS ON NSS.RECID = NST.NUMBERSEQUENCESCOPE    
      LEFT JOIN [' + @DATABASE_NAME + ']..DATAAREA DA ON NSS.DATAAREA = DA.ID   
      LEFT JOIN [' + @DATABASE_NAME + ']..COMPANYINFO CI ON NSS.LEGALENTITY = CI.RECID 
      LEFT JOIN [' + @DATABASE_NAME + ']..OMOPERATINGUNIT OU ON NSS.OPERATINGUNIT = OU.RECID
      LEFT JOIN [' + @DATABASE_NAME + ']..FISCALCALENDARPERIOD FCP ON NSS.FISCALCALENDARPERIOD = FCP.RECID
      LEFT JOIN [' + @DATABASE_NAME + ']..FISCALCALENDAR FC ON FC.RECID = FCP.FISCALCALENDAR
      LEFT JOIN [' + @DATABASE_NAME + ']..FISCALCALENDARYEAR FCY ON FCY.RECID = FCP.FISCALCALENDARYEAR
WHERE INUSE = 1'
END


IF Substring(@APP_BUILD, 1, 3) IN ( '6.2', '6.3')
BEGIN 
			SET @SQL ='	 INSERT INTO AX_NUM_SEQUENCES WITH (TABLOCK) '
			  + ' SELECT ''' + @RUN_NAME  + '''' + ','+'''' + CONVERT(NVARCHAR(24), @STATS_DATE, 121) + ''',' + '''' + @DATABASE_NAME + '''' 

			  +', NST.RecId
   , NST.NUMBERSEQUENCE AS [NumberSequence]
            , NST.TXT AS [Text]
			,NST.LOWEST
			,NST.HIGHEST
			,NST.NEXTREC

            , CAST ((CAST((NST.HIGHEST - NST.NEXTREC) AS DECIMAL(20,2))/(CAST((NST.HIGHEST - NST.LOWEST) AS DECIMAL(20,2))) * 100) AS DECIMAL(5,2)) AS [PercentRemaining]
            , NST.HIGHEST - NST.NEXTREC AS [NumbersRemaining]
   , CASE NST.CONTINUOUS
     WHEN 0 THEN ''No''
     WHEN 1 THEN ''Yes''       
    END [Continuous]
   , NST.FETCHAHEAD AS FetchAhead
   , NST.FETCHAHEADQTY AS FetchAheadQty
   , NST.CLEANINTERVAL AS CleanInterval
   , NST.CLEANATACCESS AS CleanAtAccess
            , P.NAME AS [PartitionName]
            , NST.NUMBERSEQUENCESCOPE
            , DA.ID [CompanyId]
            , DA.NAME [CompanyName]            
            , CASE DA.ISVIRTUAL
                        WHEN 0 THEN ''No''
                        WHEN 1 THEN ''Yes''       
                    END [Shared]
            , DI.DATAAREA [LegalEntityName]            
            , CASE DI.OMOPERATINGUNITTYPE
                        WHEN 0 THEN ''None''
                        WHEN 1 THEN ''Department''
                        WHEN 2 THEN ''Cost center''           
                        WHEN 3 THEN ''Value stream''
                        WHEN 4 THEN ''Business unit''
                        WHEN 5 THEN ''All operating units''
                        WHEN 6 THEN ''Retail channel''              
                    END [OperatingUnitType]
            , DI.OMOPERATINGUNITNUMBER [OperatingUnitNumber]
            , FC.CALENDARID [FiscalCalendar]
            , FCY.NAME [FiscalCalendarYear]
            , FCP.NAME [Period]
            ,NST.FORMAT
			FROM [' + @DATABASE_NAME + ']..NUMBERSEQUENCETABLE NST
      JOIN [' + @DATABASE_NAME + ']..PARTITIONS P ON  NST.PARTITION = P.RECID
      JOIN [' + @DATABASE_NAME + ']..NUMBERSEQUENCESCOPE NSS ON NSS.RECID = NST.NUMBERSEQUENCESCOPE      
      LEFT JOIN [' + @DATABASE_NAME + ']..DATAAREA DA ON NSS.DATAAREA = DA.ID  
      LEFT JOIN [' + @DATABASE_NAME + ']..DirpartyTable DI ON (NSS.LEGALENTITY = DI.RECID) OR (NSS.OPERATINGUNIT = DI.RECID)      
      LEFT JOIN [' + @DATABASE_NAME + ']..FISCALCALENDARPERIOD FCP ON NSS.FISCALCALENDARPERIOD = FCP.RECID
      LEFT JOIN [' + @DATABASE_NAME + ']..FISCALCALENDAR FC ON FC.RECID = FCP.FISCALCALENDAR
      LEFT JOIN [' + @DATABASE_NAME + ']..FISCALCALENDARYEAR FCY ON FCY.RECID = FCP.FISCALCALENDARYEAR
WHERE INUSE = 1'


END 


IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
END

EXEC (@SQL) 
END

PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted NUMBERSEQUENCETABLE SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE


END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert NUMBERSEQUENCETABLE SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE

END CATCH
-- -----------------------------------------------------------------------------------------
-- Dynamicaly build the SQL to retreive data from AOTTABLEPROPERTIES.  
-- -----------------------------------------------------------------------------------------

BEGIN TRY
PRINT 'STEP Dynamics AX AOT Table Properties'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

SET @SQL = 'IF EXISTS (SELECT * FROM [' + @DATABASE_NAME + '].sys.tables WHERE NAME = ''AOTTABLEPROPERTIES'') 
BEGIN
	 INSERT INTO AX_TABLE_DETAIL WITH (TABLOCK) ' + ' SELECT ' + '''' + CONVERT(NVARCHAR(24), @STATS_DATE, 121) + ''',' + '''' + @DATABASE_NAME + '''' + ',TABLENAME
	  ,TABID
      ,OCCENABLED
      ,CACHELOOKUP
      ,INSERTMETHODOVERRIDDEN
      ,UPDATEMETHODOVERRIDDEN
      ,DELETEMETHODOVERRIDDEN
      ,AOSVALIDATEINSERT
      ,AOSVALIDATEUPDATE
      ,AOSVALIDATEDELETE
      ,DATABASELOGINSERT
      ,DATABASELOGDELETE
      ,DATABASELOGUPDATE
      ,DATABASELOGRENAMEKEY
      ,EVENTINSERT
      ,EVENTDELETE
      ,EVENTUPDATE
      ,EVENTRENAMEKEY
	,TABLEGROUP
	,APPLAYER
	 FROM [' + @DATABASE_NAME + ']..AOTTABLEPROPERTIES  WITH (NOLOCK) 
	END'
	
IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
END

EXEC (@SQL) 

PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)


UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted AOTTABLEPROPERTIES SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE

END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert AOTTABLEPROPERTIES at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE

END CATCH

BEGIN TRY
PRINT 'STEP Dynamics AX AOT Index Properties'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)
SET @SQL = 'IF EXISTS (SELECT * FROM [' + @DATABASE_NAME + '].sys.tables WHERE NAME = ''AOTINDEXPROPERTIES'') 
BEGIN
	INSERT INTO AX_INDEX_DETAIL WITH (TABLOCK) 
	SELECT ' + '''' + CONVERT(NVARCHAR(24), @STATS_DATE, 121) + ''',' + +'''' + @DATABASE_NAME + '''' + ',
	T.TABLENAME,
	INDEXNAME,
	INDEX_ID = INDEXID,
	INDEX_DESCRIPTION = 
		CASE
			WHEN	I.INDEXNAME = T.CLUSTEREDINDEX THEN ''CLUSTERED''
			ELSE	''NONCLUSTERED''
		END +
		CASE
			WHEN	I.ALLOWDUPLICATES = 0 THEN '', UNIQUE''
			ELSE	''''
		END +
		CASE
			WHEN	I.INDEXNAME = T.PRIMARYKEY THEN '', PRIMARY KEY''
			ELSE	''''
		END,
		INDEX_KEYS = 
		CASE 
			WHEN T.DATAPERCOMPANY = 1 AND 0 < 
			(
				SELECT COUNT(*) FROM [' + @DATABASE_NAME + ']..AOTINDEXFIELDS F WITH (NOLOCK)
				WHERE	F.TABLENAME = I.TABLENAME
				AND		F.INDEXNAME = I.INDEXNAME
				AND		F.FIELDNAME = ''DATAAREAID''
			)	THEN ''''
			WHEN T.DATAPERCOMPANY = 1 THEN '' DATAAREAID,''
			ELSE ''''
		END +
	stuff	
			(
					
				(	
				SELECT '', '' + FIELDNAME
				FROM [' + @DATABASE_NAME + ']..AOTINDEXFIELDS F  WITH (NOLOCK)
				WHERE F.TABLENAME = I.TABLENAME
				AND FIELDNAME <> ''''
				AND F.INDEXNAME = I.INDEXNAME
				order	by FIELDPOSITION
				for		xml path('''')
				)
			,1,1,''''
			)
			,I.APPLAYER 
					

	FROM	[' + @DATABASE_NAME + ']..AOTTABLEPROPERTIES	T  WITH (NOLOCK),
			[' + @DATABASE_NAME + ']..AOTINDEXPROPERTIES	I  WITH (NOLOCK)
	WHERE	T.TABLENAME = I.TABLENAME
END'

IF @DEBUG = 'Y' 
BEGIN
PRINT '@SQL= ' + @SQL
END

EXEC (@SQL) 
PRINT 'Completed Successfully'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'Inserted AOTINDEXES SUCCESSFULLY at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE

END TRY

BEGIN CATCH
PRINT 'Step failed to complete !!'+ ' at ' + CONVERT(VARCHAR, GETDATE(),109)

UPDATE CAPTURE_LOG SET TEXT = TEXT + 'FAILED TO insert AOTINDEXES at ' + CONVERT(VARCHAR, GETDATE(),109)+', ' 
WHERE STATS_TIME = @STATS_DATE

END CATCH

RETURN @RETURN_CODE

GO






ALTER PROCEDURE [dbo].[SP_INDEX_CHANGES]
@BASELINE AS VARCHAR(128),
@COMPARISON_RUN_NAME AS VARCHAR(128)
AS 

SELECT * FROM (
SELECT V1.DATABASE_NAME,V1.TABLE_NAME, V1.INDEX_NAME, 'INDEX CHANGED' AS DIFFERENCE FROM 
INDEX_STATS_VW V1 
INNER JOIN INDEX_STATS_VW V2
ON V1.DATABASE_NAME = V2.DATABASE_NAME 
AND V1.TABLE_NAME = V2.TABLE_NAME 
AND V1.INDEX_NAME = V2.INDEX_NAME 
AND V1.INDEX_KEYS <> V2.INDEX_KEYS
WHERE V1.RUN_NAME = @BASELINE AND V2.RUN_NAME = @COMPARISON_RUN_NAME

UNION

SELECT V1.DATABASE_NAME,V1.TABLE_NAME, V1.INDEX_NAME, 'INDEX DELETED' AS DIFFERENCE FROM 
INDEX_STATS_VW V1 
WHERE NOT EXISTS (SELECT INDEX_NAME FROM 
 INDEX_STATS_VW V2
WHERE   V1.DATABASE_NAME = V2.DATABASE_NAME 
AND V1.TABLE_NAME = V2.TABLE_NAME 
AND V1.INDEX_NAME = V2.INDEX_NAME 
AND  V2.RUN_NAME = @COMPARISON_RUN_NAME) 
AND  V1.RUN_NAME = @BASELINE

UNION

SELECT V2.DATABASE_NAME,V2.TABLE_NAME, V2.INDEX_NAME, 'INDEX ADDED' AS DIFFERENCE FROM 
INDEX_STATS_VW V2 
WHERE NOT EXISTS (SELECT INDEX_NAME FROM 
 INDEX_STATS_VW V1
WHERE   V1.DATABASE_NAME = V2.DATABASE_NAME 
AND V1.TABLE_NAME = V2.TABLE_NAME 
AND V1.INDEX_NAME = V2.INDEX_NAME 
AND  V1.RUN_NAME = @BASELINE) 
AND   V2.RUN_NAME = @COMPARISON_RUN_NAME ) AS A
ORDER BY A.DATABASE_NAME,A.TABLE_NAME
GO




IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[PERF_HOURLY_ROWDATA_VW]'))
DROP VIEW [dbo].[PERF_HOURLY_ROWDATA_VW]
GO


GO

/****** Object:  View [dbo].[PERF_HOURLY_ROWDATA]    Script Date: 04/02/2011 11:42:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*********  PERF DATA Row Count change ************************/
CREATE VIEW [dbo].[PERF_HOURLY_ROWDATA_VW]
AS
  
  WITH ROWSRANK
       AS (SELECT A.STATS_TIME,
                  A.DATABASE_NAME,
                  A.TABLE_NAME,
                  A.ROWS_LAST_HOUR,
                  Dense_rank()
                    OVER (
                      partition BY A.STATS_TIME
                      ORDER BY A.STATS_TIME DESC, A.DATABASE_NAME DESC, ( ROWS_LAST_HOUR) DESC) AS RANK
           FROM   PERF_INDEX_DETAIL A WHERE A.INDEX_ID < 2)  --REH Only need clustered or heap index

  SELECT TOP 100 PERCENT STATS_TIME,
                         DATABASE_NAME = CASE
                                           WHEN Grouping(DATABASE_NAME) = 1 THEN 'NULL'
                                           ELSE DATABASE_NAME
                                         END,
                         ROWRANK = CASE
                                     WHEN Grouping(RANK) = 1 THEN 9999
                                     ELSE RANK
                                   END,
                         TABLE_NAME,
                         sum(ROWS_LAST_HOUR) AS ROWS_ADDED
  FROM   ROWSRANK
  GROUP  BY STATS_TIME,
            DATABASE_NAME,
            RANK,
            TABLE_NAME WITH ROLLUP
  ORDER  BY STATS_TIME DESC,
            DATABASE_NAME,
            RANK,
            TABLE_NAME 

GO


DELETE FROM PERF_INDEX_DETAIL WHERE INDEX_ID > 1
GO



;WITH MyCTE (STATS_TIME, DATABASE_NAME, TABLE_NAME, INDEX_NAME, ROW_COUNT, RowVersion)
AS(
SELECT
 STATS_TIME,
 DATABASE_NAME,
 TABLE_NAME,
 INDEX_NAME,
 ROW_COUNT

,ROW_NUMBER() OVER(PARTITION BY DATABASE_NAME,TABLE_NAME,INDEX_NAME ORDER BY STATS_TIME DESC) RowVersion
FROM PERF_INDEX_DETAIL 
)


UPDATE A 
SET ROWS_LAST_HOUR = BASE.ROW_COUNT - PREV.ROW_COUNT
FROM PERF_INDEX_DETAIL A
JOIN MyCTE BASE ON A.DATABASE_NAME = BASE.DATABASE_NAME AND A.TABLE_NAME = BASE.TABLE_NAME AND A.INDEX_NAME = BASE.INDEX_NAME AND A.STATS_TIME = BASE.STATS_TIME
 LEFT JOIN MyCTE PREV 
 ON BASE.DATABASE_NAME = PREV.DATABASE_NAME
	AND BASE.TABLE_NAME = PREV.TABLE_NAME 
	AND BASE.INDEX_NAME = PREV.INDEX_NAME
 AND BASE.RowVersion = PREV.RowVersion-1 



GO


GO

/****** Object:  View [dbo].[AX_NUM_SEQUENCES_VW]    Script Date: 10/17/2011 15:22:17 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[AX_NUM_SEQUENCES_VW]'))
DROP VIEW [dbo].[AX_NUM_SEQUENCES_VW]
GO


GO

/****** Object:  View [dbo].[AX_NUM_SEQUENCES_VW]    Script Date: 10/17/2011 15:22:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[AX_NUM_SEQUENCES_VW] 
AS
SELECT SQ.[RUN_NAME]
      ,SQ.[STATS_TIME]
      ,SQ.[DATABASE_NAME]
      ,[RECID]
      ,[NUMBERSEQUENCE]
      ,[TEXT]
      ,[FORMAT]
      ,[LOWEST]
      ,[HIGHEST]
      ,[NEXTREC]
      ,[PERCENTREMAINING]
      ,[NUMBERSREMAINING]
      ,[CONTINUOUS]
      ,[FETCHAHEAD]
      ,[FETCHAHEADQTY]
      ,[CLEANINTERVAL]
      ,[CLEANATACCESS]
      ,[PARTITIONNAME]
      ,[NUMBERSEQUENCESCOPE]
      ,[COMPANYID]
      ,[COMPANYNAME]
      ,[SHARED]
      ,[LEGALENTITYNAME]
      ,[OPERATINGUNITTYPE]
      ,[OPERATINGUNITNUMBER]
      ,[FISCALCALENDAR]
      ,[FISCALCALENDARYEAR]
      ,[PERIOD]
  FROM AX_NUM_SEQUENCES SQ
      INNER JOIN     STATS_COLLECTION_SUMMARY S WITH(NOLOCK)
  ON  SQ.STATS_TIME = S.STATS_TIME


GO



GO

/****** Object:  View [dbo].[AX_NUM_SEQUENCES_CURR_VW]    Script Date: 10/17/2011 15:21:57 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[AX_NUM_SEQUENCES_CURR_VW]'))
DROP VIEW [dbo].[AX_NUM_SEQUENCES_CURR_VW]
GO


GO

/****** Object:  View [dbo].[AX_NUM_SEQUENCES_CURR_VW]    Script Date: 10/17/2011 15:21:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[AX_NUM_SEQUENCES_CURR_VW] 
AS
SELECT SQ.[RUN_NAME]
      ,SQ.[STATS_TIME]
      ,SQ.[DATABASE_NAME]
      ,[RECID]
      ,[NUMBERSEQUENCE]
      ,[TEXT] 
      ,[FORMAT]
      ,[LOWEST]
      ,[HIGHEST]
      ,[NEXTREC]
      ,[PERCENTREMAINING]
      ,[NUMBERSREMAINING]
      ,[CONTINUOUS]
      ,[FETCHAHEAD]
      ,[FETCHAHEADQTY]
      ,[CLEANINTERVAL]
      ,[CLEANATACCESS]
      ,[PARTITIONNAME]
      ,[NUMBERSEQUENCESCOPE]
      ,[COMPANYID]
      ,[COMPANYNAME]
      ,[SHARED]
      ,[LEGALENTITYNAME]
      ,[OPERATINGUNITTYPE]
      ,[OPERATINGUNITNUMBER]
      ,[FISCALCALENDAR]
      ,[FISCALCALENDARYEAR]
      ,[PERIOD]
  FROM AX_NUM_SEQUENCES SQ
      INNER JOIN     STATS_COLLECTION_SUMMARY S WITH(NOLOCK)
  ON  SQ.STATS_TIME = S.STATS_TIME
  WHERE SQ.STATS_TIME = (SELECT MAX(STATS_TIME)
                             FROM   STATS_COLLECTION_SUMMARY)



GO



/***************************************************************************
*
* 3/2/2012  REH   Turn on row compression for all DynamicsPerf indexes
*                   if compression is supported
*
*
****************************************************************************/
IF  (cast(serverproperty('Edition') as varchar(100)) like 'Enterprise%' or cast(serverproperty('Edition') as varchar(100)) like 'Developer%')
BEGIN
		DECLARE @INDEX_NAME SYSNAME
		DECLARE @TABLE_NAME SYSNAME
		DECLARE @SQL VARCHAR(MAX)


		DECLARE INDEXCURSOR CURSOR FOR
			SELECT	
					si.name, 
					so.name
			FROM	DynamicsPerf.sys.indexes si
			JOIN	DynamicsPerf.sys.sysindexes ii on si.object_id = ii.id and si.index_id = ii.indid
			JOIN	DynamicsPerf.sys.objects so on so.object_id = si.object_id
			JOIN	DynamicsPerf.sys.schemas ss on ss.schema_id = so.schema_id
			WHERE	so.type = 'U'
			AND		si.type > 0  --other than heap tables
			
			OPEN INDEXCURSOR

		FETCH INDEXCURSOR INTO 
			@INDEX_NAME		,
			@TABLE_NAME		
			
			
		WHILE @@FETCH_STATUS = 0
			BEGIN
			
			--Need page compression on this table to get maximum space savings
			IF @TABLE_NAME = 'SQLErrorLog'
			BEGIN
			SELECT @SQL = 'ALTER INDEX ' + @INDEX_NAME + ' ON ' + @TABLE_NAME + 
			' REBUILD WITH (DATA_COMPRESSION = PAGE)'
			END
			ELSE
			BEGIN
			SELECT @SQL = 'ALTER INDEX ' + @INDEX_NAME + ' ON ' + @TABLE_NAME + 
			' REBUILD WITH (DATA_COMPRESSION = ROW)'
			END
			
			EXEC (@SQL)
			
			FETCH NEXT FROM INDEXCURSOR INTO @INDEX_NAME,@TABLE_NAME
			END
			
			CLOSE INDEXCURSOR
			DEALLOCATE INDEXCURSOR
			
			
			--REH Compress the QUERY_PLANS table that we removed the clustered index on
			ALTER TABLE dbo.QUERY_PLANS  REBUILD WITH ( DATA_COMPRESSION = ROW )
END


GO


USE [msdb]
GO

/****** Object:  Job [DYNPERF_LONG_DURATION_TRACE]    Script Date: 04/26/2012 19:26:53 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_Long_Duration_Trace')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_Long_Duration_Trace', @delete_unused_schedule=1
GO

USE [msdb]
GO

/****** Object:  Job [DYNPERF_LONG_DURATION_TRACE]    Script Date: 04/26/2012 19:26:53 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 04/26/2012 19:26:53 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DYNPERF_Long_Duration_Trace', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0,
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Records long duration SQL Statement events into a trace file C:\SQLTRACE\DYNAMICS_LONG_DURATION.TRC. You must edit the steps to change the location of this file. ', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Start Tracing]    Script Date: 04/26/2012 19:26:53 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Start Tracing', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SP_SQLTRACE
	@FILE_PATH 		= ''C:\SQLTRACE'', -- Location to write trace files.  Note: directory must exist before start of trace
	@TRACE_NAME  		= ''DYNAMICS_LONG_DURATION'', -- Trace name - becomes base of trace file name
	@DATABASE_NAME	= NULL,			-- Name of database to trace; default (NULL) will trace all databases
	@TRACE_FILE_SIZE	= 10,			-- maximum trace file size - will rollover when reached
	@TRACE_FILE_COUNT	= 100,			-- maximum numer of trace files  - will delete oldest when reached
	@TRACE_STOP  		= ''N'',			-- When set to ''Y'' will stop the trace and exit
	@TRACE_RUN_HOURS  	= 25 ,			-- Number of hours to run trace
	@DURATION_SECS	        = 5  
-- DO NOT reduce this value without direction from Microsoft support. 
-- Could cause system performance issues.
	', 
		@database_name=N'DynamicsPerf', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20110313, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'3aa2d032-645a-4a48-b96e-a40fb57097aa'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Startup', 
		@enabled=1, 
		@freq_type=64, 
		@freq_interval=0, 
		@freq_subday_type=0, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20111019, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'bce0cd16-d38d-4b96-b90b-b352600980b1'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO




/****** Object:  Job [DYNPERF_Default_Trace_Start]    Script Date: 04/26/2012 19:26:53 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DYNPERF_Detailed_Trace')
EXEC msdb.dbo.sp_delete_job @job_name=N'DYNPERF_Detailed_Trace', @delete_unused_schedule=1
GO