CREATE TABLE [dbo].[t_dim_Классификатор_Альянс]
(
	[Составной_код] nvarchar(25) not null,
	[Код_сектора] nvarchar(9) not null,
	[Наименование_сектора] nvarchar(99) not null,
	[Код_отдела] nvarchar(9) not null,
	[Наименование_отдела] nvarchar(99) not null,
	[Код_направления] nvarchar(9) not null,
	[Наименование_направления] nvarchar(99) not null,
	[Код_группы] nvarchar(9) not null,
	[Наименование_группы] nvarchar(99) not null,
	[Код_подгруппы] nvarchar(9) not null,
	[Наименование_подгруппы] nvarchar(99) not null,
	Constraint [PK_t_dim_Классификатор_Альянс] PRIMARY KEY CLUSTERED ([Составной_код] asc) on [DIMENTIONS] 
) on [DIMENTIONS]
