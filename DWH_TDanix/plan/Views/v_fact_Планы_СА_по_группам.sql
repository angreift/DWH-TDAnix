﻿CREATE VIEW [plan].[v_fact_Планы_СА_по_группам]
	AS SELECT 
		Дата, Код_магазина, Код_показателя_для_сравнительного_анализа, Значение
	FROM [plan].[t_fact_Планы_СА_по_группам]