CREATE TABLE [dbo].[t_dim_Магазины] (
    [Код]                       INT           NOT NULL,
    [Группа]                    VARCHAR (50)  NOT NULL,
    [Наименование]              VARCHAR (100) NOT NULL,
    [Адрес]                     VARCHAR (300) NULL,
    [Город]                     VARCHAR (50)  NULL,
    [График_ПРАЙД]              TINYINT       NULL,
    [Дата_закрытия]             DATETIME      NULL,
    [Дата_открытия]             DATETIME      NULL,
    [ИНН]                       BIGINT        NULL,
    [Категория_по_площади]      TINYINT       NULL,
    [КПП]                       INT           NULL,
    [Куст]                      VARCHAR (50)  NULL,
    [Ответственный]             VARCHAR (50)  NULL,
    [Отчёт]                     BIT           NULL,
    [Регион]                    VARCHAR (50)  NULL,
    [Дата_начала_реконструкции] DATETIME      NULL,
    [Дата_конца_реконструкции]  DATETIME      NULL,
    [Бренд_магазина]            VARCHAR (50)  NULL,
    [Технолог_СП]               VARCHAR (50)  NULL,
    CONSTRAINT [ix_cl_pk_Код] PRIMARY KEY CLUSTERED ([Код] ASC) ON [DIMENTIONS]
) ON [DIMENTIONS];

