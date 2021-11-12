1. Install SQL Server 2014 and 2016. Do not perform any configuration on tempdb. For this demo you need a machine with >= 8 logical CPUs
2. Run this script against 2016: tempddl.sql
3. Run this script against 2014: tempddl_2014.sql
4. Monitor these counters with perfmon (for both instances)

SQL Server:SQL Statistics\Batch Requests/sec
SQL Server:Access Methods\Pages Allocated/sec

Have two perfmon instances side by side for each instance

5. Run the following script to kick off temp stress against both instances.

QUESTION: Why is the stress test using 8 as a value for the stored procedure?
