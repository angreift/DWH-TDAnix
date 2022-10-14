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
         Begin Table = "t_fact_Чеки (cass)"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 395
               Right = 440
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "t_dim_Кассы (cass)"
            Begin Extent = 
               Top = 86
               Left = 941
               Bottom = 342
               Right = 1262
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "t_dim_Магазины"
            Begin Extent = 
               Top = 178
               Left = 1399
               Bottom = 451
               Right = 1657
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "t_fact_Смены_на_кассах (cass)"
            Begin Extent = 
               Top = 171
               Left = 516
               Bottom = 408
               Right = 806
            End
            DisplayFlags = 280
            TopColumn = 14
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 10
         Width = 284
         Width = 2535
         Width = 3270
         Width = 1500
         Width = 4005
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 7755
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
         GroupBy = 1350
         Filter ', @level0type = N'SCHEMA', @level0name = N'cass', @level1type = N'VIEW', @level1name = N'v_dim_Чеки';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'= 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'cass', @level1type = N'VIEW', @level1name = N'v_dim_Чеки';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'cass', @level1type = N'VIEW', @level1name = N'v_dim_Чеки';

