
CREATE VIEW [cass].[v_dim_Кассы]
AS
SELECT 
    cass.t_dim_Кассы.Код_кассы,
    cass.t_dim_Кассы.IP_Адрес,
    cass.t_dim_Кассы.Включена,
    dbo.t_dim_Магазины.Код AS Код_магазина,
    dbo.t_dim_Магазины.Группа AS Группа_магазина, 
    dbo.t_dim_Магазины.Наименование AS Наименование_магазина,
    case
		when cass.t_dim_Кассы.Тип_кассы = 'pos' then 'Обычная касса'
		when cass.t_dim_Кассы.Тип_кассы = 'sco' then 'Касса самообслуживания'
		when cass.t_dim_Кассы.Тип_кассы = 'tsco' then 'Универсальная касса'
		else '(Не задано)'
	end as Тип_кассы
FROM cass.t_dim_Кассы 
LEFT OUTER JOIN dbo.t_dim_Магазины ON Код_Магазина = dbo.t_dim_Магазины.Код

GO