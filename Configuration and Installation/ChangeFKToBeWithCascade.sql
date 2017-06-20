select
  DropStmt = 'ALTER TABLE [' + ForeignKeys.ForeignTableSchema + 
      '].[' + ForeignKeys.ForeignTableName + 
      '] DROP CONSTRAINT [' + ForeignKeys.ForeignKeyName + ']; '
,  CreateStmt = 'ALTER TABLE [' + ForeignKeys.ForeignTableSchema + 
      '].[' + ForeignKeys.ForeignTableName + 
      '] WITH CHECK ADD CONSTRAINT [' +  ForeignKeys.ForeignKeyName + 
      '] FOREIGN KEY([' + ForeignKeys.ForeignTableColumn + 
      ']) REFERENCES [' + schema_name(sys.objects.schema_id) + '].[' +
  sys.objects.[name] + ']([' +
  sys.columns.[name] + ']) ON DELETE CASCADE; '
 from sys.objects
  inner join sys.columns
    on (sys.columns.[object_id] = sys.objects.[object_id])
  inner join (
    select sys.foreign_keys.[name] as ForeignKeyName
     ,schema_name(sys.objects.schema_id) as ForeignTableSchema
     ,sys.objects.[name] as ForeignTableName
     ,sys.columns.[name]  as ForeignTableColumn
     ,sys.foreign_keys.referenced_object_id as referenced_object_id
     ,sys.foreign_key_columns.referenced_column_id as referenced_column_id
     from sys.foreign_keys
      inner join sys.foreign_key_columns
        on (sys.foreign_key_columns.constraint_object_id
          = sys.foreign_keys.[object_id])
      inner join sys.objects
        on (sys.objects.[object_id]
          = sys.foreign_keys.parent_object_id)
        inner join sys.columns
          on (sys.columns.[object_id]
            = sys.objects.[object_id])
           and (sys.columns.column_id
            = sys.foreign_key_columns.parent_column_id)
    ) ForeignKeys
    on (ForeignKeys.referenced_object_id = sys.objects.[object_id])
     and (ForeignKeys.referenced_column_id = sys.columns.column_id)
 where (sys.objects.[type] = 'U')
  and (sys.objects.[name] not in ('sysdiagrams'))