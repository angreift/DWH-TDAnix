CREATE TABLE [cass].[t_fact_Сторнированные_позиции] (
	[Код_кассы] [int] NOT NULL,
	[ИД_сторнированной_позиции] [int] NOT NULL,
	[Дата_время_добавления_сторнированной_позиции] [datetime] NOT NULL,
	[Дата_сторнирования_позиции] [date] NOT NULL,
	[Дата_время_сторнирования_позиции] [datetime] NOT NULL,
	[Способ_добавления_позиции] [tinyint] NOT NULL,
	[Количество] [decimal](13, 3) NOT NULL,
	[Способ_ввода_количества] [tinyint] NOT NULL,
	[Цена] [decimal](14, 2) NOT NULL,
	[Минимальная_цена] [decimal](14, 2) NOT NULL,
	[Цена_позиции] [decimal](14, 2) NOT NULL,
	[Способ_ввода_цены] [int] NOT NULL,
	[Сумма_скидки] [decimal](14, 2) NOT NULL,
	[Начальная_сумма_до_применения_скидок] [decimal](14, 2) NOT NULL,
	[Итоговая_сумма_после_применения_скидок] [decimal](14, 2) NOT NULL,
	[Код_товара] [bigint] NOT NULL,
	[Номер_сторнированной_позиции] [int] NOT NULL,
	[Составной_код_документа] [nvarchar](20) NOT NULL,
	[Составной_код_кассира] [nvarchar](20) NOT NULL,
	[Составной_код_кассира_подтвердившего_сторно] [nvarchar](20) NOT NULL
    CONSTRAINT [FK_t_fact_Сторнированные_позиции_t_fact_Чеки] FOREIGN KEY ([Составной_код_документа]) REFERENCES [cass].[t_fact_Чеки] ([Составной_код_документа]) ON DELETE CASCADE, 
    [Поставщик_холдинга] BIGINT NULL, 
    [Важный_товар] BIT NULL, 
    [Сценарий_важного_товара] INT NULL
) ON [FACTS];


GO
CREATE CLUSTERED INDEX [ix_cl_ИД_док]
    ON [cass].[t_fact_Сторнированные_позиции]([Составной_код_документа] ASC)
    ON [FACTS];

GO

CREATE INDEX [ix_uncl_Сторно_Дата] ON [cass].[t_fact_Сторнированные_позиции] ([Дата_сторнирования_позиции]) ON [FACTS];

GO

CREATE INDEX [ix_uncl_Сторно_Измерения] ON [cass].[t_fact_Сторнированные_позиции] (Код_товара, Код_кассы) ON [FACTS];

GO

CREATE TRIGGER [cass].[tg_onDeleteUpdate_Сторнированные_позиции]
       ON [cass].[t_fact_Сторнированные_позиции]
AFTER DELETE, UPDATE
AS
BEGIN
       SET NOCOUNT ON;

       DECLARE @date date, @date1 date
 
       SELECT @date = DELETED.[Дата_сторнирования_позиции]
       FROM DELETED
	   SELECT @date1 = INSERTED.[Дата_сторнирования_позиции]  
       FROM INSERTED
 
       IF DATEDIFF(day,@date,getdate())>=63 or DATEDIFF(day,@date1,getdate())>=63
       BEGIN
              RAISERROR('Удаление\изменение кассовых данных старше 63 дней запрещено!',16 ,1)
			  rollback tran
       END
END

GO