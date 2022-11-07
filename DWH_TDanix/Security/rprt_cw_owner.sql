CREATE ROLE [rprt_owner]
    AUTHORIZATION [dbo];


GO
ALTER ROLE [rpt_cw_owner] ADD MEMBER [DWH_rprt_cw_owner];

