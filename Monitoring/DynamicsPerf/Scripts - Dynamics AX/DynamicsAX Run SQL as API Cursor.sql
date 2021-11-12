
----------------------------------------------
-- Normal FFO Cursor
----------------------------------------------

declare @p1 int
set @p1=NULL
declare @p2 int
set @p2=0
declare @p5 int
--
-- Fast Forward(16)+Parameterized(4096)+AutoFetch(8192)+AutoClose(16384)
--
set @p5=16+4096+8192+16384
declare @p6 int
set @p6=8193
declare @p7 int
--
-- Number of Rows for AutoFetch. 
-- This is calculated by Maximum Buffer Size (24K default) / Row Length
--
set @p7=4
exec sp_cursorprepexec @p1 output,@p2 output,N'@P1 nvarchar(5),@P2 nvarchar(21)',N'SELECT A.SALESID,A.RECID FROM SALESLINE A WHERE ((DATAAREAID=@P1) AND (SALESID>@P2))',@p5 output,@p6 output,@p7 output,N'ceu',N'SO-100004'
-- @p2 contains cursor handle for fetch call
exec sp_cursorfetch @p2,2,1,@p7



GO
----------------------------------------------
-- FFO Cursor Retrieving Text or Image Column
----------------------------------------------
declare @p1 int
set @p1=NULL
declare @p2 int
set @p2=0
declare @p5 int
--
-- Fast Forward(16)+Parameterized(4096)+AutoClose(16384)
-- 
set @p5=16+4096+16384
set @p5=20496
declare @p6 int
set @p6=8193
declare @p7 int
-- No Autofetch
set @p7=0
exec sp_cursorprepexec @p1 output,@p2 output,N'@P1 nvarchar(5),@P2 nvarchar(21)',N'SELECT A.SALESID,A.LINENUM FROM SALESLINE A WHERE ((DATAAREAID=@P1) AND (SALESID>@P2))',@p5 output,@p6 output,@p7 output,N'ceu',N'SO-100004'
exec sp_cursorfetch @p2,2,1,@p7

GO
----------------------------------------------
-- Pessimistic Lock Cursor
-- This will change soon to be FFO
----------------------------------------------
declare @p1 int
set @p1=NULL
declare @p2 int
set @p2=0
declare @p5 int
--
-- Dynamic(2)+ Parameterized(4096)
--
set @p5=2+4096
declare @p6 int
set @p6=8193
declare @p7 int
-- No Autofetch
set @p7=0
exec sp_cursorprepexec @p1 output,@p2 output,N'@P1 nvarchar(5),@P2 nvarchar(21)',N'SELECT A.SALESID,A.LINENUM FROM SALESLINE A WITH( UPDLOCK) WHERE ((DATAAREAID=@P1) AND (SALESID=@P2))',@p5 output,@p6 output,@p7 output,N'ceu',N'SO-100004'
exec sp_cursorfetch @p2,2,1,1


GO
----------------------------------------------
-- Typical Cursor for Form
----------------------------------------------

declare @p1 int
set @p1=NULL
declare @p2 int
set @p2=0
declare @p5 int
--
-- Fast Forward(16)+Parameterized(4096)+AutoFetch(8192)+AutoClose(16384)
--
set @p5=16+4096+8192+16384
declare @p6 int
set @p6=8193
declare @p7 int

set @p7=4
exec sp_cursorprepexec @p1 output,@p2 output,N'@P1 nvarchar(5),@P2 nvarchar(21)',N'SELECT A.SALESID,A.RECID FROM SALESLINE A WHERE ((DATAAREAID=@P1) AND (SALESID>@P2)) ORDER BY DATAAREAID, SALESID OPTION(FAST 1)',@p5 output,@p6 output,@p7 output,N'ceu',N'SO-100004'
-- For a form we don't fetch the whole result set at a time.
-- We pass 20 rows back to a grid, and fetch ahead assuming user will scroll forward.
-- So to simulate this multiple sp_cursorfetch calls may be needed.
exec sp_cursorfetch @p2,2,1,@p7
exec sp_cursorfetch @p2,2,1,@p7
exec sp_cursorfetch @p2,2,1,@p7
exec sp_cursorfetch @p2,2,1,@p7
