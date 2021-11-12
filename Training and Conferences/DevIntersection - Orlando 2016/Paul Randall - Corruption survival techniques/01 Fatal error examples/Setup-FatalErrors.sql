-- Setup script for Fatal Errors demo.

-- Remove any old databases
USE [master];
GO

IF DATABASEPROPERTYEX (N'FatalCorruption1', N'Version') > 0
BEGIN
	ALTER DATABASE [FatalCorruption1] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [FatalCorruption1];
END

IF DATABASEPROPERTYEX (N'FatalCorruption2', N'Version') > 0
BEGIN
	ALTER DATABASE [FatalCorruption2] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [FatalCorruption2];
END
GO

IF DATABASEPROPERTYEX (N'FatalCorruption3', N'Version') > 0
BEGIN
	ALTER DATABASE [FatalCorruption3] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [FatalCorruption3];
END
GO

-- Create new databases
CREATE DATABASE [FatalCorruption1] ON PRIMARY (
    NAME = N'FatalCorruption1',
    FILENAME = N'D:\SQLskills\FatalCorruption1.mdf')
LOG ON (
    NAME = N'FatalCorruption1_log',
    FILENAME = N'D:\SQLskills\FatalCorruption1_log.ldf');

CREATE DATABASE [FatalCorruption2] ON PRIMARY (
    NAME = N'FatalCorruption2',
    FILENAME = N'D:\SQLskills\FatalCorruption2.mdf')
LOG ON (
    NAME = N'FatalCorruption2_log',
    FILENAME = N'D:\SQLskills\FatalCorruption2_log.ldf');

CREATE DATABASE [FatalCorruption3] ON PRIMARY (
    NAME = N'FatalCorruption3',
    FILENAME = N'D:\SQLskills\FatalCorruption3.mdf')
LOG ON (
    NAME = N'FatalCorruption3_log',
    FILENAME = N'D:\SQLskills\FatalCorruption3_log.ldf');
GO

-- Disable page protection to allow the demo to work
ALTER DATABASE [FatalCorruption1] SET PAGE_VERIFY NONE;
ALTER DATABASE [FatalCorruption2] SET PAGE_VERIFY NONE;
ALTER DATABASE [FatalCorruption3] SET PAGE_VERIFY NONE;
GO

-- Prepare databases for using DBCC WRITEPAGE
ALTER DATABASE [FatalCorruption1] SET SINGLE_USER;
ALTER DATABASE [FatalCorruption2] SET SINGLE_USER;
ALTER DATABASE [FatalCorruption3] SET SINGLE_USER;
GO

-- Corrupt fileheader page
DBCC WRITEPAGE (N'FatalCorruption1', 1, 0, 0, 4, 0x00000000, 1);
GO

-- Corrupt boot page
DBCC WRITEPAGE (N'FatalCorruption2', 1, 9, 0, 4, 0x00000000, 1);
GO

-- Corrupt metadata
DBCC WRITEPAGE (N'FatalCorruption3', 1, 20, 0, 4, 0x00000000, 1);
GO
DBCC WRITEPAGE (N'FatalCorruption3', 1, 17, 0, 4, 0x00000000, 1);
GO

-- Return databases to usable state (you'll see an error)
ALTER DATABASE [FatalCorruption1] SET MULTI_USER;
ALTER DATABASE [FatalCorruption2] SET MULTI_USER;
ALTER DATABASE [FatalCorruption3] SET MULTI_USER;
GO

-- Clean the error log and suspect_pages
DELETE FROM [msdb].[dbo].[suspect_pages];
EXEC sp_cycle_errorlog;
GO