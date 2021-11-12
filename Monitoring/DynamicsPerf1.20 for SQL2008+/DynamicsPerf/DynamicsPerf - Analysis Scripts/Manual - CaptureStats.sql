
-- --------------------------------------------------------------
-- Script to execute SP_CAPTURESTATS
--
-- The run name is output at completion:
--	 RUN NAME = TEST1
-- This date/time is then used to predicate 
-- subsequent queries to QUERY_STATS_CURR_VW or INDEX_STATS_CURR_VW
----------------------------------------------------------------


USE DynamicsPerf
EXEC SP_CAPTURESTATS	@DATABASE_NAME = 'XXXXXXXXXX'
						, @DEBUG = 'Y'
						--, @SKIP_STATS = 'Y'




-- --------------------------------------------------------------
-- Alternatively, run name can also be passed to SP_CAPTURESTATS if desired:
-- Here is an example to create a baseline capture

EXEC SP_CAPTURESTATS	@DATABASE_NAME = 'XXXXXXXXXX',
						@RUN_NAME = 'BASE Before sp1`'
						
									