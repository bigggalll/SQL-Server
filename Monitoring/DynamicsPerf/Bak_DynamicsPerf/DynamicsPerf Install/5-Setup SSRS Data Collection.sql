/*****************************************************************************************
*
*		BE SURE TO SETUP A LINKED SERVER FOR EACH SSRS SERVER YOU WILL BE MONITORING 
*
*****************************************************************************************/




USE [DynamicsPerf]

GO

INSERT INTO [dbo].[SSRS_CONFIG]
            ([SERVER_NAME],
             [LAST_COLLECTED],
             [DATABASE_NAME])
VALUES      ('SSRS_SERVER_NAME_HERE',
             '1/1/1900',
             'ReportServer') 


/********  Cleanup ****************

DELETE FROM SSRS_CONFIG 
WHERE SERVER_NAME = 'SSRS_SERVER_NAME_HERE'


**********************************/