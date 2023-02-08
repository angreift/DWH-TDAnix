CREATE TABLE [dbo].[t_dim_Сценарии_важного_товара]
(
	Код_сценария int not null identity(1,1),
	Сценарий_важного_товара  nvarchar(64)
) on [DIMENTIONS]

-- Пока не делаю индексов, так как таблица очень маленькая
