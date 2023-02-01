CREATE TABLE [td].[t_raw_Данные_Заявка_РЦ_шапки]
(
	[Дата_выгрузки] date null,
	[Отпечаток_времени] int null,
	[Выгрузка_из_ЗОД] bit null,
	[Код_магазина] int null,
	-- Столбцы до этого комментария используются для обратной совместимости при переходе от одной версии обмена к другой
	[Дата_время] datetime null,
	[Data] nvarchar(max) null,
	[Version] int null,
	[SubCode] int null,
	[DateExec] date null,
	[TimeStamp] int null,
	[DateStart] date null,
	[DateEnd] date null, 
    [EndFlag] BIT NULL
) on RAW
GO

create clustered index [ix_cl_Дата_время] on [td].[t_raw_Данные_Заявка_РЦ_шапки] (Дата_время ASC) on [RAW]