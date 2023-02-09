CREATE TABLE [rprt_cw].[t_fact_Приказы_Излишний_объем](
	[Дата] [date] NOT NULL,
	[Номер_приказа] [bigint] NOT NULL,
	[Наименование] [varchar](50) NOT NULL
) ON [REPORTS]
GO