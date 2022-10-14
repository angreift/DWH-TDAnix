CREATE TABLE [dbo].[t_dim_Поставщики]
(
	[Код] INT NOT NULL PRIMARY KEY, 
    [Наименование] nvarchar(100) NOT NULL,
    [ИНН] BIGINT NULL, 
    [КПП] BIGINT NULL, 
    [Адрес] nvarchar(200) NULL, 
    [Ответственное_лицо] nvarchar(100) NULL, 
    [Автозаявка] BIT NULL

) on [DIMENTIONS];
