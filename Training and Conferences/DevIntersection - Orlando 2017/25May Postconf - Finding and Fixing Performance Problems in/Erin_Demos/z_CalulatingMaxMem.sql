/*============================================================================
  File:    z_CalulatingMaxMem.sql

  Summary:  Jonathan's method to calculate what to set max memory to

  SQL Server Versions: 2005 onwards
------------------------------------------------------------------------------
  Written by Erin Stellato, SQLskills.com

  (c) 2017, SQLskills.com. All rights reserved.

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  You may alter this code for your own *non-commercial* purposes. You may
  republish altered code as long as you include this copyright and give due
  credit, but you must obtain prior permission before blogging this code.
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

/*
	Jonathan's calculation for max mem:
	1 GB of RAM for the OS, 
	1 GB for each 4 GB of RAM installed from 4–16 GB, 
	1 GB for every 8 GB RAM installed above 16 GB RAM

	**this assumes a single instance on a single server
*/
DECLARE @ServerMem AS INT;
DECLARE @LowRangeMem AS INT;
DECLARE @HighRangeMem AS INT;
DECLARE @MaxMem AS INT;

SET @ServerMem = 32; --set to memory on server

IF @ServerMem > 16
BEGIN
	SET @LowRangeMem = 3
	SET @HighRangeMem = (@ServerMem - 16)/8
	SET @MaxMem = @ServerMem - (1 + @LowRangeMem + @HighRangeMem)
	PRINT (@MaxMem)
END;
ELSE
BEGIN
	PRINT ('calculate manually')
END;