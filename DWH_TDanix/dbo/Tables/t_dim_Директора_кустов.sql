CREATE TABLE [dbo].[t_dim_Директора_кустов]
(
	[Составной_код_директора] NVARCHAR(20) NOT NULL, 
    [Директор] NVARCHAR(40) NOT NULL,
	CONSTRAINT [PK_t_dim_Директора_кустов] PRIMARY KEY CLUSTERED ([Составной_код_директора] ASC) ON [DIMENTIONS]
) ON [DIMENTIONS];
