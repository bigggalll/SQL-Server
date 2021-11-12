/*================================================================
  File:     Compile Happy Discovery.sql

  SQL Server Versions tested: SQL Server 2012 11.0.3321
------------------------------------------------------------
  Written by Joseph I. Sack, SQLskills.com

  (c) 2012, SQLskills.com. All rights reserved.

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  You may alter this code for your own *non-commercial* purposes. You may
  republish altered code as long as you include this copyright and give due
  credit, but you must obtain prior permission before blogging this code.
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
=================================================================*/

-- 1) Open Profiler and watch SQLStatement:Recompile
-- 1) Open Perfmon and watch compilations/recompilations        
-- 2) Launch workload

-- Deferred compile - object didn't exist at compile time                                                                                           