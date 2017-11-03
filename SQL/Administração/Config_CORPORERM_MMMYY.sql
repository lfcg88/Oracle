

USE CORPORERM_JUL08
GO

-- VISUALISANDO OS USUARIOS E ABAIXO OS ALIAS(INICIADO POR \)
sp_helpuser

-- SELECIONANDO OS ALIAS
select * from sysusers where name like '\%'

-- ALTERANDO CONFIGURA플O DO BANCO PARA PERMITIR ALTERA합ES
exec sp_configure 'allow updates', 1
reconfigure with override

-- APAGANDO ALIAS ANTIGOS
delete from sysusers where name like '\%'

-- VOLTANDO A CONFIGURA플O ORIGINAL DO BANCO
exec sp_configure 'allow updates', 0
reconfigure with override

-- CRIANDO NOVOS ALIAS
sp_addalias 'sysdba','dbo'
sp_addalias 'Amelia','dbo'
sp_addalias 'RM','dbo'
sp_addalias 'Rmnet','dbo'

-- VISUALISANDO OS USUARIOS E ABAIXO OS ALIAS
sp_helpuser

-- VERIFICANDO MODO DE RECOVERY DO BANCO (OLHAR COLUNA STATUS)
sp_helpdb CORPORERM_JUL08

-- ALTERANDO RECOVERY DO BANCO PARA SIMPLE
alter database CORPORERM_JUL08 set recovery simple

-- VERIFICANDO ALTERA플O
sp_helpdb CORPORERM_JUL08
