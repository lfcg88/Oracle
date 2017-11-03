SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_ENVIAR_EMAIL]
(         
	  @ASSUNTO AS VARCHAR(500),
	  @CORPO_MENSAGEM AS VARCHAR(5000),
	  @PARA AS VARCHAR(1000)	  
)
AS

EXEC msdb.dbo.sp_send_dbmail @profile_name = 'SQLMIPRODI',
                             @recipients= @PARA,
                             @SUBJECT=@ASSUNTO,
                             @Body=@CORPO_MENSAGEM
