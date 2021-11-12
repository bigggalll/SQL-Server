/*============================================================================
  File:     TempdbClient.sql

  Summary:  Create temp tables

  SQL Server Versions: 2005 onwards
------------------------------------------------------------------------------
  Written by Paul S. Randal, SQLskills.com

  (c) 2018, SQLskills.com. All rights reserved.

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  You may alter this code for your own *non-commercial* purposes. You may
  republish altered code as long as you include this copyright and give due
  credit, but you must obtain prior permission before blogging this code.
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

USE [tempdb];
GO

SET NOCOUNT ON;
GO

DECLARE @TableName  VARCHAR (128);
DECLARE @ExecString VARCHAR (8000);
DECLARE @a INT;

SELECT @TableName = '##Temp' + CAST (@@SPID AS VARCHAR);

SELECT @ExecString = 'CREATE TABLE [' +
	@TableName + '] ([c1] INT)';

EXEC (@ExecString);

WHILE (1=1)
BEGIN

	-- Calculate doc name length
	SELECT @ExecString = 'INSERT INTO [' +
		@TableName +
		'] SELECT * FROM [TempdbTest].[dbo].[SampleTable]';
		
	--SELECT @ExecString;
	EXEC (@ExecString);

	SELECT @ExecString = 'DELETE FROM [' + @TableName + ']';
	
	EXEC (@ExecString);

	SELECT @a = (
		SELECT TOP (1) [c1] FROM [TempdbTest].[dbo].[SampleTable]);
END;
GO