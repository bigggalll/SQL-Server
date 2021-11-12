USE AdventureWorks 
GO 

SELECT 
	name
	,snapshot_isolation_state
	,snapshot_isolation_state_desc
	,is_read_committed_snapshot_on
FROM sys.databases 
WHERE name = 'AdventureWorks'


ALTER DATABASE AdventureWorks SET READ_COMMITTED_SNAPSHOT ON WITH ROLLBACK IMMEDIATE
GO

ALTER DATABASE AdventureWorks SET ALLOW_SNAPSHOT_ISOLATION ON


--what's in the version store
SELECT * FROM sys.dm_tran_version_store
 
BEGIN TRANSACTION

UPDATE HumanResources.Department SET 
	GroupName = 'Research and Development'
WHERE DepartmentID = 1

SELECT @@trancount

SELECT * 
FROM HumanResources.Department
WHERE DepartmentID = 1

ROLLBACK
COMMIT 