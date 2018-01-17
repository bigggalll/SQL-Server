-- SQL Server 2012/2014 Permissions Code
-- donkiely@computer.org

-- *** SQL Server Logins ***
-- *************************

CREATE LOGIN Bonsai WITH PASSWORD = 'EDxQk!R209*:ZJ5';
GO

USE AdventureWorks2012;
GO

CREATE USER Bonsai FOR LOGIN Bonsai WITH DEFAULT_SCHEMA = Production;
-- User name doesn't need to be the same as login name, but here it is.
GO

-- *** User-Defined Server Role and Permissions ***
-- ************************************************

USE master;
GO

-- Create a user-defined server role
CREATE SERVER ROLE LimitedAdmin;
GO

-- Grant sysadmin privileges
GRANT CONTROL SERVER TO LimitedAdmin;
GO

-- Members of LimitedAdmin role now have omnipotent powers over the server instance and all its objects
-- Restrict that to some extent
DENY ALTER ANY SERVER ROLE TO LimitedAdmin;
DENY ALTER ANY LOGIN TO LimitedAdmin;
DENY ALTER ANY DATABASE TO LimitedAdmin;

-- Statements that exercise server-level actions - don't run these yet!
-- ** Start statements
CREATE SERVER ROLE TempRole;
CREATE LOGIN TempLogin WITH PASSWORD = 'AK8l*9%fwy/xvH';
CREATE DATABASE TempDatabase;

EXEC SP_CONFIGURE 'show advanced options', '1';
GO
RECONFIGURE;
GO
EXEC SP_CONFIGURE 'clr enabled' , '1'
GO
RECONFIGURE;
GO
-- ** End statements

-- Statement cleanup - run as sysadmin
-- ** Start statements
DROP SERVER ROLE TempRole;
DROP LOGIN TempLogin;
DROP DATABASE TempDatabase;
-- ** End statements

-- Test the statements, logged in as sysadmin
-- Go execute statements. Should all succeed.
-- Go execute cleanup statements.

-- Test permissions
-- Test 1: Can Bonsai do these things?
EXECUTE AS LOGIN = 'Bonsai';
-- go execute the block of statements
REVERT;

-- Test 2: Add Bonsai to LimitedAdmin
ALTER SERVER ROLE LimitedAdmin ADD MEMBER Bonsai;
GO
EXECUTE AS LOGIN = 'Bonsai';
-- go execute the block of statements
-- still can't execute first four operations, but can the fifth
REVERT;

-- Test 3: Deny ALTER SERVER STATE permission, which won't allow DBCC FREPROCCACHE
DENY ALTER SETTINGS TO LimitedAdmin;
GO
EXECUTE AS LOGIN = 'Bonsai';
-- go execute the block of statements
-- still can't execute first four operations, but can the fifth
REVERT;

-- *** User-defined Database Role and Permissions ***
-- **************************************************

USE AdventureWorks2012;
GO

-- Create a user-defined data entry role in the production schema
CREATE ROLE ProdDataEntry AUTHORIZATION dbo;
-- Assign Bonsai to the role
ALTER ROLE ProdDataEntry ADD MEMBER Bonsai;
GO

-- Assign permissions to the ProdDataEntry role
GRANT INSERT ON Production.UnitMeasure TO ProdDataEntry;
GRANT UPDATE ON Production.UnitMeasure TO ProdDataEntry;
GRANT INSERT ON Production.ProductCategory TO ProdDataEntry;
GRANT UPDATE ON Production.ProductCategory TO ProdDataEntry;
GRANT SELECT ON Production.ProductCategory TO ProdDataEntry;
GRANT EXECUTE ON dbo.uspGetEmployeeManagers TO ProdDataEntry;
REVOKE EXECUTE ON dbo.uspGetManagerEmployees TO ProdDataEntry;

-- See what Bonsai can do
EXECUTE AS USER = 'Bonsai';

-- Succeeds - has permission
INSERT INTO Production.UnitMeasure (UnitMeasureCode, Name)
     VALUES ('BAR', 'Standard Bar');
-- Fails
SELECT * FROM Production.UnitMeasure WHERE UnitMeasureCode = 'BAR';

-- Succeeds - has permission
INSERT INTO Production.ProductCategory (Name)
     VALUES ('Navigation');
-- Succeeds
SELECT * FROM Production.ProductCategory WHERE Name = 'Navigation';

-- Fails
INSERT INTO HumanResources.Department
	(Name, GroupName)
VALUES
	('Advertising', 'Sales and Marketing');
GO

-- Succeeds
DECLARE @rc INT;
EXECUTE @rc = dbo.uspGetEmployeeManagers 113;
GO

-- Fails
DECLARE @rc INT;
EXECUTE @rc = dbo.uspGetManagerEmployees 113;
GO

REVERT;

-- *** Permissions metadata ***
-- ****************************

-- View the permissions for the ProdDataEntry database role
USE AdventureWorks2012;
GO

SELECT DB_NAME() AS 'Database', p.name, p.type_desc, dbp.state_desc, 
	dbp.permission_name, so.name, so.type_desc
FROM sys.database_permissions dbp 
	LEFT JOIN sys.objects so ON dbp.major_id = so.object_id 
	LEFT JOIN sys.database_principals p ON dbp.grantee_principal_id = p.principal_id 
WHERE p.name = 'ProdDataEntry'
ORDER BY so.name, dbp.permission_name;

-- Get a list of all built-in permissions
SELECT * FROM sys.fn_builtin_permissions(DEFAULT);

-- Get a list of server-level permissions
SELECT * FROM sys.fn_builtin_permissions('SERVER') ORDER BY permission_name;

-- Get a list of database-level permissions
SELECT * FROM sys.fn_builtin_permissions('DATABASE') ORDER BY permission_name;


-- *** Clean Up ***
-- ****************
-- Be sure to run this as sysadmin!
-- Run earlier cleanup statements, if necessary

USE AdventureWorks2012;
GO

DELETE FROM Production.UnitMeasure WHERE UnitMeasureCode = 'BAR';
DELETE FROM Production.ProductCategory WHERE Name = 'Navigation';
GO

DROP USER Bonsai;
DROP ROLE ProdDataEntry;
GO

USE master;
GO

DROP LOGIN Bonsai;
DROP SERVER ROLE LimitedAdmin;
GO
