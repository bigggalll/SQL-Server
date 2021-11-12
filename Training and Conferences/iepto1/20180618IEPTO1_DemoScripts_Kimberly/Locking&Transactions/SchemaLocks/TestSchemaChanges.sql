/*============================================================================
  File:     Schema changes - surprising SCH_M lock requirements? 
            Can't repro

  Summary:  We traditionally think of SCH_M locks against objects but
            what about the schemas themselves... 
            
  SQL Server Version: 2005+
------------------------------------------------------------------------------
  Written by Kimberly L. Tripp, SYSolutions, Inc.

  For more scripts and sample code, check out http://www.SQLskills.com

  This script is intended only as a supplement to demos and lectures
  given by Kimberly L. Tripp.  
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

IF DATABASEPROPERTYEX('TestSchemaChanges', 'Collation') IS NOT NULL
	DROP DATABASE [TestSchemaChanges];
GO

CREATE DATABASE [TestSchemaChanges];
GO

USE [TestSchemaChanges];
GO

CREATE SCHEMA [Schema1];
GO

CREATE SCHEMA [Schema2];
GO

DECLARE @Counter    tinyint = 1
    ,   @ExecStr    nvarchar(1000);

WHILE @Counter < 255
BEGIN
    SELECT @ExecStr = N'CREATE TABLE [Schema1].[t' + convert(nvarchar, @counter) + N'] ([c1] int)';
    EXEC (@ExecStr);
    SELECT @Counter = @Counter + 1;
END;
GO

EXEC [sp_help];
GO
SELECT SCHEMA_NAME([SCHEMA_ID]), [name], [OBJECT_ID] FROM [sys].[tables];
GO

SELECT * FROM [t1]; -- fails
GO
SELECT * FROM [Schema1].[t1]; -- succeeds
GO

CREATE TABLE [Schema2].[foo] ([c1] int);
GO

-- OK... now we have 255 tables in Schema1 and one table in Schema2...
-- go to a 2nd window and open a tran that reads (and holds) data from a couple of tables...
-- then, check the locks...

--Now, let's try and change the schema of table:foo

ALTER SCHEMA Schema1 TRANSFER Schema2.foo;
GO

sp_help 'schema1.foo'

drop table schema1.foo

select @@TRANCOUNT


CREATE TABLE [Schema2].[foo2] ([c1] int);
GO
