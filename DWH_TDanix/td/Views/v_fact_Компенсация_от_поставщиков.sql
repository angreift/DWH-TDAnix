﻿CREATE VIEW [td].[v_fact_Компенсация_от_поставщиков]
	AS SELECT Код_магазина,Код_товара,Код_поставщика,Дата,Сумма FROM td.t_fact_Компенсация_от_поставщиков
