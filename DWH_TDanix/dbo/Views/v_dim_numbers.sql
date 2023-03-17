declare @q nvarchar(max)

if (SELECT count(*) FROM sys.sql_modules WHERE object_id = OBJECT_ID('dbo.v_dim_numbers')) = 0 begin
	set @q = 'drop view if exists [dbo].[v_dim_numbers]'
	exec(@q)
	
	set @q = '
		CREATE VIEW [dbo].[v_dim_numbers]
		AS select cast([number] as smallint) number from [master]..[spt_values] where [type] = ''P''
	'
	exec(@q)
end 
go