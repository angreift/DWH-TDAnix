CREATE TABLE [dbo].[t_dim_Сопоставление_классификатора_Альянс]
(
	[Код_товара] bigint not null,
	[Составной_код_Альянс] nvarchar(25),
	constraint [PK_t_dim_Сопоставление_классификатора_Альянс] primary key clustered ([Код_товара] asc) on [DIMENTIONS]
) ON [DIMENTIONS]
