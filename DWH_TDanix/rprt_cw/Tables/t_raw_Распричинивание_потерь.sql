CREATE TABLE [rprt_cw].[t_raw_Распричинивание_потерь]
(
	Дата date,
	Код_магазина int,
	Код_товара BIGINT,
	Причина_потери varchar(30),
	Подпричина_потери varchar(30), 
    [Сумма] DECIMAL(14, 2) NULL, 
    [Флаг] BIT NULL
) ON [Reports]
go

CREATE NONCLUSTERED INDEX [ix_uncl_КодТовара_КодМагазина_Дата] ON [rprt_cw].[t_raw_Распричинивание_потерь]
(
	[Код_товара] ASC,
	[Код_магазина] ASC,
	[Дата] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [RAW]
GO
