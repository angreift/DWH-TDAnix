CREATE TABLE [cass].[t_dim_Пользователи_на_кассах] (
    [Код_кассы]             INT            NOT NULL,
    [Код_кассира]           INT            NOT NULL,
    [Логин_пользователя]    NVARCHAR (100) NOT NULL,
    [Имя_пользователя]      NVARCHAR (50)  NOT NULL,
    [Запрещена_авторизация] BIT            NOT NULL,
    [Должность]             NVARCHAR (30)  NULL,
    [ИНН]                   NVARCHAR (20)  NULL
) ON [DIMENTIONS];


GO
CREATE UNIQUE CLUSTERED INDEX [ix_cl_Код_кассы_Код_кассира]
    ON [cass].[t_dim_Пользователи_на_кассах]([Код_кассы] ASC, [Код_кассира] ASC)
    ON [DIMENTIONS];

