CREATE VIEW cass.v_fact_Чеки
AS
SELECT        c.Код_кассы, c.ИД_смены, c.ИД_документа, c.Номер_чека, c.Код_кассира, c.Дата_время_открытия_чека, c.Дата_время_закрытия_чека, c.Сумма_без_скидок, c.Итоговая_сумма_со_скидками, c.Печать_чека, 
                         c.Возврат, c.Сумма_оплаты_Наличные, c.Сумма_оплаты_Терминал, c.Сумма_оплаты_СБП_Сбербанк, c.Сумма_оплаты_Неинтегрированный_терминал_СБ, c.Сумма_оплаты_Накопительные_карты, 
                         cass.v_dim_Кассы.Код_магазина, CAST(c.Код_кассы AS nvarchar) + '~' + CAST(c.Код_кассира AS nvarchar) AS Составной_код_кассира, CAST(c.Код_кассы AS nvarchar) + '~' + CAST(c.ИД_смены AS nvarchar) 
                         AS Составной_код_смены, CAST(CAST(c.Дата_время_закрытия_чека AS date) AS datetime) AS дата_закрытия_чека, goods.Количество_групп, 
                         CASE WHEN Возврат = 1 THEN c.Итоговая_сумма_со_скидками * - 1 ELSE c.Итоговая_сумма_со_скидками END AS Итоговая_сумма_со_скидками_с_учетом_возвратов, 
                         CASE WHEN Возврат = 1 THEN Сумма_оплаты_Наличные * - 1 ELSE Сумма_оплаты_Наличные END AS Сумма_оплаты_Наличные_с_учетом_возвратов, 
                         CASE WHEN Возврат = 1 THEN Сумма_оплаты_Терминал * - 1 ELSE Сумма_оплаты_Терминал END AS Сумма_оплаты_Терминал_с_учетом_возвратов, 
                         CASE WHEN Возврат = 1 THEN Сумма_оплаты_СБП_Сбербанк * - 1 ELSE Сумма_оплаты_СБП_Сбербанк END AS Сумма_оплаты_СБП_Сбербанк_с_учетом_возвратов, 
                         CASE WHEN Возврат = 1 THEN Сумма_оплаты_Неинтегрированный_терминал_СБ * - 1 ELSE Сумма_оплаты_Неинтегрированный_терминал_СБ END AS Сумма_оплаты_Неинтегрированный_терминал_СБ_с_учетом_возвратов,
                          CASE WHEN Возврат = 1 THEN Сумма_оплаты_Накопительные_карты * - 1 ELSE Сумма_оплаты_Накопительные_карты END AS Сумма_оплаты_Накопительные_карты_с_учетом_возвратов, 
                         c.Составной_код_документа, CASE WHEN Сумма_оплаты_наличные > 0 AND Возврат = 0 THEN 1 ELSE 0 END AS Количество_чеков_оплата_наличными, CASE WHEN Сумма_оплаты_Терминал > 0 AND 
                         Возврат = 0 THEN 1 ELSE 0 END AS Количество_чеков_оплата_по_терминалу, CASE WHEN Сумма_оплаты_СБП_Сбербанк > 0 AND Возврат = 0 THEN 1 ELSE 0 END AS Количество_чеков_оплата_по_СБП_Сбербанк, 
                         CASE WHEN Сумма_оплаты_Неинтегрированный_терминал_СБ > 0 AND Возврат = 0 THEN 1 ELSE 0 END AS Количество_чеков_оплата_по_неинтегрированному_терминалу_СБ, 
                         CASE WHEN Сумма_оплаты_Накопительные_карты > 0 AND Возврат = 0 THEN 1 ELSE 0 END AS Количество_чеков_оплата_по_накопительным_картам
FROM            cass.t_fact_Чеки AS c INNER JOIN
                         cass.v_dim_Кассы ON c.Код_кассы = cass.v_dim_Кассы.Код_кассы LEFT OUTER JOIN
                             (SELECT        g.Код_кассы, g.ИД_документа, COUNT(t.Код_группы) AS Количество_групп
                               FROM            cass.t_fact_Детализация_чеков AS g LEFT OUTER JOIN
                                                         dbo.t_dim_Товары AS t ON g.Код_товара = t.Код_товара
                               GROUP BY g.Код_кассы, g.ИД_документа) AS goods ON c.Код_кассы = goods.Код_кассы AND c.ИД_документа = goods.ИД_документа

GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[20] 2[18] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "c"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 281
               Right = 410
            End
            DisplayFlags = 280
            TopColumn = 6
         End
         Begin Table = "v_dim_Кассы (cass)"
            Begin Extent = 
               Top = 166
               Left = 502
               Bottom = 296
               Right = 730
            End
            DisplayFlags = 280
            TopColumn = 2
         End
         Begin Table = "goods"
            Begin Extent = 
               Top = 6
               Left = 837
               Bottom = 119
               Right = 1028
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 23
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 2850
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
        ', @level0type = N'SCHEMA', @level0name = N'cass', @level1type = N'VIEW', @level1name = N'v_fact_Чеки';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N' Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'cass', @level1type = N'VIEW', @level1name = N'v_fact_Чеки';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'cass', @level1type = N'VIEW', @level1name = N'v_fact_Чеки';

