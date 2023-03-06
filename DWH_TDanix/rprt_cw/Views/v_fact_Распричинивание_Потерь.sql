CREATE VIEW [rprt_cw].[v_fact_Распричинивание_потерь]
AS
SELECT        rprt_cw.t_fact_Распричинивание_потерь.Дата, dbo.t_dim_Магазины.Код AS Код_магазина, dbo.t_dim_Магазины.Наименование AS Магазин, dbo.t_dim_Товары.Код_товара, dbo.t_dim_Товары.Наименование AS Товар, 
                         rprt_cw.t_fact_Факты_потерь.Сумма, rprt_cw.t_fact_Факты_потерь.Количество, rprt_cw.t_dim_Причины_потерь.Причина, rprt_cw.t_dim_Причины_потерь.Подпричина, 
                         rprt_cw.t_fact_Распричинивание_потерь.Код_причины
FROM            rprt_cw.t_fact_Распричинивание_потерь INNER JOIN
                         rprt_cw.t_dim_Причины_потерь ON rprt_cw.t_fact_Распричинивание_потерь.Код_причины = rprt_cw.t_dim_Причины_потерь.Код_причины INNER JOIN
                         dbo.t_dim_Товары ON rprt_cw.t_fact_Распричинивание_потерь.Код_товара = dbo.t_dim_Товары.Код_товара INNER JOIN
                         dbo.t_dim_Магазины ON rprt_cw.t_fact_Распричинивание_потерь.Код_магазина = dbo.t_dim_Магазины.Код INNER JOIN
                         rprt_cw.t_fact_Факты_потерь ON rprt_cw.t_fact_Распричинивание_потерь.Дата = rprt_cw.t_fact_Факты_потерь.Дата AND 
                         rprt_cw.t_fact_Распричинивание_потерь.Код_магазина = rprt_cw.t_fact_Факты_потерь.Код_магазина AND rprt_cw.t_fact_Распричинивание_потерь.Код_товара = rprt_cw.t_fact_Факты_потерь.Код_товара AND 
                         rprt_cw.t_fact_Распричинивание_потерь.Списание = rprt_cw.t_fact_Факты_потерь.Списание
GO
