﻿CREATE VIEW [plan].[v_fact_Планы_СА_по_магазинам]
	AS SELECT 
		Дата,
		Код_магазина,
		Товарооборот,
		Количество_чеков,
		Валовый_доход,
		Товарооборот_СТМ,
		Производительность,
		Потребление_ЭЭ_без_ГВ_и_субаренды,
		Потери,
		Производительность_ГВ
	FROM [plan].[t_fact_Планы_СА_по_магазинам]
