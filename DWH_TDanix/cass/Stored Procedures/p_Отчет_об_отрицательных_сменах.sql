-- =============================================
-- Author:		vae20367
-- Create date: 18/01/2023
-- Description:	Отчет об обмене с кассами
-- =============================================


CREATE PROCEDURE [cass].[p_Отчет_об_отрицательных_сменах]
AS
BEGIN
	set nocount on
	declare @letter_text    nvarchar(max),
			@letter_subject nvarchar(255);
	set @letter_text = '';

	declare @buff_table table (
		Код_кассы int,
		Код_магазина int,
		Номер_смены int,
		Дата_начала_смены date,
		Сумма_выручки decimal(14, 2),
		Группа nvarchar(50),
		Наименование nvarchar(100)
	);

	insert into @buff_table
	select
		Смены.Код_кассы,
		Кассы.Код_магазина,
		Смены.Номер_смены,
		Смены.Дата_начала_смены,
		Смены.Сумма_выручки,
		Магазины.Группа,
		Магазины.Наименование
	from [DWH].[cass].[t_fact_Смены_на_кассах] as Смены
	left join cass.t_dim_Кассы as Кассы on Кассы.Код_кассы = Смены.Код_кассы
	left join dbo.t_dim_Магазины as Магазины on Магазины.Код = Кассы.Код_магазина
	where 
		Смены.Дата_время_окончания_смены is not null and 
		Смены.Сумма_выручки < 0 and 
		Смены.Дата_начала_смены = dateadd(day, -1, getdate())
	order by [Дата_начала_смены] desc


	if (select count(*) from @buff_table) > 0
		begin
		
			set @letter_text = @letter_text + 'За предыдущие сутки имеются смены с отрицательной выручкой:   ' + char(10) + '   ' + char(10);

			set @letter_text = @letter_text + (
				select
					string_agg(
						cast(
							concat(
								'Касса №: ', 
								Код_кассы,  
								'; Код Магазина: ', 
								Код_магазина, 
								'; Смена №:', 
								Номер_смены, 
								'; Наименование магазина: ', 
								trim(Наименование), 
								' (', 
								trim(Группа), 
								'); Сумма_Выручки: ',
								Сумма_выручки
							) as nvarchar(max)
						), '   ' + char(10)
					)
				from
					@buff_table
			);

			set @letter_subject = 'Отчёт об отрицательных сменах';
			exec msdb.dbo.sp_send_dbmail 
				@profile_name ='service-account@anixtd.ru'
				,@recipients = 'olap-problem@anixtd.ru,prog_rozn@tdanix.ru'
				,@body = @letter_text
				,@subject = @letter_subject

		end
END
