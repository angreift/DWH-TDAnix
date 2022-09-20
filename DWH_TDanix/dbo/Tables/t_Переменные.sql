CREATE TABLE [dbo].[t_Переменные] (
    [Наименование_переменной] NVARCHAR (50)  NOT NULL,
    [Значение_string]         NVARCHAR (MAX) NULL,
    [Значение_int]            INT            NULL,
    [Значение_datetime]       DATETIME       NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [ix_uncl_Наименование_переменной]
    ON [dbo].[t_Переменные]([Наименование_переменной] ASC);

