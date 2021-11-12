/*============================================================================
  File:     DoNotTurnOffAutoUpdateStatistics.sql

  Summary:  Strange behavior when you UPDATE STATISTICS when
            the database-level option AUTO UPDATE STATISTICS
            is OFF.
            
            For more information, check out Erin's blog:
            http://erinstellato.com/2012/02/statistics-recompilations-part-ii/ 

  Date:     March 2012

  SQL Server Version: SQL Server 2008 R2
------------------------------------------------------------------------------
  Written by Kimberly L. Tripp & Paul S. Randal, SQLskills.com

  For more scripts and sample code, check out http://www.SQLskills.com

  This script is intended as a supplement to the SQL Server 2008 Jumpstart or
  Metro training.
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

USE credit
go

CREATE INDEX test 
ON dbo.member(lastname)
go

UPDATE dbo.member
    SET lastname = 'Tripp'
    WHERE member_no = 1234
go

CREATE PROCEDURE testrecompile
(@lastname  varchar(15))
AS
SELECT m.* 
FROM dbo.member AS m
WHERE m.lastname = @lastname
go

EXEC testrecompile 'Tripp'
-- plan uses the index

EXEC testrecompile 'Anderson'
-- plan uses the index

UPDATE STATISTICS member
go

EXEC testrecompile 'Anderson'
-- plan uses a table scan because the update statistics invalidated the plan

ALTER DATABASE Credit
SET AUTO_UPDATE_STATISTICS OFF
go

EXEC testrecompile 'Tripp'
-- uses an index because turning the option off forced invalidation

EXEC testrecompile 'Anderson'
-- uses the index... 

update statistics member
go

EXEC testrecompile 'Anderson'
-- STILL uses the index... this did NOT get updated!!!

-- As an easy fix:
sp_recompile member
go

EXEC testrecompile 'Anderson'
-- now, the plan does a table scan....