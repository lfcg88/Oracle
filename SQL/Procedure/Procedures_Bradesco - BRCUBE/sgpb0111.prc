CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0111
(
    pccanal_vda_segur       in parm_perc_pgto_bonif.ccanal_vda_segur %type,
    pctpo_apurc             in parm_perc_pgto_bonif.ctpo_apurc %type,
    ptdinic_vgcia_parm      IN VARCHAR2, -- parm_perc_pgto_bonif.dinic_vgcia_parm %type,
    ppmin_margm_contb       in parm_perc_pgto_bonif.pmin_margm_contb %type
)
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0111
  --      DATA            : 16/03/2006
  --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : delete em PARAMETRO-PERC-PGTO-BONIFICACAO relativo a classe ParamPercentualPagamentoVO
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
 IS
BEGIN
  --
  --
  delete parm_perc_pgto_bonif
   where ccanal_vda_segur = pccanal_vda_segur
     and ctpo_apurc = pctpo_apurc
     and to_char(dinic_vgcia_parm, 'YYYYMMDD') = ptdinic_vgcia_parm
     and pmin_margm_contb = ppmin_margm_contb;

END SGPB0111;
/

