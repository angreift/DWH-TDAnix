CREATE TABLE [dbo].[t_dim_Время] (
    [Время_ИД]                    nvarchar(8)   NOT NULL,
    [Час]                         nvarchar(2)   NOT NULL,
    [Минута]                      NVARCHAR (2)  NOT NULL,
    [Секунда]                     NVARCHAR (2) NOT NULL,
    
    CONSTRAINT [PK_t_dim_Время] PRIMARY KEY CLUSTERED ([Время_ИД] ASC) ON [DIMENTIONS]
) ON [DIMENTIONS];

