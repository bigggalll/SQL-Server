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
             [DATABASE_NAME],
             [LAST_PROCESSED],
             [RETAIN_HISTORY_MONTHS],
             [RETAIN_HISTORY_DAYS],
             [RETAIN_DETAILS_DAYS]             
             )
VALUES      ('SSRS_SERVER_NAME_HERE',
             '1/1/1900',  -- LAST COLLECTED
             'ReportServer',
             GETDATE(),  -- LAST PROCESSED INTO HISTORY
             24,	--Number of History month records (2 yrs)
			 60,	--Number of History DAY records (2 months)
			 7      --Number of Detailed day records (7 days)
             ) 


/********  Cleanup ****************

DELETE FROM SSRS_CONFIG 
WHERE SERVER_NAME = 'SSRS_SERVER_NAME_HERE'


**********************************/

SELECT * FROM SSRS_CONFIG	

