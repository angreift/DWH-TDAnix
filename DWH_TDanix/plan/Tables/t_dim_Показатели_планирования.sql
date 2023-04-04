CREATE TABLE [plan].[t_dim_Показатели_планирования]
(
	[Код_показателя_планирования] int not null,
	[Наименование] nvarchar(50) not null,
	[Комментарий] nvarchar(99) null,
	Constraint [PK_t_dim_Показатели_планирования] primary key clustered 
	([Код_показателя_планирования] ASC) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [DIMENTIONS]
) on [DIMENTIONS]
