CREATE TABLE [td].[t_fact_Товародвижение]
(
    [Дата] DATE NOT NULL,
    [Код_магазина] INT NOT NULL, 
    [Склад_в_магазине] INT NULL, 
    [ВидДвижения] TINYINT NULL, 
    [Код_причины] SMALLINT NULL, 
    [Код_товара] BIGINT NOT NULL, 
    [Сумма] DECIMAL(14, 2) NOT NULL, 
    [СуммаЗакупа] DECIMAL(14, 2) NOT NULL,
    [СуммаЗакупаСоСклада] DECIMAL(14, 2) NOT NULL, 
    [Количество] DECIMAL(14, 3) NOT NULL, 
    [Поставщик] INT NULL, 
    [Признак] TINYINT NULL, 
    [Поставщик_холдинга] NVARCHAR(100) NULL, 
    [Важный_товар] BIT NULL, 
    [Сценарий_важного_товара] NVARCHAR(64) NULL
)

GO

CREATE NONCLUSTERED INDEX [ix_uncl_Код_товара] ON [td].[t_fact_Товародвижение] ([Код_товара]) ON [FACTS]
GO

CREATE NONCLUSTERED INDEX [ix_uncl_Код_магазина] ON [td].[t_fact_Товародвижение] ([Код_магазина]) ON [FACTS]
GO

CREATE CLUSTERED INDEX [ix_cl_Дата] ON [td].[t_fact_Товародвижение] ([Дата]) ON [FACTS]
GO