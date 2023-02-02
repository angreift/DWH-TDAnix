
CREATE VIEW [cass].[v_dim_Кассы]
AS
SELECT 
    cass.t_dim_Кассы.Код_кассы,
    cass.t_dim_Кассы.IP_Адрес,
    cass.t_dim_Кассы.Включена,
    dbo.t_dim_Магазины.Код AS Код_магазина,
    dbo.t_dim_Магазины.Группа AS Группа_магазина, 
    dbo.t_dim_Магазины.Наименование AS Наименование_магазина,
    ISNULL(cass.t_dim_Типы_касс.Наименование, '(Не задано)') AS Тип_кассы
FROM cass.t_dim_Кассы
LEFT OUTER JOIN cass.t_dim_Типы_касс ON cass.t_dim_Кассы.Код_типа_кассы = cass.t_dim_Типы_касс.Код_типа_кассы
LEFT OUTER JOIN dbo.t_dim_Магазины ON Код_Магазина = dbo.t_dim_Магазины.Код

GO