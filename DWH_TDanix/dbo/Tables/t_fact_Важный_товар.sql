CREATE TABLE [dbo].[t_fact_Важный_товар]
(
	[Код_магазина] int not null,
	[Начало_действия] date not null,
	[Конец_действия] date not null,
	[Код_товара] bigint not null,
	[Сценарий] INT not null
) on [FACTS]
go

Create clustered index [ix_cl_Дата_начала] on [dbo].[t_fact_Важный_товар] ([Начало_действия] asc, [Конец_действия] asc) on [FACTS]
go

Create nonclustered index [ix_uncl_Код_магазина] on [dbo].[t_fact_Важный_товар] ([Код_магазина]) on [FACTS]
go

Create nonclustered index [ic_uncl_Код_товара] on [dbo].[t_fact_Важный_товар] ([Код_товара]) on [FACTS]
GO