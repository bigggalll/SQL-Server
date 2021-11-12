-- +------------------------------------------------------------------------------------------------------------------+
-- | LIST JOB FAILURES FOR LAST 30 DAYS																																								|
-- +------------------------------------------------------------------------------------------------------------------+
Set Nocount On

IF OBJECT_ID('tempdb..#tmp_failed_jobs') IS NOT NULL DROP TABLE #tmp_failed_jobs
GO

IF OBJECT_ID ('tempdb..#tmp_failed_backup') IS NOT NULL DROP TABLE #tmp_failed_backup
GO

IF OBJECT_ID ('tempdb..#tmp_bkup_space') IS NOT NULL DROP TABLE #tmp_bkup_space
GO

if object_id('tempdb..#tmp_err_logs') is not null drop table #tmp_err_logs
GO

if object_id('tempdb..#tmp_logs') is not null drop table #tmp_logs
GO

if object_id('tempdb..#errors') is not null drop table #errors
GO

DECLARE @cnt  INT
       ,@idCol INT
       ,@job_name SYSNAME
       ,@step_id INT
       ,@step_name SYSNAME
       ,@description nvarchar(4000)
       ,@run_date nvarchar(30)
       ,@severity INT
       ,@strHTML nvarchar(4000)
       ,@dbname nvarchar(255)
       ,@DumpFull char(1)
       ,@dump25h char(1)
       ,@dDumpFullDate nvarchar(100)
       ,@dDernierDumpDate nvarchar(100)
       ,@lecteur char(1)
       ,@freespacemb int
       ,@requismb int
       ,@lect char(1)
       ,@verif INT
       ,@arcId INT
       ,@errdate datetime
       ,@logsize INT
       ,@logEntry nvarchar(4000)
       ,@EntryTime nvarchar(50)
       ,@source nvarchar(50)
       ,@i int

SET @strHTML = ''
Select @strHTML = @strHTML + '<Html><Head><Title> ' + @@servername + '</Title> '
Select @strHTML = @strHTML + '<Style>body{font-family: verdana;margin: 1px 1px 1px 15px;scrollbar-3d-light-color:##006BB3;
	scrollbar-arrow-color:##006BB3;scrollbar-base-color:##006BB3;scrollbar-dark-shadow-color:##006BB3;
	scrollbar-face-color:##006BB3;scrollbar-highlight-color:##006BB3;scrollbar-shadow-color:##006BB3;
	bgcolor:##006BB3;} tr.tcontent{FONT-FAMILY: verdana;FONT-SIZE: 14px}  
	TD{FONT-FAMILY: tahoma;FONT-SIZE: 8pt} TD.Head {color:##006BB3; FONT-WEIGHT:bold;}  
	td.tcontent{FONT-SIZE: 12px;color:##006BB3;} 
	TD.Title{FONT-WEIGHT:bold; FONT-FAMILY: verdana;FONT-SIZE: 10pt;color:##006BB3;font-weight: bold;bgcolor:##006BB3} 
	A{FONT-FAMILY: tahoma;FONT-SIZE: 12px;} A.Index{FONT-WEIGHT:bold;FONT-SIZE:8pt;COLOR:##006BB3;FONT-FAMILY:verdana;TEXT-DECORATION:none}</Style> '
Select @strHTML = @strHTML + '</Head> '
Select @strHTML = @strHTML + '<Body> '
Select @strHTML = @strHTML + '<Div><br><br> '
Select @strHTML = @strHTML + '<Div  align="left"><table Border="0" cellpadding="3" Cellspacing="0" style="border-collapse: collapse;" width="700px">
                  <tr><td valign="top" align="Left" height="10px"> <FONT SIZE="5" color="#006BB3"><B> Verification SQL Server: '+ @@servername +' </B></FONT></td></tr>
                  <tr><td align="left" height="1px"> <hr noshade width="700px" style="height:1px;margin:0;padding: 0;color="#B3B4B6"></td></tr>
                  <tr><td align="left" height="20px"> <FONT SIZE="3" color = #006BB3><B>Created :  ' + convert(varchar(12),getdate(),113) + ' </B></FONT></td></tr>
                  <tr><td align="left" height="1px"> <hr noshade width="700px" style="height:1px;margin:0;padding: 0;color="#B3B4B6"></td></tr>
                  </table><br><br></Div>' 
Select @strHTML = @strHTML + '<A name=Top></A><Div  align="left"><table Border="0" cellpadding="3" Cellspacing="0" style="border-collapse: collapse;" width="700px">
                  <tr><td valign="top" align="left" height="30px" width="5px"></td>
					            <td valign="top" align="left" "height="30px" class="tcontent"> <A HREF="#1.0"><FONT SIZE="2" color="#006BB3"><B><u>1.0 List of failed jobs</U></B></FONT></A></td>
				          </tr>
				          <tr><td valign="top" align="left" height="30px" width="5px"></td>
					            <td valign="top" align="left" "height="30px" class="tcontent"> <A HREF="#2.0"><FONT SIZE="2" color="#006BB3"><B><u>2.0 List of failed Backup</U></B></FONT></A></td>
				          </tr>
				          <tr><td valign="top" align="left" height="30px" width="5px"></td>
					            <td valign="top" align="left" "height="30px" class="tcontent"> <A HREF="#3.0"><FONT SIZE="2" color="#006BB3"><B><u>3.0 Potential space issue for Backup</U></B></FONT></A></td>
				          </tr>
				          <tr><td valign="top" align="left" height="30px" width="5px"></td>
					            <td valign="top" align="left" "height="30px" class="tcontent"> <A HREF="#4.0"><FONT SIZE="2" color="#006BB3"><B><u>4.0 List of Errors in SQL Log</U></B></FONT></A></td>
				          </tr>
				          </table><p><p>'

Print @strHTML

CREATE TABLE #tmp_failed_jobs(
    idCol int identity(1,1)
   ,job_name nvarchar(200)
   ,step_id int
   ,step_name nvarchar(200)
   ,description nvarchar(4000)
   ,run_date nvarchar(30)
   ,severity int
)

CREATE TABLE #tmp_failed_backup(
    idCol int identity(1,1)
   ,nomBD nvarchar(255)
   ,DumpFull char(1)
   ,dump25h char(1)
   ,DumpFullDate nvarchar(100)
   ,DernierDumpDate nvarchar(100)
   ,lecteur char(1)
)

CREATE TABLE #tmp_bkup_space(
    idCol int identity(1,1)
   ,drive char(1)
   ,freespace INT
   ,Requiredspace INT 
)

CREATE TABLE #tmp_err_logs(
    idCol int identity(1,1)
   ,archiveid INT
   ,errdate datetime
   ,logsize INT
)

CREATE TABLE #tmp_logs(
	 idCol int identity(1,1)
	,archiveid2 INT
	,errdate2 datetime
	,logsize2 INT
)


CREATE TABLE #errors(
	 idCol int identity(1,1)
	,EntryTime datetime
	,source varchar(50)
	,LogEntry varchar(4000)
)

EXEC('INSERT INTO #tmp_failed_jobs SELECT sj.name ,sjh.step_id,js.step_name,sjh.message,left(cast(sjh.run_date as char(10)),4)
                      + ''-'' + substring(cast(sjh.run_date as char(10)),5,2)
                      + ''-'' + substring(cast(sjh.run_date as char(10)),7,2)
                      + '' '' + substring (right (stuff ('' '', 1, 1, ''000000'') + convert(varchar(6),sjh.run_time), 6), 1, 2)
                      + '':'' + substring (right (stuff ('' '', 1, 1, ''000000'') + convert(varchar(6), sjh.run_time), 6) ,3 ,2)
                      + '':'' + substring (right (stuff ('' '', 1, 1, ''000000'') + convert(varchar(6),sjh.run_time), 6) ,5 ,2) 
                      ,sjh.sql_severity
     FROM msdb.dbo.sysjobhistory sjh, msdb.dbo.sysjobs sj, msdb.dbo.sysjobsteps js
     WHERE sj.job_id = sjh.job_id
       and sj.job_id = js.job_id
       and sjh.run_status = 0
       and sjh.run_date >= Convert(Varchar(8),DATEADD(dd, -30,GETDATE()),112) Order By sjh.instance_id DESC')

EXEC ('exec SRVDBA.DBO.DBA_verifEtatBackup')
EXEC ('INSERT INTO #tmp_failed_backup select nomBD,dumpFULL,dump25h,dDumpFullDate,dDernierDumpDate,lecteur from [SRVDBA].[dbo].[DBA_MonitoringEclairParBD] where (dumpFULL=''N'' or dump25h=''N'') and nomBD not in (''tempdb'', ''SRVDBA'', ''ReportServerTempDB'')');
EXEC ('INSERT INTO #tmp_bkup_space select lecteur,FreeSpaceMB,RequisMB FROM [SRVDBA].[dbo].[DBA_MonitoringEclairEspaceDisquePourDump] where lecteur <> '' ''  and (RequisMB*0.05)+ RequisMB > FreeSpaceMB ')

insert into #tmp_err_logs exec sp_enumerrorlogs
insert into #tmp_logs select archiveid,errdate,logsize from #tmp_err_logs where errdate >= CAST('01 '+ RIGHT(CONVERT(CHAR(11),DATEADD(MONTH,-1,GETDATE()),113),8) AS datetime)



/* -----------------------------------------------------------------------------------------------------------------------
1.0. List all jobs that have failed for the last 30 days
----------------------------------------------------------------------------------------------------------------------- */
Select @strHTML ='<A name=1.0></A>'
Print @strHTML
SET @strHTML = '<Div style="position : relative; left:5px"><TABLE BORDER="1" CELLPADDING="3" CELLSPACING="0" style="border-collapse: collapse"  bordercolor="#006BB3" WIDTH="1393px">
				<TR BGCOLOR="#B3B4B6"><TD CLASS="Title" COLSPAN="6" ALIGN="Left" Height="20px"><FONT SIZE="3" color="#FFFFFF"><B>1.0. Job Failures for the last 30 days</B></FONT></TD></TR>
				<TR BGCOLOR="#006BB3">
					<TD class="Head" ALIGN="left" WIDTH="260px"><FONT SIZE="2" color="#FFFFFF"><B>Job Name</B></FONT></TD>
					<TD class="Head" ALIGN="left" WIDTH="170px"><FONT SIZE="2" color="#FFFFFF"><B>Step Name</B></FONT></TD>
					<TD class="Head" ALIGN="left" WIDTH="30px"><FONT SIZE="2" color="#FFFFFF"><B>Step ID</B></FONT></TD>
					<TD class="Head" ALIGN="left" WIDTH="110px"><FONT SIZE="2" color="#FFFFFF"><B>Run Date</B></FONT></TD>
					<TD class="Head" ALIGN="left" WIDTH="55px"><FONT SIZE="2" color="#FFFFFF"><B>Severity</B></FONT></TD>
					<TD class="Head" ALIGN="left" WIDTH="768px"><FONT SIZE="2" color="#FFFFFF"><B>Description</B></FONT></TD>
				</TR> ' 
Print @strHTML

SET @cnt = 0
select @cnt = count(1) FROM #tmp_failed_jobs;
if ( @cnt > 0 )
   BEGIN
      WHILE ( @cnt > 0 )
      BEGIN
      	 SELECT top 1 
      	     @idCol       = idCol
      	    ,@job_name 		= job_name
            ,@step_id  		= step_id
            ,@step_name 	= step_name
            ,@description = description
            ,@run_date    = run_date 
            ,@severity    = severity
         FROM #tmp_failed_jobs;
         
         DELETE FROM #tmp_failed_jobs where idCol=@idCol;
         
         --<HTML CODE TO DISPLAY COLUMN RESULTS>
         Set @strHTML = '<TR><TD VALIGN="top">' + @job_name    									 + ' </TD><TD VALIGN="top">' + 
                                                  @step_name   									 + ' </TD><TD VALIGN="top">' + 
                                                  cast(@step_id as varchar(20))  + ' </TD><TD VALIGN="top">' + 
                                                  @run_date 										 + ' </TD><TD VALIGN="top">' + 
                                                  cast(@severity as varchar(20)) + ' </TD><TD VALIGN="top">' +  
                                                  @description  								 + ' </TD>' + '</TD></TR>'
         Print @strHTML
         --<END>
         
         SET @cnt=@cnt-1
      END
   END 
ELSE 
	 BEGIN
      Set @strHTML = '<TR><TD VALIGN="top" colspan=6>All Jobs executed successfully</TD></TR>'
      Print @strHTML 
   END

SET @strHTML='</table></div><p><p>'
Select @strHTML =@strHTML + ' <Div style="position : relative; left:5px"><A HREF="#Top">Top</A></Div></br></br>'
Print @strHTML

/* -----------------------------------------------------------------------------------------------------------------------
2.0. Display list of database that haven't been backup at all or during the last 25 hours 
----------------------------------------------------------------------------------------------------------------------- */
Select @strHTML ='<A name=2.0></A>'
Print @strHTML
SET @strHTML = '<Div style="position : relative; left:5px"><TABLE BORDER="1" CELLPADDING="3" CELLSPACING="0" style="border-collapse: collapse"  bordercolor="#006BB3" WIDTH="1393px">
				<TR BGCOLOR="#B3B4B6"><TD CLASS="Title" COLSPAN="6" ALIGN="Left" Height="20px"><FONT SIZE="3" color="#FFFFFF"><B>2.0. Failed/Last Backup performed</B></FONT></TD></TR>
				<TR BGCOLOR="#006BB3">
					<TD class="Head" ALIGN="left" WIDTH="300px"><FONT SIZE="2" color="#FFFFFF"><B>Database Name</B></FONT></TD>
					<TD class="Head" ALIGN="left" WIDTH="30px"><FONT SIZE="2" color="#FFFFFF"><B>Dump Full</B></FONT></TD>
					<TD class="Head" ALIGN="left" WIDTH="30px"><FONT SIZE="2" color="#FFFFFF"><B>Dump 25Hrs</B></FONT></TD>
					<TD class="Head" ALIGN="left" WIDTH="110px"><FONT SIZE="2" color="#FFFFFF"><B>dDumpFullDate</B></FONT></TD>
					<TD class="Head" ALIGN="left" WIDTH="110px"><FONT SIZE="2" color="#FFFFFF"><B>dDernierDumpDate</B></FONT></TD>
				</TR> ' 
Print @strHTML

SET @cnt = 0
select @cnt = count(1) FROM #tmp_failed_backup;
select @verif = count(1) FROM #tmp_failed_backup where lecteur is NULL;
if ( @cnt > 0)
   BEGIN 
      WHILE ( @cnt > 0 )
      BEGIN
      	 SELECT top 1 
      	     @idCol						 = idCol
      	    ,@dbname           = nomBD
      	    ,@DumpFull 		     = DumpFull
           ,@dump25h  				 = dump25h
           ,@dDumpFullDate 	 = DumpFullDate
           ,@dDernierDumpDate = DernierDumpDate
        FROM #tmp_failed_backup;
      	 
      	 DELETE FROM #tmp_failed_backup where idCol=@idCol;
      	 
      	 --<HTML CODE TO DISPLAY COLUMN RESULTS>
         Set @strHTML = '<TR><TD VALIGN="top">' + @dbname    						+ ' </TD><TD VALIGN="top">' + 
                                                  @DumpFull   					+ ' </TD><TD VALIGN="top">' + 
                                                  @dump25h  					 	+ ' </TD><TD VALIGN="top">' + 
                                                  @dDumpFullDate 				+ ' </TD><TD VALIGN="top">' + 
                                                  @dDernierDumpDate	 		+ ' </TD></TR>'
         Print @strHTML
         --<END>
      	 
      	 SET @cnt=@cnt-1
      END
   END 
ELSE
	 BEGIN
	    Set @strHTML = '<TR><TD VALIGN="top" colspan=5>No Backup issues</TD></TR>'
	    Print @strHTML
   END
   
if (@verif > 0)
BEGIN
	 Set @strHTML = '<TR><TD VALIGN="top" colspan=5 bgcolor=grey>(Obelix-Obelix)  WARNING: External Backup agent detected</TD></TR>'
	 Print @strHTML
END
	 
SET @strHTML='</table></div><p><p>'
Select @strHTML =@strHTML + ' <Div style="position : relative; left:5px"><A HREF="#Top">Top</A></Div></br></br>'
Print @strHTML

/* -----------------------------------------------------------------------------------------------------------------------
3.0. Potential space issue for the Next Backup 
----------------------------------------------------------------------------------------------------------------------- */
Select @strHTML ='<A name=3.0></A>'
Print @strHTML
SET @strHTML = '<Div style="position : relative; left:5px"><TABLE BORDER="1" CELLPADDING="3" CELLSPACING="0" style="border-collapse: collapse"  bordercolor="#006BB3" WIDTH="600px">
				<TR BGCOLOR="#B3B4B6"><TD CLASS="Title" COLSPAN="6" ALIGN="Left" Height="20px"><FONT SIZE="3" color="#FFFFFF"><B>3.0. Potential space issue for Backup</B></FONT></TD></TR>
				<TR BGCOLOR="#006BB3">
					<TD class="Head" ALIGN="left" WIDTH="200px"><FONT SIZE="2" color="#FFFFFF"><B>Drive</B></FONT></TD>
					<TD class="Head" ALIGN="left" WIDTH="200px"><FONT SIZE="2" color="#FFFFFF"><B>Free Space (MB)</B></FONT></TD>
					<TD class="Head" ALIGN="left" WIDTH="200px"><FONT SIZE="2" color="#FFFFFF"><B>Required Space (MB)</B></FONT></TD>
				</TR> ' 
Print @strHTML

SET @cnt = 0
select @cnt = count(1) FROM #tmp_bkup_space;

if ( @cnt > 0)
   WHILE ( @cnt > 0 )
   BEGIN
   	 SELECT top 1 
   	     @idCol						 = idCol
   	    ,@lecteur           = drive
   	    ,@freespacemb 		     = freespace
         ,@requismb  				 = Requiredspace
      FROM #tmp_bkup_space;
   	 
   	 DELETE FROM #tmp_bkup_space where idCol=@idCol;
   	 
   	 --<HTML CODE TO DISPLAY COLUMN RESULTS>
      Set @strHTML = '<TR><TD VALIGN="top">' + @lecteur    						+ ' </TD><TD VALIGN="top">' + 
                                               @freespacemb   					+ ' </TD><TD VALIGN="top">' + 
                                               @requismb  					 	+ ' </TD></TR>'
      Print @strHTML
      --<END>
   	 
   	 SET @cnt=@cnt-1
   END
ELSE
	 Set @strHTML = '<TR><TD VALIGN="top" colspan=3>No backup space issues</TD></TR>'   
   Print @strHTML
   
SET @strHTML='</table></div><p><p>'
Select @strHTML =@strHTML + ' <Div style="position : relative; left:5px"><A HREF="#Top">Top</A></Div></br></br>'
Print @strHTML
   
/* -----------------------------------------------------------------------------------------------------------------------
4.0 List of Errors in SQL Log                                                                            
----------------------------------------------------------------------------------------------------------------------- */
Select @strHTML ='<A name=4.0></A>'
Print @strHTML
SET @strHTML = '<Div style="position : relative; left:5px"><TABLE BORDER="1" CELLPADDING="3" CELLSPACING="0" style="border-collapse: collapse"  bordercolor="#006BB3" WIDTH="1393px">
				<TR BGCOLOR="#B3B4B6"><TD CLASS="Title" COLSPAN="6" ALIGN="Left" Height="20px"><FONT SIZE="3" color="#FFFFFF"><B>4.0 List of Errors in SQL Log</B></FONT></TD></TR>
				<TR BGCOLOR="#006BB3">
					<TD class="Head" ALIGN="left" WIDTH="80px"><FONT SIZE="2" color="#FFFFFF"><B>Entrytime</B></FONT></TD>
					<TD class="Head" ALIGN="left" WIDTH="50px"><FONT SIZE="2" color="#FFFFFF"><B>Source</B></FONT></TD>
					<TD class="Head" ALIGN="left" WIDTH="700px"><FONT SIZE="2" color="#FFFFFF"><B>LogEntry</B></FONT></TD>
				</TR> ' 
Print @strHTML

select @cnt= COUNT(1) from #tmp_logs
WHILE (@cnt > 0)
BEGIN
   SELECT TOP 1
       @idcol = idCol
      ,@arcId = archiveid2
      ,@errdate = errdate2
      ,@logsize = logsize2
   FROM #tmp_logs;   
   
   DELETE from #tmp_logs where idCol=@idcol;
   If ( @logsize < 500000000)
      BEGIN
         INSERT into #errors exec xp_readerrorlog @arcId, 1;
      END
   ELSE
      BEGIN
         INSERT INTO #errors values (GETDATE(),'Archive#'+ cast(@arcId as nvarchar(1)), 'Cannot load File greater than 500Mb');
      END
   SET @cnt=@cnt-1         
END

delete #errors where EntryTime <= CAST('01 '+ RIGHT(CONVERT(CHAR(11),DATEADD(MONTH,-1,GETDATE()),113),8) AS datetime); 

delete #errors where (logentry not like '%err%'
   AND logentry not like '%warn%'
   AND logentry not like '%kill%'
   AND logentry not like '%dead%'
   AND logentry not like '%cannot%'
   AND logentry not like '%could%'
   AND logentry not like '%fail%'
   AND logentry not like '%not%'
   AND logentry not like '%stop%'
   AND logentry not like '%terminate%'
   AND logentry not like '%bypass%'
   AND logentry not like '%roll%'
   AND logentry not like '%truncate%'
   AND logentry not like '%upgrade%'
   AND logentry not like '%victim%'
   AND logentry not like '%recover%'
   AND logentry not like '%IO requests taking longer than%')
   OR logentry like '%errorlog%'
   OR logentry like '%dbcc%'
	 OR logentry like '%No user action is required.%'
	 OR logentry like '%was successfully loaded%'
	 OR logentry like '%Login failed for user ''c2configuser''%'
	 OR logentry like '%protocol transport is disabled or not configured%';
	 

set @cnt=0
select @cnt=count(1) from #errors;
set @i=0;

while (@cnt > 0)
BEGIN	 
   SELECT top 1 
          @idCol = idCol
        , @EntryTime=convert(varchar(50),EntryTime,120)
        , @source=source
        , @logEntry=logEntry
   FROM #errors;
   
   delete from #errors where idCol=@idCol;
   
   Set @strHTML = '<TR><TD VALIGN="top">' + @EntryTime + ' </TD><TD VALIGN="top">' + 
                                            @source    + ' </TD><TD VALIGN="top">' + 
                                            @logEntry  + ' </TD></TR>'
   Print @strHTML    
   set @cnt=@cnt-1;
END



SET @strHTML='</table></div><p><p>'
Select @strHTML =@strHTML + ' <Div style="position : relative; left:5px"><A HREF="#Top">Top</A></Div></br></br>'
Print @strHTML

/* -----------------------------------------------------------------------------------------------------------------------
END                                                                          
----------------------------------------------------------------------------------------------------------------------- */

Select @strHTML = '</Div></Body></html>'
Print  @strHTML