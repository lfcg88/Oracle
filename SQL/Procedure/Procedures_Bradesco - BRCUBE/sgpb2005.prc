CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB2005 IS
-------------------------------------------------------------------------------------------------
--      BRADESCO SEGUROS S.A.
--      DATA            : 24/02/2008
--      AUTOR           : MONIQUE MARQUES - VALUE TEAM
--      PROGRAMA        : SGPB2001
--      OBJETIVO        : FINALIZA O FLUXO DE ROTINAS DO PER�ODO E INICIALIZA O FLUXO
--                        DE ROTINAS PARA O PR�XIMO PER�ODO DO PAR�METRO DE CARGA
-------------------------------------------------------------------------------------------------
--
BEGIN
	PR_CONTROLE_FIM_FLUXO ('SGPB2005', 736);
END SGPB2005;
/

