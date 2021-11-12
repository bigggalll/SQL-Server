--http://blogs.msdn.com/sqlblog/archive/2009/02/19/plan-guides-plan-freezing-in-sql-server-2005-2008.aspx


--Create a plan guide
exec sp_create_plan_guide 
@name = N'InventItemBarcode_findItemDimensions_01',
@stmt = N'SELECT TOP 1 A.ITEMBARCODE,A.ITEMID,A.INVENTDIMID,A.BARCODESETUPID,A.USEFORPRINTING,A.USEFORINPUT,A.DESCRIPTION,A.QTY,A.MODIFIEDDATETIME,A.MODIFIEDBY,A.RECVERSION,A.RECID FROM INVENTITEMBARCODE A WHERE ((A.DATAAREAID=@P1) AND (A.ITEMID=@P2)) AND EXISTS (SELECT TOP 1 ''x'' FROM INVENTDIM B WHERE ((B.DATAAREAID=@P3) AND ((((B.INVENTDIMID=A.INVENTDIMID) AND (B.CONFIGID=@P4)) AND (B.INVENTSIZEID=@P5)) AND (B.INVENTCOLORID=@P6))))',
@type = N'SQL',
@module_or_batch = NULL,
@params = N'@P1 nvarchar(8),@P2 nvarchar(42),@P3 nvarchar(8),@P4 nvarchar(22),@P5 nvarchar(22),@P6 nvarchar(22)',
@hints = N'OPTION(OPTIMIZE FOR (@P2 = N''2001'' ,@P3 = N''DAT'' ))'


--Display all plan guides
select * from sys.plan_guides 


--Validate all plan guides
SELECT plan_guide_id, msgnum, severity, state, message
FROM sys.plan_guides
CROSS APPLY fn_validate_plan_guide(plan_guide_id);


-- Drop plan guide 
EXEC sp_control_plan_guide N'DROP',N'InventItemBarcode_findItemDimensions_01'; 



                                                                                                            

