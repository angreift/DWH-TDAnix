CREATE VIEW [dbo].[v_fact_LFL]
AS
SELECT        dbo.t_fact_LFL.Дата, dbo.t_fact_LFL.Код_магазина, dbo.t_dim_Магазины.Наименование, dbo.t_fact_LFL.LFL
FROM            dbo.t_fact_LFL LEFT OUTER JOIN
                         dbo.t_dim_Магазины ON dbo.t_fact_LFL.Код_магазина = dbo.t_dim_Магазины.Код
GO
