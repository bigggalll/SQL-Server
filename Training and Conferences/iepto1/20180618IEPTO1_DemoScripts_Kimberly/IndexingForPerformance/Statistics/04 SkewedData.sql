/*============================================================================
  File:     AnalyzingDataForSkew.sql

  Summary:  What kind of data might be prone to poor estimations?
				Can we easily search for tables/columns
				that are heavily skewed.
  
  SQL Server Version: SQL Server 2008+
------------------------------------------------------------------------------
  Written by Kimberly L. Tripp, SQLskills.com

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  This script is intended only as a supplement to demos and lectures
  given by Kimberly L. Tripp.  
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

---------------------------------------------
-- Setup (for just analysis)
---------------------------------------------

-- Be sure to execute the scripts for
--	* sp_SQLskills_AnalyzeColumnSkew.sql

-- These two scripts are very complimentary
-- I'll show uses of these later in this demo
--  * sp_SQLskills_AnalyzeAllLeadingIndexColumnSkew.sql
--  * sp_SQLskills_HistogramTempTables.sql


---------------------------------------------
-- You already suspect a particular column 
-- might have skewed data
---------------------------------------------

-- Here's the dropbox link to the backup of this database
https://www.dropbox.com/sh/wbvcjsdnbj7hcw6/AAB6LRvEyghxn9qZv0zDI0gPa?dl=0

USE [AdventureWorksDW2008_ModifiedSalesKey];
GO

-- Try just the defaults
EXEC [sp_SQLskills_AnalyzeColumnSkew]
		  @schemaname		= N'dbo'
		, @objectname		= N'LinkSaleLineContext'
		, @columnname		= N'Item_HK'
-- These are the defaults for the remainder of parameters
		, @difference		= 1000
		, @factor			= 1.5
		, @numofsteps		= 10
		, @percentofsteps	= 10 
		, @keeptable		= 'FALSE'
				
-- You only need to supply a parameter for @tablename if you
-- want to programmatically use this in some other code
		, @tablename		= NULL OUTPUT		
					
/************************************************************
-- Procedure:[sp_SQLskills_AnalyzeColumnSkew]

-- PARAMETER NOTES:-- PARAMETER NOTES:
--
--  @difference		This defines the minimum difference between
--					the average for the range and the min/max
--					of that step. If the average for a step is
--					2956 sales (for example in sales per customer)
--					then there must be at least one row with 
--                     1956 or less
--			        OR
--					   3956 or more
--                  
--                  The larger the table - the more skew you might 
--                  want to test for. 

--	@factor			This is similar to difference and can be 
--                  supplied with @difference or without.
--					This defines the minimum MULTIPLE between
--					the average for the range and the min/max
--					of that step. If the average for a step is
--					3000 sales (for example in sales per customer)
--					then there must be at least one row with 
--                     2000 or less
--			        OR
--					   4500 or more
--                  
--					In terms of output - a column will have a
--                  factor of 4 is the average is 1000 and the 
--                  biggest difference is 4000 (meaning the 
--					actual value is 5000 even though the avg is
--                  only 1000). The value is off by a multiple
--                  of 4 times the average.
--
--                  The larger the table - the more skew you might 
--                  want to test for. 

--  @numofsteps		This defines the minimum number of steps
--					that have to show skew before this table
--					will output that the code sees it.
--					
--					NOTE: It doesn't take a lot. And, when you're
--					first learning, you might want to set this
--					low just to see if there are any ranges with 
--					skew. But, you might not do anything about
--					it yet.

--	@percentofsteps	Not every histogram has 200 steps. So, 10%
--                  does not necessarily equal 20 steps.
--					This is a more flexible way of analyzing
--					that there's skew without relying on a hard-
--					coded number of steps. You can use this
--					with or without @numofsteps
--					
--	@keeptable		This procedure keeps only the worktables
--					that resulted in TRUE to ALL of the 
--					requirements specified above.
************************************************************/

---------------------------------------------
-- Check for large differences
---------------------------------------------

EXEC [sp_SQLskills_AnalyzeColumnSkew]
		  @schemaname		= N'dbo'
		, @objectname		= N'factinternetsales'
		, @columnname		= N'customerkey'
		, @difference		= 20000
		, @factor			= NULL
		, @numofsteps		= 1
		, @percentofsteps	= NULL;
GO

---------------------------------------------
-- Check for differences that are off by more 
-- than 6x
---------------------------------------------

EXEC [sp_SQLskills_AnalyzeColumnSkew]
		  @schemaname		= N'dbo'
		, @objectname		= N'factinternetsales'
		, @columnname		= N'customerkey'
		, @difference		= NULL
		, @factor			= 6
		, @numofsteps		= NULL
		, @percentofsteps	= 1;
GO


---------------------------------------------
-- Check for differences that are off by more 
-- than 10x
---------------------------------------------

EXEC [sp_SQLskills_AnalyzeColumnSkew]
		  @schemaname		= N'dbo'
		, @objectname		= N'factinternetsales'
		, @columnname		= N'customerkey'
		, @difference		= NULL
		, @factor			= 10
		, @numofsteps		= NULL
		, @percentofsteps	= 1
		, @keeptable		= 'TRUE';
GO

-- Take the worktable name out of the results:
SELECT * 
FROM [tempdb]..[SQLskills_HistogramAnalysisOf_AdventureWorksDW2008_ModifiedSalesKe_dbo_factinternetsales_customerkey];
GO


---------------------------------------------
-- Is this too slow? ;-)
---------------------------------------------

-- What we're trying to do here is get better
-- use out of our already existing indexes
-- AND understand if our histograms have
-- inefficiencies.

EXEC [sp_SQLskills_AnalyzeAllLeadingIndexColumnSkew]
		  @schemaname		= N'dbo'
		, @objectname		= N'factinternetsales'
		-- ALL COLUMNS	
		, @difference		= 10000
		, @factor			= NULL
		, @numofsteps		= 1
		, @percentofsteps	= NULL;
GO
-- Two of the columns show skew at these numbers

SELECT *
FROM [tempdb]..[SQLskills_HistogramAnalysisOf_AdventureWorksDW2008_ModifiedSalesKe_dbo_FactInternetSales_OrderDateKey];
GO

EXEC [sp_SQLskills_AnalyzeAllLeadingIndexColumnSkew]
		  @schemaname		= N'dbo'
		, @objectname		= N'factinternetsales'
		-- ALL COLUMNS	
		, @difference		= 5000
		, @factor			= NULL
		, @numofsteps		= 1
		, @percentofsteps	= NULL;
GO
-- Four of them at this level
-- Reminder - this also means that there are 4 worktables 
-- remaining in tempdb

---------------------------------------------
-- Yes, even that was too slow for me
-- Once I had this working - I wanted to REALLY
-- see if it worked...

-- What about the entire database?
-- OK, not the ENTIRE database... but...
-- All of the leading index columns
---------------------------------------------

EXEC [sp_SQLskills_AnalyzeAllLeadingIndexColumnSkew]
		  @schemaname		= NULL
		, @objectname		= NULL
		-- ALL COLUMNS	
		, @difference		= 2000
		, @factor			= NULL
		, @numofsteps		= 1
		, @percentofsteps	= NULL;
GO
-- Eight tables as this level

---------------------------------------------
-- All leading index columns of all tables
-- in the entire database
---------------------------------------------

-- Or, even just :
EXEC [sp_SQLskills_AnalyzeAllLeadingIndexColumnSkew]

		-- Reminder: These are the defaults
		--, @difference		= 1000
		--, @factor			= 1.5
		--, @numofsteps		= 10
		--, @percentofsteps	= 10 

-- Take some time to review the worktables
-- Each worktable is listed with the outout
-- for that table/column combination

---------------------------------------------
-- What about "worktable" management in tempdb? 
---------------------------------------------

EXEC [sp_SQLskills_HistogramTempTables]
		@management = 'QUERY' -- this is the default

-- Or, finally, when you're all done

EXEC [sp_SQLskills_HistogramTempTables]
		@management = 'DROP' -- this is the default


---------------------------------------------
-- And, just for Aaron Bertrand

-- If doing this table by table is too slow...
-- And, doing this db by db is too slow...

-- How about ALL databases on the entire server?
---------------------------------------------

EXEC sp_MSforeachdb 'USE [?]; EXEC [sp_SQLskills_AnalyzeAllLeadingIndexColumnSkew]';
GO
-- NNNNNNNOOOOOOOOOO!
-- No, just kidding Aaron ;-)
-- Check out Aaron's post: http://sqlblog.com/blogs/aaron_bertrand/archive/2010/12/29/a-more-reliable-and-more-flexible-sp-msforeachdb.aspx
-- And, of course, his better/more reliable sp_foreachdb (link to his code/download in the article above)
-- 

EXEC sp_foreachdb
       @command = N'USE ?; EXEC [sp_SQLskills_AnalyzeAllLeadingIndexColumnSkew]',
       @user_only = 1

-- On my machine (which, yes, is pretty fast and 
-- no, I don't have A LOT of data) this takes
-- under 1 minute

-- Final notes - play around with this IN DEVELOPMENT/TEST (er, duh)
-- Start table by table - it's pretty safe and efficient. 
-- The WORST that will happen is that the ENTIRE index 
-- that you're reading (for a particular table/column) 
-- will need to be put into cache. Not the TABLE (this 
-- requires an index that has the column you're analyzing 
-- as the leading column).