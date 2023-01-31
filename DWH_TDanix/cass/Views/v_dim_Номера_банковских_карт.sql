CREATE VIEW [cass].[v_dim_Номера_банковских_карт]
	AS SELECT DISTINCT 
		Coalesce(Номер_банковской_карты, '(Не по банковской карте)') Номер_банковской_карты
	FROM            
		cass.t_fact_Чеки