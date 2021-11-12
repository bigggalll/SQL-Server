USE DynamicsPerf

GO


/*************** Display Defined Traces *********************/


SELECT status,
       path,
       max_size,
       buffer_count,
       buffer_size,
       event_count,
       dropped_event_count
FROM   sys.traces


/**********************  Start the Trace *********************/
DBCC traceon(1222,-1)

GO
EXEC SP_SQLTRACE @FILE_PATH = 'C:\SQLTRACE', -- Location to write trace files.  Note: directory must exist before start of trace
	@TRACE_NAME = 'DYNAMICS_DEFAULT', -- Trace name - becomes base of trace file name
	@DATABASE_NAME = NULL,			 -- Name of database to trace; default (NULL) will trace all databases
	@TRACE_FILE_SIZE = 10,			-- Maximum trace file size - will rollover when reached
	@TRACE_FILE_COUNT = 100,		-- Maximum numer of trace files  - will delete oldest when reached
	@TRACE_STOP = 'N',				-- When set to 'Y' will stop the trace and exit
	@TRACE_RUN_HOURS = 25			-- Number of hours to run trace

	
	
/****************  Stop the Trace ****************************/


EXEC SP_SQLTRACE @TRACE_NAME = 'DYNAMICS_DEFAULT', -- Trace name - becomes base of trace file name
	@TRACE_STOP = 'Y' -- When set to 'Y' will stop the trace and exit
	
	
/***************  Read the trace  ***************************/


SELECT E.name, F.*
      FROM fn_trace_gettable('C:\SQLTRACE\DYNAMICS_DEFAULT.trc', DEFAULT) F,
      sys.trace_events E
      WHERE EventClass = trace_event_id
