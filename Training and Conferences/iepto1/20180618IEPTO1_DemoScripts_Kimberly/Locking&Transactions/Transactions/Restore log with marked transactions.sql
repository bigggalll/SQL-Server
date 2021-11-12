-----------------------IMPORTANT ----------------------------------

-- This is just a sample script. It's OLD/against pubs... and you'll 
-- need to update your directory structures/paths.

-----------------------IMPORTANT ----------------------------------


/*============================================================================
  File:     Restore Log with Marked Transactions.sql

  Summary:  Creating user defined transactions with transaction markers.
  
  Date:     June 2006

  SQL Server Version:SQL Server 2000/2005/2008
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

--IMPORTANT: This script requires the pubs database. Yes, it's an old
-- script. But, the example/sample is the same. If you don't have pubs you can
-- easily download from here: http://www.microsoft.com/downloads/details.aspx?FamilyID=06616212-0356-46A0-8DA2-EEBC53A68034&displaylang=en)

--This script will create another copy of the Pubs database named
--PubsTest. PubsTest will be created in the default location of SQL
--SQL Server on drive c:\. BEFORE you execute this script, be sure to
--Change the directory. Also, do not execute this script in on run, 
--work your way through it - analyzing the different choices/commands.
--
--Once created this script will modify records in the PubsTest database
--the first and the third are UNMARKED transactions: transactions
--without a name. The second transaction has been named TitlesUpdate
--and includes a transaction which updates the totals for sales from
--the sales table.
--
--Towards the end of the file you can see the RESTORE LOG command
--syntax to use this MARK for recovery...choosing to either STOP BEFORE
--the mark or stop at and INCLUDE the marked transaction.
--Copy the STOPAT... line and move it to the RESTORE log syntax to
--test out and play with this script!
--
--Have fun,
--kt

USE pubs
go

BACKUP DATABASE [pubs] 
	TO DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\BACKUP\pubsbackup.dat' WITH INIT
go

RESTORE DATABASE [PubsTest] 
	FROM  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\BACKUP\pubsbackup.dat' 
	WITH  FILE = 1,  NOUNLOAD ,  STATS = 10,  RECOVERY ,  
MOVE N'pubs_log' TO N'C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\DATA\PubsTestLog.ldf',  
MOVE N'pubs' TO N'C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\data\PubsTest.mdf'
go

ALTER DATABASE [PubsTest] 
	SET RECOVERY FULL
go

USE [PubsTest] 
go

-- Create a new backup to use as a starting point for recovery
BACKUP DATABASE [PubsTest] TO DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\BACKUP\pubsbackup.dat'
	WITH INIT
go

-- Modify some data without a mark
UPDATE authors
	SET au_fname = 'Kimberly'
	WHERE au_id = '267-41-2394'
go

-- Modify some data with a mark
BEGIN TRANSACTION TitlesUpdate
	WITH MARK 'Aggregation for the sales totals'
UPDATE t
	SET ytd_sales = (SELECT ISNULL(sum(qty), 0) 
	                FROM sales AS S
				    WHERE s.title_id = t.title_id)
FROM titles AS t
COMMIT TRAN
go

-- Modify some data without a mark
UPDATE authors
	SET au_lname = 'Tripp'
	WHERE au_id = '267-41-2394'
go

-- Backup the transaction log and append to the backup location
BACKUP LOG [PubsTest] TO DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\BACKUP\pubsbackup.dat'
	WITH NOINIT
go

-- Now restore to another PubsTest location and test the options
-- for restoring with a mark...
RESTORE DATABASE [PubsTest2] 
	FROM  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\BACKUP\pubsbackup.dat' 
	WITH  FILE = 1,  NOUNLOAD ,  STATS = 10,  
		NORECOVERY,  REPLACE,
MOVE N'pubs_log' TO N'C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\DATA\PubsTest2Log.ldf',  
MOVE N'pubs' TO N'C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\data\PubsTest2Data.mdf'
go

RESTORE LOG [PubsTest2] 
	FROM  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\BACKUP\pubsbackup.dat' 
	WITH  FILE = 2,  NOUNLOAD ,  STATS = 10,  RECOVERY   
	-- COPY THE SYNTAX TO TEST HERE!!!
/*
Use one of the following two options to see the intermediate
	STOPBEFOREMARK Will produce Kimberly O'Leary 
	(not Tripp) and the totals for titles WILL *NOT* be up to date

		, STOPBEFOREMARK = 'TitlesUpdate'  

	STOPATMARK Will produce Kimberly O'Leary (not Tripp)
	And the totals for titles *WILL* be up to date

		, STOPATMARK = 'TitlesUpdate'  

	STOPAT allows a time

		, STOPAT = 'date/time stamp that's valid for this log'  

	IF NEITHER Option is supplied the log will completely restore
	and you will have all three modifications:
		Kimberly Tripp
		and the Titles aggregates!
*/
go

USE PubsTest2
go

SELECT * FROM authors
SELECT title_id, ytd_sales FROM titles
	-- NOTE: MC3026 and PC9999
	-- Values are hard to verify here but MC3026 and PC9999
	-- have no sales...the pubs database originally shows them
	-- as NULL. The query to update them will change them
	-- to 0.....
go