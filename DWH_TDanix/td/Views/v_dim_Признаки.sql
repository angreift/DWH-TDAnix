CREATE VIEW [td].[v_dim_Признаки]
	AS SELECT distinct Признак FROM td.t_fact_Товарная_матрица
