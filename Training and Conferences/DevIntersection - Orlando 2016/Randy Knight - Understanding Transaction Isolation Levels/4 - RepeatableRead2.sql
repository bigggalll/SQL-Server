USE AdventureWorks
go

BEGIN TRAN 

UPDATE HumanResources.Department SET
	GroupName = 'R&D'
WHERE DepartmentID = 1

	
SELECT * FROM HumanResources.Department WHERE DepartmentID = 1

ROLLBACK



