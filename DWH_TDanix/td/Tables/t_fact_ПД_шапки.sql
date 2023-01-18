CREATE TABLE [td].[t_fact_ПД_шапки]
(	
	[Составной_код_ПД] nvarchar(25) not null,
	[Дата_ПД] date not null,
	[Код_магазина] int not null,
	[Форма_оплаты] nvarchar(30) null,
	[Код_поставщика_RSF] int null,
	[Код_магазина_отправителя] int null,
	[Составной_код_заявки_РЦ] nvarchar(15) null,
	[Составной_код_заявки_СТ] nvarchar(15) null,
	[Номер_фактуры] nvarchar(20) null,
	[Дата_фактуры] date null,
	[Основание] nvarchar(120) null,
	[Дата_ТТН] date null,
	[Номер_ТТН] nvarchar(20) null,
	constraint [PK_Составной_код_ПД] primary key clustered ([Составной_код_ПД] asc) on [FACTS]
) on [FACTS]
GO

create nonclustered index [ix_uncl_Заявки] on [td].[t_fact_ПД_шапки] ([Составной_код_заявки_РЦ], [Составной_код_заявки_СТ]) on [FACTS]
GO
create nonclustered index [ix_uncl_Код_магазина] on [td].[t_fact_ПД_шапки] ([Код_магазина]) on [FACTS]
GO
