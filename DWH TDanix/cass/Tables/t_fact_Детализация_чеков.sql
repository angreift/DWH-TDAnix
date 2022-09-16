CREATE TABLE [cass].[t_fact_Детализация_чеков] (
    [Код_кассы]                                  INT             NOT NULL,
    [Код_кассира]                                INT             NOT NULL,
    [ИД_позиции]                                 INT             NOT NULL,
    [ИД_документа]                               INT             NOT NULL,
    [Код_товара]                                 BIGINT          NOT NULL,
    [Дата_время_добавления_позиции]              DATETIME        NOT NULL,
    [Способ_добавления_позиции]                  TINYINT         NULL,
    [Количество]                                 DECIMAL (13, 3) NOT NULL,
    [Способ_ввода_количества]                    TINYINT         NOT NULL,
    [Цена]                                       MONEY           NOT NULL,
    [Минимальная_цена]                           MONEY           NOT NULL,
    [Цена_позиции]                               MONEY           NOT NULL,
    [Способ_ввода_цены]                          TINYINT         NOT NULL,
    [Сумма_скидки]                               MONEY           NOT NULL,
    [Начальная_сумма_до_применения_скидок]       MONEY           NOT NULL,
    [Итоговая_сумма_после_применения_скидок]     MONEY           NOT NULL,
    [Номер_позиции_в_чеке]                       TINYINT         NOT NULL,
    [Сумма_Наличные]                             MONEY           NULL,
    [Сумма_Терминал]                             MONEY           NULL,
    [Сумма_СБП_Сбербанк]                         MONEY           NULL,
    [Сумма_оплаты_Неинтегрированный_терминал_СБ] MONEY           NULL,
    [Сумма_оплаты_Накопительные_карты]           MONEY           NULL,
    [Возврат]                                    BIT             NOT NULL,
    [Итоговая_сумма_всего_чека]                  MONEY           NULL,
    [Составной_код_позиции]                      NVARCHAR (20)   NOT NULL,
    [Составной_код_документа]                    NVARCHAR (20)   NOT NULL,
    CONSTRAINT [PK_t_fact_Детализация_чеков] PRIMARY KEY CLUSTERED ([Составной_код_позиции] ASC) ON [FACTS],
    CONSTRAINT [FK_t_fact_Детализация_чеков_t_fact_Чеки] FOREIGN KEY ([Составной_код_документа]) REFERENCES [cass].[t_fact_Чеки] ([Составной_код_документа]) ON DELETE CASCADE
) ON [FACTS];


GO
CREATE NONCLUSTERED INDEX [ix_uncl_Ид_док]
    ON [cass].[t_fact_Детализация_чеков]([Составной_код_документа] ASC)
    ON [FACTS];

