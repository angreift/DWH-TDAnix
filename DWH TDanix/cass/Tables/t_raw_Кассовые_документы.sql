CREATE TABLE [cass].[t_raw_Кассовые_документы] (
    [ИД_документа]               INT           NOT NULL,
    [ИД_смены]                   INT           NOT NULL,
    [Номер_чека]                 INT           NOT NULL,
    [Код_кассира]                NVARCHAR (30) NOT NULL,
    [Дата_время_открытия_чека]   DATETIME      NOT NULL,
    [Дата_время_закрытия_чека]   DATETIME      NOT NULL,
    [Возврат]                    BIT           NOT NULL,
    [Сумма_без_скидок]           MONEY         NOT NULL,
    [Итоговая_сумма_со_скидками] MONEY         NOT NULL,
    [Печать_чека]                BIT           NOT NULL,
    CONSTRAINT [PK_t_raw_Кассовые_документы] PRIMARY KEY CLUSTERED ([ИД_документа] ASC) ON [RAW]
) ON [RAW];

