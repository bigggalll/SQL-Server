/*============================================================================
  File:     3a_tempdb_Configuration.sq

  Summary:  Generate some IO against a database on an external, slow drive

  SQL Server Versions: 2008 onwards
------------------------------------------------------------------------------
  Written by Erin Stellato, SQLskills.com

  (c) 2017, SQLskills.com. All rights reserved.

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

/*
	check current tempdb files and sizes
*/
USE [tempdb];
GO

SELECT 
	[file_id],	
	[type],	
	[type_desc],	
	[name],
	[physical_name],
	[size] [Size In Pages],
	[size]*8 [Size in KB],
	[max_size],	
	[growth],
	[is_percent_growth]
FROM [sys].[database_files];



/*
	list all trace flags enabled for this connection
*/
DBCC TRACESTATUS(); 
GO 

/*
	list all trace flags enabled globally
*/ 
DBCC TRACESTATUS(-1); 
GO 

/*
	enable TF 1118 globally
	note that this will only persist until next restart 
	enable this through SQL Server Configuration Manager, not DBCC TRACEON
*/
DBCC TRACEON (1118, -1);
GO


/*
	run 2b_tempdb_Configuration_Contention_setup.sql
	and 2c_tempdb_Configuration_Contention_setup.sql
	to setup and see performance issue
*/

/*
	re-size original files
	add additional files to alleviate contention AFTER 
	the performance issue has been created
*/

/*
USE [master];
GO

ALTER DATABASE [tempdb] MODIFY FILE ( 
	NAME = N'tempdev', 
	SIZE = 1024MB , 
	FILEGROWTH = 512MB);
GO

ALTER DATABASE [tempdb] MODIFY FILE ( 
	NAME = N'templog', 
	SIZE = 512MB , 
	FILEGROWTH = 256MB);
GO

USE [master]
GO
ALTER DATABASE [tempdb] ADD FILE ( 
	NAME = N'tempdev2', 
	FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.SQL2016\MSSQL\DATA\tempdev2.ndf' , 
	SIZE = 1024MB , 
	FILEGROWTH = 512MB);
GO

ALTER DATABASE [tempdb] ADD FILE ( 
	NAME = N'tempdev3', 
	FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.SQL2016\MSSQL\DATA\tempdev3.ndf' , 
	SIZE = 1024MB , 
	FILEGROWTH = 512MB);
GO

ALTER DATABASE [tempdb] ADD FILE ( 
	NAME = N'tempdev4', 
	FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.SQL2016\MSSQL\DATA\tempdev4.ndf' , 
	SIZE = 1024MB , 
	FILEGROWTH = 512MB);
GO
*/

/*
	re-check sizes
*/
USE [tempdb];
GO

SELECT 
	[file_id],	
	[type],	
	[type_desc],	
	[name],
	[physical_name],
	[size] [Size In Pages],
	[size]*8 [Size in KB],
	[max_size],	
	[growth],
	[is_percent_growth]
FROM [sys].[database_files];