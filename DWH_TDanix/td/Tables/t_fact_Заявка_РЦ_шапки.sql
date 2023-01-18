CREATE TABLE [td].[t_fact_Заявка_РЦ_шапки]
(	
	[Составной_код_заявки_РЦ] nvarchar(15) not null,
	[Дата_заявки_РЦ] date not null,
	[Код_магазина] int not null,
	constraint [PK_Составной_код_Заявка_РЦ] primary key clustered ([Составной_код_заявки_РЦ] asc) on [FACTS]
) on [FACTS]
GO

create nonclustered index [ix_uncl_Дата] on [td].[t_fact_Заявка_РЦ_шапки] ([Дата_заявки_РЦ]) on [FACTS]
GO
create nonclustered index [ix_uncl_Код_магазина] on [td].[t_fact_Заявка_РЦ_шапки] ([Код_магазина]) on [FACTS]
GO
