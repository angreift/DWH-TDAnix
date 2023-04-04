CREATE TABLE [plan].[t_dim_Показатели_для_сравнительного_анализа]
(
	[Код_показателя_для_сравнительного_анализа] int identity(1, 1),
	[Наименование] nvarchar(50) not null,
	[Вид_показателя] nvarchar(50) null,
	[Наименование_в_отчете] nvarchar(50) null,
	constraint [pk_t_dim_Показатели_для_сравнительного_анализа] primary key clustered 
	([Код_показателя_для_сравнительного_анализа] ASC) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [DIMENTIONS]
)
GO

Create nonclustered index [ix_uncl_Наименование] on [plan].[t_dim_Показатели_для_сравнительного_анализа]([Наименование]) on [DIMENTIONS]
GO
