
-- --------------------------------------------------------------
-- Script to execute SP_CAPTURESTATS
--
-----------------------------------------------------------------


USE DynamicsPerf

EXEC SP_CAPTURESTATS
		@SERVER_NAME = 'MY_SERVER',
		  @DATABASE_NAME = 'MY_DATABASE',
		  @DYNAMICS_PRODUCT = 'AX',
		  @AZURE_DB = 0,
		  @TASK_TYPE = 'COLLECT',
		  @DEBUG = 'Y' 




USE DynamicsPerf

EXEC SP_CAPTURESTATS
		--@SERVER_NAME = 'MYSERVER\INSTANCE',
		  @DATABASE_NAME = 'MY_DATABASE',
		  @DYNAMICS_PRODUCT = 'AX',
		  @TASK_TYPE = 'COLLECT',
		  @AZURE_DB = 0,
		  @DEBUG = 'Y' 

		
	

									