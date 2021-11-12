USE AdventureWorks2012;
GO

BEGIN TRANSACTION

UPDATE HumanResources.Employee SET Gender = 'M'

UPDATE HumanResources.Department SET ModifiedDate = GETDATE()

ROLLBACK
