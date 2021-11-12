/*============================================================================
  File:     3c_tempdb_Configuration_Contention_setup.sql

  Summary:  This script is used to view tempdb contention
			using the SQL Server DMVs.

  Date:     October 2016

  SQL Server Version: 2005/2008/2008R2/2012/2014
------------------------------------------------------------------------------
  Written by Jonathan Kehayias, SQLskills.com

  For more scripts and other useful content, go to:
	http://www.SQLskills.com

  This script is intended only as a supplement to demos and lectures
  given by Jonathan Kehayias or Erin Stellato.  
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

SELECT 
   session_id,
   wait_type,
   wait_duration_ms,
   blocking_session_id,
   resource_description,
   ResourceType = CASE
   WHEN PageID = 1 OR PageID % 8088 = 0 THEN 'Is PFS Page'
   WHEN PageID = 2 OR PageID % 511232 = 0 THEN 'Is GAM Page'
   WHEN PageID = 3 OR (PageID - 1) % 511232 = 0 THEN 'Is SGAM Page'
       ELSE 'Is Not PFS, GAM, or SGAM page'
   END
FROM (  SELECT  
           session_id,
           wait_type,
           wait_duration_ms,
           blocking_session_id,
           resource_description,
           CAST(RIGHT(resource_description, LEN(resource_description)
           - CHARINDEX(':', resource_description, 3)) AS INT) AS PageID
       FROM sys.dm_os_waiting_tasks
       WHERE wait_type LIKE 'PAGE%LATCH_%'
         AND resource_description LIKE '2:%'
) AS tab;