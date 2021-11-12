-- Script to demonstrate runaway log file

USE [Company];
GO
SET NOCOUNT ON;
GO

WHILE (1 = 1)
BEGIN
	INSERT INTO [BigRows] DEFAULT VALUES;
	WAITFOR DELAY N'00:00:00:300';
END;
GO
