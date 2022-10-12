-- =============================================
-- Author:		kma1860
-- Create date: 11/10/2022
-- Description:	Принимает наименования складов из магазина, синхронизирует со справочником DWH и возвращает кода
-- =============================================
CREATE PROCEDURE [td].[p_Синхронизация_складов_из_БМ]
	@Имена_складов nvarchar(max)
AS
BEGIN
	SET NOCOUNT ON;
	Declare @Return table (
		Код_склада int,
		Наименование_склада varchar(65)
	);
	Declare @ТекущийСклад varchar(65);
	while (len(@Имена_складов) > 0) begin
		Set @ТекущийСклад = left(@Имена_складов, charindex(';', @Имена_складов) - 1);
		Set @Имена_складов = substring(@Имена_складов, CHARINDEX(';', @Имена_складов) + 1, len(@Имена_складов) - CHARINDEX(';', @Имена_складов));
		merge 
			[td].t_dim_Склад_в_магазине a
		using
			(select @ТекущийСклад Склад) [raw] on a.Наименование_склада = [raw].Склад
		when not matched then 
			insert (Наименование_склада) values ([raw].Склад);
		Insert into @Return (Код_склада, Наименование_склада) 
			select [Код_склада], [Наименование_склада] from [td].[t_dim_Склад_в_магазине] where Наименование_склада = @ТекущийСклад
	end
	Select * from @Return;
END
GO


