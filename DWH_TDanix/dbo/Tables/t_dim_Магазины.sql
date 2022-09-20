CREATE TABLE [dbo].[t_dim_Магазины] (
    [Код]                       INT           NOT NULL,
    [Группа]                    NVARCHAR (50)  NOT NULL,
    [Наименование]              NVARCHAR (100) NOT NULL,
    [Адрес]                     NVARCHAR (300) NULL,
    [Город]                     NVARCHAR (50)  NULL,
    [График_ПРАЙД]              TINYINT       NULL,
    [Дата_закрытия]             DATETIME      NULL,
    [Дата_открытия]             DATETIME      NULL,
    [ИНН]                       NVARCHAR (30)   NULL,
    [Категория_по_площади]      TINYINT       NULL,
    [КПП]                       NVARCHAR (30)           NULL,
    [Куст]                      NVARCHAR (50)  NULL,
    [Ответственный]             NVARCHAR (50)  NULL,
    [Отчёт]                     BIT           NULL,
    [Регион]                    NVARCHAR (50)  NULL,
    [Дата_начала_реконструкции] DATETIME      NULL,
    [Дата_конца_реконструкции]  DATETIME      NULL,
    [Бренд_магазина]            NVARCHAR (50)  NULL,
    [Технолог_СП]               NVARCHAR (50)  NULL,
    CONSTRAINT [ix_cl_pk_Код] PRIMARY KEY CLUSTERED ([Код] ASC) ON [DIMENTIONS]
) ON [DIMENTIONS];

