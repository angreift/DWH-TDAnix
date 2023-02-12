CREATE VIEW [dbo].[v_dim_Сценарии_важного_товара]
	AS SELECT Код_сценария, Сценарий_важного_товара, cast(1 as bit) Важный_товар FROM dbo.t_dim_Сценарии_важного_товара
	UNION select -1, '(Не задано)', cast(1 as bit)
	UNION select -1, '(Не задано)', cast(0 as bit)