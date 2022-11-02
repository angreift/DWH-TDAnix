﻿CREATE VIEW [cass].[v_fact_Детализация_чеков]
AS
SELECT               cass.t_fact_Детализация_чеков.Код_кассы, cass.t_fact_Детализация_чеков.Дата_время_добавления_позиции, cass.t_fact_Детализация_чеков.Способ_добавления_позиции, 
                         cass.t_fact_Детализация_чеков.Количество, cass.t_fact_Детализация_чеков.Способ_ввода_количества, cass.t_fact_Детализация_чеков.Цена, cass.t_fact_Детализация_чеков.Минимальная_цена, 
                         cass.t_fact_Детализация_чеков.Цена_позиции, cass.t_fact_Детализация_чеков.Способ_ввода_цены, cass.t_fact_Детализация_чеков.Сумма_скидки, 
                         cass.t_fact_Детализация_чеков.Начальная_сумма_до_применения_скидок, cass.t_fact_Детализация_чеков.Итоговая_сумма_после_применения_скидок, cass.t_fact_Детализация_чеков.Номер_позиции_в_чеке, 
                         cass.t_fact_Детализация_чеков.Сумма_Наличные, cass.t_fact_Детализация_чеков.Сумма_Терминал, cass.t_fact_Детализация_чеков.Сумма_СБП_Сбербанк, 
                         cass.t_fact_Детализация_чеков.Сумма_оплаты_Неинтегрированный_терминал_СБ, cass.t_fact_Детализация_чеков.Сумма_оплаты_Накопительные_карты, cass.t_fact_Детализация_чеков.Возврат, 
                         CASE WHEN cass.t_fact_Детализация_чеков.Возврат = 1 THEN cass.t_fact_Детализация_чеков.Количество * - 1 ELSE cass.t_fact_Детализация_чеков.Количество END AS Количество_с_учетом_возвратов, 
                         CASE WHEN cass.t_fact_Детализация_чеков.Возврат = 1 THEN cass.t_fact_Детализация_чеков.Сумма_скидки * - 1 ELSE cass.t_fact_Детализация_чеков.Сумма_скидки END AS Сумма_скидки_с_учетом_возвратов, 
                         CASE WHEN cass.t_fact_Детализация_чеков.Возврат = 1 THEN cass.t_fact_Детализация_чеков.Начальная_сумма_до_применения_скидок * - 1 ELSE cass.t_fact_Детализация_чеков.Начальная_сумма_до_применения_скидок
                          END AS Начальная_сумма_до_применения_скидок_с_учетом_возвратов, 
                         CASE WHEN cass.t_fact_Детализация_чеков.Возврат = 1 THEN cass.t_fact_Детализация_чеков.Итоговая_сумма_после_применения_скидок * - 1 ELSE cass.t_fact_Детализация_чеков.Итоговая_сумма_после_применения_скидок
                          END AS Итоговая_сумма_после_применения_скидок_с_учетом_возвратов, 
                         CASE WHEN cass.t_fact_Детализация_чеков.Возврат = 1 THEN cass.t_fact_Детализация_чеков.Сумма_наличные * - 1 ELSE cass.t_fact_Детализация_чеков.Сумма_наличные END AS Сумма_наличные_с_учетом_возвратов,
                          CASE WHEN cass.t_fact_Детализация_чеков.Возврат = 1 THEN cass.t_fact_Детализация_чеков.Сумма_Терминал * - 1 ELSE cass.t_fact_Детализация_чеков.Сумма_Терминал END AS Сумма_Терминал_с_учетом_возвратов,
                          CASE WHEN cass.t_fact_Детализация_чеков.Возврат = 1 THEN cass.t_fact_Детализация_чеков.Сумма_СБП_Сбербанк * - 1 ELSE cass.t_fact_Детализация_чеков.Сумма_СБП_Сбербанк END AS Сумма_СБП_Сбербанк_с_учетом_возвратов,
                          CASE WHEN cass.t_fact_Детализация_чеков.Возврат = 1 THEN cass.t_fact_Детализация_чеков.Сумма_оплаты_Неинтегрированный_терминал_СБ * - 1 ELSE cass.t_fact_Детализация_чеков.Сумма_оплаты_Неинтегрированный_терминал_СБ
                          END AS Сумма_оплаты_Неинтегрированный_терминал_СБ_с_учетом_возвратов, 
                         CASE WHEN cass.t_fact_Детализация_чеков.Возврат = 1 THEN cass.t_fact_Детализация_чеков.Сумма_оплаты_Накопительные_карты * - 1 ELSE cass.t_fact_Детализация_чеков.Сумма_оплаты_Накопительные_карты END
                          AS Сумма_оплаты_Накопительные_карты_с_учетом_возвратов, cass.t_fact_Детализация_чеков.Составной_код_кассира, CAST(CAST(cass.t_fact_Детализация_чеков.Дата_время_добавления_позиции AS date) 
                         AS datetime) AS Дата_добавления_позиции, cass.t_dim_Кассы.Код_магазина, cass.t_fact_Детализация_чеков.Составной_код_документа, cass.t_fact_Чеки.Составной_код_смены, dbo.t_dim_Товары.Код_товара, 
                         COALESCE
                             ((SELECT        TOP (1) Признак
                                 FROM            td.t_fact_Товарная_матрица AS м
                                 WHERE        (Дата <= cass.t_fact_Детализация_чеков.Дата_добавления_позиции) AND (Код_товара = cass.t_fact_Детализация_чеков.Код_товара) AND (Код_магазина = cass.t_dim_Кассы.Код_магазина)
                                 ORDER BY Дата desc), 0) 
                         AS Признак,
                             COALESCE( (SELECT        TOP (1) Код_поставщика
								   FROM            td.t_fact_Товарная_матрица AS м
								   WHERE        (Дата <=Дата_добавления_позиции) AND (Код_магазина = cass.t_dim_Кассы.Код_магазина) AND (Код_товара = cass.t_fact_Детализация_чеков.Код_товара)
								   ORDER BY Дата DESC), -1) AS Код_поставщика
FROM            cass.t_fact_Детализация_чеков INNER JOIN
                         cass.t_dim_Кассы WITH (nolock) ON cass.t_fact_Детализация_чеков.Код_кассы = cass.t_dim_Кассы.Код_кассы INNER JOIN
                         cass.t_fact_Чеки ON cass.t_fact_Детализация_чеков.Составной_код_документа = cass.t_fact_Чеки.Составной_код_документа LEFT OUTER JOIN
                         dbo.t_dim_Товары WITH (nolock) ON cass.t_fact_Детализация_чеков.Код_товара = dbo.t_dim_Товары.Код_товара
GO