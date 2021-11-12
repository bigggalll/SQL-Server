/**************************************************************************
*
*  Sample script that can be setup as a SQL Job to grow the 
*	database in a mainteance window vs. letting autogrow occur
*	in the middle of the production day.
*
***************************************************************************/



DECLARE @MINFREE BIGINT, @GROWTH_MB BIGINT, @NEWSIZE BIGINT, @DATABASE_NAME SYSNAME, @FILE_NAME SYSNAME
DECLARE @SQL VARCHAR(MAX), @DBFREE BIGINT, @DBSIZE  BIGINT

SET @MINFREE = 200  -- Suggested to be no less then 1 month of free space
SET @GROWTH_MB =3500 -- Suggested to grow out to at least 3 months of free space
SET @DATABASE_NAME = 'xxxxxxxxx'
SET @FILE_NAME = 'xxxxx_Data'
 

 
SELECT @DBFREE = [DB_FREE(MB)], @DBSIZE = [DB_SIZE(MB)]
FROM   DynamicsPerf..SQL_DATABASEFILES_CURR_VW where DATABASE_NAME = @DATABASE_NAME AND FILE_NAME = @FILE_NAME

IF @DBFREE < @MINFREE
BEGIN
SET @NEWSIZE = @DBSIZE + @MINFREE
SET @SQL = 'ALTER DATABASE ' + @DATABASE_NAME + ' MODIFY FILE( NAME = ' + @FILE_NAME + ' , SIZE = ' +CAST(@NEWSIZE AS VARCHAR(20)) + ')'

--PRINT @SQL
EXEC (@SQL)


END
