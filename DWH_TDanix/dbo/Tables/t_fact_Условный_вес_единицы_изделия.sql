CREATE TABLE [dbo].[t_fact_Условный_Вес_Единицы_Изделия](
	[Код_товара] [bigint] NULL,
	[Дата_Изменения] [date] NULL,
	[Значение] [decimal](10, 3) NULL,
	[Автор] [varchar](30) NULL
) ON [FACTS]
GO
