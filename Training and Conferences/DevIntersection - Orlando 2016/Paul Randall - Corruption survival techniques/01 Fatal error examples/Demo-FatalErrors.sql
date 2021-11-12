-- Demo script for Fatal Errors demo.

-- Run the Setup-FatalErrors.sql script first.

-- Corrupt fileheader page
DBCC CHECKDB (N'FatalCorruption1') WITH NO_INFOMSGS;
GO

DBCC CHECKDB (N'FatalCorruption1') WITH NO_INFOMSGS, TABLOCK;
GO

-- Corrupt boot page
DBCC CHECKDB (N'FatalCorruption2') WITH NO_INFOMSGS;
GO

-- Corrupt metadata
-- You may see different messages depending on which
-- version of SQL Server you are using
DBCC CHECKDB (N'FatalCorruption3') WITH NO_INFOMSGS;
GO

DBCC CHECKDB (N'FatalCorruption3') WITH NO_INFOMSGS, TABLOCK;
GO


