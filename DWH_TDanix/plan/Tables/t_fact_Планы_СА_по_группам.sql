CREATE TABLE [plan].[t_fact_Планы_СА_по_группам]
(
	Дата date not null,
	Код_магазина int not null,
	Код_группы bigint not null,
	Код_показателя_для_сравнительного_анализа int not null,
	Значение decimal(12,2) not null
) on [FACTS]
GO

Create clustered index [ix_cl_Дата] on [plan].[t_fact_Планы_СА_по_группам] ([Дата] asc) on [FACTS]
GO

Create nonclustered index [ix_uncl_Код_магазина] on [plan].[t_fact_Планы_СА_по_группам] ([Код_магазина]) on [FACTS]
GO
