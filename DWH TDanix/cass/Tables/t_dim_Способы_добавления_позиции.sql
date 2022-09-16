CREATE TABLE [cass].[t_dim_Способы_добавления_позиции] (
    [ИД_способа_добавления_позиции] TINYINT        NOT NULL,
    [Наименование]                  NVARCHAR (200) NOT NULL,
    CONSTRAINT [PK_t_dim_Способы_добаления_позиции] PRIMARY KEY CLUSTERED ([ИД_способа_добавления_позиции] ASC) ON [DIMENTIONS]
) ON [DIMENTIONS];

