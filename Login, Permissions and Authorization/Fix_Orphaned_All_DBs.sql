DECLARE @DatabaseName SYSNAME;
DECLARE @UserName SYSNAME;
DECLARE @Command NVARCHAR(MAX);

IF OBJECT_ID('tempdb..#UserOrphened') IS NOT NULL
    DROP TABLE #UserOrphened;

CREATE TABLE  #UserOrphened(name VARCHAR(100));

DECLARE database_cur CURSOR
	FOR SELECT    sd.name
		FROM      sys.databases sd
   		WHERE database_id NOT IN (1,2,3,4)
			AND user_access = 0
			AND is_read_only = 0
			AND state = 0

OPEN database_cur;
FETCH NEXT FROM database_cur INTO @DatabaseName;

WHILE(@@FETCH_STATUS = 0)
    BEGIN
        SET @Command = '
					INSERT INTO #UserOrphened 
						SELECT dp.name AS user_name  
							FROM '+QUOTENAME(@DatabaseName)+'.sys.database_principals AS dp  
								LEFT JOIN sys.server_principals AS sp  
								ON dp.SID = sp.SID  
						WHERE sp.SID IS NULL  
							AND authentication_type_desc = ''INSTANCE'';';
        EXEC sp_executesql
             @command;

        DECLARE orphan_user_cur CURSOR
			FOR SELECT name
				FROM   #UserOrphened
				WHERE  name IS NOT NULL;
        IF @@ROWCOUNT = 0
            BEGIN
                PRINT 'No Orphan User to be fixed for '+@DatabaseName;
            END;

        OPEN orphan_user_cur;
        FETCH NEXT FROM orphan_user_cur INTO @UserName;
        WHILE(@@FETCH_STATUS = 0)
            BEGIN
                PRINT @UserName+'Orphan User Name Is Being Resynced';
				SET @command = 
					'
					USE ' + QUOTENAME(@DatabaseName)+'
					ALTER USER '+QUOTENAME(@UserName)+' WITH LOGIN = '+QUOTENAME(@UserName)
                PRINT @command;

				EXEC sp_executesql
					@command;

                FETCH NEXT FROM orphan_user_cur INTO @UserName;
            END;
        CLOSE orphan_user_cur;
        DEALLOCATE orphan_user_cur;

        TRUNCATE TABLE #UserOrphened;

        FETCH NEXT FROM database_cur INTO @DatabaseName;
    END;

CLOSE database_cur;
DEALLOCATE database_cur;
