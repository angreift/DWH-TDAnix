CREATE TABLE [cass].[t_fact_Чеки] (
	[Код_кассы] [int] NOT NULL,
	[Номер_чека] [int] NOT NULL,
	[Дата_закрытия_чека] [date] NULL,
	[Дата_время_открытия_чека] [datetime] NOT NULL,
	[Дата_время_закрытия_чека] [datetime] NULL,
	[Сумма_без_скидок] [decimal](14, 2) NOT NULL,
	[Итоговая_сумма_со_скидками] [money] NOT NULL,
	[Печать_чека] [bit] NOT NULL,
	[Возврат] [bit] NOT NULL,
	[Сумма_оплаты_Наличные] [decimal](14, 2) NOT NULL,
	[Сумма_оплаты_Терминал] [decimal](14, 2) NOT NULL,
	[Сумма_оплаты_СБП_Сбербанк] [decimal](14, 2) NOT NULL,
	[Сумма_оплаты_Неинтегрированный_терминал_СБ] [decimal](14, 2) NOT NULL,
	[Сумма_оплаты_Накопительные_карты] [decimal](14, 2) NOT NULL,
	[Составной_код_смены] [nvarchar](20) NOT NULL,
	[Составной_код_документа] [nvarchar](20) NOT NULL,
	[Составной_код_кассира] [nvarchar](20) NOT NULL,
    [Флаг_закрытия_чека] TINYINT NULL, 
    CONSTRAINT [PK_t_fact_Чеки] PRIMARY KEY CLUSTERED ([Составной_код_документа] ASC) ON [FACTS],
    CONSTRAINT [FK_t_fact_Чеки_t_fact_Смены_на_кассах] FOREIGN KEY ([Составной_код_смены]) REFERENCES [cass].[t_fact_Смены_на_кассах] ([Составной_код_смены]) ON DELETE CASCADE
) ON [FACTS];


GO
CREATE NONCLUSTERED INDEX [ix_uncl_ИД_смены]
    ON [cass].[t_fact_Чеки]([Составной_код_смены] ASC)
    ON [FACTS];

GO

CREATE INDEX [ix_uncl_Чеки_Дата] ON [cass].[t_fact_Чеки] ([Дата_закрытия_чека]) ON [FACTS];

GO

CREATE INDEX [ix_uncl_Чеки_Измерения] ON [cass].[t_fact_Чеки] (Код_кассы, Составной_код_смены) ON [FACTS];

GO

CREATE TRIGGER [cass].[tg_onDeleteUpdate_Чеки]
       ON [cass].[t_fact_Чеки]
AFTER DELETE, UPDATE
AS
BEGIN
       SET NOCOUNT ON;

       DECLARE @date date, @date1 date
 
       SELECT @date = DELETED.[Дата_закрытия_чека]
       FROM DELETED
	   SELECT @date1 = INSERTED.[Дата_закрытия_чека] 
       FROM INSERTED
 
       IF DATEDIFF(day,@date,getdate())>=60 or DATEDIFF(day,@date1,getdate())>=60
       BEGIN
              RAISERROR('Удаление\изменение кассовых данных старше 60 дней запрещено!',16 ,1)
			  rollback tran
       END
END
