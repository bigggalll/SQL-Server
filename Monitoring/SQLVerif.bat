
ECHO OFF
REM This procedure takes the server name as parameter
REM ------------------------------------------------------------
rem This is usefull to make the maintenance of the SQL databases
rem It reindexes and makes backups of all databases( except system db) on an SQL server
rem This batch could be run in remote mode for all SQL servers 

REM SETTINGS that need to be changed from one server to an other
REM ------------------------------------------------------------
SET SQLSERVER=CPT723
SET USER=%2
SET PWD=%3
SET SQLSERVERNAMEFILE=%1

rem SET SQLSERVER=SRVSQLTEST-MTL
rem SET USERID=
rem SET PASSWORD=

rem DATE /T >> %SQLSERVER%.log
rem TIME /T >> %SQLSERVER%.log

SET SQLSERVERNAMEFILE=%SQLSERVER:\=_%

ECHO %SQLSERVER%

rem echo allo 
OSQL -E -S%SQLSERVER% -n -b -r0 -i"chk_weekly_dba.Sql" -o%SQLSERVERNAMEFILE%_%RANDOM%.html -x300000 -w1000 -n

pause

REM check for the errors
REM ----------------------
IF %ERRORLEVEL% EQU 1 GOTO EXIT
ECHO OK %SQLSERVER%
GOTO END

:EXIT
ECHO ********** %SQLSERVER% ERROR *************

:END
            
