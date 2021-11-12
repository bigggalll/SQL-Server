/*============================================================================
  File:     RestoreIndexInternalsSampleDatabase.sql
  
  Resource: SQL Server 2008 Internals
            http://www.microsoft.com/learning/en/us/books/12967.aspx

  Summary:  This script restores the IndexInternals sample database 
            as used in Chapter 6 of SQL Server 2008 Internals.
  
  Date:     Tweaked for SQL 2014
------------------------------------------------------------------------------
  Written by Kimberly L. Tripp, SQLskills.com

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

-- IMPORTANT NOTES: 
-- 1) This is a compressed SQL Server 2008 backup and will only restore to 
--    SQL Server 2008 and higher.
-- 2) All examples expect a database name of IndexInternals. However, if you
--    already have a database with this name, you can change it. In all other
--    scripts, you'll need to be sure to continue to change this based on your
--    new database name. (LINE 41)
-- 3) Be sure to set your complete path\file based on where the 
--    IndexInternals2008.BAK is located. (LINE 42)
-- 4) Be sure to set the server/instance name for restore. (LINES 44-45)
-- 5) Be sure to set your instance directory structure based on your
--    version/installation. (LINES 47-50) NOTE: You only need ONE setting
--    for RestoreToDirectory. The others are just samples.

-- In general, this script should take less than 30 seconds to execute.

:ON ERROR EXIT
go

:SETVAR DB IndexInternals
:SETVAR IndexInternalsBackup "d:\IndexInternals\01_IndexInternals\IndexInternals2008.bak"

-- Server/Instance for restore
:SETVAR RestoreToServer (local)\SQLServer2014

-- Instance directory path OR another suitable path...
--:SETVAR RestoreToDirectory "C:\Program Files\Microsoft SQL Server\MSSQL10.SQLDev01\MSSQL\data"
:SETVAR RestoreToDirectory "C:\Program Files\Microsoft SQL Server\MSSQL12.SQLServer2014\MSSQL\data"
--:SETVAR RestoreToDirectory "D:\Microsoft SQL Server\MSSQL12.SQL2014\MSSQL\data"

go

:CONNECT $(RestoreToServer)
go

SET NOCOUNT ON;
go

USE master;
go

IF DATABASEPROPERTYEX('$(DB)', 'Collation') IS NOT NULL
	ALTER DATABASE $(DB)
		SET RESTRICTED_USER 
		WITH ROLLBACK IMMEDIATE;
go

IF SUBSTRING(CONVERT(VARCHAR, SERVERPROPERTY('ProductVersion')), 1, 2) < '10' 
BEGIN
	RAISERROR('The IndexInternals backup can only be restored on SQL Server 2008 and higher.', 16, -1)
	RETURN
END;
go

IF substring(convert(varchar, SERVERPROPERTY('ProductVersion')), 1, 2) >= '10' 
	RESTORE DATABASE $(DB) 
	FROM  DISK = N'$(IndexInternalsBackup)'
	WITH  FILE = 1,  
		MOVE N'IndexInternalsData' 
			TO N'$(RestoreToDirectory)\IndexInternalsData.mdf',  
		MOVE N'IndexInternalsLog' 
			TO N'$(RestoreToDirectory)\IndexInternalsLog.ldf',
	STATS = 10, REPLACE;
go

IF DATABASEPROPERTYEX('$(DB)', 'Collation') IS NOT NULL
	ALTER DATABASE $(DB)
		SET MULTI_USER 
		WITH ROLLBACK IMMEDIATE;
go

IF DATABASEPROPERTYEX('$(DB)', 'Collation') IS NOT NULL
	ALTER DATABASE [$(DB)]
		SET COMPATIBILITY_LEVEL = 120;
go

--Here are the valid values for Compatibility Level
--80	SQL Server 2000
--90	SQL Server 2005
--100	SQL Server 2008 and SQL Server 2008 R2
--110	SQL Server 2012
--120	SQL Server 2014

EXEC sp_dbcmptlevel [$(DB)];
go