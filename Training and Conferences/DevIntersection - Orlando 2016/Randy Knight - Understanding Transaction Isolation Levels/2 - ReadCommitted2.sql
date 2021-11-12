USE AdventureWorks
go

-- read committed demo
SET TRANSACTION ISOLATION LEVEL READ COMMITTED 
GO 

SELECT * 
FROM HumanResources.Department
WHERE DepartmentID = 1
GO

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
GO 

SELECT * 
FROM HumanResources.Department
WHERE DepartmentID = 1

-- back to connection 1 and rollback






