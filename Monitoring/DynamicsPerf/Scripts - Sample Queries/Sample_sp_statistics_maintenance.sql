/************************************************************************************
sp_statistics_maintenance -	This script is essentially just runs 
							sp_updatestats which uses the 
							sys.sysindexes.rowmodctr to determine whether
							a statistics needs to be updated or not.  If 
							data in the statistic has changed then the statistic
							gets updated, and if no data has changed it does not 
							get updated.  This is far more precise and less 
							time consuming than just updating all statistics 
							in a database blindly.
							
							This script just adds code to set MAXDOP to 0 so the
							UPDATE STATITICS operation can make full use of all
							CPUs available to SQL Server, and also because that we
							recommend setting MAXDOP to 1 for all Dynamics
							applications which is best option for OLTP operations
							by not database maintenance operations.  When
							the script is complete it sets MAXDOP back to the
							original value configuration value.
															 
				
Witten By:					Michael De Voe 
							Sr. Premier Field Engineer
							
			
Date:						Jan. 13th, 2014

Version:					1.2

This script is presented "AS IS" and has no warranties expressed or implied!!!
**********************************************************************************/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_statistics_maintenance]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[sp_statistics_maintenance]
GO

Create Procedure SP_STATISTICS_MAINTENANCE

as

DECLARE @MAXDOP INT

CREATE TABLE #Config(
name VARCHAR(250),
minimum INT,
maximum INT,
config_value INT,
run_value INT
)

INSERT #Config
(name,minimum,maximum,config_value,run_value)

EXEC SP_CONFIGURE

SET @MAXDOP = (SELECT config_value FROM #Config WHERE name = 'max degree of parallelism')

EXEC SP_CONFIGURE 'max degree of parallelism', 0
RECONFIGURE WITH OVERRIDE

EXEC SP_UPDATESTATS

EXEC SP_CONFIGURE 'max degree of parallelism', @MAXDOP
RECONFIGURE WITH OVERRIDE

DROP TABLE #Config

GO





















