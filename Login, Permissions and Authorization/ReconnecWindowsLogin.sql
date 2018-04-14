SET NOCOUNT ON
USE grpJeanCoutuCorp_PrePROD
GO
DECLARE @loop INT
DECLARE @USER sysname
DECLARE @sqlcmd NVARCHAR(500) = ''
 
IF OBJECT_ID('tempdb..#Orphaned') IS NOT NULL 
 BEGIN
  DROP TABLE #orphaned
 END
 
CREATE TABLE #Orphaned (UserName sysname,IDENT INT IDENTITY(1,1))
 
INSERT INTO #Orphaned (UserName)
SELECT [name] FROM sys.database_principals WHERE [type] IN ('U','S') AND is_fixed_role = 0 AND [Name] NOT IN ('dbo','guest','sys','INFORMATION_SCHEMA')
 
IF(SELECT COUNT(*) FROM #Orphaned) > 0
BEGIN
 SET @loop = 1
 WHILE @loop <= (SELECT MAX(IDENT) FROM #Orphaned)
  BEGIN
    SET @USER = (SELECT UserName FROM #Orphaned WHERE IDENT = @loop)
    IF(SELECT COUNT(*) FROM sys.server_principals WHERE [Name] = @USER) <= 0
     BEGIN
	   PRINT '         Login ' + @USER + ' does not exists!'
        --IF EXISTS(SELECT 1 FROM sys.database_principals WHERE [Name] = @USER AND type_desc = 'WINDOWS_USER')
        -- BEGIN
        --    SET @sqlcmd = 'CREATE LOGIN [' + @USER + '] FROM WINDOWS'
        --    --Exec(@sqlcmd)
        --    PRINT @sqlcmd
        -- END
        --IF EXISTS(SELECT 1 FROM sys.database_principals WHERE [Name] = @USER AND type_desc = 'SQL_USER')
        -- BEGIN
        --    SET @sqlcmd = 'CREATE LOGIN [' + @USER + '] WITH PASSWORD = N''password'''
        --    --Exec(@sqlcmd)
        --    PRINT @sqlcmd
        -- END
     END
    ELSE
     BEGIN 
	   SET @sqlcmd = 'ALTER USER [' + @USER + '] WITH LOGIN = [' + @USER + ']'
	   Exec(@sqlcmd)
	   PRINT @USER + ' link to DB user reset';
     END
    SET @loop = @loop + 1
  END
END
SET NOCOUNT OFF