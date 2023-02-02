-- Справочник из ОТБРС Клиенты.[Поставщики поставщиков]

CREATE TABLE [dbo].[t_dim_Поставщики_холдинга]
(
	[Код_поставщика_холдинга] int not null,
	[Наименование] nvarchar(40) not null,
	[ИНН] nvarchar(20) null,
	[КПП] nvarchar(19) null,
	Constraint [pk_t_dim_Поставщики_холдинга] primary key clustered ([Код_поставщика_холдинга] asc) on [DIMENTIONS]
) on [DIMENTIONS]