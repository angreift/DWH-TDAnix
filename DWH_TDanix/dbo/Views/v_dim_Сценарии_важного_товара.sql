CREATE VIEW [dbo].[v_dim_Сценарии_важного_товара]
	AS SELECT Код_сценария, Сценарий_важного_товара FROM dbo.t_dim_Сценарии_важного_товара
	UNION select -1, '(Не задано)'