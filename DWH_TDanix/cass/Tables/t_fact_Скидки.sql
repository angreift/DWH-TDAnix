CREATE TABLE [cass].[t_fact_Скидки] (
	[Код_кассы] [int] NOT NULL,
	[ИД_скидки] NVARCHAR(20) NOT NULL,
	[Код_товара] [bigint] NOT NULL,
	[Номер_позиции] [int] NOT NULL,
	[Дата_применения_скидки] [date] NOT NULL,
	[Дата_время_применения_скидки] [datetime] NOT NULL,
	[Объект_скидки] [bit] NOT NULL,
	[Номер_скидки] [int] NOT NULL,
	[Режим_скидки] [int] NOT NULL,
	[Тип_скидки] [int] NOT NULL,
	[Ставка_скидки] [decimal](13, 2) NOT NULL,
	[Сумма_скидки] [decimal](14, 2) NOT NULL,
	[Сумма_чека] [decimal](14, 2) NOT NULL,
	[Номер_дисконтной_карты] [nvarchar](200) NULL,
	[Название_дисконтной_карты] [nvarchar](200) NULL,
	[ИД_карты] [int] NULL,
	[Составной_код_позиции] [nvarchar](20) NOT NULL,
	[Составной_код_кассира] [nvarchar](20) NOT NULL
    CONSTRAINT [FK_t_fact_Скидки_t_fact_Детализация_чеков] FOREIGN KEY ([Составной_код_позиции]) REFERENCES [cass].[t_fact_Детализация_чеков] ([Составной_код_позиции]) ON DELETE CASCADE
) ON [FACTS];


GO
CREATE CLUSTERED INDEX [ix_cl_ИД_позиции]
    ON [cass].[t_fact_Скидки]([Составной_код_позиции] ASC)
    ON [FACTS];


GO

CREATE INDEX [ix_uncl_Скидки_Дата] ON [cass].[t_fact_Скидки] ([Дата_применения_скидки]) ON [FACTS];

GO

CREATE INDEX [ix_uncl_Скидки_Измерения] ON [cass].[t_fact_Скидки] (Код_товара, Код_кассы) ON [FACTS];
