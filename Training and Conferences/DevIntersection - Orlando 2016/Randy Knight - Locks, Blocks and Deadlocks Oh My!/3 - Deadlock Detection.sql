
--turn on trace flag 1222
DBCC TRACESTATUS;
DBCC TRACEON(3065, -1);
DBCC TRACESTATUS;


--start profiler trace


