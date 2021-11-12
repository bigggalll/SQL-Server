/******************  Set AX Client tracing *************/
/* NOTE: Versions prior to AX2012 must enable AX client tracing on the AOS servers  */

--The SQL job DYNPERF_Set_AX_User_Trace_on will run this for you on a schedule so that
-- new users are setup as they are added to the system

USE DynamicsPerf

EXEC SET_AX_SQLTRACE
  @DATABASE_NAME = 'dbname',
  @QUERY_TIME_LIMIT = 5000
  
  --NOTE:  Setting @QUERY_TIME_LIMIT too low could casue performance issues
  
  
  GO

/**************** Disable AX client tracing ****************/

--Can also use the SQL job DYNPERF_Set_AX_User_Trace_off for this task
-- instead of this script

USE DynamicsPerf

EXEC SET_AX_SQLTRACE
  @DATABASE_NAME = 'dbname',
  @TRACE_STATUS = 'OFF' 
