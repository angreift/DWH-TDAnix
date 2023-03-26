CREATE TABLE [plan].[t_fact_Планы_СА_по_магазинам]
(
	Дата date not null,
	Код_магазина int not null,
	Товарооборот decimal(12,2) null,
	Количество_чеков int null,
	Валовый_доход decimal(12,2) null,
	Товарооборот_СТМ decimal(12,2) null,
	Производительность decimal(12,2) null,
	Потребление_ЭЭ_без_ГВ_и_субаренды decimal(12,2) null,
	Потери decimal(12,2) null,
	Производительность_ГВ decimal(12,2) null
) on [FACTS]
GO

Create clustered index [ix_cl_Дата] on [plan].[t_fact_Планы_СА_по_магазинам] ([Дата] asc) on [FACTS]
GO

Create nonclustered index [ix_uncl_Код_магазина] on [plan].[t_fact_Планы_СА_по_магазинам] ([Код_магазина]) on [FACTS]
GO