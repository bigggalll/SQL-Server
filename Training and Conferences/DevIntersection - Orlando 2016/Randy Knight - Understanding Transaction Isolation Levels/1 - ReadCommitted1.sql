USE AdventureWorks 
GO 

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

BEGIN TRAN 

SELECT * FROM HumanResources.Department	
go

SELECT * FROM dbo.SalesOrderHeaderBig

COMMIT TRAN

--lets try an update 
BEGIN TRANSACTION 
	
UPDATE HumanResources.Department SET 
	GroupName = 'R&D' 
WHERE DepartmentID = 1

SELECT * FROM HumanResources.Department	

SELECT @@trancount

--go to Connection2
ROLLBACK


COMMIT 




