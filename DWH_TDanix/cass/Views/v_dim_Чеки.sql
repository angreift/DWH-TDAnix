CREATE VIEW cass.v_dim_Чеки
AS
SELECT        cass.t_fact_Чеки.Составной_код_документа, cass.t_fact_Смены_на_кассах.Номер_смены, cass.t_fact_Чеки.Номер_чека, dbo.t_dim_Магазины.Группа, dbo.t_dim_Магазины.Наименование, dbo.t_dim_Магазины.Код, 
                         cass.t_fact_Чеки.Код_кассы, cass.t_fact_Смены_на_кассах.Составной_код_смены, 'Чек №' + CAST(cass.t_fact_Чеки.Номер_чека AS nvarchar) + ' от ' + CONVERT(nvarchar, cass.t_fact_Чеки.Дата_время_закрытия_чека, 13) 
                         AS [Наименование чека]
FROM            cass.t_fact_Чеки INNER JOIN
                         cass.t_dim_Кассы ON cass.t_fact_Чеки.Код_кассы = cass.t_dim_Кассы.Код_кассы INNER JOIN
                         dbo.t_dim_Магазины ON cass.t_dim_Кассы.Код_магазина = dbo.t_dim_Магазины.Код INNER JOIN
                         cass.t_fact_Смены_на_кассах ON cass.t_fact_Чеки.Составной_код_смены = cass.t_fact_Смены_на_кассах.Составной_код_смены
WHERE
                cass.t_fact_Чеки.Флаг_закрытия_чека in (1, 2) and cass.t_fact_Чеки.Флаг_закрытия_чека is not null --Сюда попадаю только закрытые чеки. Незакрытые чеки используются в сторно

GO