CREATE TABLE [td].[t_fact_Продажи_ТСД]
(
	[Дата] date not null,
	[Код_магазина] int not null,
	[Код_товара] bigint not null,
	[Штрихкод] NVARCHAR(13) null,
	[Цена] decimal(10,2) not null,
	[Количество] decimal(10,3) not null,
	[Сумма] decimal(10,2) not null,
	[Количество_чеков] int not null,
	[Поставщик_холдинга] NVARCHAR(100) NULL, 
    [Важный_товар] BIT NULL, 
    [Сценарий_важного_товара] NVARCHAR(64) NULL
)
GO
Create clustered index [ix_cl_Дата] on [td].[t_fact_Продажи_ТСД] (Дата) on [FACTS]
GO
Create nonclustered index [ix_uncl_Код_магазина] on [td].[t_fact_Продажи_ТСД] (Код_магазина) on [FACTS]
GO
Create nonclustered index [ix_uncl_Код_товара] on [td].[t_fact_Продажи_ТСД] (Код_товара) on [FACTS]
GO