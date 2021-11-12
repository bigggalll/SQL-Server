/**************************************************************************

This step is only necessary if you intend to collect data remotely for
your production server.  For example, installing DynamicsPerf on UAT/STAGE
and collect data from production. 
***************************************************************************/


/************************************************************************
MUST ENABLE DTC DISTRIBUTED TRANSACTION COORDINATOR  on the server
hosting DynamicsPerf database to do remote collections
*************************************************************************/


/*****************************************************************************
*  NOTE: The account used for the Linked Server must have rights 
*   to local server hosting DynamicsPerf
*	and the remote SQL Server hosting the Dynamics database
******************************************************************************/


USE [DynamicsPerf]
GO



-- Setup a Linked Server for each remote database you want to collect data from 

--The following are the TSQL scripts to setup a Linked Server. You can use
-- SSMS to setup the linked server as well.

-- Step 1 Create the Linked Server

EXEC sp_addlinkedserver
@server='LstnAX01Q', -- — here you can specify the name of the linked server
@srvproduct='',     
@provider='sqlncli', -- — using SQL Server native client
@datasrc='LSTNAX01Q.groupe.jeancoutu-qa.com.database.windows.net', --  — add your server name here
@location='',
@provstr='',
@catalog='AX2012R3'  -- add here your database name as initial catalog (you cannot connect to the master database)

GO


-- Step 2 Add credentials and options to this linked server

/*****************************************************************************
*  NOTE: This account must have rights to local server hosting DynamicsPerf
*	and the remote SQL Server hosting the Dynamics database
******************************************************************************/

EXEC sp_addlinkedsrvlogin
@rmtsrvname = 'LstnAX01Q',
@useself = 'true'		-- <<<<< Set to false and add login on next 2 lines for SQL login
--,@rmtuser = 'your_admin_user'             -- add here your login on Azure DB or Local Server
--,@rmtpassword = 'your_password' -- add here your password for Azure DB or Local Server


GO


--Step 3  Enable the correct options for the Linked Server

EXEC sp_serveroption @server = 'LstnAX01Q'
	,@optname = 'remote proc transaction promotion'
	,@optvalue = 'false' ;
	
GO

EXEC sp_serveroption 'LstnAX01Q'
	,'rpc out', true;
	
GO

EXEC sp_serveroption 'LstnAX01Q'
	,'collation compatible', false

GO

EXEC sp_serveroption 'LstnAX01Q'
	,'lazy schema validation', false



