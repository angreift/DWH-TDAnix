CREATE TABLE [dbo].[t_dim_Форматы_магазинов]
(
	[Код_формата_магазина] NVARCHAR(6) NOT NULL, 
    [Наименование_формата_магазина] NVARCHAR(50) NOT NULL,
 CONSTRAINT [PK_t_dim_Форматы_магазинов] PRIMARY KEY CLUSTERED ([Код_формата_магазина] ASC) ON [DIMENTIONS]
) ON [DIMENTIONS];