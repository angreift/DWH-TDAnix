﻿-- =============================================
-- Author:		kma1860
-- Create date: 25/08/2022
-- Description:	Непосредственный обмен с кассами и кассовым сервером
-- =============================================
CREATE PROCEDURE [cass].[p_Обмен_с_кассами]
@ТолькоРозница              bit = 0,
@Номер_кассы_для_переснятия int = 0,
@ИД_смены_для_переснятия    int = 0
AS
BEGIN
	SET NOCOUNT ON;

	-- Переменные для ведения журнала
	declare @object_name  nvarchar(128);                              -- Наименование данной хранимки для заиписи в журнал
	declare @msg          nvarchar(max);                              -- Переменная для хранения текста, которое будет записано в журнал

	-- Переменные для обхода касс по циклу
	declare @Код_кассы    int;
	declare @IP_адрес     nvarchar(15);
	declare @Включена     bit;
	declare @Код_магазина int;
	declare @R            bit;                                        -- Результат создания/обновления ODBC подключения
	declare @str          nvarchar(max);                              -- Для хранения текста динамического запроса

	-- Переменные для обхода смен по циклу
	declare @ИД_смены                         int;
	declare @Составной_код_смены              nvarchar(20); 
	declare @Составной_код_кассира            nvarchar(20); 
	declare @Номер_смены                      int;
	declare @Код_кассира                      varchar(30);
	declare @Дата_время_начала_смены          datetime;
	declare @Дата_время_окончания_смены       datetime;
	declare @Номер_первого_чека_в_смене       int;
	declare @Номер_последнего_чека_в_смене    int;
	declare @Сумма_продажи                    money;
	declare @Сумма_выручки                    money;
	declare @Сумма_в_денежном_ящике           money;
	declare @Признак_изменения_данных         bit;
	declare @Дата_время_открытия_первого_чека datetime;
	declare @Сумма_продажи_наличные           money;
	declare @Сумма_продажи_безналичные        money;
	declare @Сумма_продажи_прочие             money;
	declare @Сумма_выручки_наличные           money;
	declare @Сумма_выручки_безналичные        money;
	declare @Сумма_возвратов                  money;
	declare @Сумма_возвратов_наличные         money;
	declare @Сумма_возвратов_безналичные      money;
	declare @Количество_чеков_продажи         money;
	declare @Количество_чеков_возврата        money;
	declare @Флаг_загрузки_смены              bit;

	declare @TransactionName                  nvarchar(32);           -- Уникальное имя транзакции (чтобы по нему делать rollback)
	declare @SeqNum	                          int;                    -- Код события в журнале загрузки смен

	declare @forcePOS                         bit;                    -- Если явно задается касса, то не проверяется включена ли она
	declare @forceWorkshift                   bit;                    -- Если явно задается смена, то она перезаписывается
	declare @shiftRange                       int;                    -- Количество дней для выборки смен

	set @object_name = object_schema_name(@@procid)+'.'+object_name(@@procid); -- Получаем название данной процедуры

	set @forcePOS       = 0;
	set @forceWorkshift = 0;

	if (@Номер_кассы_для_переснятия > 0) set @forcePOS       = 1
	if (@ИД_смены_для_переснятия    > 0) set @forceWorkshift = 1

	-- Поиск уже запущенных обменов с кассами
	declare @Tran table (
		[tran_elapsed_time_seconds] int, 
		[session_id] int, 
		[text] nvarchar(max), 
		[transaction_id] int, 
		[name] nvarchar(32)
	)

	insert into @Tran
	select
		datediff(second, transaction_begin_time, getDate()) as [tran_elapsed_time_seconds],
		st.session_id,
		txt.text, 
		at.transaction_id,
		[name]
	from
		sys.dm_tran_active_transactions at
	inner join 
		sys.dm_tran_session_transactions st ON st.transaction_id = at.transaction_id
	left outer join 
		sys.dm_exec_sessions sess ON st.session_id = sess.session_id
	left outer join 
		sys.dm_exec_connections conn ON conn.session_id = sess.session_id
	outer apply 
		sys.dm_exec_sql_text(conn.most_recent_sql_handle) AS [txt]
	where name like 'CassLoader%' --kill 66

	-- Выход из процедуры, если обмен уже запущен
	if (select count(*) from @Tran) > 0
	begin
		set @msg = concat(
			'Ошибка запуска обмена с кассами. Существует активная транзакция. [tran_elapsed_time_seconds]: ', 
			(select top 1 [tran_elapsed_time_seconds] from @Tran), 
			', [session_id]: ', 
			(select top 1 [session_id] from @Tran),
			', [transaction_id]: ', 
			(select top 1 [transaction_id] from @Tran),
			', [name]: ', 
			(select top 1 [name] from @Tran)
		
		);
		exec [dbo].[p_Сообщить_в_общий_журнал] 1, @object_name, @msg;
		raiserror(@msg, 13, 1) with nowait;
		return;
	end
	
	-- Заполнение табличной переменной кассами, которые нужно будет опросить
	declare @Список_касс table (
		Код_кассы int not null,
		IP_адрес nvarchar(15) not null,
		Код_магазина int not null,
		Включена bit not null
	)
	
	insert into
		@Список_касс
	select
		Код_кассы,
		IP_адрес,
		Код_магазина,
		Включена
	from
		cass.t_dim_Кассы

	-- Оставляем только розницу, если передан такой параметр
	if @ТолькоРозница = 1 begin
		delete from @Список_касс where Код_кассы not in (
			select Код_кассы from cass.v_dim_Кассы where cass.v_dim_Кассы.Группа_магазина in ('Розница', 'РС Закрытые')
		)
	end

	-- Оставляем конкретную кассу, если передан такой параметр
	if @Номер_кассы_для_переснятия > 0 begin
		delete from @Список_касс where Код_кассы <> @Номер_кассы_для_переснятия
	end

	-- Обход по циклу выбранные кассы
	while (select count(*) from @Список_касс) > 0
	begin
		
		-- Заполнение основных переменных по кассам
		set @Код_кассы = (select top 1 Код_кассы from @Список_касс);
		set @IP_адрес     = (select IP_адрес     from @Список_касс where Код_кассы = @Код_кассы)
		set @Код_магазина = (select Код_магазина from @Список_касс where Код_кассы = @Код_кассы)
		set @Включена     = (select Включена     from @Список_касс where Код_кассы = @Код_кассы)

		-- Удаление кассы из табличной переменной, чтобы больше не опрашивать ее в данном сеансе
		delete from @Список_касс where Код_кассы = @Код_кассы;

		-- Журналирование
		set @msg = concat('Начало выгрузки с кассы. Код_кассы: ', @Код_кассы, ', IP: ', @IP_адрес, ', Код_магазина: ', @Код_магазина);
		exec [dbo].[p_Сообщить_в_общий_журнал] 3, @object_name, @msg;

		if (@Включена = 0 and @forcePOS = 0)
		begin
			set @msg = concat('Пропуск кассы, так как обмен с кассой выключен. Код_кассы: ', @Код_кассы, ', IP: ', @IP_адрес, ', Код_магазина: ', @Код_магазина);
			exec [dbo].[p_Сообщить_в_общий_журнал] 3, @object_name, @msg;
			continue;
		end

		
		/*
		-- 1. Создадим/обновим подключение для драйвера ODBC
		exec [dbo].[p_Регистрация_ODBC_подключения] @Код_кассы, @IP_адрес, @R output;
		if @R = 0
		begin
			set @msg = concat('Пропуск кассы, так не удалось создать или обновить подключение к кассе. Код_кассы: ', @Код_кассы, ', IP: ', @IP_адрес, ', Код_магазина: ', @Код_магазина);
			exec [dbo].[p_Сообщить_в_общий_журнал] 1, @object_name, @msg;
			continue;
		end */

		--2. Заполнение таблиц RAW (сырые данные)

		--Пользователи
		truncate table cass.t_raw_Пользователи

		set @str = '
			insert into 
				cass.t_raw_Пользователи (
					Код_кассира,
					Логин_пользователя,
					Имя_пользователя,
					Запрещена_авторизация,
					Должность,
					ИНН
				)
			select
				code,
				login,
				coalesce(name, ''(Имя кассира не задано)'') name,
				locked,
				rank,
				inn
			from
				openquery(
					[pos_%cassnum%],
					''select
						`code`,
						`login`,
						`name`,
						`locked`,
						`rank`,
						`inn`
					from
						`dictionaries`.`mol`''
				) where code is not null
		';
		set @str = REPLACE(@str, '%cassnum%', @Код_кассы);
		begin try
			exec(@str);
		end try
		begin catch
			set @msg = concat('Не удалось выполнить запрос к таблице Mol. Код_кассы: ', @Код_кассы, ', IP: ', @IP_адрес, ', Код_магазина: ', @Код_магазина, ', Ошибка: ', error_message());
			exec [dbo].[p_Сообщить_в_общий_журнал] 1, @object_name, @msg;
			set @msg = error_message();
			exec [cass].p_Добавить_информацию_об_ошибке_обмена @Код_кассы, @msg;
			continue;
		end catch

		-- Слияние таблиц, чтобы удаленные на кассе пользователи не удалялись из базы
		begin try
			merge cass.t_dim_Пользователи_на_кассах
			using cass.t_raw_Пользователи
			on (cass.t_dim_Пользователи_на_кассах.Составной_код_кассира = cast(@Код_кассы as nvarchar) + '~' + cast(cass.t_raw_Пользователи.Код_кассира as nvarchar))
			when matched then
				update set	cass.t_dim_Пользователи_на_кассах.Логин_пользователя    = cass.t_raw_Пользователи.Логин_пользователя, 
							cass.t_dim_Пользователи_на_кассах.Имя_пользователя      = cass.t_raw_Пользователи.Имя_пользователя, 
							cass.t_dim_Пользователи_на_кассах.Запрещена_авторизация = cass.t_raw_Пользователи.Запрещена_авторизация, 
							cass.t_dim_Пользователи_на_кассах.Должность             = cass.t_raw_Пользователи.Должность, 
							cass.t_dim_Пользователи_на_кассах.ИНН                   = cass.t_raw_Пользователи.ИНН
			when not matched then
				insert (Код_кассы, Составной_код_кассира, Логин_пользователя, Имя_пользователя, Запрещена_авторизация, Должность, ИНН)
				values (@Код_кассы,cast(@Код_кассы as nvarchar) + '~' + cast(cass.t_raw_Пользователи.Код_кассира as nvarchar),cass.t_raw_Пользователи.Логин_пользователя,cass.t_raw_Пользователи.Имя_пользователя,cass.t_raw_Пользователи.Запрещена_авторизация, cass.t_raw_Пользователи.Должность, cass.t_raw_Пользователи.ИНН);
		end try
		begin catch
			set @msg = concat('Не удалось выполнить слияние таблицы Пользователи_на_кассах. Код_кассы: ', @Код_кассы, ', IP: ', @IP_адрес, ', Код_магазина: ', @Код_магазина, ', Ошибка: ', error_message());
			exec [dbo].[p_Сообщить_в_общий_журнал] 1, @object_name, @msg;
		end catch

		-- Получим список смен на кассе
		set @str = '
			truncate table cass.t_raw_Смены
			insert into 
				cass.t_raw_Смены (
					ИД_смены,
					Номер_смены,
					Код_кассира,
					Дата_время_начала_смены,
					Дата_время_окончания_смены,
					Номер_первого_чека_в_смене,
					Номер_последнего_чека_в_смене,
					Сумма_продажи,
					Сумма_выручки,
					Сумма_в_денежном_ящике,
					Признак_изменения_данных,
					Дата_время_открытия_первого_чека,
					Сумма_продажи_наличные,
					Сумма_продажи_безналичные,
					Сумма_продажи_прочие,
					Сумма_выручки_наличные,
					Сумма_выручки_безналичные,
					Сумма_возвратов,
					Сумма_возвратов_наличные,
					Сумма_возвратов_безналичные,
					Количество_чеков_продажи,
					Количество_чеков_возврата
				)
			select
				workshiftid,
				shiftnum,
				scode,
				time_beg,
				time_end,
				checknum1,
				checknum2,
				sumsale,
				sumgain,
				sumdrawer,
				changed,
				firstchecktime,
				sumsalecash,
				sumsalenoncash,
				sumsaleother,
				sumgaincash,
				sumgainnoncash,
				sumrefund,
				sumrefundcash,
				sumrefundnoncash,
				countsale,
				countrefund
			from
				openquery(
					[pos_%cassnum%],
						''select
							`workshiftid`,
							`shiftnum`,
							`scode`,
							`time_beg`,
							`time_end`,
							`checknum1`,
							`checknum2`,
							`sumsale`,
							`sumgain`,
							`sumdrawer`,
							`changed`,
							`firstchecktime`,
							`sumsalecash`,
							`sumsalenoncash`,
							`sumsaleother`,
							`sumgaincash`,
							`sumgainnoncash`,
							`sumrefund`,
							`sumrefundcash`,
							`sumrefundnoncash`,
							`countsale`,
							`countrefund`,
							`cashcode`
						from
							`workshift`''
				) where time_beg is not null and time_beg >= dateadd(day, -%range%, getdate()) and time_beg >= ''20221101'' and cashcode = %cassnum% and scode is not null and (countsale + countrefund) > 0 
		'; -- Забираем только закрытые смены с цифрами, у которых указан кассир
		-- Берем данные за предыдущие 60 дней
		set @str = REPLACE(@str, '%cassnum%', @Код_кассы);
		-- Если явно указываем кассу для переснятия, то ищем смены за 60 дней, если это обычный обмен, то только за 3 дня
		if (@forcePOS = 1) set @shiftRange = 60 else set @shiftRange = 3;
		set @str = REPLACE(@str, '%range%', @shiftRange);
		begin try
			exec (@str);
		--	print('Выполнен запрос получения смен (Workshift)');
		end try
		begin catch

			-- На старых артиксах нет некоторых итоговых полей. Попробуем запрос без них
			set @str = '
				truncate table cass.t_raw_Смены
				insert into 
					cass.t_raw_Смены (
						ИД_смены,
						Номер_смены,
						Код_кассира,
						Дата_время_начала_смены,
						Дата_время_окончания_смены,
						Номер_первого_чека_в_смене,
						Номер_последнего_чека_в_смене,
						Сумма_продажи,
						Сумма_выручки,
						Сумма_в_денежном_ящике,
						Признак_изменения_данных,
						Дата_время_открытия_первого_чека,
						Сумма_продажи_наличные,
						Сумма_продажи_безналичные,
						Сумма_продажи_прочие,
						Сумма_выручки_наличные,
						Сумма_выручки_безналичные,
						Сумма_возвратов,
						Сумма_возвратов_наличные,
						Сумма_возвратов_безналичные,
						Количество_чеков_продажи,
						Количество_чеков_возврата
					)
				select
					workshiftid,
					shiftnum,
					scode,
					time_beg,
					time_end,
					checknum1,
					checknum2,
					sumsale,
					sumgain,
					sumdrawer,
					changed,
					firstchecktime,
					sumsalecash,
					sumsalenoncash,
					sumsaleother,
					sumgaincash,
					sumgainnoncash,
					sumrefund,
					sumrefundcash,
					sumrefundnoncash,
					countsale,
					countrefund
				from
					openquery(
						[pos_%cassnum%],
							''select
								`workshiftid`,
								`shiftnum`,
								`scode`,
								`time_beg`,
								`time_end`,
								`checknum1`,
								`checknum2`,
								`sumsale`,
								`sumgain`,
								`sumdrawer`,
								`changed`,
								`firstchecktime`,
								0 as `sumsalecash`,
								0 as`sumsalenoncash`,
								0 as`sumsaleother`,
								0 as `sumgaincash`,
								0 as `sumgainnoncash`,
								0 as `sumrefund`,
								0 as `sumrefundcash`,
								0 as `sumrefundnoncash`,
								0 as `countsale`,
								0 as `countrefund`,
								`cashcode`
							from
								`workshift`''
					) where time_beg is not null and time_beg >= dateadd(day, -60, getdate()) and cashcode = %cassnum% and scode is not null and sumsale > 0
			'; -- Забираем только закрытые смены с цифрами, у которых указан кассир
			-- Берем данные за предыдущие 60 дней
			set @str = REPLACE(@str, '%cassnum%', @Код_кассы);
			begin try
				exec (@str);
			--	print('Выполнен запрос получения смен (Workshift)');
			end try
			begin catch
				set @msg = concat('Не удалось выполнить запрос получения смен. КАССА БУДЕТ ПРОПУЩЕНА. Код_кассы: ', @Код_кассы, ', IP: ', @IP_адрес, ', Код_магазина: ', @Код_магазина, ', Ошибка: ', error_message());
				exec [dbo].[p_Сообщить_в_общий_журнал] 1, @object_name, @msg;
				set @msg = error_message();
				exec [cass].p_Добавить_информацию_об_ошибке_обмена @Код_кассы, @msg;
				continue;
			end catch
		end catch

		if @ИД_смены_для_переснятия > 0 delete from cass.t_raw_Смены where ИД_смены <> @ИД_смены_для_переснятия

		while (select count(*) from cass.t_raw_Смены) > 0 begin
			
			-- Проверка на существование/изменение данных в каждой смене. Если в хранилище смена отсутствует,
			-- или будут обнаружены расхождения, то данные будут перезагружены заново

			set @Номер_смены                      = (select top 1 Номер_смены                from cass.t_raw_Смены);
			set @Составной_код_смены              = cast(@Код_кассы as nvarchar) + '~' + cast(@Номер_смены as nvarchar);
			set @ИД_смены                         = (select ИД_смены                         from cass.t_raw_Смены where Номер_смены = @Номер_смены);
			set @Код_кассира                      = (select Код_кассира                      from cass.t_raw_Смены where Номер_смены = @Номер_смены);
			set @Составной_код_кассира            = cast(@Код_кассы as nvarchar) + '~' + cast(@Код_кассира as nvarchar);
			set @Дата_время_начала_смены          = (select Дата_время_начала_смены          from cass.t_raw_Смены where Номер_смены = @Номер_смены);
			set @Дата_время_окончания_смены       = (select Дата_время_окончания_смены       from cass.t_raw_Смены where Номер_смены = @Номер_смены);
			set @Номер_первого_чека_в_смене       = (select Номер_первого_чека_в_смене       from cass.t_raw_Смены where Номер_смены = @Номер_смены);
			set @Номер_последнего_чека_в_смене    = (select Номер_последнего_чека_в_смене    from cass.t_raw_Смены where Номер_смены = @Номер_смены);
			set @Сумма_продажи                    = (select Сумма_продажи                    from cass.t_raw_Смены where Номер_смены = @Номер_смены);
			set @Сумма_выручки                    = (select Сумма_выручки                    from cass.t_raw_Смены where Номер_смены = @Номер_смены);
			set @Сумма_в_денежном_ящике           = (select Сумма_в_денежном_ящике           from cass.t_raw_Смены where Номер_смены = @Номер_смены);
			set @Признак_изменения_данных         = (select Признак_изменения_данных         from cass.t_raw_Смены where Номер_смены = @Номер_смены);
			--set @Дата_время_открытия_первого_чека = (select Дата_время_открытия_первого_чека from cass.t_raw_Смены where ИД_смены = @ИД_смены);
			set @Сумма_продажи_наличные           = (select Сумма_продажи_наличные           from cass.t_raw_Смены where Номер_смены = @Номер_смены);
			set @Сумма_продажи_безналичные        = (select Сумма_продажи_безналичные        from cass.t_raw_Смены where Номер_смены = @Номер_смены);
			set @Сумма_продажи_прочие             = (select Сумма_продажи_прочие             from cass.t_raw_Смены where Номер_смены = @Номер_смены);
			set @Сумма_выручки_наличные           = (select Сумма_выручки_наличные           from cass.t_raw_Смены where Номер_смены = @Номер_смены);
			set @Сумма_выручки_безналичные        = (select Сумма_выручки_безналичные        from cass.t_raw_Смены where Номер_смены = @Номер_смены);
			set @Сумма_возвратов                  = (select Сумма_возвратов                  from cass.t_raw_Смены where Номер_смены = @Номер_смены);
			set @Сумма_возвратов_наличные         = (select Сумма_возвратов_наличные         from cass.t_raw_Смены where Номер_смены = @Номер_смены);
			set @Сумма_возвратов_безналичные      = (select Сумма_возвратов_безналичные      from cass.t_raw_Смены where Номер_смены = @Номер_смены);
			set @Количество_чеков_продажи         = (select Количество_чеков_продажи         from cass.t_raw_Смены where Номер_смены = @Номер_смены);
			set @Количество_чеков_возврата        = (select Количество_чеков_возврата        from cass.t_raw_Смены where Номер_смены = @Номер_смены);
			delete from cass.t_raw_Смены where Номер_смены = @Номер_смены;

			set @Флаг_загрузки_смены = 0;

			if ((select count(*) from cass.t_fact_Смены_на_кассах where Составной_код_смены = @Составной_код_смены) = 0) begin
				set @Флаг_загрузки_смены = 1;
				set @msg = concat('Смена отсутствует в хранилище. Перезапишем. Код_кассы: ', @Код_кассы, ', IP: ', @IP_адрес, ', Код_магазина: ', @Код_магазина, ', ИД_смены: ', @Номер_смены);
				exec [dbo].[p_Сообщить_в_общий_журнал] 3, @object_name, @msg;
			end

			if (@forceWorkshift = 0) begin
				-- Если явно не указана смена для переснятия, то перезаписываются только незакрытые смены (на кассе или в хранилище)
				if (@Дата_время_окончания_смены is null or 
					(select Дата_время_окончания_смены from cass.t_fact_Смены_на_кассах where Составной_код_смены = @Составной_код_смены) is null) 
					set @Флаг_загрузки_смены = 1;
				set @msg = concat('Смена не закрыта. Перезапишем. Код_кассы: ', @Код_кассы, ', IP: ', @IP_адрес, ', Код_магазина: ', @Код_магазина, ', ИД_смены: ', @Номер_смены);
				exec [dbo].[p_Сообщить_в_общий_журнал] 3, @object_name, @msg;
			end

			if (@forceWorkshift = 1) begin
				-- Если смена указано явно, то она переснимается в любом случае
				set @Флаг_загрузки_смены = 1;
				set @msg = concat('Смена явно указана. Перезапишем. Код_кассы: ', @Код_кассы, ', IP: ', @IP_адрес, ', Код_магазина: ', @Код_магазина, ', ИД_смены: ', @Номер_смены);
				exec [dbo].[p_Сообщить_в_общий_журнал] 3, @object_name, @msg;
			end

			-- Если смена существует и данные не изменились, то не загружаем
			if @Флаг_загрузки_смены = 0 continue;

			set @SeqNum = next value for cass.s_Код_загрузки_смены;

			set @TransactionName = left('CassLoader_' + cast(@Код_кассы as nvarchar) + '_' + cast(@Номер_смены as nvarchar), 32);

			-- Журнал загрузки смен
			insert into cass.t_j_История_загрузки_смен_на_кассе (
				Код_события,
				Код_кассы,
				ИД_смены,
				Составной_код_смены,
				Дата_время_начала_загрузки
			) values (
				@SeqNum,
				@Код_кассы,
				@Номер_смены,
				@Составной_код_смены,
				GETDATE()
			)

			-- Добавление информации о документах (чеках)

			begin try
				set @str = '
				truncate table [cass].[t_raw_Кассовые_документы]
				insert into
					[cass].[t_raw_Кассовые_документы] (
						ИД_документа,
						ИД_смены,
						Номер_чека,
						Код_кассира,
						Дата_время_открытия_чека,
						Дата_время_закрытия_чека,
						Возврат,
						Сумма_без_скидок,
						Итоговая_сумма_со_скидками,
						Печать_чека,
						Флаг_закрытия_чека
				) select 
					documentid,
					workshiftid,
					checknum,
					scode,
					time_beg,
					time_end,
					case when doctype = 1 then 0 else 1 end Возврат,
					sum1,
					sumb,
					closewithoutprint,
					closed
				from openquery (
					[pos_%cassnum%],
					''
					select
						`document`.`documentid`,
						`document`.`workshiftid`,
						`document`.`checknum`,
						`document`.`scode`,
						`document`.`time_beg`,
						`document`.`time_end`,
						`document`.`doctype`,
						`document`.`sum1`,
						`document`.`sumb`,
						`document`.`closewithoutprint`,
						`document`.`closed`
					from
						`documents`.`document`
					where
						`documents`.`document`.`workshiftid` = %workshiftid%
					''
				) where doctype in (1, 2, 25)';

				set @str = REPLACE(@str, '%cassnum%', @Код_кассы);
				set @str = REPLACE(@str, '%workshiftid%', @ИД_смены);
				exec(@str);
			end try
			begin catch
				--rollback tran @TransactionName
				set @msg = concat('Не удалось извлечь данные о документах из кассы в таблицу t_raw_Кассовые_документы (Смена НЕ была загружена). Код кассы: ', @Код_кассы, ', IP: ', @IP_адрес, ', Код_магазина: ', @Код_магазина, ', ИД_смены: ', @Номер_смены, ', Ошибка: ', error_message());
				exec [dbo].[p_Сообщить_в_общий_журнал] 1, @object_name, @msg;
				continue
			end catch

			-- Если есть данные старше 60 дней при регулярном обмене - явный признак аномалии, пропускаем такую смену
			if (@forcePOS = 0) and (Select count(*) from [cass].[t_raw_Кассовые_документы] 
					where Дата_время_закрытия_чека is null or Дата_время_закрытия_чека < dateadd(day, -60, cast(getdate() as date))) > 0 begin
				set @msg = concat('Смена пропущена, так как таблица чеков содержит незакрытый чек, либо закрытый более 60 дней назад (аномалия). Код кассы: ', @Код_кассы, ', IP: ', @IP_адрес, ', Код_магазина: ', @Код_магазина, ', ИД_смены: ', @Номер_смены, ', Ошибка: ', error_message());
				exec [dbo].[p_Сообщить_в_общий_журнал] 1, @object_name, @msg;
				continue
			end;

			-- Добавление информации об оплатах

			begin try
				set @str = '
				truncate table [cass].[t_raw_Оплаты]
				insert into
					[cass].[t_raw_Оплаты] (
						ИД_документа,
						Код_типа_оплаты,
						Сумма_оплаты,
						Номер_банковской_карты
				) select 
					documentid,
					valcode,
					sumb,
					cardnum
				from openquery (
					[pos_%cassnum%],
					''
					select distinct
						`moneyitem`.`documentid`,
						`moneyitem`.`valcode`,
						case when 
							cte70.sumb is null then 0 else cte70.sumb end - 
						case when 
							cte72.sumb is null then 0 else cte72.sumb end as sumb,
						(select a.`cardnum` from `documents`.`moneyitem` as a where a.`documentid` = `moneyitem`.`documentid` limit 1) cardnum
					from
						`documents`.`moneyitem`
					left join (
						select
							`moneyitem`.`documentid`,
							`moneyitem`.`valcode`,
							sum(`moneyitem`.`sumb`) as sumb,
							`moneyitem`.`opcode`
						from
							`documents`.`moneyitem`
						left join
							`documents`.`document` on `documents`.`moneyitem`.`documentid` = `documents`.`document`.`documentid`
						where
							`documents`.`document`.`workshiftid` = %workshiftid% and
							`documents`.`document`.`doctype` in (1, 2, 25) and `documents`.`document`.`closed` in (1, 2)
						group by
							`moneyitem`.`documentid`,`moneyitem`.`valcode`,`moneyitem`.`opcode`
					) as cte70 on 
						`documents`.`moneyitem`.`documentid` = cte70.`documentid` and 
						`documents`.`moneyitem`.`valcode` = cte70.`valcode` and 
						cte70.opcode in (70, 74)
					left join (
						select
							`moneyitem`.`documentid`,
							`moneyitem`.`valcode`,
							sum(`moneyitem`.`sumb`) as sumb,
							`moneyitem`.`opcode`
						from
							`documents`.`moneyitem`
						left join
							`documents`.`document` on `documents`.`moneyitem`.`documentid` = `documents`.`document`.`documentid`
						where
							`documents`.`document`.`workshiftid` = %workshiftid% and
							`documents`.`document`.`doctype` in (1, 2, 25) and `documents`.`document`.`closed` in (1, 2)
						group by
							`moneyitem`.`documentid`,`moneyitem`.`valcode`,`moneyitem`.`opcode`
					) as cte72 on 
						`documents`.`moneyitem`.`documentid` = cte72.`documentid` and 
						`documents`.`moneyitem`.`valcode` = cte72.`valcode` and 
						cte72.opcode in (72, 76)
					left join
						`documents`.`document` on `documents`.`moneyitem`.`documentid` = `documents`.`document`.`documentid`
					where
						`documents`.`document`.`workshiftid` = %workshiftid%;
					''
				)';

				set @str = REPLACE(@str, '%cassnum%', @Код_кассы);
				set @str = REPLACE(@str, '%workshiftid%', @ИД_смены);
				exec(@str);
			end try
			begin catch
				--rollback tran @TransactionName
				set @msg = concat('Не удалось извлечь данные об оплатах из кассы в таблицу t_raw_Оплаты (Смена НЕ была загружена). Код кассы: ', @Код_кассы, ', IP: ', @IP_адрес, ', Код_магазина: ', @Код_магазина, ', ИД_смены: ', @Номер_смены, ', Ошибка: ', error_message());
				exec [dbo].[p_Сообщить_в_общий_журнал] 1, @object_name, @msg;
				continue
			end catch

			-- Добавление информации о позициях документа

			begin try
				set @str = '
				truncate table [cass].[t_raw_Позиции_документа]
				insert into
					[cass].[t_raw_Позиции_документа] (
						ИД_позиции,
						ИД_документа,
						Код_кассира,
						Дата_время_добавления_позиции,
						Способ_добавления_позиции,
						Количество,
						Способ_ввода_количества,
						Цена,
						Минимальная_цена,
						Цена_позиции,
						Способ_ввода_цены,
						Сумма_скидки,
						Начальная_сумма_до_применения_скидок,
						Итоговая_сумма_после_применения_всех_скидок,
						Код_товара,
						Номер_позиции,
						Возврат
				) select 
					goodsitemid,
					documentid,
					scode,
					ttime,
					bcode_mode,
					bquant,
					bquant_mode,
					price,
					minprice,
					pricei,
					price_mode,
					disc_abs,
					sumi,
					sumb,
					code,
					posnum,
					case when opcode = 50 then 0 else 1 end Возврат
				from openquery (
					[pos_%cassnum%],
					''
					select
						`goodsitem`.`goodsitemid`,
						`goodsitem`.`documentid`,
						`goodsitem`.`scode`,
						`goodsitem`.`ttime`,
						`goodsitem`.`bcode_mode`,
						`goodsitem`.`bquant`,
						`goodsitem`.`bquant_mode`,
						`goodsitem`.`price`,
						`goodsitem`.`minprice`,
						`goodsitem`.`pricei`,
						`goodsitem`.`price_mode`,
						`goodsitem`.`disc_abs`,
						`goodsitem`.`sumi`,
						`goodsitem`.`sumb`,
						`goodsitem`.`code`,
						`goodsitem`.`posnum`,
						`goodsitem`.`opcode`
					from
						`documents`.`goodsitem`
					left join
						`documents`.`document` on `documents`.`goodsitem`.`documentid` = `documents`.`document`.`documentid`
					where
						`documents`.`document`.`workshiftid` = %workshiftid% and
						`documents`.`document`.`doctype` in (1, 2, 25) and `documents`.`document`.`closed` in (1, 2)
					''
				) where opcode in (50, 58)';

				set @str = REPLACE(@str, '%cassnum%', @Код_кассы);
				set @str = REPLACE(@str, '%workshiftid%', @ИД_смены);
				exec(@str);
			end try
			begin catch
				--rollback tran @TransactionName
				set @msg = concat('Не удалось извлечь данные о позициях документов в таблицу t_raw_Позиции_документа (Смена НЕ была загружена). Код кассы: ', @Код_кассы, ', IP: ', @IP_адрес, ', Код_магазина: ', @Код_магазина, ', ИД_смены: ', @Номер_смены, ', Ошибка: ', error_message());
				exec [dbo].[p_Сообщить_в_общий_журнал] 1, @object_name, @msg;
				continue
			end catch

			-- Если есть данные старше 60 дней при регулярном обмене - явный признак аномалии, пропускаем такую смену
			if (@forcePOS = 0) and (Select count(*) from [cass].[t_raw_Позиции_документа] 
					where Дата_время_добавления_позиции is null or Дата_время_добавления_позиции < dateadd(day, -60, cast(getdate() as date))) > 0 begin
				set @msg = concat('Смена пропущена, так как таблица детализации чеков содержит нулевую, либо старше 60 дней дату (аномалия). Код кассы: ', @Код_кассы, ', IP: ', @IP_адрес, ', Код_магазина: ', @Код_магазина, ', ИД_смены: ', @Номер_смены, ', Ошибка: ', error_message());
				exec [dbo].[p_Сообщить_в_общий_журнал] 1, @object_name, @msg;
				continue
			end;


			-- Добавление информации о скидках

			begin try
				set @str = '
				truncate table [cass].[t_raw_Скидки]
				insert into
					[cass].[t_raw_Скидки] (
						ИД_скидки,
						ИД_позиции,
						Номер_позиции,
						Код_кассира,
						Дата_время_применения_скидки,
						Объект_скидки,
						Номер_скидки,
						Режим_скидки,
						Тип_скидки,
						Ставка_скидки,
						Сумма_скидки,
						Сумма_чека,
						Номер_дисконтной_карты,
						Название_дисконтной_карты,
						ИД_кнопки,
						ИД_карты
				) select 
					discitemid,
					goodsitemid,
					positionnum,
					scode,
					dtime,
					ispositiondiscount,
					discnumber,
					discmode,
					disctype,
					discsize,
					discsum,
					checksum,
					cardnumber,
					cardname,
					buttonid,
					carditemid
				from openquery (
					[pos_%cassnum%],
					''
					select
						`discitem`.`discitemid`,
						`discitem`.`goodsitemid`,
						`discitem`.`positionnum`,
						`discitem`.`scode`,
						`discitem`.`dtime`,
						`discitem`.`ispositiondiscount`,
						`discitem`.`discnumber`,
						`discitem`.`discmode`,
						`discitem`.`disctype`,
						`discitem`.`discsize`,
						`discitem`.`discsum`,
						`discitem`.`checksum`,
						`discitem`.`cardnumber`,
						`discitem`.`cardname`,
						`discitem`.`buttonid`,
						`discitem`.`carditemid`
					from
						`documents`.`discitem`
					left join
						`documents`.`goodsitem` on `documents`.`discitem`.`goodsitemid` = `documents`.`goodsitem`.`goodsitemid`	
					left join
						`documents`.`document`  on `documents`.`goodsitem`.`documentid` = `documents`.`document`.`documentid`
					where
						`documents`.`document`.`workshiftid` = %workshiftid% and
						`documents`.`document`.`doctype` in (1, 2, 25) and `documents`.`document`.`closed` in (1, 2)
					''
				)';

				set @str = REPLACE(@str, '%cassnum%', @Код_кассы);
				set @str = REPLACE(@str, '%workshiftid%', @ИД_смены);
				exec(@str);
			end try
			begin catch
				--rollback tran @TransactionName
				set @msg = concat('Не удалось извлечь данные о скидках в таблицу t_raw_Скидки (Смена НЕ была загружена). Код кассы: ', @Код_кассы, ', IP: ', @IP_адрес, ', Код_магазина: ', @Код_магазина, ', ИД_смены: ', @Номер_смены, ', Ошибка: ', error_message());
				exec [dbo].[p_Сообщить_в_общий_журнал] 1, @object_name, @msg;
				continue
			end catch

			-- Если есть данные старше 60 дней при регулярном обмене - явный признак аномалии, пропускаем такую смену
			if (@forcePOS = 0) and (Select count(*) from [cass].[t_raw_Скидки]
					where Дата_время_применения_скидки is null or Дата_время_применения_скидки < dateadd(day, -60, cast(getdate() as date))) > 0 begin
				set @msg = concat('Смена пропущена, так как таблица скидок содержит нулевую, либо старше 60 дней дату (аномалия). Код кассы: ', @Код_кассы, ', IP: ', @IP_адрес, ', Код_магазина: ', @Код_магазина, ', ИД_смены: ', @Номер_смены, ', Ошибка: ', error_message());
				exec [dbo].[p_Сообщить_в_общий_журнал] 1, @object_name, @msg;
				continue
			end;

			-- Добавление информации о сторнированных позициях

			begin try
				set @str = '
				truncate table [cass].[t_raw_Сторнированные_позиции]
				insert into
					[cass].[t_raw_Сторнированные_позиции] (
						ИД_сторнированной_позиции,
						ИД_документа,
						Код_кассира,
						Дата_время_добавления_позиции,
						Дата_время_сторнирования_позиции,
						Способ_добавления_позиции,
						Количество,
						Способ_ввода_количества,
						Цена,
						Минимальная_цена,
						Цена_позиции,
						Способ_ввода_цены,
						Сумма_скидки,
						Начальная_сумма_до_применения_скидок,
						Итоговая_сумма_после_применения_скидок,
						Код_товара,
						Номер_сторнированной_позиции,
						Пользователь_подтвердивший_операцию
				) select 
					stornogoodsitemid,
					documentid,
					scode,
					tstime,
					timestorno,
					bcode_mode,
					bquant,
					bquant_mode,
					price,
					minprice,
					pricei,
					price_mode,
					disc_abs,
					sumi,
					sumb,
					code,
					posnum,
					opid
				from openquery (
					[pos_%cassnum%],
					''
					select
						`stornogoodsitem`.`stornogoodsitemid`,
						`stornogoodsitem`.`documentid`,
						`stornogoodsitem`.`scode`,
						`stornogoodsitem`.`tstime`,
						`stornogoodsitem`.`timestorno`,
						`stornogoodsitem`.`bcode_mode`,
						`stornogoodsitem`.`bquant`,
						`stornogoodsitem`.`bquant_mode`,
						`stornogoodsitem`.`price`,
						`stornogoodsitem`.`minprice`,
						`stornogoodsitem`.`pricei`,
						`stornogoodsitem`.`price_mode`,
						`stornogoodsitem`.`disc_abs`,
						`stornogoodsitem`.`sumi`,
						`stornogoodsitem`.`sumb`,
						`stornogoodsitem`.`code`,
						`stornogoodsitem`.`posnum`,
						`stornogoodsitem`.`opid`,
						`stornogoodsitem`.`opcode`
					from
						`documents`.`stornogoodsitem`
					left join
						`documents`.`document` on `documents`.`stornogoodsitem`.`documentid` = `documents`.`document`.`documentid`
					where
						`document`.`workshiftid` = %workshiftid%
					''
				) where opcode = 50';

				set @str = REPLACE(@str, '%cassnum%', @Код_кассы);
				set @str = REPLACE(@str, '%workshiftid%', @ИД_смены);
				exec(@str);
			end try
			begin catch
				--rollback tran @TransactionName
				set @msg = concat('Не удалось извлечь данные о сторнированных позициях в таблицу t_raw_Сторнированные_позиции (Смена НЕ была загружена). Код кассы: ', @Код_кассы, ', IP: ', @IP_адрес, ', Код_магазина: ', @Код_магазина, ', ИД_смены: ', @Номер_смены, ', Ошибка: ', error_message());
				exec [dbo].[p_Сообщить_в_общий_журнал] 1, @object_name, @msg;
				continue
			end catch

			-- Если есть данные старше 60 дней при регулярном обмене - явный признак аномалии, пропускаем такую смену
			if (@forcePOS = 0) and (Select count(*) from [cass].[t_raw_Сторнированные_позиции]
					where Дата_время_сторнирования_позиции is null or Дата_время_сторнирования_позиции < dateadd(day, -60, cast(getdate() as date))) > 0 begin
				set @msg = concat('Смена пропущена, так как таблица сторно содержит нулевую, либо старше 60 дней дату (аномалия). Код кассы: ', @Код_кассы, ', IP: ', @IP_адрес, ', Код_магазина: ', @Код_магазина, ', ИД_смены: ', @Номер_смены, ', Ошибка: ', error_message());
				exec [dbo].[p_Сообщить_в_общий_журнал] 1, @object_name, @msg;
				continue
			end;

			begin tran @TransactionName 

			-- Удаление смены. Все связанные данные удалятся каскадно.

			delete from
				cass.t_fact_Смены_на_кассах
			where
				cass.t_fact_Смены_на_кассах.Составной_код_смены = @Составной_код_смены

			-- Загрузка кассовых документов

			-- Добавление смены
				
			begin try 
				insert into 
					cass.t_fact_Смены_на_кассах (
						Код_кассы,
						Номер_смены,
						Дата_начала_смены,
						Дата_время_начала_смены,
						Дата_время_окончания_смены,
						Номер_первого_чека_в_смене,
						Номер_последнего_чека_в_смене,
						Сумма_продажи,
						Сумма_выручки,
						Сумма_в_денежном_ящике,
						Признак_изменения_данных,
						Дата_время_открытия_первого_чека,
						Сумма_продажи_наличные,
						Сумма_продажи_безналичные,
						Сумма_продажи_прочие,
						Сумма_выручки_наличные,
						Сумма_выручки_безналичные,
						Сумма_возвратов,
						Сумма_возвратов_наличные,
						Сумма_возвратов_безналичные,
						Количество_чеков_продажи,
						Количество_чеков_возврата,
						Составной_код_смены,
						Составной_код_кассира
					) values (
						@Код_кассы,
						@Номер_смены,
						cast(@Дата_время_начала_смены as date),
						@Дата_время_начала_смены,
						@Дата_время_окончания_смены,
						@Номер_первого_чека_в_смене,
						@Номер_последнего_чека_в_смене,
						@Сумма_продажи,
						@Сумма_выручки,
						@Сумма_в_денежном_ящике,
						@Признак_изменения_данных,
						@Дата_время_открытия_первого_чека,
						@Сумма_продажи_наличные,
						@Сумма_продажи_безналичные,
						@Сумма_продажи_прочие,
						@Сумма_выручки_наличные,
						@Сумма_выручки_безналичные,
						@Сумма_возвратов,
						@Сумма_возвратов_наличные,
						@Сумма_возвратов_безналичные,
						@Количество_чеков_продажи,
						@Количество_чеков_возврата,
						@Составной_код_смены,
						@Составной_код_кассира
					)
			end try
			begin catch
				rollback tran @TransactionName
				set @msg = concat('Не удалось добавить информацию о смене в таблицу t_fact_Смены_на_кассе (Смена НЕ была загружена). Код кассы: ', @Код_кассы, ', IP: ', @IP_адрес, ', Код_магазина: ', @Код_магазина, ', ИД_смены: ', @Номер_смены, ', Ошибка: ', error_message());
				exec [dbo].[p_Сообщить_в_общий_журнал] 1, @object_name, @msg;
				continue
			end catch

			-- Консолидируем данные в таблицы фактов

			-- Чеки
			
			begin try
				insert into
					cass.t_fact_Чеки(
						Код_кассы,
						Номер_чека,
						Дата_время_открытия_чека,
						Дата_закрытия_чека,
						Дата_время_закрытия_чека,
						Сумма_без_скидок,
						Итоговая_сумма_со_скидками,
						Печать_чека,
						Возврат,
						Сумма_оплаты_Наличные,
						Сумма_оплаты_Терминал,
						Сумма_оплаты_СБП_Сбербанк,
						Сумма_оплаты_Неинтегрированный_терминал_СБ,
						Сумма_оплаты_Накопительные_карты,
						Составной_код_смены,
						Составной_код_документа,
						Составной_код_кассира,
						Флаг_закрытия_чека,
						Номер_банковской_карты
					) select
						@Код_кассы,
						RDoc.Номер_чека,
						RDoc.Дата_время_открытия_чека,
						cast(RDoc.Дата_время_закрытия_чека as date),
						RDoc.Дата_время_закрытия_чека,
						RDoc.Сумма_без_скидок,
						RDoc.Итоговая_сумма_со_скидками,
						RDoc.Печать_чека,
						RDoc.Возврат,
						isnull(RM_n.Сумма_оплаты,  0) Сумма_оплаты_Наличные,
						isnull(RM_t.Сумма_оплаты,  0) Сумма_оплаты_Терминал,
						isnull(RM_s.Сумма_оплаты,  0) Сумма_оплаты_СБП,
						isnull(RM_nt.Сумма_оплаты, 0) Сумма_оплаты_Неинтегрированный_терминал_СБ,
						isnull(RM_c.Сумма_оплаты,  0) Сумма_оплаты_Накопительные_карты,
						@Составной_код_смены,
						@Составной_код_смены + '~' + cast(RDoc.ИД_документа as nvarchar),
						@Составной_код_кассира,
						Флаг_закрытия_чека,
						(Select top 1 Номер_банковской_карты from cass.t_raw_Оплаты where Номер_банковской_карты is not null 
																					and cass.t_raw_Оплаты.ИД_документа = RDoc.ИД_документа 
																					and cass.t_raw_Оплаты.Код_типа_оплаты in (2, 3)) Номер_банковской_карты
					from
						cass.t_raw_Кассовые_документы RDoc
					left join
						cass.t_raw_Оплаты RM_n  on RDoc.ИД_документа = RM_n.ИД_документа  and RM_n.Код_типа_оплаты  in (1)
					left join
						cass.t_raw_Оплаты RM_t  on RDoc.ИД_документа = RM_t.ИД_документа  and RM_t.Код_типа_оплаты  in (2,3)
					left join
						cass.t_raw_Оплаты RM_s  on RDoc.ИД_документа = RM_s.ИД_документа  and RM_s.Код_типа_оплаты  in (15)
					left join
						cass.t_raw_Оплаты RM_nt on RDoc.ИД_документа = RM_nt.ИД_документа and RM_nt.Код_типа_оплаты in (101)
					left join
						cass.t_raw_Оплаты RM_c  on RDoc.ИД_документа = RM_c.ИД_документа  and RM_c.Код_типа_оплаты  in (105)
						
			end try
			begin catch
				rollback tran @TransactionName
				set @msg = concat('Не удалось сформировать таблицу фактов t_Чеки. Код кассы: ', @Код_кассы, ', IP: ', @IP_адрес, ', Код_магазина: ', @Код_магазина, ', ИД_смены: ', @Номер_смены, ', Ошибка: ', error_message());
				exec [dbo].[p_Сообщить_в_общий_журнал] 1, @object_name, @msg;
				continue
			end catch


			-- Детализация чеков

			begin try
				insert into
					cass.t_fact_Детализация_чеков (
						Код_кассы,
						Код_товара,
						Дата_добавления_позиции,
						Дата_время_добавления_позиции,
						Способ_добавления_позиции,
						Количество,
						Способ_ввода_количества,
						Цена,
						Минимальная_цена,
						Цена_позиции,
						Способ_ввода_цены,
						Сумма_скидки,
						Начальная_сумма_до_применения_скидок,
						Итоговая_сумма_после_применения_скидок,
						Номер_позиции_в_чеке,
						Сумма_Наличные,
						Сумма_Терминал,
						Сумма_СБП_Сбербанк,
						Сумма_оплаты_Неинтегрированный_терминал_СБ,
						Сумма_оплаты_Накопительные_карты,
						Возврат,
						Составной_код_позиции,
						Составной_код_документа,
						Составной_код_кассира,
						Составной_код_смены
					) select
						@Код_кассы,
						RG.Код_товара,
						cast(RG.Дата_время_добавления_позиции as date),
						RG.Дата_время_добавления_позиции,
						RG.Способ_добавления_позиции,
						RG.Количество,
						RG.Способ_ввода_количества,
						RG.Цена,
						RG.Минимальная_цена,
						RG.Цена_позиции,
						RG.Способ_ввода_цены,
						RG.Сумма_скидки,
						RG.Начальная_сумма_до_применения_скидок,
						RG.Итоговая_сумма_после_применения_всех_скидок,
						RG.Номер_позиции,
						Case when RDoc.Итоговая_сумма_со_скидками = 0 then 0 else round(RG.Итоговая_сумма_после_применения_всех_скидок * ( ISNULL(RM_n.Сумма_оплаты, 0)  / RDoc.Итоговая_сумма_со_скидками),  2) end as Сумма_Наличные,
						Case when RDoc.Итоговая_сумма_со_скидками = 0 then 0 else round(RG.Итоговая_сумма_после_применения_всех_скидок * ( ISNULL(RM_t.Сумма_оплаты, 0)  / RDoc.Итоговая_сумма_со_скидками ), 2) end as Сумма_Терминал,
						Case when RDoc.Итоговая_сумма_со_скидками = 0 then 0 else round(RG.Итоговая_сумма_после_применения_всех_скидок * ( ISNULL(RM_s.Сумма_оплаты, 0)  / RDoc.Итоговая_сумма_со_скидками ), 2) end as Сумма_СБП_Сбербанк,						
						Case when RDoc.Итоговая_сумма_со_скидками = 0 then 0 else round(RG.Итоговая_сумма_после_применения_всех_скидок * ( ISNULL(RM_nt.Сумма_оплаты, 0) / RDoc.Итоговая_сумма_со_скидками ), 2) end as Сумма_оплаты_Неинтегрированный_терминал_СБ,						
						Case when RDoc.Итоговая_сумма_со_скидками = 0 then 0 else round(RG.Итоговая_сумма_после_применения_всех_скидок * ( ISNULL(RM_c.Сумма_оплаты, 0)  / RDoc.Итоговая_сумма_со_скидками ), 2) end as Сумма_оплаты_Накопительные_карты,
						RG.Возврат,
						@Составной_код_смены + '~' + CAST(RG.ИД_позиции as nvarchar),
						@Составной_код_смены + '~' + CAST(RG.ИД_документа as nvarchar),
						cast(@Код_кассы as nvarchar) + '~' + CAST(RG.Код_кассира as nvarchar),
						@Составной_код_смены
					from
						cass.t_raw_Позиции_документа RG
					left join
						cass.t_raw_Оплаты RM_n  on RG.ИД_документа = RM_n.ИД_документа  and RM_n.Код_типа_оплаты  in (1)
					left join
						cass.t_raw_Оплаты RM_t  on RG.ИД_документа = RM_t.ИД_документа  and RM_t.Код_типа_оплаты  in (3)
					left join
						cass.t_raw_Оплаты RM_s  on RG.ИД_документа = RM_s.ИД_документа  and RM_s.Код_типа_оплаты  in (15)
					left join
						cass.t_raw_Оплаты RM_nt on RG.ИД_документа = RM_nt.ИД_документа and RM_nt.Код_типа_оплаты in (101)
					left join
						cass.t_raw_Оплаты RM_c  on RG.ИД_документа = RM_c.ИД_документа  and RM_c.Код_типа_оплаты  in (105)
					left join
						cass.t_raw_Кассовые_документы RDoc on RG.ИД_документа = RDoc.ИД_документа
			end try
			begin catch
				rollback tran @TransactionName
				set @msg = concat('Не удалось сформировать таблицу фактов t_fact_Детализация_чеков. Код кассы: ', @Код_кассы, ', IP: ', @IP_адрес, ', Код_магазина: ', @Код_магазина, ', ИД_смены: ', @Номер_смены, ', Ошибка: ', error_message());
				exec [dbo].[p_Сообщить_в_общий_журнал] 1, @object_name, @msg;
				continue
			end catch

			-- Сторнированные позиции
			
			begin try
				insert into
					cass.t_fact_Сторнированные_позиции (
						Код_кассы,
						ИД_Сторнированной_позиции,
						Дата_время_добавления_сторнированной_позиции,
						Дата_сторнирования_позиции,
						Дата_время_сторнирования_позиции,
						Способ_добавления_позиции,
						Количество,
						Способ_ввода_количества,
						Цена,
						Минимальная_цена,
						Цена_позиции,
						Способ_ввода_цены,
						Сумма_скидки,
						Начальная_сумма_до_применения_скидок,
						Итоговая_сумма_после_применения_скидок,
						Код_товара,
						Номер_сторнированной_позиции,
						Составной_код_документа,
						Составной_код_кассира,
						Составной_код_кассира_подтвердившего_сторно
					) select
						@Код_кассы,
						ИД_сторнированной_позиции,
						Дата_время_добавления_позиции,
						cast(Дата_время_сторнирования_позиции as date),
						Дата_время_сторнирования_позиции,
						Способ_добавления_позиции,
						Количество,
						Способ_ввода_количества,
						Цена,
						Минимальная_цена,
						Цена_позиции,
						Способ_ввода_цены,
						Сумма_скидки,
						Начальная_сумма_до_применения_скидок,
						Итоговая_сумма_после_применения_скидок,
						Код_товара,
						Номер_сторнированной_позиции,
						@Составной_код_смены + '~' + CAST(ИД_документа as nvarchar),
						@Составной_код_кассира,
						cast(@Код_кассы as nvarchar) + '~' + cast(Пользователь_подтвердивший_операцию as nvarchar)
					from
						[cass].t_raw_Сторнированные_позиции
			end try
			begin catch
				rollback tran @TransactionName
				set @msg = concat('Не удалось сформировать таблицу фактов t_Сторнированные_позиции. Код кассы: ', @Код_кассы, ', IP: ', @IP_адрес, ', Код_магазина: ', @Код_магазина, ', ИД_смены: ', @Номер_смены, ', Ошибка: ', error_message());
				exec [dbo].[p_Сообщить_в_общий_журнал] 1, @object_name, @msg;
				continue
			end catch

			-- Скидки
			
			begin try
				insert into
					cass.t_fact_Скидки(
						Код_кассы,
						ИД_скидки,
						Код_товара,
						Номер_позиции,
						Дата_применения_скидки,
						Дата_время_применения_скидки,
						Объект_скидки,
						Номер_скидки,
						Режим_скидки,
						Тип_скидки,
						Ставка_скидки,
						Сумма_скидки,
						Сумма_чека,
						Номер_дисконтной_карты,
						Название_дисконтной_карты,
						ИД_карты, 
						Составной_код_позиции,
						Составной_код_кассира
					) select
						@Код_кассы,
						RD.ИД_скидки,
						RG.Код_товара,
						RD.Номер_позиции,
						cast(RD.Дата_время_применения_скидки as date),
						RD.Дата_время_применения_скидки,
						RD.Объект_скидки,
						RD.Номер_скидки,
						RD.Режим_скидки,
						RD.Тип_скидки,
						RD.Ставка_скидки,
						RD.Сумма_скидки,
						RD.Сумма_чека,
						RD.Номер_дисконтной_карты,
						RD.Название_дисконтной_карты,
						RD.ИД_карты,
						@Составной_код_смены + '~' + CAST(RD.ИД_позиции as nvarchar),
						@Составной_код_кассира
					from
						cass.t_raw_Скидки RD
					left join
						cass.t_raw_Позиции_документа RG on RD.ИД_позиции = RG.ИД_позиции
						
			end try
			begin catch
				rollback tran @TransactionName
				set @msg = concat('Не удалось сформировать таблицу фактов t_fact_Скидки. Код кассы: ', @Код_кассы, ', IP: ', @IP_адрес, ', Код_магазина: ', @Код_магазина, ', ИД_смены: ', @Номер_смены, ', Ошибка: ', error_message());
				exec [dbo].[p_Сообщить_в_общий_журнал] 1, @object_name, @msg;
				continue
			end catch

			begin try
				commit tran @TransactionName

			update 
				cass.t_j_История_загрузки_смен_на_кассе
			set 
				Дата_время_окончания_загрузки = getDate()
			where 
				Код_события = @SeqNum;
			end try
			begin catch
				rollback tran @TransactionName
				set @msg = concat('Не удалось зафиксировать транзакцию загрузки данных (Смена НЕ была загружена): ', @Код_кассы, ', IP: ', @IP_адрес, ', Код_магазина: ', @Код_магазина, ', ИД_смены: ', @Номер_смены, ', Ошибка: ', error_message());
				exec [dbo].[p_Сообщить_в_общий_журнал] 1, @object_name, @msg;
				continue
			end catch
		end
	end
END
