ALTER ROLE [db_owner] ADD MEMBER [DWH_All_SuperAdmin];


GO
ALTER ROLE [db_datareader] ADD MEMBER [DWH_All_ОТБРС_RW];


GO
ALTER ROLE [db_datareader] ADD MEMBER [S19-OLAP];


GO
ALTER ROLE [db_datareader] ADD MEMBER [NT Service\MSSQLSERVER];


GO
ALTER ROLE [db_datareader] ADD MEMBER [DWH_OLAP_Reader];


GO
ALTER ROLE [db_datawriter] ADD MEMBER [DWH_All_ОТБРС_RW];


GO
ALTER ROLE [db_datawriter] ADD MEMBER [S19-OLAP];


GO
ALTER ROLE [db_datawriter] ADD MEMBER [NT Service\MSSQLSERVER];

