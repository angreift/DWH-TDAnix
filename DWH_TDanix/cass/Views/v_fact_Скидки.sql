CREATE VIEW [cass].[v_fact_Скидки]
AS
SELECT        cass.t_fact_Скидки.Код_кассы, cass.t_fact_Скидки.ИД_скидки, cass.t_fact_Скидки.Номер_позиции, cass.t_fact_Скидки.Дата_время_применения_скидки, cass.t_fact_Скидки.Объект_скидки, 
                         cass.t_fact_Скидки.Номер_скидки, cass.t_fact_Скидки.Режим_скидки, cass.t_fact_Скидки.Тип_скидки, cass.t_fact_Скидки.Ставка_скидки, cass.t_fact_Скидки.Сумма_скидки, cass.t_fact_Скидки.Сумма_чека, 
                         cass.t_fact_Скидки.Номер_дисконтной_карты, cass.t_fact_Скидки.Название_дисконтной_карты, cass.t_fact_Скидки.ИД_карты, cass.t_fact_Скидки.Составной_код_кассира, 
                         CAST(CAST(cass.t_fact_Скидки.Дата_время_применения_скидки AS date) AS datetime) AS Дата_применения_скидки, cass.t_dim_Кассы.Код_магазина, cass.t_fact_Детализация_чеков.Составной_код_документа, 
                         dbo.t_dim_Товары.Код_товара, 
                         COALESCE
                             ((SELECT        TOP (1) Признак
                                 FROM            td.t_fact_Товарная_матрица AS м
                                 WHERE        (Дата <= cass.t_fact_Скидки.[Дата_применения_скидки]) AND (Код_товара = cass.t_fact_Скидки.Код_товара) AND (Код_магазина = cass.t_dim_Кассы.Код_магазина)), 0) 
                         AS Признак,
                             (SELECT        TOP (1) Код_поставщика
                               FROM            td.t_fact_Товарная_матрица AS м
                               WHERE        (Дата <= cass.t_fact_Скидки.[Дата_применения_скидки]) AND (Код_товара = cass.t_fact_Скидки.Код_товара) AND (Код_магазина = cass.t_dim_Кассы.Код_магазина)) 
                         AS Код_поставщика
FROM            cass.t_fact_Скидки INNER JOIN
                         cass.t_dim_Кассы with (nolock) ON cass.t_fact_Скидки.Код_кассы = cass.t_dim_Кассы.Код_кассы INNER JOIN
                         cass.t_fact_Детализация_чеков ON cass.t_fact_Скидки.Составной_код_позиции = cass.t_fact_Детализация_чеков.Составной_код_позиции LEFT OUTER JOIN
                         dbo.t_dim_Товары with (nolock) ON cass.t_fact_Скидки.Код_товара = dbo.t_dim_Товары.Код_товара
GO


