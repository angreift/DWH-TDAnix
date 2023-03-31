CREATE TABLE [plan].[t_fact_Планы_СА_по_группам]
(
	id int identity(1,1),
	Дата date not null,
	Код_магазина int not null,
	Код_показателя_для_сравнительного_анализа int not null,
	Значение decimal(12,2) not null,
	constraint [ix_cl_id] primary key
	([id] ASC) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FACTS]
) on [FACTS]
GO

Create nonclustered index [ix_uncl_Дата] on [plan].[t_fact_Планы_СА_по_группам] ([Дата] asc) on [FACTS]
GO

Create nonclustered index [ix_uncl_Код_магазина] on [plan].[t_fact_Планы_СА_по_группам] ([Код_магазина]) on [FACTS]
GO
