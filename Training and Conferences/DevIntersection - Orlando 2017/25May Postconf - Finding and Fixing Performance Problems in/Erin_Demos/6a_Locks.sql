/*============================================================================
  File:    6a_locks.sql

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

USE [AdventureWorks2016];
GO

BEGIN TRANSACTION;

UPDATE [Production].[Product]
SET Color = 'Blue'
WHERE Name = 'Decal 1'
OR Name LIKE '%Washer%';

ROLLBACK;
/*
	Copy and run in another window
*/
SELECT *
FROM [Production].[Product];

/*
	Use who_is_active to look at blocking chain
*/