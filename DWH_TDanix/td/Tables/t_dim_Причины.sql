CREATE TABLE [td].[t_dim_Причины]
(
	[Код_причины] smallint not null,
	[Наименование_причины] nvarchar(50) not null,
	[Код_категории] smallint not null,
	[Наименование_категории] nvarchar(50) not null,
	[Код_в_бухгалтерской_базе] int null,
	[Заголовок] nvarchar(10) null,
	[Вид] tinyint null,
	[Сумма] decimal(10,2) null,
	[Процент] decimal(10,2) null,
	[Причина_по_умолчанию_для_отчетов] bit null,
	[Причина_для_учета_потерь] bit null,
	[Причина_для_учета_потерь_магазина] bit null,
	constraint [ix_cl_Код_причины] primary key clustered ([Код_причины] asc) on [DIMENTIONS]
) on [DIMENTIONS]