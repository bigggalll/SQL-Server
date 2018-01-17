
--	=================================================================================================================	
--											S A U V E G A R D E 
--										                        
--	Effectuer une sauvegarde rapide d'une BD sur le share drive 
--	=================================================================================================================	

-- Ce script permet de faire une sauvegarde rapide d'une base de données.  La sauvegarde va se placer sur le
-- Share drive voulu (associé au serveur).  Le nom du fichier .bak contient la BD, la date et l'heure
--	=================================================================================================================
--     Paramètre     		Utilisation 
--     @DataBase			Nom de la base de données
--	   @TypeServer          Type de serveur où on est
--								P = Prod
--								Q = Qua
--								D = Dev
--	=================================================================================================================
declare @DataBase varchar(100) = N'PJCCMS'
Declare @TypeServer varchar(1) = N'Q'                           

--	=================================================================================================================
Declare @Path varchar(200)
Declare @WorkTime varchar(8)= rtrim(convert(char(8), getdate(), 108))
Declare @UserName varchar(200) = SYSTEM_USER
Set @UserName = replace(@UserName, '\', '_')

If @TypeServer='P'
	begin
		set @Path = N'\\pjc.ca\ti\AG-SHR\' + rTrim(@DataBase) + '_____by_' + @UserName + '_from_' +
		RTrim( CONVERT(date, GETDATE())) + '@' + rtrim(substring(@worktime,1,2))  + 'H' +
		rtrim(substring(@worktime,4,2)) + '.bak';
		print @path;
	end
Else
	If @TypeServer='Q'
		Begin
			set @Path = N'\\jeancoutu-qa.com\ti\AG-SHR\' + rTrim(@DataBase) + '_____by_' + @UserName + '_from_' +
			RTrim( CONVERT(date, GETDATE())) + '@' + rtrim(substring(@worktime,1,2))  + 'H' +
			rtrim(substring(@worktime,4,2)) + '.bak';
			print @path
		end
	Else
		Begin
			set @Path = N'\\jeancoutu-dev.com\ti\AG-SHR\' + rTrim(@DataBase) + '_____by_' + @UserName +'_from_' +
			RTrim( CONVERT(date, GETDATE())) + '@' + rtrim(substring(@worktime,1,2))  + 'H' +
			rtrim(substring(@worktime,4,2)) + '.bak';
			print @path
		end
backup database @DataBase to disk = @Path with COPY_ONLY,compression

--	=================================================================================================================<
