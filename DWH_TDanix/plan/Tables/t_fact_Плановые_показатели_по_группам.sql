CREATE TABLE [plan].[t_fact_Плановые_показатели_по_группам]
(
	[Дата] date not null,
	[Код_магазина] int not null,
	[Код_группы] bigint not null,
	[Код_показателя_планирования] int not null,
	[Значение] decimal(15,4) null  
)
GO

Create clustered index [ix_cl_Дата] on [plan].[t_fact_Плановые_показатели_по_группам] ([Дата] asc) on [FACTS]
GO

Create nonclustered index [ix_cl_Код_магазина] on [plan].[t_fact_Плановые_показатели_по_группам] ([Код_магазина] asc) on [FACTS]
GO