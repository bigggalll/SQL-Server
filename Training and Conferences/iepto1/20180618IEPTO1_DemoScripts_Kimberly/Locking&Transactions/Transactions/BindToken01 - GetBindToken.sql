-- Defining a Token has to be done in a transaction

BEGIN TRAN
DECLARE @bindtoken varchar(255)
--select @bindtoken varchar(255) 

EXEC sp_getbindtoken @bindtoken output

SELECT @bindtoken

UPDATE member 
    SET lastname = 'Tripp' 
WHERE member_no between 1000 and 1500