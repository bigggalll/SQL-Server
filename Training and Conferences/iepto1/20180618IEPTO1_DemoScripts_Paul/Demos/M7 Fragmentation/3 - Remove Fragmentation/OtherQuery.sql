-- This is not the main script

USE [GUIDtest];
GO

BEGIN TRAN;
GO

UPDATE [BadKeyTable]
SET [c4] = 'b';
GO

-- Run down to here

-- Now try this after the online index
-- operation has completed.
COMMIT TRAN;
GO
