CREATE TABLE [cass].[t_raw_fsk_Позиции_документа] (
    [ИД_позиции]                                  INT             NOT NULL,
    [ИД_документа]                                INT             NOT NULL,
    [Код_кассира]                                 NVARCHAR (30)   NOT NULL,
    [Дата_время_добавления_позиции]               DATETIME        NOT NULL,
    [Способ_добавления_позиции]                   INT             NOT NULL,
    [Количество]                                  DECIMAL (13, 3) NOT NULL,
    [Способ_ввода_количества]                     INT             NOT NULL,
    [Цена]                                        MONEY           NOT NULL,
    [Минимальная_цена]                            MONEY           NOT NULL,
    [Цена_позиции]                                MONEY           NOT NULL,
    [Способ_ввода_цены]                           INT             NOT NULL,
    [Сумма_скидки]                                MONEY           NOT NULL,
    [Начальная_сумма_до_применения_скидок]        MONEY           NOT NULL,
    [Итоговая_сумма_после_применения_всех_скидок] MONEY           NOT NULL,
    [Код_товара]                                  VARCHAR (100)   NOT NULL,
    [Номер_позиции]                               INT             NOT NULL,
    [Возврат]                                     BIT             NOT NULL,
    CONSTRAINT [PK_t_raw_fsk_Позиции_документа] PRIMARY KEY CLUSTERED ([ИД_позиции] ASC) ON [RAW]
) ON [RAW];

