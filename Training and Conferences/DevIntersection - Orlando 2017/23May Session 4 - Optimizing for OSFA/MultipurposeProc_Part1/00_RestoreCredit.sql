/*============================================================================
  File:     RestoreCredit.sql

  Summary:  Restore the Credit Database to give us a clean for demos.
			***** THIS IS A SQLCMD SCRIPT! ***** 
            Be sure to turn that on before running.
  
  SQL Server Version: 2008+
------------------------------------------------------------------------------
  Written by Kimberly L. Tripp, SYSolutions, Inc.

  For more scripts and sample code, check out http://www.SQLskills.com

  This script is intended only as a supplement to demos and lectures
  given by Kimberly L. Tripp.  
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

-- IMPORTANT NOTES: 
-- 1) This is a compressed SQL Server 2008 backup and will restore to SQL 
--      Server 2008/R2, SQL 2012, SQL 2014, or SQL 2016.
-- 2) All examples expect a database name of Credit. However, if you
--    already have a database with this name, you can change it. In all other
--    scripts, you'll need to be sure to continue to change this based on your
--    new database name. (LINE 44)
-- 3) Be sure to set your complete path\file based on where the 
--    CreditBackup100.BAK is located. (LINE 45)
-- 4) Be sure to set the server/instance name for restore. (LINES 47-49)
-- 5) Be sure to set your instance directory structure based on your
--    installation. (LINES 51-54)
-- 6) Be sure to set your COMPATIBILITY LEVEL to the correct instance-level
--    if you want to test things that are version specific! (LINES 89-92)


-- In general, this script should take less than 30 seconds to execute.

:ON ERROR EXIT
go

:SETVAR DB Credit
:SETVAR CreditBackup "D:\SQLskills\CreditBackup100.BAK"

--:SETVAR RestoreToServer (local)\SQLDev01
--:SETVAR RestoreToServer (local)\SQL2012Dev01
:SETVAR RestoreToServer (local)\SQL2014

--:SETVAR RestoreToDirectory "C:\Program Files\Microsoft SQL Server\MSSQL10.SQLDev01\MSSQL\data"
--:SETVAR RestoreToDirectory "C:\Program Files\Microsoft SQL Server\MSSQL10_50.SQL2008R2Dev01\MSSQL\data"
--:SETVAR RestoreToDirectory "D:\Microsoft SQL Server\MSSQL11.SQL2012Dev01\MSSQL\data"
:SETVAR RestoreToDirectory "D:\Microsoft SQL Server\MSSQL12.SQL2014\MSSQL\data"
go

:CONNECT $(RestoreToServer)
go

SET NOCOUNT ON
go

USE master
go

IF DATABASEPROPERTYEX('$(DB)', 'Collation') IS NOT NULL
	ALTER DATABASE [$(DB)]
		SET RESTRICTED_USER 
		WITH ROLLBACK AFTER 5;
go

IF substring(convert(varchar, SERVERPROPERTY('ProductVersion')), 1, 2) >= '10' 
	RESTORE DATABASE [$(DB)] 
	FROM  DISK = N'$(CreditBackup)' 
	WITH  FILE = 1,  
		MOVE N'CreditData' 
			TO N'$(RestoreToDirectory)\CreditData.mdf',  
		MOVE N'CreditLog' 
			TO N'$(RestoreToDirectory)\CreditLog.ldf',
	STATS = 10, REPLACE;
go

IF DATABASEPROPERTYEX('$(DB)', 'Collation') IS NOT NULL
	ALTER DATABASE [$(DB)]
		SET MULTI_USER 
		WITH ROLLBACK IMMEDIATE;
go

IF DATABASEPROPERTYEX('$(DB)', 'Collation') IS NOT NULL
	ALTER DATABASE [$(DB)]
		SET COMPATIBILITY_LEVEL = 110;
go

--Here are the valid values for Compatibility Level
--80	SQL Server 2000
--90	SQL Server 2005
--100	SQL Server 2008 and SQL Server 2008 R2
--110	SQL Server 2012
--120	SQL Server 2014

-- NOTE: As a general recommendation, you might choose
-- the Legacy CE by default (compat mode 110) but then
-- as you're troubleshooting, try the New CE with
-- OPTION (QUERYTRACEON 2312);

-- It's not until you thoroughly test the new CE that 
-- I would recommend moving over to it. Having said that,
-- you might get some great results!

-- If you end up with only a couple of regressions and 
-- you've switched to compat mode 120 then you can access 
-- the Legacy CE with:
-- OPTION (QUERYTRACEON 9481);
