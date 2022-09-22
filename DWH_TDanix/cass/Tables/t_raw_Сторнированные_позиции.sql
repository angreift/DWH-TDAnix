CREATE TABLE [cass].[t_raw_Сторнированные_позиции] (
    [ИД_сторнированной_позиции]              INT             NOT NULL,
    [ИД_документа]                           INT             NOT NULL,
    [Код_кассира]                            NVARCHAR (30)   NOT NULL,
    [Дата_время_добавления_позиции]          DATETIME        NOT NULL,
    [Дата_время_сторнирования_позиции]       DATETIME        NOT NULL,
    [Способ_добавления_позиции]              TINYINT             NOT NULL,
    [Количество]                             DECIMAL (13, 3) NOT NULL,
    [Способ_ввода_количества]                TINYINT             NOT NULL,
    [Цена]                                   MONEY           NOT NULL,
    [Минимальная_цена]                       MONEY           NOT NULL,
    [Цена_позиции]                           MONEY           NOT NULL,
    [Способ_ввода_цены]                      INT             NOT NULL,
    [Сумма_скидки]                           MONEY           NOT NULL,
    [Начальная_сумма_до_применения_скидок]   MONEY           NOT NULL,
    [Итоговая_сумма_после_применения_скидок] MONEY           NOT NULL,
    [Код_товара]                             VARCHAR (100)   NOT NULL,
    [Номер_сторнированной_позиции]           INT             NOT NULL,
    [Пользователь_подтвердивший_операцию]    INT             NULL
) ON [RAW];

