CREATE TABLE [td].[t_fact_Товародвижение]
(
	[Составной_код_документа] NVARCHAR(20) NOT NULL, 
    [Дата] DATE NOT NULL,
    [Код_магазина] NCHAR(10) NOT NULL, 
    [Склад_в_магазине] INT NULL, 
    [ВидДвижения] TINYINT NULL, 
    [Код_причины] TINYINT NULL, 
    [Код_товара] BIGINT NOT NULL, 
    [Сумма] DECIMAL(14, 2) NOT NULL, 
    [СуммаЗакупа] DECIMAL(14, 2) NOT NULL,
    [СуммаЗакупаСоСклада] DECIMAL(14, 2) NOT NULL, 
    [Цена] DECIMAL(14, 2) NOT NULL, 
    [ЦенаЗакупа] DECIMAL(14, 2) NOT NULL, 
    [ЦенаЗакупаСоСклада] DECIMAL(14, 2) NOT NULL,
    [Количество] DECIMAL(14, 3) NOT NULL, 
    CONSTRAINT [PK_t_fact_Товародвижение] PRIMARY KEY CLUSTERED ([Составной_код_документа] ASC) ON [FACTS],
)

GO

CREATE NONCLUSTERED INDEX [ix_uncl_Код_товара_Код_магазина] ON [td].[t_fact_Товародвижение] ([Код_товара], [Код_магазина]) ON [FACTS]
GO

CREATE NONCLUSTERED INDEX [ix_uncl_Дата] ON [td].[t_fact_Товародвижение]  ([Дата]) ON [FACTS]
GO