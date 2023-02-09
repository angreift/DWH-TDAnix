CREATE VIEW [cass].[v_fact_Скидки]
AS
SELECT        cass.t_fact_Скидки.Код_кассы, cass.t_fact_Скидки.ИД_скидки, cass.t_fact_Скидки.Номер_позиции, cass.t_fact_Скидки.Дата_время_применения_скидки, cass.t_fact_Скидки.Объект_скидки, 
                         cass.t_fact_Скидки.Номер_скидки, cass.t_fact_Скидки.Режим_скидки, cass.t_fact_Скидки.Тип_скидки, cass.t_fact_Скидки.Ставка_скидки, 
                         cass.t_fact_Скидки.Сумма_скидки * case when cass.t_fact_Чеки.Возврат = 1 then -1 else 1 end Сумма_скидки, cass.t_fact_Скидки.Сумма_чека, 
                         cass.t_fact_Скидки.Номер_дисконтной_карты, cass.t_fact_Скидки.Название_дисконтной_карты, cass.t_fact_Скидки.ИД_карты, cass.t_fact_Скидки.Составной_код_кассира, 
                         cass.t_fact_Скидки.Дата_применения_скидки, cass.t_dim_Кассы.Код_магазина, cass.t_fact_Детализация_чеков.Составной_код_документа, 
                         dbo.t_dim_Товары.Код_товара, 
                         COALESCE
                             ((SELECT        TOP (1) Признак
                                 FROM            td.t_fact_Товарная_матрица AS м
                                 WHERE        (Дата <= cass.t_fact_Скидки.[Дата_применения_скидки]) AND (Код_товара = cass.t_fact_Скидки.Код_товара) AND (Код_магазина = cass.t_dim_Кассы.Код_магазина)
                                 ORDER BY Дата DESC), 0) 
                         AS Признак,
                             COALESCE
                             ((SELECT        TOP (1) Признак
                                 FROM            td.t_fact_Товарная_матрица AS м
                                 WHERE        (Дата <= cass.t_fact_Скидки.[Дата_применения_скидки]) AND (Код_товара = cass.t_fact_Скидки.Код_товара) AND (Код_магазина = cass.t_dim_Кассы.Код_магазина)
                                 ORDER BY Дата desc), 0) as Код_поставщика,
                                 CONCAT(trim(Номер_дисконтной_карты), '~', trim(Название_дисконтной_карты)) AS Составной_ид_карты,
                Coalesce(cass.t_fact_Чеки.Номер_банковской_карты, '(Не по банковской карте)') Номер_банковской_карты,
                -- Не будем выводить null, чтобы не генерировать ошибку при обработке куба
                Coalesce(cass.t_fact_Скидки.Поставщик_холдинга, '(Не задан)') Поставщик_холдинга,
                Coalesce(cass.t_fact_Скидки.Важный_товар, cast(0 as bit)) Важный_товар,
                Coalesce(cass.t_fact_Скидки.Сценарий_важного_товара, -1) Сценарий_важного_товара
FROM            cass.t_fact_Скидки INNER JOIN
                         cass.t_dim_Кассы with (nolock) ON cass.t_fact_Скидки.Код_кассы = cass.t_dim_Кассы.Код_кассы INNER JOIN
                         cass.t_fact_Детализация_чеков ON cass.t_fact_Скидки.Составной_код_позиции = cass.t_fact_Детализация_чеков.Составной_код_позиции LEFT OUTER JOIN
                         dbo.t_dim_Товары with (nolock) ON cass.t_fact_Скидки.Код_товара = dbo.t_dim_Товары.Код_товара INNER JOIN
                         cass.t_fact_Чеки with (nolock) on cass.t_fact_Детализация_чеков.Составной_код_документа = cass.t_fact_Чеки.Составной_код_документа
GO


