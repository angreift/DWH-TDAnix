CREATE TABLE [plan].[t_fact_Планы_СА_по_группам_детализация]
(
	[id_плана] int not null,
	[Код_группы] bigint not null, 
    CONSTRAINT [FK_t_fact_Планы_СА_по_группам_детализация_t_fact_Планы_СА_по_группам] FOREIGN KEY ([id_плана]) REFERENCES [plan].[t_fact_Планы_СА_по_группам]([id]) ON DELETE CASCADE
) on [FACTS]
GO

Create clustered index [ix_cl_id] on [plan].[t_fact_Планы_СА_по_группам_детализация]([id_плана] asc) on [FACTS]
GO