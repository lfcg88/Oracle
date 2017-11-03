EXEC sp_dropuser 'SYSDBA'
GO
EXEC sp_dropuser 'SYSDBA'
GO
EXEC sp_dropuser '\sysdba'
GO
EXEC sp_dropuser 'sysdba'
GO
EXEC sp_dropalias 'RM'
GO
EXEC sp_dropalias 'rm'
GO
EXEC sp_dropalias '\RM'
GO
EXEC sp_dropalias '\rm'
GO

/*
CREATE LOGIN rm WITH PASSWORD = 'rm',CHECK_POLICY=OFF
GO
CREATE LOGIN sysdba WITH PASSWORD = 'masterkey',CHECK_POLICY=OFF 
GO
EXEC sp_adduser sysdba,sysdba
GO

GRANT SELECT ON GPARAMS TO sysdba
GO
GRANT SELECT , UPDATE ON GUSUARIO TO sysdba
GO
GRANT SELECT ON GPERMIS  TO sysdba
GO
GRANT SELECT ON GACESSO  TO sysdba
GO
GRANT SELECT ON GSISTEMA  TO sysdba
GO
GRANT SELECT ON GCOLIGADA  TO sysdba
GO
GRANT SELECT ON GUSRPERFIL TO sysdba
GO
GRANT SELECT ON WPESSOAEXT TO SYSDBA
GO
*/

sp_addalias 'sysdba','dbo'
sp_addalias 'Amelia','dbo'
sp_addalias 'RM','dbo'
