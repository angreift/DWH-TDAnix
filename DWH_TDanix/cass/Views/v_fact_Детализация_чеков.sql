CREATE VIEW [cass].[v_fact_Детализация_чеков]
AS
SELECT        cass.t_fact_Детализация_чеков.Код_кассы, cass.t_fact_Детализация_чеков.Дата_время_добавления_позиции, cass.t_fact_Детализация_чеков.Способ_добавления_позиции, cass.t_fact_Детализация_чеков.Количество, 
                         cass.t_fact_Детализация_чеков.Способ_ввода_количества, cass.t_fact_Детализация_чеков.Цена, cass.t_fact_Детализация_чеков.Минимальная_цена, cass.t_fact_Детализация_чеков.Цена_позиции, 
                         cass.t_fact_Детализация_чеков.Способ_ввода_цены, cass.t_fact_Детализация_чеков.Сумма_скидки, cass.t_fact_Детализация_чеков.Начальная_сумма_до_применения_скидок, 
                         cass.t_fact_Детализация_чеков.Итоговая_сумма_после_применения_скидок, cass.t_fact_Детализация_чеков.Номер_позиции_в_чеке, cass.t_fact_Детализация_чеков.Сумма_Наличные, 
                         cass.t_fact_Детализация_чеков.Сумма_Терминал, cass.t_fact_Детализация_чеков.Сумма_СБП_Сбербанк, cass.t_fact_Детализация_чеков.Сумма_оплаты_Неинтегрированный_терминал_СБ, 
                         cass.t_fact_Детализация_чеков.Сумма_оплаты_Накопительные_карты, cass.t_fact_Детализация_чеков.Возврат,
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
                          AS Сумма_оплаты_Накопительные_карты_с_учетом_возвратов, cass.t_fact_Детализация_чеков.Составной_код_кассира, CAST(CAST(cass.t_fact_Детализация_чеков.Дата_время_добавления_позиции AS date) AS datetime) AS Дата_добавления_позиции, cass.t_dim_Кассы.Код_магазина, 
                         cass.t_fact_Детализация_чеков.Составной_код_документа, cass.t_fact_Чеки.Составной_код_смены, 
                         dbo.t_dim_Товары.Код_товара
FROM            cass.t_fact_Детализация_чеков INNER JOIN
                         cass.t_dim_Кассы ON cass.t_fact_Детализация_чеков.Код_кассы = cass.t_dim_Кассы.Код_кассы INNER JOIN
                         cass.t_fact_Чеки ON cass.t_fact_Детализация_чеков.Составной_код_документа = cass.t_fact_Чеки.Составной_код_документа LEFT OUTER JOIN
                         dbo.t_dim_Товары ON cass.t_fact_Детализация_чеков.Код_товара = dbo.t_dim_Товары.Код_товара
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
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
         Begin Table = "t_fact_Детализация_чеков (cass)"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 322
               Right = 410
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "t_dim_Кассы (cass)"
            Begin Extent = 
               Top = 11
               Left = 535
               Bottom = 141
               Right = 709
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "t_fact_Чеки (cass)"
            Begin Extent = 
               Top = 160
               Left = 526
               Bottom = 290
               Right = 898
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "t_dim_Товары"
            Begin Extent = 
               Top = 42
               Left = 1067
               Bottom = 172
               Right = 1335
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
      Begin ColumnWidths = 11
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
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 13' , @level0type=N'SCHEMA',@level0name=N'cass', @level1type=N'VIEW',@level1name=N'v_fact_Детализация_чеков'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'50
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'cass', @level1type=N'VIEW',@level1name=N'v_fact_Детализация_чеков'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'cass', @level1type=N'VIEW',@level1name=N'v_fact_Детализация_чеков'
GO


