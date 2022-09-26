-- =============================================
-- Author:		kma1860
-- Create date: 23/09/2022
-- Description:	Отчет об обмене с кассами
-- =============================================
CREATE PROCEDURE [cass].[p_Отчет_об_обмене_с_кассами]
AS
BEGIN
	set nocount on
	declare @letter_body nvarchar(max);
	set @letter_body = '';
	declare @letter_subject nvarchar(255);

	drop table if exists #Неправильные_номера_касс


	declare @cid int;
	declare @str nvarchar(max);
	declare @cid_cass int;
	declare cur cursor local for
	select
		Код_кассы	
	from 
		cass.t_dim_Кассы
	where
		cass.t_dim_Кассы.Включена = 1

	drop table if exists ##cass 

	create table ##cass (
		code int,
		code_in_cass int
	)

	open cur
	fetch next from cur into @cid
	while @@FETCH_STATUS = 0 begin

		set @str = '
		insert into ##cass (code, code_in_cass)
		select
			null,
			cashcode
		from openquery(
			[pos_%cid%], ''
				select cashcode from workshift order by time_beg desc limit 1;
			''
		)';
		set @str = replace(@str, '%cid%', @cid);
		begin try
			exec(@str);
		end try
		begin catch
			print('Нет связи: ' + cast(@cid as nvarchar))
		end catch
	
		update ##cass set code = @cid where code is null

		fetch next from cur into @cid

	end

	delete from ##cass where code = code_in_cass
	
	if (select count(*) from ##cass) > 0 begin
		set @letter_body = @letter_body + 'На следующих кассах установлен неправильный код! Поправьте код на кассе, а так же в таблице documents.workshift' + char(10) + '   ' + char(10);
		set @letter_body = @letter_body + (		
			select 
				string_agg(
					concat(
						'Код на кассе: ', k1.code_in_cass, ', Касса №', k2.Код_кассы,  ' (ip ', k2.IP_Адрес, '); Магазин ', k2.Код_магазина, ' ', trim(k2.Наименование_магазина), ' (', trim(k2.Группа_магазина), ')'
					), '   ' + char(10)
				)
			from 
				##cass k1
			left join
				cass.v_dim_Кассы k2 on k1.code = k2.Код_кассы
		)
		set @letter_body = @letter_body + CHAR(10) + '   ' + char(10);
	end

	drop table if exists #Неопрошенные_кассы

	SELECT к.[Код_кассы] as [Код_кассы]
		,к.[IP_Адрес] as [IP_Адрес]
		,к.[Включена] as [Включена]
		,к.[Код_магазина] as [Код_магазина]
		,к.[Группа_магазина] as [Группа_магазина]
		,к.[Наименование_магазина] as [Наименование_магазина]
		,(
			select top 1 
				сообщение 
			from 
				dbo.v_j_Общий_журнал_ошибки о with (nolock)
			where
				cast(о.Дата_время_события as date) = dateadd(day, -1, cast(getdate() as date)) and 
				charindex('Код_кассы: ' + cast(к.Код_кассы as nvarchar) + ',', о.Сообщение) > 0 and
				charindex('Не удалось выполнить запрос к таблице Mol.', о.Сообщение) = 0 and
				charindex('Не удалось проинициализировать объект источника данных поставщика OLE DB', о.Сообщение) = 0
		  ) as [Сообщение]
	into
		#Неопрошенные_кассы
	FROM [DWH].[cass].[v_dim_Кассы] к with (nolock)
	where Включена = 1 and not exists (
		SELECT [Код_события]
		,[Код_кассы]
		,[ИД_смены]
		,[Дата_время_начала_загрузки]
		,[Дата_время_окончания_загрузки]
		,[ИД_обмена]
		,[Составной_код_смены]
		FROM [DWH].[cass].[t_j_История_загрузки_смен_на_кассе] with (nolock)
		where cast(Дата_время_начала_загрузки as date) = dateadd(day, -1, cast(getdate() as date))
		and Дата_время_окончания_загрузки is not null
		and Код_кассы = к.Код_кассы
	) 		
	order by Группа_магазина, Наименование_магазина

	if (select count(*) from #Неопрошенные_кассы) > 0 begin
	
		set @letter_body = @letter_body + 'За предыдущие сутки не удалось опросить следующие кассы:   ' + char(10) + '   ' + char(10);

		set @letter_body = @letter_body + (
			select
				string_agg(
					concat(
						'Касса №', Код_кассы,  ' (ip ', IP_Адрес, '); Магазин ', Код_магазина, ' ', trim(Наименование_магазина), ' (', trim(Группа_магазина), ')', 
						case when Сообщение is not null then concat('; [Сообщение об ошибке: ', trim(replace(replace(replace(Сообщение, char(13), ' '), char(10), ' '), '	', '')), ']') else '' end 
					), '   ' + char(10)
				)
			from
				#Неопрошенные_кассы
		)

		set @letter_body = @letter_body + char(10) + char(13) + 'Если касса больше не работает, отключите обмен с ней.' + char(10);

		drop table if exists #Медленные_кассы

		select ъ.Код_кассы, ъ.Время, к.Группа_магазина, к.Код_магазина, к.Наименование_магазина, к.IP_Адрес
		into
			#Медленные_кассы
		from (
			select Код_кассы, avg([Время загрузки в мс]) Время
			from 
				cass.v_j_Итория_загрузки_смен
			where 
				cast(Дата_время_начала_загрузки as date) = dateadd(day, -1, cast(getdate() as date)) and
				[Время загрузки в мс] is not null

			group by Код_кассы
			having avg([Время загрузки в мс]) >= 10000
		
		) as ъ
		left join cass.v_dim_Кассы к on ъ.Код_кассы = к.Код_кассы
		order by Время desc
		if (select count(*) from #Медленные_кассы) > 0 begin 
			set @letter_body = concat(@letter_body, char(10), 
				'Сводка по скорости обмена с кассами: за вчерашние сутки средняя скорость загрузки одной смены с кассы составила ', (
					select avg([Время загрузки в мс]) Время
					from 
						cass.v_j_Итория_загрузки_смен
					where 
						cast(Дата_время_начала_загрузки as date) = dateadd(day, -1, cast(getdate() as date)) and
						[Время загрузки в мс] is not null
				), ' мс. Топ самых медленных касс за вчера:', char(10))
			set @letter_body = @letter_body + (
				select
					string_agg(cast(
						concat(
							'Касса №', Код_кассы, ' (', IP_Адрес, ') - ', Время, ' мс | ', Код_магазина, ' ', trim(Наименование_магазина), ' (', trim(Группа_магазина), ') ' 
						) as nvarchar(max)), '   ' + char(10)
					)
				from
					#Медленные_кассы
			) + '   ' + char(10) + 'Оптимальное время загрузки одной смены - от 500 до 3000 мс';
		end;
	end

	if len(@letter_body) > 0 begin
		set @letter_subject = 'Отчет об обмене с кассами';
		exec msdb.dbo.sp_send_dbmail 
			@profile_name ='service-account@anixtd.ru'
			,@recipients = 'olap-problem@anixtd.ru;help@anixtd.ru'
			,@body = @letter_body
			,@subject = @letter_subject

	end
END