﻿CREATE TABLE [dbo].[t_dim_Товары] (
    [Код_товара]                    BIGINT       NOT NULL,
    [Наименование]                  NVARCHAR (55) NOT NULL,
    [Акцизный_объём]                FLOAT (53)   NULL,
    [Ассортимент]                   INT          NULL,
    [Бренд]                         NVARCHAR (45) NULL,
    [Вид_упаковки]                  NVARCHAR (50) NULL,
    [Главный_код]                   BIGINT       NULL,
    [Главный_аналог_для_автозаказа] BIGINT       NULL,
    [Дней_годности]                 INT          NULL,
    [Единиц_в_упаковке]             FLOAT (53)   NULL,
    [Единица_измерения]             NVARCHAR (10) NULL,
    [Марка]                         NVARCHAR (50) NULL,
    [Собственная_торговая_марка]    BIT          NULL,
    [Страна]                        NVARCHAR (50) NULL,
    [Страна_производитель]          NVARCHAR (50) NULL,
    [Маркировка]                    BIT          NULL,
    [Период_грин]                   BIT          NULL,
    [Гастрономия]                   BIT          NULL,
    [Вид_маркированной_продукции]   NVARCHAR (50) NULL,
    [Категория_группы]                    NVARCHAR (50) NULL,
    [Код_группы]                    BIGINT       NOT NULL,
    [Наименование_группы]           NVARCHAR (50) NOT NULL,
    [Код_подгруппы]                 BIGINT       NULL,
    [Наименование_подгруппы]        NVARCHAR (50) NULL,
    [Менеджер_группы]               nvarchar (100) null
    CONSTRAINT [ix_cl_Код] PRIMARY KEY CLUSTERED ([Код_товара] ASC) ON [DIMENTIONS]
) ON [DIMENTIONS];

