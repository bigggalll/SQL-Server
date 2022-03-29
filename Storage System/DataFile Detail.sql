SELECT 
    db_name() dbname,
	[TYPE] = A.type_desc
    ,[FILE_Name] = A.name
    ,[FILEGROUP_NAME] = fg.name
    ,[File_Location] = A.physical_name
    ,[FILESIZE_MB] = CONVERT(DECIMAL(10,2),A.size/128.0)
    ,[USEDSPACE_MB] = CONVERT(DECIMAL(10,2),A.size/128.0 - ((SIZE/128.0) - CAST(FILEPROPERTY(A.name, 'SPACEUSED') AS INT)/128.0))
    ,[FREESPACE_MB] = CONVERT(DECIMAL(10,2),A.size/128.0 - CAST(FILEPROPERTY(A.name, 'SPACEUSED') AS INT)/128.0)
    ,[FREESPACE_%] = CONVERT(DECIMAL(10,2),((A.size/128.0 - CAST(FILEPROPERTY(A.name, 'SPACEUSED') AS INT)/128.0)/(A.size/128.0))*100)
    ,[AutoGrow] = 'By ' + CASE is_percent_growth WHEN 0 THEN CAST(growth/128 AS VARCHAR(10)) + ' MB -' 
        WHEN 1 THEN CAST(growth AS VARCHAR(10)) + '% -' ELSE '' END 
        + CASE max_size WHEN 0 THEN 'DISABLED' WHEN -1 THEN ' Unrestricted' 
            ELSE ' Restricted to ' + CAST(max_size/(128*1024) AS VARCHAR(10)) + ' GB' END 
        + CASE is_percent_growth WHEN 1 THEN ' [autogrowth by percent, BAD setting!]' ELSE '' END
FROM sys.database_files A LEFT JOIN sys.filegroups fg ON A.data_space_id = fg.data_space_id 
order by  FILEGROUP_NAME;