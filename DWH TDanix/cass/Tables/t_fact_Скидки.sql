CREATE TABLE [cass].[t_fact_Скидки] (
    [Код_кассы]                    INT             NOT NULL,
    [ИД_скидки]                    INT             NOT NULL,
    [ИД_позиции]                   INT             NOT NULL,
    [Код_товара]                   BIGINT          NOT NULL,
    [Номер_позиции]                INT             NOT NULL,
    [Код_кассира]                  INT             NOT NULL,
    [Дата_время_применения_скидки] DATETIME        NOT NULL,
    [Объект_скидки]                BIT             NOT NULL,
    [Номер_скидки]                 INT             NOT NULL,
    [Режим_скидки]                 INT             NOT NULL,
    [Тип_скидки]                   INT             NOT NULL,
    [Ставка_скидки]                DECIMAL (13, 2) NOT NULL,
    [Сумма_скидки]                 MONEY           NOT NULL,
    [Сумма_чека]                   MONEY           NOT NULL,
    [Номер_дисконтной_карты]       NVARCHAR (200)  NULL,
    [Название_дисконтной_карты]    NVARCHAR (200)  NULL,
    [ИД_кнопки]                    INT             NULL,
    [ИД_карты]                     INT             NULL,
    [Составной_код_позиции]        NVARCHAR (20)   NOT NULL,
    CONSTRAINT [FK_t_fact_Скидки_t_fact_Детализация_чеков] FOREIGN KEY ([Составной_код_позиции]) REFERENCES [cass].[t_fact_Детализация_чеков] ([Составной_код_позиции]) ON DELETE CASCADE
) ON [FACTS];


GO
CREATE CLUSTERED INDEX [ix_cl_ИД_позиции]
    ON [cass].[t_fact_Скидки]([Составной_код_позиции] ASC)
    ON [FACTS];


GO

CREATE INDEX [ix_uncl_Скидки_Дата] ON [cass].[t_fact_Скидки] ([Дата_время_применения_скидки]) ON [FACTS];

GO

CREATE INDEX [ix_uncl_Скидки_Измерения] ON [cass].[t_fact_Скидки] (Код_товара, Код_кассы) ON [FACTS];
