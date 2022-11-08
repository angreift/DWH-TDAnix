CREATE TABLE [td].[t_dim_Склад_в_магазине]
(
	[Код_склада] INT NOT NULL IDENTITY(1,1) PRIMARY KEY, 
    [Наименование_склада] NVARCHAR(100) NOT NULL, 
    [Представление_склада] NVARCHAR(100) NULL
) on [DIMENTIONS]
