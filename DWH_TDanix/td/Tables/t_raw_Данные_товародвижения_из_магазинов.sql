CREATE TABLE [td].[t_raw_Данные_товародвижения_из_магазинов]
(
	[Дата_время] datetime not null,
	[Дата_выгрузки] date not null,
	[Отпечаток_времени] int null,
	[Код_магазина] int not null,
	[Выгрузка_из_ЗОД] bit not null,
	[Data] nvarchar(max) not null
) on RAW