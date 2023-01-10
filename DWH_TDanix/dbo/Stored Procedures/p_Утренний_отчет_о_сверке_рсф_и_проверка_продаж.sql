-- =============================================
-- Author:		vae20367, kma1860
-- Create date: 09/01/2023
-- Description:	Автоматическая сверка сумм РСФ и Хранилища чеков, а так же проверка продаж в ОТБРС
-- =============================================

CREATE PROCEDURE [dbo].[p_Утренний_отчет_о_сверке_рсф_и_проверка_продаж] @output nvarchar(max) output
AS
BEGIN
	declare @dateStart2000  datetime;
	declare @dateEnd2000    datetime;
	declare @dateStart      datetime;
	declare @dateEnd        datetime;
	declare @letter_text    nvarchar(max);
	declare @dateSQL2000    nchar(8);
	declare @letter_subject nvarchar(255);
	declare @n              int;

	set @dateStart     = cast(cast(dateadd(day, -7, GETDATE()) as date) as datetime);
	set @dateStart2000 = dateadd(year, 2000, @dateStart);
	set @dateEnd       = dateadd(day, 6, DATEADD(second, -1, DATEADD(DAY, 1, @dateStart)));
	set @dateEnd2000   = dateadd(year, 2000, @dateEnd);
	set @dateSQL2000   = format(@dateEnd, 'yyyyMMdd');

		-- Проверим разницу между РСФ, хранилищем и DWH

		drop table if exists tempdb.dbo.morning_report_cube_rsf

		create table tempdb.dbo.morning_report_cube_rsf (
			Дата date,
			Код_магазина int,
			Имя_магазина nchar(50),
			Чеки_сумма money,
			РСФ_сумма money,
			DWH_сумма money
		)

		declare @d table (d datetime);
		set @n = 0;
		while dateadd(day, @n, @dateStart) <= @dateEnd begin
			insert into @d (d) values (dateadd(day, @n, @dateStart))
			set @n = @n + 1;
		end

		insert 
			into tempdb.dbo.morning_report_cube_rsf
		select
			Дата,
			Код Код_магазина,
			Наименование Имя_магазина,
			СуммаЧеки Чеки_сумма,
			СуммаРСФ РСФ_сумма,
			СуммаDWH DWH_сумма 
		from (
			Select
				d Дата, 
				t.Код, 
				t.Наименование, 
				case when чеки.Сумма is null then 0 else чеки.Сумма end СуммаЧеки, 
				case when РСФ.Сумма is null then 0 else РСФ.Сумма end СуммаРСФ,
				case when DWH.Сумма is null then 0 else DWH.Сумма end СуммаDWH
			from
				[dbo].[t_dim_Магазины] t
			cross join @d
			left join (
				select 
					Чеки.[Дата_закрытия_чека] Дата,
					Магазины.[Код] КодМагазина,
					sum(Чеки.[Итоговая_сумма_со_скидками]) Сумма
				from [DWH].[cass].[t_fact_Чеки] as Чеки
				left join [DWH].[cass].[t_dim_Кассы] as Кассы on Кассы.[Код_кассы] = Чеки.[Код_кассы]
				left join [DWH].[dbo].[t_dim_Магазины] as Магазины on Кассы.[Код_магазина] = Магазины.[Код]
				where Чеки.[Дата_закрытия_чека] between @dateStart and @dateEnd and Магазины.[Группа] = 'Розница                                 '
				group by Чеки.[Дата_закрытия_чека], Магазины.[Код], Магазины.[Наименование]
			) Чеки on t.Код = Чеки.КодМагазина and d = Чеки.Дата
			left join (
				SELECT 
					dateadd(year, -2000, cast([_Date_Time] as date)) as Дата,
					СтруктурныеЕдиницы._Code КодМагазина,
					Sum(ZОтчет.[_Fld1800]) Сумма
				FROM 
					[S19-RDSAPP-PROD].[RSF].[dbo].[_Document146] ZОтчет
				left join [S19-RDSAPP-PROD].[RSF].[dbo].[_Reference107] СтруктурныеЕдиницы on ZОтчет._Fld1798RRef = СтруктурныеЕдиницы._IDRRef
				where 
					[_Date_Time] between @dateStart2000 and @dateEnd2000
					and 
					ZОтчет._Fld1796RRef = 0xA1A8005056B3407811E239FAE9D25FE9
					and 
					ZОтчет._Posted = 0x01
				group by dateadd(year, -2000, cast([_Date_Time] as date)),СтруктурныеЕдиницы._Code
			) РСФ on t.Код = РСФ.КодМагазина and d = РСФ.Дата
			left join (
				select
					Дата_закрытия_чека Дата, 
					Код_магазина Код_магазина,
					sum([Итоговая_сумма_со_скидками]) Сумма
				from dwh.cass.v_fact_Чеки
				where Дата_закрытия_чека between @dateStart and @dateEnd
				group by Дата_закрытия_чека, Код_магазина
			) dwh on t.Код = dwh.Код_магазина and d = dwh.Дата
			where Группа in ('Розница                                 ', 'РС Закрытые                             ') 
		) as a where СуммаРСФ <> СуммаЧеки

		if (select count(*) from tempdb.dbo.morning_report_cube_rsf) > 0
			begin
				set @output = concat(
					@output,
					'Есть расхождения между рсф, olap-rozn, DWH. Добавляем информацию об этом в текст письма',
					char(13), char(13)
				)

				set @letter_text = concat(
					@letter_text,
					'Обнаружены расхождения между РСФ и хранилищами чеков ([s19-olap].[olap-rozn])',
					char(13), char(13)
				);
				set @letter_text = concat(@letter_text, (
					select
						STRING_AGG(cast(
							concat(
								cast(t.Дата as NCHAR(10)),
								' | ',
								cast(t.Код_магазина as nchar(3)),
								' | ', 
								cast(t.Имя_магазина as nchar(50)),
								' Хранилище: ', 
								cast(t.Чеки_сумма as nchar(10)),
								'; РСФ: ', 
								cast(t.РСФ_сумма as nchar(10)), 
								'; DWH: ',
								cast(t.DWH_сумма as nchar(10))
							) as nvarchar(max))
						, CHAR(13))

					from
						tempdb.dbo.morning_report_cube_rsf t
				))
				set @letter_text = concat(
					@letter_text,
					CHAR(13), '.', CHAR(13),
					'Возможные проблемы:', char(13), 
					'	· Не закрыта смена на кассе, не установлен флаг закрытия смены в документе ОтчетОтдела базы магазина', char(13),
					'	· Отрицательная сумма смены (нужно привязать возврат к другому отчету отдела)', char(13),
					'	· Не работает обмен БМ -> РСФ', char(13),
					'	· Не работает сборщик SERV-OLAP', char(13),
					'	· Поломка кассы', char(13), '.', char(13),
					'----------------------------------------------', char(13), '.', char(13)
				)
			end
		else
			set @output = concat(
				@output,
				'Расхождений между рсф и кубами нет',
				char(13), char(13)
			)
		set @output = concat(
			@output,
			Concat(
				'Текст письма:',
				char(13),
				@letter_text,
				char(13), char(13)
			),
			char(13), char(13)
		)
		set @output = concat(
			@output,
			concat(
				'Длина текста письма: ',
				len(@letter_text),
				char(13), char(13)
			),
			char(13), char(13)
		)

		if len(@letter_text) > 0
			begin
				set @letter_subject = 'Сверка данных о продажах (ОТБРС, РСФ)';
				set @output = concat(
					@output,
					'СФормировано не пустое письмо, отправляем его в Итилиум и на альяс',
					char(13), char(13)
				)
				exec msdb.dbo.sp_send_dbmail 
					@profile_name ='service-account@anixtd.ru'
					,@recipients = 'vae20367@tdanix.ru'
					,@body = @letter_text
					,@subject = @letter_subject
					-- 'olap-problem@anixtd.ru'
			end
		else
			set @output = concat(
				@output,
				'Проблем нет, письма не отправляем',
				char(13), char(13)
			)
END