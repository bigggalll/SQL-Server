-- Setup script for Fixing Nonclustered Indexes demo.

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

USE [SalesDB];
GO

-- Create the index we're going to break
CREATE NONCLUSTERED INDEX [CustomerName]
ON [Customers] ([LastName]);
GO

-- What's the index ID?
SELECT
	[index_id]
FROM
	sys.indexes
WHERE
	[name] = N'CustomerName'
	AND [object_id] = OBJECT_ID (N'Customers');
GO

-- List the pages in the index
DBCC IND (N'SalesDB', N'Customers', 2);
GO

-- Corrupt some records (you may have to change the page ID)
ALTER DATABASE [SalesDB] SET SINGLE_USER;
GO
DBCC WRITEPAGE (N'SalesDB', 1, 24630, 140, 1, 0x64);
DBCC WRITEPAGE (N'SalesDB', 1, 24630, 188, 1, 0x70);
DBCC WRITEPAGE (N'SalesDB', 1, 24630, 572, 1, 0x74);
DBCC WRITEPAGE (N'SalesDB', 1, 24630, 2228, 1, 0x74);
DBCC WRITEPAGE (N'SalesDB', 1, 24630, 3822, 1, 0x70);
GO
ALTER DATABASE [SalesDB] SET MULTI_USER;
GO

-- Clean the error log and suspect_pages
DELETE FROM [msdb].[dbo].[suspect_pages];
EXEC sp_cycle_errorlog;
GO