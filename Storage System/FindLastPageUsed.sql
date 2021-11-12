--DBCC SHRINKFILE(AX2012R3_00, 10600000)
--DBCC TRACEON (3604);
----dbcc page ( {'dbname' | dbid}, filenum, pagenum [, printopt={0|1|2|3} ])
--DBCC PAGE (7, 1, 1791868160, 0);
--DBCC TRACEOFF (3604);
--GO


SET NOCOUNT ON;

-- Create Temp Table to push DBCC PAGE results into
CREATE TABLE #dbccPage_output(
      ID                INT IDENTITY(1,1)
    , [ParentObject]    VARCHAR(255)
    , [Object]          VARCHAR(255)
    , [Field]           VARCHAR(255)
    , [Value]           VARCHAR(255)
)
GO

-- Variables to hold pointer information for traversing GAM and SGAM pages
DECLARE @GAM_maxPageID INT, @SGAM_maxPageID INT, @maxPageID INT,
        @GAM_page INT, @SGAM_page INT
DECLARE @stmt VARCHAR(2000)

-- Final Output Table
DECLARE @myOutputTable TABLE
(
      Logical_FileName  sysname
    , Last_ObjectID                            INT
                , Last_IndexID                  INT
    , max_page_id       INT
                , actual_size_MB             INT
)

-- Cursor to iterate through each file
DECLARE cursorFileIds CURSOR
FOR
        SELECT file_id, size
        FROM sys.database_files
        WHERE type = 0 and name = 'AX2012R3_00'

-- Variable to hold fileID
DECLARE @fileID INT, @size INT, @interval INT

-- Inject the data into the cursor
OPEN cursorFileIds
FETCH NEXT FROM cursorFileIds INTO @fileID, @size

-- Enter the While Loop.  This loop will end when the
--  end of the data injected into the cursor is reached.
WHILE @@FETCH_STATUS = 0
BEGIN

    -- # of pages in a GAM interval
    SET @interval = @size / 511232

                -- Init
                SET @GAM_page = 0
                SET @SGAM_page = 0
                SET @maxPageID = 0

                While @interval > 0 and @maxPageID in (@GAM_page, @SGAM_page)
                begin
                               print 'FileID=' + cast(@fileID as varchar) + ' @interval=' + cast(@interval as varchar)

                               -- Set GAM Page to read
        SET @GAM_page = CASE @interval WHEN 0 THEN 2 ELSE @interval * 511232 END
        -- Set SGAM page to read (always the next page after the GAM)
        SET @SGAM_page = CASE @interval WHEN 0 THEN 3 ELSE (@interval * 511232) + 1 END
                               
        -- Search Last GAM Interval page
        SET @stmt = 'DBCC PAGE(0, ' + CAST(@fileID AS VARCHAR(10)) + ', ' + CAST(@GAM_page AS VARCHAR(20)) + ', 3) WITH TABLERESULTS, NO_INFOMSGS' -- GAM on Primary Datafile
        PRINT @stmt
                               
                               TRUNCATE TABLE #dbccPage_output
        INSERT INTO #dbccPage_output ([ParentObject], [Object], [Field], [Value])
        EXEC (@stmt)

        -- Get Last Allocated Page Number
                               Set @GAM_maxPageID=0
        SELECT TOP 1 @GAM_maxPageID = REVERSE(SUBSTRING(REVERSE(Field), CHARINDEX(')', REVERSE(Field)) + 1, CHARINDEX(':', REVERSE(Field)) - CHARINDEX(')', REVERSE(Field)) - 1))
                                               FROM #dbccPage_output
                                               WHERE [Value] = '    ALLOCATED'
                                               ORDER BY ID DESC

        -- Search Last SGAM Interval page
        SET @stmt = 'DBCC PAGE(0, ' + CAST(@fileID AS VARCHAR(10)) + ', ' + CAST(@SGAM_page AS VARCHAR(20)) + ', 3) WITH TABLERESULTS, NO_INFOMSGS' -- SGAM on Primary Datafile
        PRINT @stmt

                               TRUNCATE TABLE #dbccPage_output
        INSERT INTO #dbccPage_output ([ParentObject], [Object], [Field], [Value])
        EXEC (@stmt)

        -- Get Last Allocated Page Number
                               Set @SGAM_maxPageID=0
        SELECT TOP 1 @SGAM_maxPageID = REVERSE(SUBSTRING(REVERSE(Field), CHARINDEX(')', REVERSE(Field)) + 1, CHARINDEX(':', REVERSE(Field)) - CHARINDEX(')', REVERSE(Field)) - 1))
                                               FROM #dbccPage_output
                                               WHERE [Value] = '    ALLOCATED'
                                               ORDER BY ID DESC

        -- Get highest page value between SGAM and GAM
        SELECT @maxPageID = MAX(t.value) 
                                               FROM (VALUES (@GAM_maxPageID), (@SGAM_maxPageID)) t(value)

                               -- ** Si seulement le GAM et SGAM sont alloué, traiter le GAM et SGAM précédent.
                               Set @interval -= 1
                end                        


    -- Search Highest Page Number of Data File
    SET @stmt = 'DBCC PAGE(0, ' + CAST(@fileID AS VARCHAR(10)) + ', ' + CAST(@maxPageID AS VARCHAR(50)) + ', 1) WITH TABLERESULTS, NO_INFOMSGS' -- Page ID of Last Allocated Object
    PRINT @stmt

    TRUNCATE TABLE #dbccPage_output
    INSERT INTO #dbccPage_output ([ParentObject], [Object], [Field], [Value])
    EXEC (@stmt)

    -- Capture Object Name of DataFile
    INSERT INTO @myOutputTable
    SELECT TOP 1 
            (SELECT name FROM sys.database_files WHERE file_id = @fileID) AS Logical_FileName
        , Value AS Last_ObjectID
                               ,(select top 1 x.Value FROM #dbccPage_output x WHERE x.Field = 'Metadata: IndexId' ORDER BY x.ID DESC) as Last_IndexID
                               , @maxPageID AS max_page_id
                               , @size / 128 AS actual_size_MB
    FROM #dbccPage_output
    WHERE Field = 'Metadata: ObjectId'
    ORDER BY ID DESC

                --select * from #dbccPage_output

    -- Reset Max Page Values
    SELECT @GAM_maxPageID = 0, @SGAM_maxPageID = 0, @maxPageID = 0

     -- Traverse the Data in the cursor
     FETCH NEXT FROM cursorFileIds INTO @fileID, @size
END

-- Close and deallocate the cursor because you've finished traversing all it's data
CLOSE cursorFileIds
DEALLOCATE cursorFileIds

-- Output Object Closest to the End
SELECT  Logical_FileName
    ,   max_page_id AS max_page_id_allocated
                ,   actual_size_MB
    ,   coalesce(OBJECT_SCHEMA_NAME(Last_ObjectId) + N'.' + OBJECT_NAME(Last_ObjectId),'Object_ID = '+cast(Last_ObjectId as varchar)  ) AS Last_ObjectName 
                ,   idx.name AS Last_IndexName
    ,   'DBCC SHRINKFILE(' + Logical_FileName + ', ' + CAST(CEILING((max_page_id + 8) * 0.0078125) AS VARCHAR(50)) + ')' AS ShrinkCommand_ImmediateRelease
                ,   'ALTER INDEX [' + idx.name + '] ON [' + OBJECT_SCHEMA_NAME(Last_ObjectId) + '].[' + OBJECT_NAME(Last_ObjectId) + '] REBUILD WITH(ONLINE=ON, MAXDOP=8)' AS RebuildCommand
FROM @myOutputTable o
left outer join sys.indexes idx on idx.index_id = Last_IndexID and idx.object_id = o.Last_ObjectId

-- Cleanup
DROP TABLE #dbccPage_output
GO




 

 

	


