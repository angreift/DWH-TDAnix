﻿CREATE VIEW [td].[v_fact_ПД]
	AS SELECT 
		Ш.[Составной_код_ПД],
		[Дата_ПД],
		[Код_магазина],
		[Форма_оплаты],
		[Код_поставщика_RSF],
		[Код_магазина_отправителя],
		[Составной_код_заявки_РЦ],
		[Составной_код_заявки_СТ],
		[Номер_фактуры],
		[Дата_фактуры],
		[Основание],
		[Дата_ТТН],
		[Номер_ТТН],
		[Код_товара],
		[Количество_факт],
		[Количество_план],
		[Количество_по_документу],
		[Цена_закупа],
		[Сумма_закупа],
		[Процент_наценки],
		[Цена],
		[Сумма],
		[Процент_НДС],
		[Сумма_НДС_закупочная],
		[Сумма_НДС_розничная],
		[Срок_годности],
		[Штрихкод],
		[Поставщик_холдинга]
	from
		td.t_fact_ПД_шапки Ш
	join
		td.t_fact_ПД_строки С on Ш.Составной_код_ПД = С.Составной_код_ПД
