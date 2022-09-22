CREATE TABLE [cass].[t_dim_Пользователи_на_кассах] (
	[Логин_пользователя] [nvarchar](100) NOT NULL,
	[Имя_пользователя] [nvarchar](50) NOT NULL,
	[Запрещена_авторизация] [bit] NULL,
	[Должность] [nvarchar](30) NULL,
	[ИНН] [nvarchar](20) NULL,
	[Составной_код_кассира] [nvarchar](20) NOT NULL,
	[Код_кассы] [int] NOT NULL
 CONSTRAINT [PK_t_dim_Пользователи_на_кассах] PRIMARY KEY NONCLUSTERED 
(
	[Составной_код_кассира] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [OTHERS]
) ON [DIMENTIONS]
GO

