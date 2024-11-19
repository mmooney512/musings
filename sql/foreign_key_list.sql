--select 
--			t.name as TableWithForeignKey, 
--			fk.constraint_column_id as FK_PartNo, c.
--    name as ForeignKeyColumn 
--from 
--    sys.foreign_key_columns as fk
--inner join 
--    sys.tables as t on fk.parent_object_id = t.object_id
--inner join 
--    sys.columns as c on fk.parent_object_id = c.object_id and fk.parent_column_id = c.column_id
--where 
--    fk.referenced_object_id = (select object_id 
--                               from sys.tables 
--                               where name = 'TableOthersForeignKeyInto')
--order by 
--    TableWithForeignKey, FK_PartNo


--To get names of foreign key constraints

--select distinct name from sys.objects where object_id in 
--(   select fk.constraint_object_id from sys.foreign_key_columns as fk
--    where fk.referenced_object_id = 
--        (select object_id from sys.tables where name = 'TableOthersForeignKeyInto')
--)


SELECT OBJECT_NAME(f.object_id) as ForeignKeyConstraintName,
    OBJECT_NAME(f.parent_object_id) TableName,
    COL_NAME(fk.parent_object_id,fk.parent_column_id) ColumnName,
    OBJECT_NAME(fk.referenced_object_id) as ReferencedTableName,
    COL_NAME(fk.referenced_object_id,fk.referenced_column_id) as ReferencedColumnName

FROM sys.foreign_keys AS f
    INNER JOIN sys.foreign_key_columns AS fk 
        ON f.OBJECT_ID = fk.constraint_object_id
    INNER JOIN sys.tables t
        ON fk.referenced_object_id = t.object_id

WHERE OBJECT_NAME(fk.referenced_object_id) = 'your table name'
    and COL_NAME(fk.referenced_object_id,fk.referenced_column_id) = 'your key column name'

