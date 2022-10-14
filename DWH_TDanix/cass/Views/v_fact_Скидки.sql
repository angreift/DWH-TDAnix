CREATE VIEW [cass].[v_fact_Скидки]
AS
SELECT        cass.t_fact_Скидки.Код_кассы, cass.t_fact_Скидки.ИД_скидки, cass.t_fact_Скидки.Номер_позиции, cass.t_fact_Скидки.Дата_время_применения_скидки, cass.t_fact_Скидки.Объект_скидки, 
                         cass.t_fact_Скидки.Номер_скидки, cass.t_fact_Скидки.Режим_скидки, cass.t_fact_Скидки.Тип_скидки, cass.t_fact_Скидки.Ставка_скидки, cass.t_fact_Скидки.Сумма_скидки, cass.t_fact_Скидки.Сумма_чека, 
                         cass.t_fact_Скидки.Номер_дисконтной_карты, cass.t_fact_Скидки.Название_дисконтной_карты, cass.t_fact_Скидки.ИД_карты, cass.t_fact_Скидки.Составной_код_кассира, 
                         CAST(CAST(cass.t_fact_Скидки.Дата_время_применения_скидки AS date) AS datetime) AS Дата_применения_скидки, cass.t_dim_Кассы.Код_магазина, cass.t_fact_Детализация_чеков.Составной_код_документа, 
                         dbo.t_dim_Товары.Код_товара, td.[v_fact_Товарная_матрица].Признак, td.[v_fact_Товарная_матрица].Код_поставщика
FROM            cass.t_fact_Скидки INNER JOIN
                         cass.t_dim_Кассы ON cass.t_fact_Скидки.Код_кассы = cass.t_dim_Кассы.Код_кассы INNER JOIN
                         cass.t_fact_Детализация_чеков ON cass.t_fact_Скидки.Составной_код_позиции = cass.t_fact_Детализация_чеков.Составной_код_позиции INNER JOIN
                         td.[v_fact_Товарная_матрица] ON cass.t_fact_Скидки.Код_товара = td.[v_fact_Товарная_матрица].Код_товара AND cass.t_dim_Кассы.Код_магазина = td.[v_fact_Товарная_матрица].Код_магазина LEFT OUTER JOIN
                         dbo.t_dim_Товары ON cass.t_fact_Скидки.Код_товара = dbo.t_dim_Товары.Код_товара
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
         Begin Table = "t_fact_Скидки (cass)"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 335
               Right = 369
            End
            DisplayFlags = 280
            TopColumn = 4
         End
         Begin Table = "t_dim_Кассы (cass)"
            Begin Extent = 
               Top = 111
               Left = 644
               Bottom = 241
               Right = 818
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "t_fact_Детализация_чеков (cass)"
            Begin Extent = 
               Top = 332
               Left = 520
               Bottom = 462
               Right = 892
            End
            DisplayFlags = 280
            TopColumn = 22
         End
         Begin Table = "t_dim_Товары"
            Begin Extent = 
               Top = 12
               Left = 958
               Bottom = 142
               Right = 1226
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
      Begin ColumnWidths = 9
         Width = 284
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
         Column = 3615
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 13' , @level0type=N'SCHEMA',@level0name=N'cass', @level1type=N'VIEW',@level1name=N'v_fact_Скидки'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'50
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'cass', @level1type=N'VIEW',@level1name=N'v_fact_Скидки'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'cass', @level1type=N'VIEW',@level1name=N'v_fact_Скидки'
GO


