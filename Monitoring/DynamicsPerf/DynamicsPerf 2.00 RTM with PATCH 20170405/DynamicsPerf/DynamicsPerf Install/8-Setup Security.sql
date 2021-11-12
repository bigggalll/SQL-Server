/***********************************************************************************************************

Run the following script on each server that you intend to collect data from

This script will produce the statements to setup security for DynamicsPerf toolset

***********************************************************************************************************/


DECLARE @DB_Name varchar(100), @SERVER_TO_COLLECT varchar(100)
DECLARE @SQL nvarchar(max)  

DECLARE @SERVICE_ACCOUNT VARCHAR(8000), @DB_TO_COLLECT VARCHAR(1000), @REPORT_SERVER_DB VARCHAR(1000)
DECLARE @AOS_SERVICE_ACCT VARCHAR(8000)


SET @SERVER_TO_COLLECT = 'your_server_here'
SET @SERVICE_ACCOUNT = 'Domain\Acct'
SET @AOS_SERVICE_ACCT = 'Domain\Acct'
SET @DB_TO_COLLECT = 'DynamicsProdDB'
SET @REPORT_SERVER_DB = 'ReportServer'

IF EXISTS (SELECT *
           FROM   sys.synonyms
           WHERE  name = 'DYN_SECURITY')
  EXEC ('DROP SYNONYM [dbo].DYN_SECURITY')


         SET @SQL = '
				CREATE SYNONYM DYN_SECURITY
				FOR [' + @SERVER_TO_COLLECT + '].master.sys.sysdatabases'
		EXEC (@SQL)


	 PRINT ' '
	 PRINT ' '
	 PRINT '/*************************************************************************************'
	 PRINT ' --RUN THESE SCRIPTS ON THE SERVER YOU ARE COLLECTIING DATA FROM '
	 PRINT '**************************************************************************************/'
	 PRINT ' '

	 	SET @SQL = 'IF NOT EXISTS(SELECT loginname FROM master.dbo.syslogins WHERE name = ' + '''' + @SERVICE_ACCOUNT + '''' + ')'
		+char(10) + 'BEGIN' + char(10) +
		'CREATE LOGIN [' + @SERVICE_ACCOUNT + '] FROM WINDOWS WITH DEFAULT_DATABASE = [' + @DB_TO_COLLECT + '];'
		+ char(10) + 'END'
	 PRINT @SQL
	 PRINT ''

DECLARE database_cursor CURSOR FOR 
SELECT name FROM DYN_SECURITY

OPEN database_cursor 

FETCH NEXT FROM database_cursor INTO @DB_Name 

WHILE @@FETCH_STATUS = 0 
BEGIN 



     SELECT @SQL = CHAR(10) + CHAR(10) + 'USE [' + @DB_NAME + '] 
     IF NOT EXISTS
    (SELECT name
     FROM sys.database_principals
     WHERE name = ' + '''' + @SERVICE_ACCOUNT +''''+ ')
BEGIN
     CREATE USER  [' + @SERVICE_ACCOUNT + '] FOR LOGIN [' + @SERVICE_ACCOUNT + ']'
     + CHAR(10) + ' END' + CHAR(10)
     --EXEC sp_executesql @SQL 
	 PRINT @SQL

     SELECT @SQL = 'USE [master] GRANT VIEW SERVER STATE TO [' + @SERVICE_ACCOUNT + ']'
     --EXEC sp_executesql @SQL 
	 PRINT @SQL


     SELECT @SQL = 'USE [' + @DB_NAME + '] GRANT VIEW DATABASE STATE TO [' + @SERVICE_ACCOUNT + ']'
     --EXEC sp_executesql @SQL 
	 PRINT @SQL

	IF @DB_Name = 'master'
	BEGIN
		SET @SQL = 'USE [' + @DB_NAME + '] GRANT EXECUTE ON master.sys.xp_readerrorlog to [' + @SERVICE_ACCOUNT + ']'
		PRINT @SQL
	END

	IF @DB_Name = 'msdb'
	BEGIN
		SET @SQL = 'USE [' + @DB_NAME + '] EXEC sp_addrolemember ''db_datareader'', ' + '''' +  @SERVICE_ACCOUNT + ''''
		PRINT @SQL
	END

		IF @DB_Name = 'tempdb'
	BEGIN
		SET @SQL = 'USE [' + @DB_NAME + '] EXEC sp_addrolemember ''db_datareader'', ' + '''' +  @SERVICE_ACCOUNT + ''''
		PRINT @SQL
		SET @SQL = 'USE [' + @DB_NAME + '] EXEC sp_addrolemember ''db_datawriter'', ' + '''' +  @SERVICE_ACCOUNT + ''''
		PRINT @SQL
		SET @SQL = 'USE [' + @DB_NAME + '] EXEC sp_addrolemember ''db_ddladmin'', ' + '''' +  @SERVICE_ACCOUNT + ''''
		PRINT @SQL
	END

			IF @DB_Name = @DB_TO_COLLECT
	BEGIN
		SET @SQL = 'USE [' + @DB_NAME + '] EXEC sp_addrolemember ''db_datareader'', ' + '''' +  @SERVICE_ACCOUNT + ''''
		PRINT @SQL
		SET @SQL = 'USE [' + @DB_NAME + '] GRANT Showplan  to [' + @SERVICE_ACCOUNT + ']'
		PRINT @SQL
	END


     FETCH NEXT FROM database_cursor INTO @DB_Name 



END 
	 PRINT ' '
	 PRINT ' '	
	 PRINT ' '
	 PRINT ' '
	 PRINT '/***************************************************************************************************'
	 PRINT '--RUN THESE SCRIPTS ON YOUR DYNAMICSPERF DATABASE SERVER'
	 PRINT '****************************************************************************************************/'
	 PRINT char(10) + char(10) 
	 	SET @SQL = 'IF NOT EXISTS(SELECT loginname FROM master.dbo.syslogins WHERE name = ' + '''' + @SERVICE_ACCOUNT + '''' + ')'
		+char(10) + 'BEGIN' + char(10) +
		'CREATE LOGIN [' + @SERVICE_ACCOUNT + '] FROM WINDOWS WITH DEFAULT_DATABASE = [DynamicsPerf];'
		+ char(10) + 'END'
		PRINT @SQL
			 PRINT char(10) + char(10) 
	 	SET @SQL = 'IF NOT EXISTS(SELECT loginname FROM master.dbo.syslogins WHERE name = ' + '''' + @AOS_SERVICE_ACCT + '''' + ')'
		+char(10) + 'BEGIN' + char(10) +
		'CREATE LOGIN [' + @AOS_SERVICE_ACCT + '] FROM WINDOWS WITH DEFAULT_DATABASE = [DynamicsPerf];'
		+ char(10) + 'END'
		PRINT @SQL
		PRINT ''
     SELECT @SQL = CHAR(10) + 'USE [DynamicsPerf] 
     IF NOT EXISTS
    (SELECT name
     FROM sys.database_principals
     WHERE name = ' + '''' + @SERVICE_ACCOUNT +''''+ ')
BEGIN
     CREATE USER  [' + @SERVICE_ACCOUNT + '] FOR LOGIN [' + @SERVICE_ACCOUNT + ']'
     + CHAR(10) + ' END' + CHAR(10)
     --EXEC sp_executesql @SQL 
	 PRINT @SQL
	 	SET @SQL = 'USE DynamicsPerf  EXEC sp_addrolemember ''db_datareader'', ' + '''' +  @SERVICE_ACCOUNT + ''''
		PRINT @SQL
		SET @SQL = 'USE DynamicsPerf EXEC sp_addrolemember ''db_datawriter'', ' + '''' +  @SERVICE_ACCOUNT + ''''
		PRINT @SQL
		SET @SQL = 'USE DynamicsPerf GRANT EXECUTE ON SP_DELETE_AOTEXPORT TO PUBLIC'
		PRINT @SQL
		SET @SQL = 'USE DynamicsPerf GRANT EXECUTE ON DYNPERF_SERVER_ACTIVITY TO PUBLIC'
		PRINT @SQL
		PRINT ' '
		PRINT ' '
		 SELECT @SQL = CHAR(10) + 'USE [DynamicsPerf] 
     IF NOT EXISTS
    (SELECT name
     FROM sys.database_principals
     WHERE name = ' + '''' + @AOS_SERVICE_ACCT +''''+ ')
BEGIN
     CREATE USER  [' + @AOS_SERVICE_ACCT + '] FOR LOGIN [' + @AOS_SERVICE_ACCT + ']'
     + CHAR(10) + ' END' + CHAR(10)
     --EXEC sp_executesql @SQL 
	 PRINT @SQL
	 	SET @SQL = 'USE DynamicsPerf  EXEC sp_addrolemember ''db_datareader'', ' + '''' +  @AOS_SERVICE_ACCT + ''''
		PRINT @SQL
		SET @SQL = 'USE DynamicsPerf EXEC sp_addrolemember ''db_datawriter'', ' + '''' +  @AOS_SERVICE_ACCT + ''''
		PRINT @SQL


	 PRINT ' '
	 PRINT ' '

	 PRINT ' '
	 PRINT ' '
	 PRINT '/********************************************************'
	 PRINT '--RUN THESE SCRIPTS ON YOUR ReportServer DATABASE SERVER '
	 PRINT '********************************************************/'
	 PRINT ' '

	 	SET @SQL = 'IF NOT EXISTS(SELECT loginname FROM master.dbo.syslogins WHERE name = ' + '''' + @SERVICE_ACCOUNT + '''' + ')'
		+char(10) + 'BEGIN' + char(10) +
		'CREATE LOGIN [' + @SERVICE_ACCOUNT + '] FROM WINDOWS WITH DEFAULT_DATABASE = [' + @REPORT_SERVER_DB + '];'
		+ char(10) + 'END'
		PRINT @SQL
		PRINT ''
		     SELECT @SQL = CHAR(10) + CHAR(10) + 'USE [' + @REPORT_SERVER_DB + '] 
     IF NOT EXISTS
    (SELECT name
     FROM sys.database_principals
     WHERE name = ' + '''' + @SERVICE_ACCOUNT +''''+ ')
BEGIN
     CREATE USER  [' + @SERVICE_ACCOUNT + '] FOR LOGIN [' + @SERVICE_ACCOUNT + ']'
     + CHAR(10) + ' END' + CHAR(10)
     --EXEC sp_executesql @SQL 
	 PRINT @SQL
		SET @SQL = 'USE [' + @REPORT_SERVER_DB + '] EXEC sp_addrolemember ''db_datareader'', ' + '''' +  @SERVICE_ACCOUNT + ''''
		PRINT @SQL


CLOSE database_cursor 
DEALLOCATE database_cursor 



IF EXISTS (SELECT *
           FROM   sys.synonyms
           WHERE  name = 'DYN_SECURITY')
  EXEC ('DROP SYNONYM [dbo].DYN_SECURITY')

