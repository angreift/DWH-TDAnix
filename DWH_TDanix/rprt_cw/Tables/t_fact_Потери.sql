CREATE TABLE [rprt_cw].[t_fact_Потери]
(
	[Дата] date NOT NULL,
	[Код_товара] bigint not null,
	[Код_магазина] int not null,
	[Сумма] decimal(14,2)
)
on [REPORTS];