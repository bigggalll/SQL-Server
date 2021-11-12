/********************************************************************************************
sp_index_maintenance:	This Stored Procedure pulls the index fragementation
For Enterprise Edition  percentage for each index from the sys.dm_db_index_physical_stats
						Database Management View.  It then compares that to the fragementation
						threshold specified by the users (defaults to 50%) and REBUILDS all
						indexes that greater than or equal to that value and RORGANIZES all 
						indexes that are less than that value.  This cuts down on the overhead
						and runtime of the maintenance job as we are only REBUILDING the indxes
						that really need it and use the less intensive REORGANIZE on the rest
						and completely skips indexes that are fragmented 10% or less. 
						 

Witten By:				Michael De Voe 
						Sr. Premier Field Engineer
						Microsoft Dynamics AX
						Microsoft Certified Master - SQL Server 2008
			
Date:					Feb. 4th, 2014 

Recommendation:			We recommend you create an SQL Job that runs this Stored
						Procedure weekly against the Dynamics AX production 
						database.

This script is presented "AS IS" and has no warranties expressed or implied!!!
*********************************************************************************************/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_index_maintenance]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[sp_index_maintenance]
GO

CREATE PROCEDURE SP_INDEX_MAINTENANCE_ENTERPRISE

AS

DECLARE @RowThreshold INT
DECLARE @PercentThreshold DECIMAL(38,10)

/***********************************************************************************************************************************
*************SET PARAMETERS*********************************************************************************************************/

SET @RowThreshold		= 1000	--Threshold for the number of rows.  In the number of rows in the index is less that the threshold 
								--then it will skip it completely.
SET @PercentThreshold	= 50	--FOR THIS SCRIPT 50 = 50%
								--Fragmentation threshold percentage.  If greater than or equal to this amount them REBUILD the Index
								--If less than this amount REORGANIZE the index
						
/************SET PARAMETERS*********************************************************************************************************
************************************************************************************************************************************/

SET NOCOUNT ON

--INDEXES THAT CAN BE REBUILT ONLINE

DECLARE @tablename SYSNAME;
DECLARE @index_name SYSNAME;
DECLARE @percentfrag DECIMAL(38,10);
DECLARE @command VARCHAR(8000);
DECLARE @command2 VARCHAR(8000);
DECLARE Index_Maint CURSOR FOR


SELECT
o.name,
i.name,
f.avg_fragmentation_in_percent
FROM SYS.DM_DB_INDEX_PHYSICAL_STATS (DB_ID(), NULL, NULL , NULL, 'LIMITED') f
JOIN sys.objects o on o.object_id = f.object_id
JOIN sys.indexes i on i.object_id = f.object_id and i.index_id = f.index_depth 
WHERE f.index_id > 0
AND NOT EXISTS (							--eliminate indexes that can not be rebuilt ONLINE
  SELECT 1 FROM sys.index_columns AS ic
  INNER JOIN sys.columns AS c
  ON ic.object_id = c.object_id
  AND ic.column_id = c.column_id
  AND ((c.system_type_id IN (34,35,99,241)) -- image, text, ntext, xml
   OR (c.system_type_id IN (167,231,165) -- varchar, nvarchar, varbinary
       AND max_length = -1))
  WHERE ic.object_id = I.object_id
  AND ic.index_id = I.index_id
)

OPEN Index_Maint

FETCH NEXT FROM Index_Maint INTO 
	  @tablename, @index_name, @percentfrag

While @@FETCH_STATUS = 0
BEGIN

	IF @percentfrag >= @PercentThreshold
		BEGIN
			SELECT @command2 = 'ALTER INDEX ' + '[' + @index_name + ']' + ' ON ' + '[' + @tablename + ']' + ' REBUILD WITH(MAXDOP=0, ONLINE=ON)'; --Take advantage of parallelism and ONLINE INDEX REBUILDS
			EXEC (@command2);
			PRINT 'Executed ' + @command2;
		END; 
	ELSE
		BEGIN
			SELECT @command = 'ALTER INDEX ' + '[' + @index_name + ']' + ' ON ' + '[' + @tablename + ']' + ' REORGANIZE';
			EXEC (@command);	
			PRINT 'Executed ' + @command;
		END;			
						
FETCH NEXT FROM Index_Maint INTO 
	  @tablename, @index_name, @percentfrag
END 

CLOSE Index_Maint
DEALLOCATE Index_Maint


--INDEXES THAT CANNOT BE REBUILT ONLINE

DECLARE @tablename2 SYSNAME;
DECLARE @index_name2 SYSNAME;
DECLARE @percentfrag2 DECIMAL(38,10);
DECLARE @command3 VARCHAR(8000);
DECLARE @command2b VARCHAR(8000);
DECLARE Index_Maint2 CURSOR FOR


SELECT
o.name,
i.name,
f.avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL , NULL, 'LIMITED') f
JOIN sys.objects o on o.object_id = f.object_id
JOIN sys.indexes i on i.object_id = f.object_id and i.index_id = f.index_depth 
WHERE f.index_id > 0
AND EXISTS (							--Select only indexes that CANNOT be rebuilt ONLINE
  SELECT 1 FROM sys.index_columns AS ic
  INNER JOIN sys.columns AS c
  ON ic.object_id = c.object_id
  AND ic.column_id = c.column_id
  AND ((c.system_type_id IN (34,35,99,241)) -- image, text, ntext, xml
   OR (c.system_type_id IN (167,231,165) -- varchar, nvarchar, varbinary
       AND max_length = -1))
  WHERE ic.object_id = I.object_id
  AND ic.index_id = I.index_id
)

OPEN Index_Maint2

FETCH NEXT FROM Index_Maint2 INTO 
	  @tablename2, @index_name2, @percentfrag2

While @@FETCH_STATUS = 0
BEGIN

	IF @percentfrag2 >= @PercentThreshold
		BEGIN
			SELECT @command2b = 'ALTER INDEX ' + '[' + @index_name2 + ']' + ' ON ' + '[' + @tablename2 + ']' + ' REBUILD WITH(MAXDOP=0)'; --Take advantage of parallelism and ONLINE INDEX REBUILDS
			EXEC (@command2b);
			--PRINT 'Executed ' + @command2b;
		END; 
	ELSE
		BEGIN
			SELECT @command3 = 'ALTER INDEX ' + '[' + @index_name2 + ']' + ' ON ' + '[' + @tablename2 + ']' + ' REORGANIZE';
			EXEC (@command3);	
			--PRINT 'Executed ' + @command3;
		END;			
						
FETCH NEXT FROM Index_Maint2 INTO 
	  @tablename2, @index_name2, @percentfrag2
END 

CLOSE Index_Maint2
DEALLOCATE Index_Maint2



GO



