CREATE TABLE [cass].[t_dim_Способы_ввода_количества] (
    [ИД_способа_ввода_количества] TINYINT        NOT NULL,
    [Наименование]                NVARCHAR (200) NOT NULL,
    CONSTRAINT [PK_t_dim_Способы_ввода_количества] PRIMARY KEY CLUSTERED ([ИД_способа_ввода_количества] ASC) ON [DIMENTIONS]
) ON [DIMENTIONS];

