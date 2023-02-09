﻿CREATE VIEW [td].[v_fact_Товародвижение]
AS
SELECT        td.t_fact_Товародвижение.Дата, td.t_fact_Товародвижение.Код_магазина, td.t_fact_Товародвижение.Склад_в_магазине, td.t_dim_Склад_в_магазине.Наименование_склада, 
                         td.t_dim_Склад_в_магазине.Представление_склада, td.t_fact_Товародвижение.ВидДвижения, td.t_dim_Виды_движения.Наименование_вида_движения, td.t_fact_Товародвижение.Код_причины, 
                         td.t_dim_Причины.Наименование_причины, td.t_dim_Причины.Код_категории, td.t_dim_Причины.Наименование_категории, td.t_fact_Товародвижение.Код_товара, td.t_fact_Товародвижение.Сумма, 
                         td.t_fact_Товародвижение.СуммаЗакупа, td.t_fact_Товародвижение.СуммаЗакупаСоСклада, 
                         CASE WHEN td.t_fact_Товародвижение.Количество = 0 THEN 0 ELSE CAST(td.t_fact_Товародвижение.Сумма / td.t_fact_Товародвижение.Количество AS decimal(15, 2)) END AS Цена, 
                         CASE WHEN td.t_fact_Товародвижение.Количество = 0 THEN 0 ELSE CAST(td.t_fact_Товародвижение.СуммаЗакупа / td.t_fact_Товародвижение.Количество AS decimal(15, 2)) END AS ЦенаЗакупа, 
                         CASE WHEN td.t_fact_Товародвижение.Количество = 0 THEN 0 ELSE CAST(td.t_fact_Товародвижение.СуммаЗакупаСоСклада / td.t_fact_Товародвижение.Количество AS decimal(15, 2)) END AS ЦенаЗакупаСоСклада, 
                         td.t_fact_Товародвижение.Количество, td.t_fact_Товародвижение.Поставщик, td.t_fact_Товародвижение.Признак,
                        -- Не будем выводить null, чтобы не генерировать ошибку при обработке куба
                        Coalesce(Поставщик_холдинга, '(Не задан)') Поставщик_холдинга,
                        Coalesce(Важный_товар, cast(0 as bit)) Важный_товар,
                        Coalesce(Сценарий_важного_товара, -1) Сценарий_важного_товара
FROM            td.t_fact_Товародвижение INNER JOIN
                         td.t_dim_Виды_движения ON td.t_fact_Товародвижение.ВидДвижения = td.t_dim_Виды_движения.Код_вида_движения INNER JOIN
                         td.t_dim_Склад_в_магазине ON td.t_fact_Товародвижение.Склад_в_магазине = td.t_dim_Склад_в_магазине.Код_склада INNER JOIN
                         td.t_dim_Причины ON td.t_fact_Товародвижение.Код_причины = td.t_dim_Причины.Код_причины
GO