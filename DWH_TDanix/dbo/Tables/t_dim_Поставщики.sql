CREATE TABLE [dbo].[t_dim_Поставщики](
	[Код] [int] NOT NULL,
	[Наименование] [nvarchar](100) NOT NULL,
	[ИНН] [bigint] NULL,
	[КПП] [bigint] NULL,
	[Адрес] [nvarchar](200) NULL,
	[Ответственное_лицо] [nvarchar](100) NULL,
	[Автозаявка] [bit] NULL,
	[Код_РСФ] INT NULL, 
    PRIMARY KEY CLUSTERED 
(
	[Код] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [DIMENTIONS]
) ON [DIMENTIONS]
GO

CREATE NONCLUSTERED INDEX [ix_uncl_Код_РСФ] ON [dbo].[t_dim_Поставщики]
(
	[Код_РСФ] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [DIMENTIONS]
GO