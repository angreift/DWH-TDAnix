CREATE ROLE [td_owner]
    AUTHORIZATION [dbo];


GO
ALTER ROLE [td_owner] ADD MEMBER [DWH_td_owner];

