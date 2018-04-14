use master;
 
-- Get a new GUID value to use as the SID
declare @SID uniqueidentifier = newid();
 
-- In order to use the SID in a create login statement, it must be in binary format
declare @SID_Binary varbinary(max) = (select cast(@SID as varbinary(max)));
 
-- View the SID in GUID and Binary format:
select @SID, @SID_Binary;
-- E72669E3-9FAA-4BCB-8F8F-570EBF114674, 0xE36926E7AA9FCB4B8F8F570EBF114674
 
-- Here is the statement we really want to run:
--create login SQLDiablo with password='Passw0rd!', sid=0xE36926E7AA9FCB4B8F8F570EBF114674;
 
-- But that requires us to paste in the SID. There has to be a better way:
declare @UserName nvarchar(128) = 'SQLDiablo', @Password nvarchar(max) = 'Passw0rd!';
declare @Query nvarchar(max) = 'create login ' + @UserName + ' with password=''' + @Password + ''', sid=0x' + cast('' as xml).value('xs:hexBinary(sql:variable("@SID_Binary") )', 'varchar(max)') + ';';
 
select @Query;
execute sp_executesql @Query;
 
-- Since varbinary can be a little tricky to work with in dynamic SQL, XPath is our friend.
-- Above we converted the value of @SID_Binary to Hex using XPath's value method (don't forget to add 0x to the beginning of it).
 
-- Get the SID for the login we just created, as a GUID
select sp.name, cast(sp.sid as uniqueidentifier) SID_AS_GUID from sys.server_principals sp where sp.name = 'SQLDiablo';
 
-- SQLDiablo, E72669E3-9FAA-4BCB-8F8F-570EBF114674
 
set @Query = 'drop login ' + @UserName + ';';
execute sp_executesql @Query;
