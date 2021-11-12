/*============================================================================
  File:     Using-DBCC_IND.sql
  
  Resource: SQL Server 2008 Internals
            http://www.microsoft.com/learning/en/us/books/12967.aspx

  Summary:  This script shows examples of how to use the undocumented
            DBCC IND command as described in Chapter 6 of SQL Server 
            2008 Internals.
  
  Date:     April 2009
------------------------------------------------------------------------------
  Written by Kimberly L. Tripp, SQLskills.com

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

------------------------------------------------------------------------------
-- Many examples use the DBCC IND command but change the output in some 
-- way (change the sort or only look at one level - for example). To do this
-- easily, use the sp_TablePages to store the data.
------------------------------------------------------------------------------
USE master;
go

IF OBJECTPROPERTY(object_id('sp_tablepages'), 'IsUserTable') IS NOT NULL
    DROP TABLE sp_tablepages;
go

CREATE TABLE sp_tablepages
(
    PageFID         tinyint,
    PagePID         int,
    IAMFID          tinyint,
    IAMPID          int,
    ObjectID        int,
    IndexID         tinyint,
    PartitionNumber tinyint,
    PartitionID     bigint,
    iam_chain_type  varchar(30),
    PageType        tinyint,
    IndexLevel      tinyint,
    NextPageFID     tinyint,
    NextPagePID     int,
    PrevPageFID     tinyint,
    PrevPagePID     int,
    CONSTRAINT sp_tablepages_PK
        PRIMARY KEY (PageFID, PagePID)
);
go


------------------------------------------------------------------------------
-- How do you use sp_tablepages?
-- Just truncate the table before insert and then select!
------------------------------------------------------------------------------
TRUNCATE TABLE sp_tablepages;
INSERT INTO sp_tablepages
EXEC ('DBCC IND (AdventureWorks2008, [Sales.SalesOrderDetail], -1)');
go

-- More examples in later scripts!
SELECT * 
FROM sp_tablepages
ORDER BY IndexLevel DESC;
go