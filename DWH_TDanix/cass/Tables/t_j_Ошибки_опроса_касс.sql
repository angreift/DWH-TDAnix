CREATE TABLE [cass].[t_j_Ошибки_опроса_касс]
(
	Код_события int not null identity(1,1),
	Дата_время_события datetime not null,
	Код_кассы int not null,
	Сообщение nvarchar(max) null
) on [JOURNAL]
