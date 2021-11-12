USE AdventureWorks2012;
GO

BEGIN TRANSACTION

UPDATE HumanResources.Department SET GroupName = GroupName + '_B'


--go to other conn
UPDATE HumanResources.Employee
SET JobTitle = JobTitle + '_B'

ROLLBACK

