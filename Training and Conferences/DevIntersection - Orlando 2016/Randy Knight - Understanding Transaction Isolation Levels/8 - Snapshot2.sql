USE AdventureWorks 
GO 

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

SELECT * FROM HumanResources.Department	WITH (NOLOCK)

SELECT * FROM HumanResources.Department

--lets try an update 
BEGIN TRANSACTION 
	
UPDATE HumanResources.Department SET 
	GroupName = 'R&D' 
WHERE DepartmentID = 1

SELECT * FROM HumanResources.Department	

SELECT @@trancount

--go to Connection2
COMMIT



COMMIT 



