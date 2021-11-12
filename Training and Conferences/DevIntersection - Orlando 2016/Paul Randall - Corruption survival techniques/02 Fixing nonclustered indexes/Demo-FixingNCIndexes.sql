-- Demo script for Fixing Nonclustered Indexes demo.

-- Run the Setup-FixingNCIndexes.sql script first.

-- Run a CHECKDB
DBCC CHECKDB (N'SalesDB') WITH NO_INFOMSGS;
GO

-- Imagine if there were hundreds of errors...
-- Is it just non-clustered indexes?
-- Scan through all the errors looking for index IDs
-- Maybe use WITH TABLERESULTS?
DBCC CHECKDB (N'SalesDB') WITH NO_INFOMSGS, TABLERESULTS;
GO

-- If you wanted to fix them with DBCC CHECKDB, it
-- may do single row repairs or rebuild the index,
-- depending on the error
DBCC CHECKDB (N'SalesDB', REPAIR_REBUILD) WITH NO_INFOMSGS;
GO

-- You need to be in SINGLE_USER mode! Just to
-- fix non-clustered indexes.
--
-- That doesn't make sense. Just rebuild them
-- manually and keep the database online. Try an
-- online rebuild...
USE [SalesDB];
GO
EXEC sp_HelpIndex N'Customers';
GO

ALTER INDEX [CustomerName] ON [Customers] REBUILD
WITH (ONLINE = ON);
GO

-- And check again...
DBCC CHECKDB (N'SalesDB') WITH NO_INFOMSGS;
GO

-- Didn't work! Online index rebuild scans
-- the old index...
-- Try offline... on some versions this might work
ALTER INDEX [CustomerName] ON [Customers] REBUILD;
GO

DBCC CHECKDB (N'SalesDB') WITH NO_INFOMSGS;
GO

-- But on 2008 onward you should disable and rebuild
-- the index (or use repair to do it).
USE [SalesDB];
GO

-- Do it inside a transaction to prevent problems
-- by forcing locks to be held which should prevent
-- constraint violations
BEGIN TRAN;
GO
ALTER INDEX [CustomerName] ON [Customers] DISABLE;
ALTER INDEX [CustomerName] ON [Customers] REBUILD;
GO
COMMIT TRAN;
GO

-- Final check
DBCC CHECKDB (N'SalesDB') WITH NO_INFOMSGS;
GO