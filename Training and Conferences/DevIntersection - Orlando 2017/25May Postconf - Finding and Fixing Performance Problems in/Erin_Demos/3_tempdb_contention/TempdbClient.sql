USE [AdventureWorks2016]
GO
SET NOCOUNT ON;

WHILE 1=1
BEGIN
	EXECUTE [Person].[GetNextDuplicateCustomerSet] 1;
	WAITFOR DELAY '00:00:01.000';
END