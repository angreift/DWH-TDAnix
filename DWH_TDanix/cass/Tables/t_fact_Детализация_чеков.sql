CREATE TABLE [cass].[t_fact_Детализация_чеков] (
	[Код_кассы] [int] NOT NULL,
	[Код_товара] [bigint] NOT NULL,
	[Дата_добавления_позиции] [date] NOT NULL,
	[Дата_время_добавления_позиции] [datetime] NOT NULL,
	[Способ_добавления_позиции] [tinyint] NULL,
	[Количество] [decimal](14, 3) NOT NULL,
	[Способ_ввода_количества] [tinyint] NOT NULL,
	[Цена] [decimal](14, 2) NOT NULL,
	[Минимальная_цена] [decimal](14, 2) NOT NULL,
	[Цена_позиции] [decimal](14, 2) NOT NULL,
	[Способ_ввода_цены] [tinyint] NOT NULL,
	[Сумма_скидки] [decimal](14, 2) NOT NULL,
	[Начальная_сумма_до_применения_скидок] [decimal](14, 2) NOT NULL,
	[Итоговая_сумма_после_применения_скидок] [decimal](14, 2) NOT NULL,
	[Номер_позиции_в_чеке] SMALLINT NOT NULL,
	[Сумма_Наличные] [decimal](14, 2) NULL,
	[Сумма_Терминал] [decimal](14, 2) NULL,
	[Сумма_СБП_Сбербанк] [decimal](14, 2) NULL,
	[Сумма_оплаты_Неинтегрированный_терминал_СБ] [decimal](14, 2) NULL,
	[Сумма_оплаты_Накопительные_карты] [decimal](14, 2) NULL,
	[Возврат] [bit] NOT NULL,
	[Составной_код_позиции] [nvarchar](20) NOT NULL,
	[Составной_код_документа] [nvarchar](20) NOT NULL,
	[Составной_код_кассира] [nvarchar](20) NOT NULL,
    [Составной_код_смены] NVARCHAR(20) NOT NULL, 
    [Поставщик_холдинга] NVARCHAR(100) NULL, 
    [Важный_товар] BIT NULL, 
    [Сценарий_важного_товара] NVARCHAR(64) NULL, 
    CONSTRAINT [PK_t_fact_Детализация_чеков] PRIMARY KEY NONCLUSTERED ([Составной_код_позиции] ASC) ON [FACTS],
    CONSTRAINT [FK_t_fact_Детализация_чеков_t_fact_Чеки] FOREIGN KEY ([Составной_код_документа]) REFERENCES [cass].[t_fact_Чеки] ([Составной_код_документа]) ON DELETE CASCADE
) ON [FACTS];
GO

CREATE CLUSTERED INDEX [ix_cl_Дата] ON [cass].[t_fact_Детализация_чеков]
(
	[Дата_добавления_позиции] ASC
) ON [FACTS]
GO

CREATE NONCLUSTERED INDEX [ix_uncl_товар_касса] ON [cass].[t_fact_Детализация_чеков]
(
	[Код_товара] ASC,
	[Код_кассы] ASC
) ON [FACTS]
GO

CREATE NONCLUSTERED INDEX [ix_uncl_чек] ON [cass].[t_fact_Детализация_чеков]
(
	[Составной_код_документа] ASC
) ON [FACTS]
GO
CREATE TRIGGER [cass].[tg_onDeleteUpdate_Детализация_чеков]
       ON [cass].[t_fact_Детализация_чеков]
AFTER DELETE, UPDATE
AS
BEGIN
       SET NOCOUNT ON;

       DECLARE @date date, @date1 date
 
       SELECT @date = DELETED.[Дата_добавления_позиции]     
       FROM DELETED
	   SELECT @date1 = INSERTED.[Дата_добавления_позиции]     
       FROM INSERTED
 
       IF DATEDIFF(day,@date,getdate())>=63 or DATEDIFF(day,@date1,getdate())>=63
       BEGIN
              RAISERROR('Удаление\изменение кассовых данных старше 63 дней запрещено!',16 ,1)
			  rollback tran
       END
END
GO