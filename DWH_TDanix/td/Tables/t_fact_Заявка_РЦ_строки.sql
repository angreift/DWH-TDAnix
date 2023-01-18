CREATE TABLE [td].[t_fact_Заявка_РЦ_строки]
(
	[Составной_код_заявки_РЦ] nvarchar(15) not null,
	[Код_товара] bigint not null,
	[Остаток] decimal(14,3) null,
	[Остаток_цех] decimal(10,3) null,
	[Прогноз] decimal(14,3) null,
	[План] decimal(12,3) null,
	[Заказ] decimal(14,3) null,
	[Заказ_выпечка] decimal(14,3) null,
	[В_пути] decimal(14,3) null,
	[Цена] decimal(12,2) null,
	[Единиц_в_упаковке] decimal(14,3) null,
	[Минимальная_норма] decimal(14,3) null,
	[Средние_продажи] decimal(14,3) null,
	[Период_заказа] smallInt null,
	[Страховой_запас] decimal(14,3) null,
	[Неснижаемый_остаток] decimal(14,3) null,
	[Спец_заказ] decimal(6,2) null,
	-- Ккрит
	[Критический_остаток] decimal(3,1) null,
	-- Кдн
	[Дневной_коэффициент] decimal(10,3) null,
	-- Кнед
	[Недельный_коэффициент] decimal(10,3) null,
	-- Kt
	[Температурный_коэффициент] decimal(10,2) null,
	[Категория_РЦ] smallint null,
	[Приказ_с_планом] int null,
	[Категория_ABC] nvarchar(10) null,
	[Не_заказывать] tinyint null,
	[Неснижаемый_остаток_в_матрице] nvarchar(10) null,
	constraint [FK_t_fact_Заявка_РЦ_строки_t_fact_Заявка_РЦ_шапки] foreign key ([Составной_код_заявки_РЦ]) references [td].[t_fact_Заявка_РЦ_шапки] ([Составной_код_заявки_РЦ]) on delete cascade
) on [FACTS]
GO

create clustered index [ix_cl_Состаной_код_Заявка_РЦ] on [td].[t_fact_Заявка_РЦ_строки] ([Составной_код_заявки_РЦ]) on [FACTS]
GO
create nonclustered index [ix_uncl_Код_товара] on [td].[t_fact_Заявка_РЦ_строки] ([Код_товара]) on [FACTS]
GO
