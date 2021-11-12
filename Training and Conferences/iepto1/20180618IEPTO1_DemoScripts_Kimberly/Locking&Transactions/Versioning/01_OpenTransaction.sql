/*============================================================================
  File:     Open Transaction
  
  Summary:  This open transaction will require the version generated
            by the subsequent update to remain until it (this transaction)
            completes.

            This script is used DURING the Understanding Versions
            demo / script.
            
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

USE [ViewVersions];
GO

SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
GO

BEGIN TRAN
SELECT * FROM [dbo].[tbl_ViewVersions]





SELECT * FROM [dbo].[tbl_ViewVersions]
-- ROLLBACK TRAN