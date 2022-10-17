CREATE VIEW [td].[v_fact_Товарная_матрица]
	AS SELECT        dbo.t_dim_Календарь.ИД_дата AS Дата, t_m.Код_магазина, t_t.Код_товара,
                             (SELECT        TOP (1) Признак
                               FROM            td.t_fact_Товарная_матрица AS ТовМат
                               WHERE        (Дата <= Дата) AND (Код_магазина = t_m.Код_магазина) AND (Код_товара = t_t.Код_товара)) AS Признак,
                             (SELECT        TOP (1) Код_поставщика
                               FROM            td.t_fact_Товарная_матрица AS ТовМат
                               WHERE        (Дата <= Дата) AND (Код_магазина = t_m.Код_магазина) AND (Код_товара = t_t.Код_товара)) AS Код_поставщика
FROM            dbo.t_dim_Календарь CROSS JOIN
                             (SELECT DISTINCT Код_магазина
                               FROM            td.t_fact_Товарная_матрица) AS t_m CROSS JOIN
                             (SELECT DISTINCT Код_товара
                               FROM            td.t_fact_Товарная_матрица AS t_fact_Товарная_матрица_1) AS t_t
