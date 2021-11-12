/*============================================================================
  File:    6b_Using_WhoIsActive.sql

  Summary:  Generate a lock to see blocking

  SQL Server Versions: 2005 onwards
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
	includes built-in help 
*/
EXEC dbo.sp_WhoIsActive @help=1



/* 
	execute with no input parameters 
*/
EXEC dbo.sp_WhoIsActive 


/* 
	specificy sort order 
*/
EXEC dbo.sp_WhoIsActive 
	@sort_order = '[CPU] DESC'

EXEC dbo.sp_WhoIsActive 
	@sort_order = '[tempdb_current] DESC'



/*	
	can include query plans 
	1 = plan for current statement or last statement if is complete
	2 = plan for the entire running batch
*/
EXEC dbo.sp_WhoIsActive 
	@get_plans = 1


/* 
	walk blocking chain 
*/
EXEC dbo.sp_WhoIsActive 
	@find_block_leaders=1


/* 
	change output order of columns 
*/
EXEC dbo.sp_WhoIsActive 
	@output_column_list = '[dd%],[session_id],[blocking%],[blocked_session_count],
		[wait_info],[%tran%],[login_name],[sql_text]'


/* 
	walk blocking chain and change output order of columns 
*/
EXEC dbo.sp_WhoIsActive 
	@find_block_leaders=1, 
	@output_column_list = '[dd%],[session_id],[blocking%],[blocked_session_count],
		[wait_info],[%tran%],[login_name],[sql_text]'



/* 
	display additional information about transaction log data (and filter out sleeping spids)
	for each database a transaction has touched, include the number and size of transaction log records
	number of transaction log records updated loosely corresponds to the number rows (does not count page splits) 
*/
EXEC dbo.sp_WhoIsActive 
	@get_transaction_info = 1


/* 
	get delta information, where the interval is number of seconds between pulls of data 
*/
EXEC dbo.sp_WhoIsActive 
	@delta_interval = 5



/*
	there is a collection mode built in, the output column list changes depends on which options you use

	there is an output schema option (@return_schema)that will output the schema for a particular set of options, can then run
	that option to create a table, then can run it again and push the data into it
*/

/* this creates the statement for the destination table */
DECLARE @schema varchar(max) 
EXEC dbo.sp_WhoIsActive 
	@return_schema=1, 
	@schema=@schema OUTPUT 
SELECT REPLACE(@schema, '<table_name>', 'dbo.WIA_Output' )


/* execute statement to create table */

USE DMV_Data;
GO

IF EXISTS (SELECT name FROM sys.tables WHERE name = 'WIA_Output')
	DROP TABLE dbo.WIA_Output

CREATE TABLE dbo.WIA_Output ( 
	[dd hh:mm:ss.mss] VARCHAR(15) NULL,
	[session_id] SMALLINT NOT NULL,
	[sql_text] XML NULL,
	[login_name] NVARCHAR(128) NOT NULL,
	[wait_info] NVARCHAR(4000) NULL,
	[CPU] VARCHAR(30) NULL,
	[tempdb_allocations] VARCHAR(30) NULL,
	[tempdb_current] VARCHAR(30) NULL,
	[blocking_session_id] SMALLINT NULL,
	[reads] VARCHAR(30) NULL,
	[writes] VARCHAR(30) NULL,
	[physical_reads] VARCHAR(30) NULL,
	[used_memory] VARCHAR(30) NULL,
	[status] VARCHAR(30) NOT NULL,
	[open_tran_count] VARCHAR(30) NULL,
	[percent_complete] VARCHAR(30) NULL,
	[host_name] NVARCHAR(128) NULL,
	[database_name] NVARCHAR(128) NULL,
	[program_name] NVARCHAR(128) NULL,
	[start_time] DATETIME NOT NULL,
	[request_id] INT NULL,
	[collection_time] DATETIME NOT NULL)

/*	run blocking scripts
	load data 
*/
EXEC dbo.sp_WhoIsActive 
	@destination_table = 'dbo.WIA_Output'


/* view data */
SELECT * FROM dbo.WIA_Output;


/* variation of the above, specifying columns */
USE DMV_Data;
GO

IF EXISTS (SELECT name FROM sys.tables WHERE name = 'WIA_Output_blocking')
	DROP TABLE dbo.WIA_Output

DECLARE @schema VARCHAR(MAX) 
EXEC dbo.sp_WhoIsActive 
	@output_column_list = '[dd%],[session_id],[blocking%],[%tran%],[login_name],[sql_text]',
	@return_schema=1, 
	@schema=@schema OUTPUT
SELECT REPLACE(@schema, '<table_name>', 'dbo.WIA_Output_blocking' )


CREATE TABLE dbo.WIA_Output_blocking ( 
	[dd hh:mm:ss.mss] VARCHAR(15) NULL,
	[session_id] SMALLINT NOT NULL,
	[blocking_session_id] SMALLINT NULL,
	[open_tran_count] VARCHAR(30) NULL,
	[login_name] NVARCHAR(128) NOT NULL,
	[sql_text] XML NULL)
	

EXEC dbo.sp_WhoIsActive 
	@destination_table = 'dbo.WIA_Output_blocking', 
	@output_column_list = '[dd%],[session_id],[blocking%],[%tran%],[login_name],[sql_text]'





