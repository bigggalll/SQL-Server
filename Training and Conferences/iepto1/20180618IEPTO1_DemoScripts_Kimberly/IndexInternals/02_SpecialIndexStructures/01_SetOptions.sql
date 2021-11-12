/*============================================================================
  File:     SetOptions.sql
  
  Resource: SQL Server 2008 Internals
            http://www.microsoft.com/learning/en/us/books/12967.aspx

  Summary:  This script shows examples of how to use the DMV
            sys.dm_exec_sessions as described in 
            Chapter 6 of SQL Server 2008 Internals.
            
            This can be used to see if a client has the appropriate
            session settings to leverage indexes on computed columns
            or indexed views. 
  
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

-- To see a specific session property, use the SESSIONPROPERTY function:
SELECT SESSIONPROPERTY ('NUMERIC_ROUNDABORT');
go

-- To see the session settings that are currently on:
DBCC USEROPTIONS;
go

-- To see the "Set Options that Affect Results" for the current spid:
SELECT quoted_identifier
    , arithabort
    , ansi_warnings
    , ansi_padding
    , ansi_nulls
    , concat_null_yields_null
    --, numeric_roundabort -- Not supported - unfortunately.
FROM sys.dm_exec_sessions
WHERE session_id = @@spid;
go

-- To see the "Set Options that Affect Results" for the current spid:
SELECT session_id
    , quoted_identifier
    , arithabort
    , ansi_warnings
    , ansi_padding
    , ansi_nulls
    , concat_null_yields_null
FROM sys.dm_exec_sessions
go

-- Review ALL session settings for all sessions:
SELECT *
FROM sys.dm_exec_sessions
go
