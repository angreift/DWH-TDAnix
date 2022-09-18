CREATE TABLE [cass].[t_fact_Смены_на_кассах] (
    [Код_кассы]                        INT           NOT NULL,
    [ИД_смены]                         INT           NOT NULL,
    [Номер_смены]                      INT           NULL,
    [Код_кассира]                      INT           NOT NULL,
    [Дата_время_начала_смены]          DATETIME      NOT NULL,
    [Дата_время_окончания_смены]       DATETIME      NULL,
    [Номер_первого_чека_в_смене]       INT           NOT NULL,
    [Номер_последнего_чека_в_смене]    INT           NOT NULL,
    [Сумма_продажи]                    MONEY         NOT NULL,
    [Сумма_выручки]                    MONEY         NOT NULL,
    [Сумма_в_денежном_ящике]           MONEY         NOT NULL,
    [Признак_изменения_данных]         BIT           NOT NULL,
    [Дата_время_открытия_первого_чека] DATETIME      NOT NULL,
    [Сумма_продажи_наличные]           MONEY         NOT NULL,
    [Сумма_продажи_безналичные]        MONEY         NOT NULL,
    [Сумма_продажи_прочие]             MONEY         NOT NULL,
    [Сумма_выручки_наличные]           MONEY         NOT NULL,
    [Сумма_выручки_безналичные]        MONEY         NOT NULL,
    [Сумма_возвратов]                  MONEY         NOT NULL,
    [Сумма_возвратов_наличные]         MONEY         NOT NULL,
    [Сумма_возвратов_безналичные]      MONEY         NOT NULL,
    [Количество_чеков_продажи]         INT           NOT NULL,
    [Количество_чеков_возврата]        INT           NOT NULL,
    [Составной_код_смены]              NVARCHAR (20) NOT NULL,
    CONSTRAINT [PK_t_fact_Смены_на_кассах] PRIMARY KEY CLUSTERED ([Составной_код_смены] ASC) ON [FACTS]
) ON [FACTS];

GO

CREATE INDEX [ix_uncl_Смены_Дата] ON [cass].[t_fact_Смены_на_кассах] ([Дата_время_начала_смены]) ON [FACTS];

GO

CREATE INDEX [ix_uncl_Смены_Измерения] ON [cass].[t_fact_Смены_на_кассах] (Код_кассы) ON [FACTS];

GO