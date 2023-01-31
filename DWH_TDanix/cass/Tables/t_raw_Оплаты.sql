CREATE TABLE [cass].[t_raw_Оплаты] (
    [ИД_документа]    INT   NOT NULL,
    [Код_типа_оплаты] INT   NOT NULL,
    [Сумма_оплаты]    MONEY NOT NULL, 
    [Номер_банковской_карты] NCHAR(100) NULL
) ON [RAW];

