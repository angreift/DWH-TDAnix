CREATE TABLE [cass].[t_fact_Смены_на_кассах] (
	[Код_кассы] [int] NOT NULL,
	[Номер_смены] [int] NULL,
	[Дата_начала_смены] [date] NOT NULL,
	[Дата_время_начала_смены] [datetime] NOT NULL,
	[Дата_время_окончания_смены] [datetime] NULL,
	[Номер_первого_чека_в_смене] [int] NOT NULL,
	[Номер_последнего_чека_в_смене] [int] NOT NULL,
	[Сумма_продажи] [decimal](14, 2) NOT NULL,
	[Сумма_выручки] [decimal](14, 2) NOT NULL,
	[Сумма_в_денежном_ящике] [decimal](14, 2) NOT NULL,
	[Признак_изменения_данных] [bit] NOT NULL,
	[Дата_время_открытия_первого_чека] [datetime] NULL,
	[Сумма_продажи_наличные] [decimal](14, 2) NOT NULL,
	[Сумма_продажи_безналичные] [decimal](14, 2) NOT NULL,
	[Сумма_продажи_прочие] [decimal](14, 2) NOT NULL,
	[Сумма_выручки_наличные] [decimal](14, 2) NOT NULL,
	[Сумма_выручки_безналичные] [decimal](14, 2) NOT NULL,
	[Сумма_возвратов] [decimal](14, 2) NOT NULL,
	[Сумма_возвратов_наличные] [decimal](14, 2) NOT NULL,
	[Сумма_возвратов_безналичные] [decimal](14, 2) NOT NULL,
	[Количество_чеков_продажи] [int] NOT NULL,
	[Количество_чеков_возврата] [int] NOT NULL,
	[Составной_код_смены] [nvarchar](20) NOT NULL,
	[Составной_код_кассира] [nvarchar](20) NOT NULL,
    CONSTRAINT [PK_t_fact_Смены_на_кассах] PRIMARY KEY CLUSTERED ([Составной_код_смены] ASC) ON [FACTS]
) ON [FACTS];

GO

CREATE INDEX [ix_uncl_Смены_Дата] ON [cass].[t_fact_Смены_на_кассах] ([Дата_начала_смены]) ON [FACTS];

GO

CREATE INDEX [ix_uncl_Смены_Измерения] ON [cass].[t_fact_Смены_на_кассах] (Код_кассы) ON [FACTS];

GO

CREATE TRIGGER [cass].[tg_onDeleteUpdate_Смены_на_кассах]
       ON [cass].[t_fact_Смены_на_кассах]
AFTER DELETE, UPDATE
AS
BEGIN
       SET NOCOUNT ON;

       DECLARE @date date, @date1 date
 
       SELECT @date = DELETED.[Дата_начала_смены]  
       FROM DELETED
	   SELECT @date1 = INSERTED.[Дата_начала_смены]     
       FROM INSERTED
 
       IF DATEDIFF(day,@date,getdate())>=63 or DATEDIFF(day,@date1,getdate())>=63
       BEGIN
              RAISERROR('Удаление\изменение кассовых данных старше 63 дней запрещено!',16 ,1)
			  rollback tran
       END
END

GO