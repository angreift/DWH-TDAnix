CREATE TABLE [dbo].[t_j_Общий_журнал] (
    [Код_события]          BIGINT         IDENTITY (1, 1) NOT NULL,
    [Дата_время_события]   DATETIME       NOT NULL,
    [Тип_события]          TINYINT        NOT NULL,
    [Наименование_объекта] NVARCHAR (128) NULL,
    [Сообщение]            NVARCHAR (MAX) NOT NULL,
    [Имя_пользователя]     NVARCHAR (100) NULL,
    CONSTRAINT [PK_t_j_Общий_журнал] PRIMARY KEY CLUSTERED ([Код_события] ASC) ON [JOURNAL]
) ON [JOURNAL] TEXTIMAGE_ON [JOURNAL];

