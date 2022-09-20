CREATE VIEW cass.v_fact_Смены_на_кассах
AS
SELECT        cass.t_fact_Смены_на_кассах.Код_кассы, cass.t_fact_Смены_на_кассах.ИД_смены, cass.t_fact_Смены_на_кассах.Номер_смены, cass.t_fact_Смены_на_кассах.Код_кассира, 
                         cass.t_fact_Смены_на_кассах.Дата_время_начала_смены, cass.t_fact_Смены_на_кассах.Дата_время_окончания_смены, cass.t_fact_Смены_на_кассах.Номер_первого_чека_в_смене, 
                         cass.t_fact_Смены_на_кассах.Номер_последнего_чека_в_смене, cass.t_fact_Смены_на_кассах.Сумма_продажи, cass.t_fact_Смены_на_кассах.Сумма_выручки, 
                         cass.t_fact_Смены_на_кассах.Сумма_в_денежном_ящике, cass.t_fact_Смены_на_кассах.Признак_изменения_данных, cass.t_fact_Смены_на_кассах.Дата_время_открытия_первого_чека, 
                         cass.t_fact_Смены_на_кассах.Сумма_продажи_наличные, cass.t_fact_Смены_на_кассах.Сумма_продажи_безналичные, cass.t_fact_Смены_на_кассах.Сумма_продажи_прочие, 
                         cass.t_fact_Смены_на_кассах.Сумма_выручки_наличные, cass.t_fact_Смены_на_кассах.Сумма_выручки_безналичные, cass.t_fact_Смены_на_кассах.Сумма_возвратов, 
                         cass.t_fact_Смены_на_кассах.Сумма_возвратов_наличные, cass.t_fact_Смены_на_кассах.Сумма_возвратов_безналичные, cass.t_fact_Смены_на_кассах.Количество_чеков_продажи, 
                         cass.t_fact_Смены_на_кассах.Количество_чеков_возврата, CAST(cass.t_fact_Смены_на_кассах.Код_кассы AS nvarchar) + '~' + CAST(cass.t_fact_Смены_на_кассах.ИД_смены AS Nvarchar) AS Составной_код_Смены, 
                         CAST(cass.t_fact_Смены_на_кассах.код_кассы AS nvarchar) + '~' + CAST(cass.t_fact_Смены_на_кассах.Код_кассира AS nvarchar) AS Составной_код_кассира, dbo.t_dim_Магазины.Код, 
                         dbo.t_dim_Магазины.Наименование, CAST(CAST(cass.t_fact_Смены_на_кассах.Дата_время_начала_смены AS date) AS datetime) AS Дата_открытия_Смены
FROM            cass.t_fact_Смены_на_кассах INNER JOIN
                         cass.t_dim_Кассы ON cass.t_fact_Смены_на_кассах.Код_кассы = cass.t_dim_Кассы.Код_кассы INNER JOIN
                         dbo.t_dim_Магазины ON cass.t_dim_Кассы.Код_магазина = dbo.t_dim_Магазины.Код

GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
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
         Begin Table = "t_fact_Смены_на_кассах (cass)"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 335
               Right = 312
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "t_dim_Кассы (cass)"
            Begin Extent = 
               Top = 75
               Left = 408
               Bottom = 285
               Right = 593
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "t_dim_Магазины"
            Begin Extent = 
               Top = 133
               Left = 623
               Bottom = 263
               Right = 870
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
      Begin ColumnWidths = 28
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 2520
         Width = 3150
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
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
        ', @level0type = N'SCHEMA', @level0name = N'cass', @level1type = N'VIEW', @level1name = N'v_fact_Смены_на_кассах';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N' Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'cass', @level1type = N'VIEW', @level1name = N'v_fact_Смены_на_кассах';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'cass', @level1type = N'VIEW', @level1name = N'v_fact_Смены_на_кассах';

