CREATE VIEW dbo.v_dim_Календарь
AS
SELECT        ИД_дата, ИД_год, Год_наименование, ИД_квартал, Квартал_наименование, ИД_месяц, Месяц_наименование, ИД_неделя, Неделя_наименование, ИД_день_недели, День_недели_наименование, ISO_неделя, 
                         ISO_неделя_наименование, ISO_год, ISO_год_наименование, ISO_неделя_год_наименование, Месяц_год_наименование, День_месяц_год_наименование, Полное_наименование, Месяц_год_кратко, 
                         День_месяц_год_кратко, CAST(ИД_год AS nvarchar) + ' г' AS Г, CAST(ИД_квартал AS nvarchar) + N' кв' AS КВ, CAST(ИД_месяц AS nvarchar) AS М, CAST(DATEPART(day, ИД_дата) AS nvarchar) AS Д, 
                         RIGHT('0' + CAST(ИД_месяц AS nvarchar), 2) + N'-' + CAST(ИД_год AS nvarchar) + N' г' AS [М-Г], RIGHT('0' + CAST(DATEPART(day, ИД_дата) AS nvarchar), 2) + N'-' + RIGHT('0' + CAST(ИД_месяц AS nvarchar), 2) 
                         + N'-' + CAST(ИД_год AS nvarchar) + N' г' AS [Д-М-Г], CAST(ИД_квартал AS nvarchar) + N' кв ' + CAST(ИД_год AS nvarchar) + ' г' AS [К-Г], RIGHT('0' + CAST(ИД_месяц AS nvarchar), 2) + ' ' + CAST(ИД_квартал AS nvarchar) 
                         + N' кв ' + CAST(ИД_год AS nvarchar) + ' г' AS [М-К-Г], RIGHT('0' + CAST(DATEPART(day, ИД_дата) AS nvarchar), 2) + ' ' + RIGHT('0' + CAST(ИД_месяц AS nvarchar), 2) + ' ' + CAST(ИД_квартал AS nvarchar) 
                         + N' кв ' + CAST(ИД_год AS nvarchar) + ' г' AS [Д-М-К-Г]
FROM            dbo.t_dim_Календарь

GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[45] 4[14] 2[22] 3) )"
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
         Begin Table = "t_dim_Календарь"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 435
               Right = 302
            End
            DisplayFlags = 280
            TopColumn = 6
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 30
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
         Column = 7605
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'v_dim_Календарь';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'v_dim_Календарь';

