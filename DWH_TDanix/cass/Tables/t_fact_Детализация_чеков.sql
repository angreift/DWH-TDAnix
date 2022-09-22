CREATE TABLE [cass].[t_fact_Детализация_чеков] (
	[Код_кассы] [int] NOT NULL,
	[Код_товара] [bigint] NOT NULL,
	[Дата_добавления_позиции] [date] NOT NULL,
	[Дата_время_добавления_позиции] [datetime] NOT NULL,
	[Способ_добавления_позиции] [tinyint] NULL,
	[Количество] [decimal](13, 3) NOT NULL,
	[Способ_ввода_количества] [tinyint] NOT NULL,
	[Цена] [decimal](14, 2) NOT NULL,
	[Минимальная_цена] [decimal](14, 2) NOT NULL,
	[Цена_позиции] [decimal](14, 2) NOT NULL,
	[Способ_ввода_цены] [tinyint] NOT NULL,
	[Сумма_скидки] [decimal](14, 2) NOT NULL,
	[Начальная_сумма_до_применения_скидок] [decimal](14, 2) NOT NULL,
	[Итоговая_сумма_после_применения_скидок] [decimal](14, 2) NOT NULL,
	[Номер_позиции_в_чеке] [tinyint] NOT NULL,
	[Сумма_Наличные] [decimal](14, 2) NULL,
	[Сумма_Терминал] [decimal](14, 2) NULL,
	[Сумма_СБП_Сбербанк] [decimal](14, 2) NULL,
	[Сумма_оплаты_Неинтегрированный_терминал_СБ] [decimal](14, 2) NULL,
	[Сумма_оплаты_Накопительные_карты] [decimal](14, 2) NULL,
	[Возврат] [bit] NOT NULL,
	[Составной_код_позиции] [nvarchar](20) NOT NULL,
	[Составной_код_документа] [nvarchar](20) NOT NULL,
	[Составной_код_кассира] [nvarchar](20) NOT NULL,
    CONSTRAINT [PK_t_fact_Детализация_чеков] PRIMARY KEY CLUSTERED ([Составной_код_позиции] ASC) ON [FACTS],
    CONSTRAINT [FK_t_fact_Детализация_чеков_t_fact_Чеки] FOREIGN KEY ([Составной_код_документа]) REFERENCES [cass].[t_fact_Чеки] ([Составной_код_документа]) ON DELETE CASCADE
) ON [FACTS];


GO
CREATE NONCLUSTERED INDEX [ix_uncl_Ид_док]
    ON [cass].[t_fact_Детализация_чеков]([Составной_код_документа] ASC)
    ON [FACTS];


GO

CREATE INDEX [ix_uncl_Детализация_чеков_Дата] ON [cass].[t_fact_Детализация_чеков] ([Дата_добавления_позиции]) on [FACTS]

GO

CREATE INDEX [ix_uncl_Детализация_чеков_Измерения] ON [cass].[t_fact_Детализация_чеков] ([Код_товара], [Код_кассы]) on [FACTS]
