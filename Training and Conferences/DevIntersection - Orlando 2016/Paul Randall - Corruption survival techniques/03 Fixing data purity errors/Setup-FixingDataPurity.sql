-- Setup script for Fixing Data Purity demo.

-- Demo databases can be downloaded from
-- http://bit.ly/10fKpbS (that's a zero).

-- Download the 2008/2014 SalesDB Sample Database from the link above

-- Restore as follows:
USE [master];
GO

IF DATABASEPROPERTYEX (N'SalesDB', N'Version') > 0
BEGIN
	ALTER DATABASE [SalesDB] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [SalesDB];
END
GO

RESTORE DATABASE [SalesDB]
FROM DISK = N'D:\SQLskills\DemoBackups\SalesDB2014.bak';
GO

-- Change the column type and rebuild the index
USE [SalesDB];
GO

ALTER TABLE [products] ALTER COLUMN [price] FLOAT;
GO
ALTER INDEX [productsPK] ON [products] REBUILD;
GO

-- What pages are there?
DBCC IND (N'SalesDB', N'Products', -1);
GO

-- Pick the page two up from the bottom
-- Check slot 23 is product ID 306
-- Your page ID may be different
DBCC TRACEON (3604)
DBCC PAGE (N'SalesDB', 1, 310, 3);
GO

-- Take the slot 23 offset and add 8, covert to an int
SELECT CONVERT (INT, 0x613 + 8);
GO

-- Corrupt slot 23's float value record
ALTER DATABASE [SalesDB] SET SINGLE_USER;
GO
-- Your page ID may be different
DBCC WRITEPAGE (N'SalesDB', 1, 310, 1563, 8, 0xFFFFFFFFFFFFFFFF);
GO
ALTER DATABASE [SalesDB] SET MULTI_USER;
GO

-- Clean the error log and suspect_pages
DELETE FROM [msdb].[dbo].[suspect_pages];
EXEC sp_cycle_errorlog;
GO