﻿CREATE ROLE [itil_owner]
    AUTHORIZATION [dbo];


GO
ALTER ROLE [itil_owner] ADD MEMBER [DWH_itil_owner];