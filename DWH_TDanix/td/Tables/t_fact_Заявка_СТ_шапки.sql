CREATE TABLE [td].[t_fact_Заявка_СТ_шапки]
(	
	[Составной_код_заявки_СТ] nvarchar(15) not null,
	[Дата_заявки_СТ] date not null,
	[Код_магазина] int not null,
	constraint [PK_Составной_код_Заявка_СТ] primary key clustered ([Составной_код_заявки_СТ] asc) on [FACTS]
) on [FACTS]
GO

create nonclustered index [ix_uncl_Дата] on [td].[t_fact_Заявка_СТ_шапки] ([Дата_заявки_СТ]) on [FACTS]
GO
create nonclustered index [ix_uncl_Код_магазина] on [td].[t_fact_Заявка_СТ_шапки] ([Код_магазина]) on [FACTS]
GO
