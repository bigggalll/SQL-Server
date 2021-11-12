-- Demo script for Fixing Data Purity demo.

-- Run the Setup-FixingDataPurity.sql script first.

-- Run a CHECKDB
DBCC CHECKDB (N'SalesDB') WITH NO_INFOMSGS; 
GO

-- Data purity corruption. Error only gives the page
-- and slot. Let's take a look.

-- Enable DBCC PAGE output to the console
DBCC TRACEON (3604);
GO

DBCC PAGE (N'SalesDB', 1, XXX, 3);
GO

-- It's definitely corrupt. Let's see if we can
-- just delete the record. Maybe not a good idea...
USE [SalesDB];
GO

-- Make sure we have the right column for the key
sp_helpindex N'Products';
GO

DELETE FROM [Products] WHERE [ProductID] = XXX;
GO

-- Hmm - ok - we'll need to update it to something
-- for now.
UPDATE
	[Products]
SET
	[Price] = 0.01
WHERE
	[ProductID] = XXX;
GO

-- Hopefully that fixed it...
DBCC CHECKDB (N'SalesDB') WITH NO_INFOMSGS;
GO

-- Success. Steps: look at the page to get the
-- index keys. Update the row and set the column
-- to a valid value. Make sure the value makes
-- sense for the application.