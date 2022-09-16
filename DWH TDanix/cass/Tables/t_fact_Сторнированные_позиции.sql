CREATE TABLE [cass].[t_fact_Сторнированные_позиции] (
    [Код_кассы]                                    INT             NOT NULL,
    [ИД_сторнированной_позиции]                    INT             NOT NULL,
    [ИД_документа]                                 INT             NOT NULL,
    [Код_кассира]                                  INT             NOT NULL,
    [Дата_время_добавления_сторнированной_позиции] DATETIME        NOT NULL,
    [Дата_время_сторнирования_позиции]             DATETIME        NOT NULL,
    [Способ_добавления_позиции]                    INT             NOT NULL,
    [Количество]                                   DECIMAL (13, 3) NOT NULL,
    [Способ_ввода_количества]                      INT             NOT NULL,
    [Цена]                                         MONEY           NOT NULL,
    [Минимальная_цена]                             MONEY           NOT NULL,
    [Цена_позиции]                                 MONEY           NOT NULL,
    [Способ_ввода_цены]                            INT             NOT NULL,
    [Сумма_скидки]                                 MONEY           NOT NULL,
    [Начальная_сумма_до_применения_скидок]         MONEY           NOT NULL,
    [Итоговая_сумма_после_применения_скидок]       MONEY           NOT NULL,
    [Код_товара]                                   BIGINT          NOT NULL,
    [Номер_сторнированной_позиции]                 INT             NOT NULL,
    [Пользователь_подтвердивший_операцию]          INT             NULL,
    [Составной_код_документа]                      NVARCHAR (20)   NOT NULL,
    CONSTRAINT [FK_t_fact_Сторнированные_позиции_t_fact_Чеки] FOREIGN KEY ([Составной_код_документа]) REFERENCES [cass].[t_fact_Чеки] ([Составной_код_документа]) ON DELETE CASCADE
) ON [FACTS];


GO
CREATE CLUSTERED INDEX [ix_cl_ИД_док]
    ON [cass].[t_fact_Сторнированные_позиции]([Составной_код_документа] ASC)
    ON [FACTS];

