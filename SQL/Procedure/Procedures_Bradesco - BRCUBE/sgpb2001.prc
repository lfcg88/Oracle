CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB2001 IS
-------------------------------------------------------------------------------------------------
--      BRADESCO SEGUROS S.A.
--      DATA            : 24/02/2008
--      AUTOR           : FABIO GIGLIO - VALUE TEAM
--      PROGRAMA        : SGPB2001
--      OBJETIVO        : FINALIZA O FLUXO DE ROTINAS DO PER�ODO E INICIALIZA O FLUXO
--                        DE ROTINAS PARA O PR�XIMO PER�ODO DO PAR�METRO DE CARGA
-------------------------------------------------------------------------------------------------
--
BEGIN
	PR_CONTROLE_FIM_FLUXO ('SGPB2001', 734);
END SGPB2001;
/

