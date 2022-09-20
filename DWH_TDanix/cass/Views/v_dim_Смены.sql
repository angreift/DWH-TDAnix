CREATE VIEW cass.v_dim_Смены
AS
SELECT        с.Код_кассы, с.ИД_смены, с.Номер_смены, с.Код_кассира, CAST(с.Код_кассы AS nvarchar) + '~' + CAST(с.ИД_смены AS nvarchar) AS Составной_код_смены, dbo.t_dim_Магазины.Группа, 
                         dbo.t_dim_Магазины.Наименование, dbo.t_dim_Магазины.Код, CAST(с.Код_кассы AS nvarchar) + '~' + CAST(с.Код_кассира AS nvarchar) AS Составной_код_кассира, 
                         cass.v_dim_Пользователи_на_кассах.Имя_пользователя, 'Касса ' + CAST(с.Код_кассы AS nvarchar) + ' Смена ' + CAST(с.Номер_смены AS nvarchar) + ' от ' + CONVERT(nvarchar, с.Дата_время_начала_смены, 104) 
                         AS Наименование_смены
FROM            cass.v_dim_Пользователи_на_кассах INNER JOIN
                         cass.t_fact_Смены_на_кассах AS с ON cass.v_dim_Пользователи_на_кассах.Составной_код = CAST(с.Код_кассы AS nvarchar) + '~' + CAST(с.Код_кассира AS nvarchar) LEFT OUTER JOIN
                         cass.t_dim_Кассы AS к INNER JOIN
                         dbo.t_dim_Магазины ON к.Код_магазина = dbo.t_dim_Магазины.Код ON с.Код_кассы = к.Код_кассы

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
         Begin Table = "v_dim_Пользователи_на_кассах (cass)"
            Begin Extent = 
               Top = 118
               Left = 1040
               Bottom = 248
               Right = 1268
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "с"
            Begin Extent = 
               Top = 0
               Left = 74
               Bottom = 130
               Right = 364
            End
            DisplayFlags = 280
            TopColumn = 5
         End
         Begin Table = "к"
            Begin Extent = 
               Top = 86
               Left = 389
               Bottom = 248
               Right = 563
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "t_dim_Магазины"
            Begin Extent = 
               Top = 176
               Left = 654
               Bottom = 306
               Right = 901
            End
            DisplayFlags = 280
            TopColumn = 15
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 12
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 2790
         Width = 3015
         Width = 1500
         Width = 2055
         Width = 765
         Width = 2715
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 3555
         Alias = 4425
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350', @level0type = N'SCHEMA', @level0name = N'cass', @level1type = N'VIEW', @level1name = N'v_dim_Смены';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'cass', @level1type = N'VIEW', @level1name = N'v_dim_Смены';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'cass', @level1type = N'VIEW', @level1name = N'v_dim_Смены';

