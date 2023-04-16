CREATE TABLE [dbo].[t_fact_Поставщики_холдинга]
(
	[Дата] date not null,
	[Код_магазина] int not null,
	[Код_товара] bigint not null,
	[Поставщик_холдинга] bigint null
) on [FACTS]
go

create nonclustered index [ix_uncl_Дата] on [dbo].[t_fact_Поставщики_холдинга] ([дата]) on [FACTS]
go

create nonclustered index [ix_uncl_Код_магазина] on [dbo].[t_fact_Поставщики_холдинга] ([Код_магазина]) on [FACTS]
go

create nonclustered index [ix_uncl_Код_товара] on [dbo].[t_fact_Поставщики_холдинга] ([Код_товара]) on [FACTS]
go