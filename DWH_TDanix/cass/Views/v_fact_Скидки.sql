CREATE VIEW [cass].[v_fact_Скидки]
AS
SELECT        cass.t_fact_Скидки.Код_кассы, cass.t_fact_Скидки.ИД_скидки, cass.t_fact_Скидки.Номер_позиции, cass.t_fact_Скидки.Дата_время_применения_скидки, cass.t_fact_Скидки.Объект_скидки, 
                         cass.t_fact_Скидки.Номер_скидки, cass.t_fact_Скидки.Режим_скидки, cass.t_fact_Скидки.Тип_скидки, cass.t_fact_Скидки.Ставка_скидки, cass.t_fact_Скидки.Сумма_скидки, cass.t_fact_Скидки.Сумма_чека, 
                         cass.t_fact_Скидки.Номер_дисконтной_карты, cass.t_fact_Скидки.Название_дисконтной_карты, cass.t_fact_Скидки.ИД_карты, cass.t_fact_Скидки.Составной_код_кассира, 
                         CAST(CAST(cass.t_fact_Скидки.Дата_время_применения_скидки AS date) AS datetime) AS Дата_применения_скидки, cass.t_dim_Кассы.Код_магазина, cass.t_fact_Детализация_чеков.Составной_код_документа, 
                         dbo.t_dim_Товары.Код_товара, case when td.v_fact_Товарная_матрица.Признак is null then 0 else td.v_fact_Товарная_матрица.Признак end as Признак, td.v_fact_Товарная_матрица.Код_поставщика
FROM            cass.t_fact_Скидки INNER JOIN
                         cass.t_dim_Кассы ON cass.t_fact_Скидки.Код_кассы = cass.t_dim_Кассы.Код_кассы INNER JOIN
                         cass.t_fact_Детализация_чеков ON cass.t_fact_Скидки.Составной_код_позиции = cass.t_fact_Детализация_чеков.Составной_код_позиции LEFT OUTER JOIN
                         td.v_fact_Товарная_матрица ON cass.t_fact_Скидки.Дата_применения_скидки = td.v_fact_Товарная_матрица.Дата AND cass.t_fact_Скидки.Код_товара = td.v_fact_Товарная_матрица.Код_товара AND 
                         cass.t_dim_Кассы.Код_магазина = td.v_fact_Товарная_матрица.Код_магазина LEFT OUTER JOIN
                         dbo.t_dim_Товары ON cass.t_fact_Скидки.Код_товара = dbo.t_dim_Товары.Код_товара
GO


