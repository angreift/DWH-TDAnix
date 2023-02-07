CREATE TABLE [td].[t_fact_ПД_строки]
(
	[Составной_код_ПД] nvarchar(25) not null,
	[Код_товара] bigint not null,
	[Количество_факт] decimal(19,3) null,
	[Количество_план] decimal(19,3) null,
	[Количество_по_документу] decimal(13,3) null,
	[Цена_закупа] decimal(15,2) null,
	[Сумма_закупа] decimal(19,2) null,
	[Процент_наценки] int null,
	[Цена] decimal(19,2) null,
	[Сумма] decimal(19,2) null,
	[Процент_НДС] tinyint null,
	[Сумма_НДС_закупочная] decimal(12,2) null,
	[Сумма_НДС_розничная] decimal(12,2) null,
	[Срок_годности] date null,
	[Штрихкод] nvarchar(13) null,
	[Поставщик_холдинга] NVARCHAR(100) NULL, 
    constraint [FK_t_fact_ПД_строки_t_fact_ПД_шапки] foreign key ([Составной_код_ПД]) references [td].[t_fact_ПД_шапки] ([Составной_код_ПД]) on delete cascade
) on [FACTS]
GO

create clustered index [ix_cl_Состаной_код_ПД] on [td].[t_fact_ПД_строки] ([Составной_код_ПД]) on [FACTS]
GO
create nonclustered index [ix_uncl_Код_товара] on [td].[t_fact_ПД_строки] ([Код_товара]) on [FACTS]
GO
