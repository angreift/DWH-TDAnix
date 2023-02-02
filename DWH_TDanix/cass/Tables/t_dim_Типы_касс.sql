CREATE TABLE [cass].[t_dim_Типы_касс]
(
	[Код_типа_кассы] NVARCHAR(7) NOT NULL,
	[Наименование] NVARCHAR(30) NULL,
	CONSTRAINT [PK_t_dim_Типы_касс] PRIMARY KEY CLUSTERED ([Код_типа_кассы] ASC) ON [DIMENTIONS]
) ON [DIMENTIONS];
