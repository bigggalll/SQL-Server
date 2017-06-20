--Provides transaction log space usage statistics for all databases. In SQL Server it can also be used to reset wait and latch statistics.


--Column name         Definition
--Database            Name Name of the database for the log statistics displayed. 
--Log Size (MB)       Current size allocated to the log. This value is always smaller than the amount originally allocated for log space because the Database Engine reserves a small amount of disk space for internal header information. 
--Log Space Used (%)  Percentage of the log file currently in use to store transaction log information. 
--Status              Status of the log file. Always 0. 
DBCC SQLPERF (logspace)

