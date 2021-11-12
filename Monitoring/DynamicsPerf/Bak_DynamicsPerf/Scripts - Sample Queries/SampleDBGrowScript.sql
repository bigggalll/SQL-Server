USE DynamicsPerf
GO


DECLARE @MINFREE        BIGINT,
        @GROWTH_MB      BIGINT,
        @NEWSIZE        BIGINT,
        @DATABASE_NAME  SYSNAME,
        @FILE_NAME      SYSNAME,
        @DAYS           INT,
        @GROWTHPERMONTH BIGINT
DECLARE @SQL             VARCHAR(MAX),
        @DBFREE          BIGINT,
        @DBSIZE          BIGINT,
        @CURRENTCAPTURE  VARCHAR(60),
        @STARTINGCAPTURE VARCHAR(60),
        @GROWTH          BIGINT

--SET @MINFREE = 200
--SET @GROWTH_MB =3500 --REH about 1 month of growth
SET @DATABASE_NAME = 'DynamicsPerf'
SET @FILE_NAME = 'DynamicsPerf_Data' 


SET @CURRENTCAPTURE = (SELECT TOP 1 RUN_NAME
                       FROM   STATS_COLLECTION_SUMMARY
                       WHERE  DATABASE_NAME = @DATABASE_NAME
                              AND STATS_TIME < GETDATE()
                       ORDER  BY STATS_TIME DESC)
SET @STARTINGCAPTURE = (SELECT TOP 1 RUN_NAME
                        FROM   STATS_COLLECTION_SUMMARY
                        WHERE  DATABASE_NAME = @DATABASE_NAME
                               AND STATS_TIME < ( GETDATE() - 90 )
                        ORDER  BY STATS_TIME DESC) 
--REH Check to see if starting capture isnull, if so we need to pick the oldest date we have collected then
IF @STARTINGCAPTURE IS NULL
  BEGIN
      SET @STARTINGCAPTURE = (SELECT TOP 1 RUN_NAME
                              FROM   STATS_COLLECTION_SUMMARY
                              WHERE  DATABASE_NAME = @DATABASE_NAME
                              ORDER  BY STATS_TIME ASC)
  END 



SET @GROWTH = ISNULL((SELECT SUM(DELTA_SIZEMB)
                      FROM   FN_DBSTATS(@STARTINGCAPTURE, @CURRENTCAPTURE)), 0)
SET @DAYS = DATEDIFF(DD, (SELECT STATS_TIME
                          FROM   STATS_COLLECTION_SUMMARY
                          WHERE  RUN_NAME = @STARTINGCAPTURE), (SELECT STATS_TIME
                                                                FROM   STATS_COLLECTION_SUMMARY
                                                                WHERE  RUN_NAME = @CURRENTCAPTURE))
SET @GROWTHPERMONTH = @GROWTH / @DAYS * 30 


SELECT @DBFREE = [DB_FREE(MB)],@DBSIZE = [DB_SIZE(MB)]
FROM   DynamicsPerf..SQL_DATABASEFILES_CURR_VW
WHERE  DATABASE_NAME = @DATABASE_NAME
       AND FILE_NAME = @FILE_NAME 

--PRINT 'CURRENT CAPTURE = ' + @CURRENTCAPTURE
--PRINT 'STARTING CAPTURE = ' + @STARTINGCAPTURE
--PRINT 'GROWTH = ' + CAST(@GROWTH AS VARCHAR(100))
--PRINT 'DAYS = ' + CAST(@DAYS AS VARCHAR(100))
--PRINT 'GROWTH PER MONTH = ' + CAST(@GROWTHPERMONTH AS VARCHAR(100))
--PRINT 'CURRENT SIZE = ' +CAST( @DBSIZE AS VARCHAR(100))


IF @DBFREE < @GROWTHPERMONTH
  BEGIN
      SET @NEWSIZE = @DBSIZE + ( @GROWTHPERMONTH * 3 )
      SET @SQL = 'ALTER DATABASE ' + @DATABASE_NAME
                 + ' MODIFY FILE( NAME = ' + @FILE_NAME
                 + ' , SIZE = '
                 + CAST(@NEWSIZE AS VARCHAR(20)) + ')'

      --PRINT @SQL
      EXEC (@SQL)
  END 



