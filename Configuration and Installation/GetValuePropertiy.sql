--select * FROM syscurconfigs order by comment

SELECT OBJECTPROPERTY(object_id('trgPreventDDL'), 'ExecIsQuotedIdentOn')
