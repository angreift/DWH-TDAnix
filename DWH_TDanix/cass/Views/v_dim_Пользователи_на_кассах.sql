CREATE VIEW [cass].v_dim_Пользователи_на_кассах
AS
SELECT        cass.t_dim_Пользователи_на_кассах.Код_кассы, cass.t_dim_Пользователи_на_кассах.Код_кассира, cass.t_dim_Пользователи_на_кассах.Логин_пользователя, 
                         cass.t_dim_Пользователи_на_кассах.Имя_пользователя, cass.t_dim_Пользователи_на_кассах.Запрещена_авторизация, cass.t_dim_Пользователи_на_кассах.Должность, cass.t_dim_Пользователи_на_кассах.ИНН, 
                         cass.v_dim_Кассы.Код_магазина, cass.v_dim_Кассы.Группа_магазина, cass.v_dim_Кассы.Наименование_магазина, CAST(cass.t_dim_Пользователи_на_кассах.Код_кассы AS nvarchar) 
                         + '~' + CAST(cass.t_dim_Пользователи_на_кассах.Код_кассира AS nvarchar) AS Составной_код
FROM            cass.t_dim_Пользователи_на_кассах INNER JOIN
                         cass.v_dim_Кассы ON cass.t_dim_Пользователи_на_кассах.Код_кассы = cass.v_dim_Кассы.Код_кассы

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
         Begin Table = "t_dim_Пользователи_на_кассах (cass)"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 254
               Right = 264
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "v_dim_Кассы (cass)"
            Begin Extent = 
               Top = 6
               Left = 514
               Bottom = 285
               Right = 742
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
         Width = 3120
         Width = 2655
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
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'cass', @level1type = N'VIEW', @level1name = N'v_dim_Пользователи_на_кассах';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'cass', @level1type = N'VIEW', @level1name = N'v_dim_Пользователи_на_кассах';

