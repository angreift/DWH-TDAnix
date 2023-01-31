CREATE TABLE [dbo].[t_dim_Поставщики](
	[Код] [int] NOT NULL,
	[Наименование] [nvarchar](100) NOT NULL,
	[ИНН] [bigint] NULL,
	[КПП] [bigint] NULL,
	[Адрес] [nvarchar](200) NULL,
	[Ответственное_лицо] [nvarchar](100) NULL,
	[Автозаявка] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[Код] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [DIMENTIONS]
) ON [DIMENTIONS]
GO