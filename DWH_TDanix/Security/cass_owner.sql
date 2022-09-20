CREATE ROLE [cass_owner]
    AUTHORIZATION [dbo];


GO
ALTER ROLE [cass_owner] ADD MEMBER [DWH_cass_owner];

