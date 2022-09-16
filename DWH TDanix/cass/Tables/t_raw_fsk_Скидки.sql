CREATE TABLE [cass].[t_raw_fsk_Скидки] (
    [ИД_скидки]                    INT             NOT NULL,
    [ИД_позиции]                   INT             NOT NULL,
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
    [ИД_карты]                     INT             NULL
) ON [RAW];

