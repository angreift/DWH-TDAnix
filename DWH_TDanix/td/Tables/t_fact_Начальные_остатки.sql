CREATE TABLE [td].[t_fact_Начальные_остатки]
(
	[Дата] DATE NOT NULL, 
    [Код_товара] BIGINT NOT NULL, 
    [Код_магазина] INT NOT NULL, 
    [Код_склада_в_магазине] INT NOT NULL, 
    [Сумма_закупа] DECIMAL(14, 2) NOT NULL, 
    [Сумма_закупа_со_склада] DECIMAL(14, 2) NOT NULL, 
    [Остаток] DECIMAL(14, 3) NOT NULL 
) on [FACTS]
