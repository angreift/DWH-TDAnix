CREATE TABLE [cass].[t_j_История_загрузки_смен_на_кассе] (
    [Код_события]                   INT      NOT NULL,
    [Код_кассы]                     INT      NOT NULL,
    [ИД_смены]                      INT      NOT NULL,
    [Дата_время_начала_загрузки]    DATETIME NOT NULL,
    [Дата_время_окончания_загрузки] DATETIME NULL,
    [ИД_обмена]                     BIGINT   NULL,
    [Составной_код_смены] [nvarchar](20) NOT NULL
) ON [JOURNAL];

