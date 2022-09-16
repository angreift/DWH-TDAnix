CREATE TABLE [cass].[t_raw_fsk_Оплаты] (
    [ИД_документа]    INT   NOT NULL,
    [Код_типа_оплаты] INT   NOT NULL,
    [Сумма_оплаты]    MONEY NOT NULL
) ON [RAW];

