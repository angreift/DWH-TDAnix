CREATE TABLE [cass].[t_dim_Кассы] (
    [Код_кассы]    INT            NOT NULL,
    [IP_Адрес]     NVARCHAR (15)  NOT NULL,
    [Включена]     BIT            NOT NULL,
    [Код_магазина] INT            NOT NULL,
    [UserBind]     NVARCHAR (100) NULL,
    [Тип_кассы] NVARCHAR(30) NULL, 
    CONSTRAINT [PK_t_dim_Кассы] PRIMARY KEY CLUSTERED ([Код_кассы] ASC) ON [DIMENTIONS]
) ON [DIMENTIONS];


GO
CREATE UNIQUE NONCLUSTERED INDEX [ix_uncl_IP_Адрес]
    ON [cass].[t_dim_Кассы]([IP_Адрес] ASC)
    ON [DIMENTIONS];


GO
ALTER INDEX [ix_uncl_IP_Адрес]
    ON [cass].[t_dim_Кассы] DISABLE;


GO
-- =============================================
-- Author:		kma1860
-- Create date: 31/08/2022
-- Description:	Добавляет информацию в жрнал если была добавлена касса
-- =============================================
CREATE TRIGGER [cass].[tg_onInsert_Добавление_информации_в_журнал]
   ON  [cass].[t_dim_Кассы]
   AFTER insert
AS 
BEGIN
	SET NOCOUNT ON;
	declare @object_name  nvarchar(128);
	declare @msg          nvarchar(max);
	declare @cur_cassid   int;
	declare @incIP        nvarchar(16);
	declare @prcIP        nvarchar(15);

	declare cur_ins cursor local for
		select 
			Код_кассы
		from
			inserted

	open cur_ins 
		fetch next from cur_ins into @cur_cassid
		while @@FETCH_STATUS = 0
		begin
			set @object_name = object_schema_name(@@procid)+'.'+object_name(@@procid);

			set @msg = concat(
				'Добавлена новая касса. Код кассы: ', 
				(select Код_кассы from inserted where Код_кассы = @cur_cassid), 
				', IP: ', (select IP_Адрес from inserted where Код_кассы = @cur_cassid), 
				', Код_магазина: ', 
				(select Код_магазина from inserted where Код_кассы = @cur_cassid),
				', Флаг включения кассы: ',
				(select Включена from inserted where Код_кассы = @cur_cassid),
				', Дополнительная информация: ',
				(select UserBind from inserted where Код_кассы = @cur_cassid)
			)

			exec [dbo].[p_Сообщить_в_общий_журнал] 3, @object_name, @msg;

			set	@incIP = (select IP_адрес from inserted where Код_кассы = @cur_cassid);
			if len(@incIP) <> 15 begin
				set @incIP = trim(@incIP) + '.'; set @prcIP = '';
				while charindex('.', @incIP) > 0 begin
					if len(@prcIP) > 0 set @prcIP += '.';
					set @prcIP = @prcIP + right('000' + substring(@incIP, 1, charindex('.', @incIP) - 1), 3);
					set @incIP = substring(@incIP, charindex('.', @incIP) + 1, 15);
				end
				update [cass].[t_dim_Кассы] set IP_адрес = @prcIP where Код_кассы = @cur_cassid;
			end;

			fetch next from cur_ins into @cur_cassid
		end
	close cur_ins
END

GO
-- =============================================
-- Author:		kma1860
-- Create date: 31/08/2022
-- Description:	Добавляет информацию в жрнал если была добавлена касса
-- =============================================
CREATE TRIGGER [cass].[tg_onUpdate_Добавление_информации_в_журнал]
   ON  [cass].[t_dim_Кассы]
   AFTER update
AS 
BEGIN	
	SET NOCOUNT ON;
	declare @cur_cassid   int;
	declare @object_name  nvarchar(128);
	declare @msg          nvarchar(max);
	declare @incIP        nvarchar(16);
	declare @prcIP        nvarchar(15);

	set @object_name = object_schema_name(@@procid)+'.'+object_name(@@procid);

	declare cur cursor local for
		select 
			Код_кассы
		from
			deleted

	open cur
		fetch next from cur into @cur_cassid
		while @@FETCH_STATUS = 0
		begin
			set @msg = concat(
				'Обновлена касса. Код кассы: ', 
				(select Код_кассы    from deleted  where Код_кассы = @cur_cassid),
				'->',
				(select Код_кассы    from inserted where Код_кассы = @cur_cassid), 
				', IP: ', 
				(select IP_Адрес     from deleted  where Код_кассы = @cur_cassid),
				'->',
				(select IP_Адрес     from inserted where Код_кассы = @cur_cassid), 
				', Код_магазина: ', 
				(select Код_магазина from deleted  where Код_кассы = @cur_cassid),
				'->',
				(select Код_магазина from inserted where Код_кассы = @cur_cassid),
				', Флаг включения кассы: ',
				(select Включена     from deleted  where Код_кассы = @cur_cassid),
				'->',
				(select Включена     from inserted where Код_кассы = @cur_cassid),
				', Дополнительная информация: ',
				(select UserBind     from deleted  where Код_кассы = @cur_cassid),
				'->',
				(select UserBind     from inserted where Код_кассы = @cur_cassid)
			);
			exec [dbo].[p_Сообщить_в_общий_журнал] 3, @object_name, @msg;

			set	@incIP = (select IP_адрес from inserted where Код_кассы = @cur_cassid);
			if len(@incIP) <> 15 begin
				set @incIP = trim(@incIP) + '.'; set @prcIP = '';
				while charindex('.', @incIP) > 0 begin
					if len(@prcIP) > 0 set @prcIP += '.';
					set @prcIP = @prcIP + right('000' + substring(@incIP, 1, charindex('.', @incIP) - 1), 3);
					set @incIP = substring(@incIP, charindex('.', @incIP) + 1, 15);
				end
				update [cass].[t_dim_Кассы] set IP_адрес = @prcIP where Код_кассы = @cur_cassid;
			end;

			fetch next from cur into @cur_cassid
		end
	close cur
END

GO
-- =============================================
-- Author:		kma1860
-- Create date: 31/08/2022
-- Description:	Добавляет информацию в жрнал если была добавлена касса
-- =============================================
CREATE TRIGGER [cass].[tg_onDelete_Добавление_информации_в_журнал]
   ON  [cass].[t_dim_Кассы]
   AFTER delete
AS 
BEGIN
	SET NOCOUNT ON;
	declare @object_name  nvarchar(128);
	declare @msg          nvarchar(max);
	set @object_name = object_schema_name(@@procid)+'.'+object_name(@@procid);

	set @msg = concat(
		'Удалена касса. Код кассы: ', 
		(select Код_кассы from deleted),
		', IP: ', 
		(select IP_Адрес from deleted),
		', Код_магазина: ', 
		(select Код_магазина from deleted),
		', Флаг включения кассы: ',
		(select Включена from deleted),
		', Дополнительная информация: ',
		(select UserBind from deleted)
	);
	exec [dbo].[p_Сообщить_в_общий_журнал] 3, @object_name, @msg;

END
