CREATE TABLE [cass].[t_raw_fsk_Пользователи] (
    [Код_кассира]           NVARCHAR (30)  NOT NULL,
    [Логин_пользователя]    NVARCHAR (100) NOT NULL,
    [Имя_пользователя]      NVARCHAR (50)  NOT NULL,
    [Запрещена_авторизация] BIT            NOT NULL,
    [Должность]             NVARCHAR (30)  NULL,
    [ИНН]                   NVARCHAR (20)  NULL,
    CONSTRAINT [PK_t_raw_fsk_Пользователи] PRIMARY KEY CLUSTERED ([Код_кассира] ASC) ON [RAW]
) ON [RAW];

