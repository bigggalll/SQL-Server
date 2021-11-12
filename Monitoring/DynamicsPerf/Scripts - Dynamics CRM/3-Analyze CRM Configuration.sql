
/*********************************************************************
Copy one of the following links and press Ctrl-F and click FIND NEXT
in order to go to that section of the scripts

CRM_ORG
CRM_PLUGINS
CRM_POA


********************************************************************/


USE [DynamicsPerf]


--CRM ORGANIZATION INFORMATION
--
--				CRM_ORG
		-- --------------------------------------------------------------
		-- Is the organization setup correctly ?
		-----------------------------------------------------------------
		
SELECT *
FROM   CRM_ORGANIZATION 
--WHERE SERVER_NAME = 'XXXXXXXXX' AND DATABASE_NAME = 'XXXXXXXXXXXXX'



--CRM PLUGINS INFORMATION
--
--				CRM_PLUGINS
		-- --------------------------------------------------------------
		-- What plugins are installed ?
		-----------------------------------------------------------------
		
SELECT *
FROM   CRM_PLUGINS 
--WHERE SERVER_NAME = 'XXXXXXXXX' AND DATABASE_NAME = 'XXXXXXXXXXXXX'



--CRM PRINCIPAL OBJECT ACCESS INFORMATION
--
--				CRM_POA
		-- --------------------------------------------------------------
		-- What ojbects are being accessed how often ?
		-----------------------------------------------------------------
		
		
SELECT *
FROM   CRM_POA_TOTALS 
--WHERE SERVER_NAME = 'XXXXXXXXX' AND DATABASE_NAME = 'XXXXXXXXXXXXX'
