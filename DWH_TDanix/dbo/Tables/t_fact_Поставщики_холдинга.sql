CREATE TABLE [dbo].[t_fact_Поставщики_холдинга]
(
	[Дата] date not null,
	[Код_магазина] int not null,
	[Код_товара] bigint not null,
	[Поставщик_холдинга] NVARCHAR(100) null
) on [FACTS]
go

create clustered index [ix_cl_Дата] on [dbo].[t_fact_Поставщики_холдинга] ([дата] asc) on [FACTS]
go

create nonclustered index [ix_uncl_Код_магазина] on [dbo].[t_fact_Поставщики_холдинга] ([Код_магазина]) on [FACTS]
go

create nonclustered index [ix_uncl_Код_товара] on [dbo].[t_fact_Поставщики_холдинга] ([Код_товара]) on [FACTS]
go