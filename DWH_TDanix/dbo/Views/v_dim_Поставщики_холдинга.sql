CREATE VIEW [dbo].[v_dim_Поставщики_холдинга]
	AS Select distinct 
		Поставщик_холдинга
	FROM td.t_fact_ПД_строки
	union 
	select '(Не задан)'