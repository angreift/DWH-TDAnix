CREATE VIEW [dbo].[v_dim_Магазины]
AS
SELECT        dbo.t_dim_Магазины.Код, dbo.t_dim_Магазины.Группа, dbo.t_dim_Магазины.Наименование, dbo.t_dim_Магазины.Адрес, dbo.t_dim_Магазины.Город, dbo.t_dim_Магазины.График_ПРАЙД, 
                         dbo.t_dim_Магазины.Дата_закрытия, dbo.t_dim_Магазины.Дата_открытия, dbo.t_dim_Магазины.ИНН, dbo.t_dim_Магазины.Категория_по_площади, dbo.t_dim_Магазины.КПП, dbo.t_dim_Магазины.Куст, 
                         dbo.t_dim_Магазины.Ответственный, dbo.t_dim_Магазины.Отчёт, dbo.t_dim_Магазины.Регион, dbo.t_dim_Магазины.Дата_начала_реконструкции, dbo.t_dim_Магазины.Дата_конца_реконструкции, 
                         dbo.t_dim_Магазины.Бренд_магазина, dbo.t_dim_Магазины.Технолог_СП, ISNULL(dbo.t_Директора_кустов.Директор, N'(Не заполнено)') AS Директор, ISNULL(dbo.t_Форматы_магазинов.Наименование_формата, 
                         N'(Не заполнено)') AS Наименование_формата
FROM            dbo.t_dim_Магазины LEFT OUTER JOIN
                         dbo.t_Форматы_магазинов ON dbo.t_dim_Магазины.Код_формата_магазина = dbo.t_Форматы_магазинов.Код_формата LEFT OUTER JOIN
                         dbo.t_Директора_кустов ON dbo.t_dim_Магазины.Составной_код_директора = dbo.t_Директора_кустов.Составной_код
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[34] 4[27] 2[9] 3) )"
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
         Begin Table = "t_dim_Магазины"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 323
               Right = 380
            End
            DisplayFlags = 280
            TopColumn = 6
         End
         Begin Table = "t_Форматы_магазинов"
            Begin Extent = 
               Top = 6
               Left = 418
               Bottom = 102
               Right = 644
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "t_Директора_кустов"
            Begin Extent = 
               Top = 6
               Left = 682
               Bottom = 102
               Right = 854
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
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'v_dim_Магазины'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'v_dim_Магазины'
GO