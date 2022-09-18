CREATE TABLE [cass].[t_fact_Чеки] (
    [Код_кассы]                                  INT           NOT NULL,
    [ИД_смены]                                   INT           NOT NULL,
    [ИД_документа]                               INT           NOT NULL,
    [Номер_чека]                                 INT           NOT NULL,
    [Код_кассира]                                INT           NOT NULL,
    [Дата_время_открытия_чека]                   DATETIME      NOT NULL,
    [Дата_время_закрытия_чека]                   DATETIME      NOT NULL,
    [Сумма_без_скидок]                           MONEY         NOT NULL,
    [Итоговая_сумма_со_скидками]                 MONEY         NOT NULL,
    [Печать_чека]                                BIT           NOT NULL,
    [Возврат]                                    BIT           NOT NULL,
    [Сумма_оплаты_Наличные]                      MONEY         NOT NULL,
    [Сумма_оплаты_Терминал]                      MONEY         NOT NULL,
    [Сумма_оплаты_СБП_Сбербанк]                  MONEY         NOT NULL,
    [Сумма_оплаты_Неинтегрированный_терминал_СБ] MONEY         NOT NULL,
    [Сумма_оплаты_Накопительные_карты]           MONEY         NOT NULL,
    [Составной_код_смены]                        NVARCHAR (20) NOT NULL,
    [Составной_код_документа]                    NVARCHAR (20) NOT NULL,
    CONSTRAINT [PK_t_fact_Чеки] PRIMARY KEY CLUSTERED ([Составной_код_документа] ASC) ON [FACTS],
    CONSTRAINT [FK_t_fact_Чеки_t_fact_Смены_на_кассах] FOREIGN KEY ([Составной_код_смены]) REFERENCES [cass].[t_fact_Смены_на_кассах] ([Составной_код_смены]) ON DELETE CASCADE
) ON [FACTS];


GO
CREATE NONCLUSTERED INDEX [ix_uncl_ИД_смены]
    ON [cass].[t_fact_Чеки]([Составной_код_смены] ASC)
    ON [FACTS];

GO

CREATE INDEX [ix_uncl_Чеки_Дата] ON [cass].[t_fact_Чеки] ([Дата_время_закрытия_чека]) ON [FACTS];

GO

CREATE INDEX [ix_uncl_Чеки_Измерения] ON [cass].[t_fact_Чеки] (Код_кассы, Составной_код_смены) ON [FACTS];

GO