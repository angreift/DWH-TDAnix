CREATE TABLE [dbo].[t_fact_Мониторинг_печати_ценников](
	[Дата] [date] NOT NULL,
	[Код_магазина] [int] NOT NULL,
	[Количество] [int] NOT NULL,
	[Тип] [tinyint] NOT NULL
) ON [FACTS]
GO