/*============================================================================
	File: Logical IO and CPU.sql 

	SQL Server Versions: 2012 11.0.3321
------------------------------------------------------------------------------
	Copyright (C) 2012 Joe Sack, SQLskills.com
	All rights reserved. 

	For more scripts and sample code, check out
		http://www.sqlskills.com/ 

	You may alter this code for your own *non-commercial* purposes. You may
	republish altered code as long as you give due credit. 

	THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF
	ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED
	TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
	PARTICULAR PURPOSE.
============================================================================*/ 
USE [master];
GO

ALTER DATABASE [Credit] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

RESTORE DATABASE [Credit] FROM  DISK = N'C:\SQLBackup\CreditBackup100.bak' 
WITH  FILE = 1,  
	  MOVE N'CreditData' TO N'c:\SQLData\CreditData.mdf',  
	  MOVE N'CreditLog' TO N'c:\SQLData\CreditLog.ldf',  
	  REPLACE,  STATS = 5;

GO



USE Credit;
GO

DBCC FREEPROCCACHE;
DBCC DROPCLEANBUFFERS;
GO

-- Investigate the IO/CPU of this simple query
EXEC sp_executesql 
	N'SELECT charge_no FROM dbo.charge
	WHERE charge_dt = @charge_dt',
	N'@charge_dt datetime',  
	@charge_dt = '1999-07-20 10:49:11.833';
GO

-- What LIOs, PIOs, CPU time do we see?
SELECT	t.text, 
		s.total_logical_reads,
		s.total_physical_reads, 
		s.total_worker_time,
		p.query_plan
FROM sys.dm_exec_query_stats s
CROSS APPLY sys.dm_exec_query_plan (s.plan_handle) p
CROSS APPLY sys.dm_exec_sql_text (s.plan_handle) t
WHERE t.text LIKE '%WHERE charge_dt%';
GO

-- Adding index
CREATE NONCLUSTERED INDEX NCL_charge_charge_dt 
ON [dbo].[charge] ([charge_dt]);
GO

-- Test again
DBCC FREEPROCCACHE;
DBCC DROPCLEANBUFFERS;
GO

EXEC sp_executesql 
	N'SELECT charge_no FROM dbo.charge
	WHERE charge_dt = @charge_dt',
	N'@charge_dt datetime',  
	@charge_dt = '1999-07-20 10:49:11.833';
GO

-- What LIOs, PIOs, CPU time do we see?
SELECT	t.text, 
		s.total_logical_reads,
		s.total_physical_reads, 
		s.total_worker_time,
		p.query_plan
FROM sys.dm_exec_query_stats s
CROSS APPLY sys.dm_exec_query_plan (s.plan_handle) p
CROSS APPLY sys.dm_exec_sql_text (s.plan_handle) t
WHERE t.text LIKE '%WHERE charge_dt%';
GO

-- Cleanup
DROP INDEX NCL_charge_charge_dt ON [dbo].[charge];