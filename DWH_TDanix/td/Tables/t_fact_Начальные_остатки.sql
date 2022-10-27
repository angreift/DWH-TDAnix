CREATE TABLE [td].[t_fact_Начальные_остатки]
(
	[Дата] DATE NOT NULL, 
    [Код_товара] BIGINT NOT NULL, 
    [Код_магазина] INT NOT NULL, 
    [Код_склада_в_магазине] INT NOT NULL, 
    [Сумма] DECIMAL(14, 2) NOT NULL,
    [Сумма_закупа] DECIMAL(14, 2) NOT NULL, 
    [Сумма_закупа_со_склада] DECIMAL(14, 2) NOT NULL, 
    [Остаток] DECIMAL(14, 3) NOT NULL
) on [FACTS]
GO

CREATE CLUSTERED INDEX [ix_cl_Дата] on [td].[t_fact_Начальные_остатки] (
    Дата ASC
) ON [FACTS]
GO

CREATE NONCLUSTERED INDEX [ix_uncl_Код_магазина_Код_склада_Код_товара] on [td].[t_fact_Начальные_остатки] (
    Код_магазина,
    Код_склада_в_магазине,
    Код_товара
) on [FACTS]
GO