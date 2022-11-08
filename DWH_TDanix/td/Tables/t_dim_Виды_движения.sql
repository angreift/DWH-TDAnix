CREATE TABLE [td].[t_dim_Виды_движения]
(
	[Код_вида_движения] TINYINT NOT NULL PRIMARY KEY, 
    [Наименование_вида_движения] NVARCHAR(50) NOT NULL
) ON DIMENTIONS
