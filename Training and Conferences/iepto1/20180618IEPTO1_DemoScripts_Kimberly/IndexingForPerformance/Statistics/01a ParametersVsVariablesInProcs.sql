-- Just a quick tangeant to cover the behavior of parameters and
-- variables in a procedure.

-- This is expecting that you've already executed script:
-- "01 Statistics Examples.sql"

USE [Credit];
GO

CREATE PROC [GetInfo1]
	@p1	varchar(15)
AS
SELECT [m].*
FROM [dbo].[Member] AS [m]
WHERE [m].[LastName] = @p1;  -- parameter
GO

CREATE PROC [GetInfo2]
	@p1	varchar(15)
AS
DECLARE @v1 varchar(15);
SELECT @v1 = @p1
SELECT [m].*
FROM [dbo].[Member] AS [m]
WHERE [m].[LastName] = @v1;  -- variable
GO

CREATE PROC [GetInfo3]
	@p1	varchar(15)
AS
SELECT [m].*
FROM [dbo].[Member] AS [m]
WHERE [m].[LastName] = @p1
OPTION (OPTIMIZE FOR UNKNOWN);  -- parameter - but with hint...
GO

EXEC [GetInfo1] 'Tripp';  -- Can be sniffed and will get a plan for 'Tripp'
GO

EXEC [GetInfo2] 'Tripp';  -- Cannot be sniffed, will use "average" plan
GO

EXEC [GetInfo3] 'Tripp';  -- Cannot be sniffed, will use "average" plan
GO