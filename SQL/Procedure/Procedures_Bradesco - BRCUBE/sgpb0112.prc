CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0112
(
    pccanal_vda_segur       in parm_perc_pgto_bonif.ccanal_vda_segur %type,
    pctpo_apurc             in parm_perc_pgto_bonif.ctpo_apurc %type,
    ptdinic_vgcia_parm      IN VARCHAR2, -- parm_perc_pgto_bonif.dinic_vgcia_parm %type,
    ppmin_margm_contb       in parm_perc_pgto_bonif.pmin_margm_contb %type,
    ptdfim_vgcia_parm       in VARCHAR2, -- parm_perc_pgto_bonif.dfim_vgcia_parm %type,
    ptdult_alt              in VARCHAR2, -- parm_perc_pgto_bonif.dult_alt %TYPE,
    pcresp_ult_alt          in parm_perc_pgto_bonif.cresp_ult_alt %TYPE,
    pperfil_crrtr           in parm_perc_pgto_bonif.ctpo_prfil_crrtr %TYPE

)
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0112
  --      DATA            : 16/03/2006
  --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : update em PARAMETRO-PERC-PGTO-BONIFICACAO relativo a classe ParamPercentualPagamentoVO
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
 IS
  pdfim_vgcia_parm        parm_perc_pgto_bonif.dfim_vgcia_parm %type;
  pdult_alt               parm_perc_pgto_bonif.dult_alt %TYPE;

BEGIN
  --
  /*Formata a data adequadamente*/
  pdfim_vgcia_parm  := To_date(ptdfim_vgcia_parm,
                               'YYYYMMDD');
  pdult_alt         := To_date(ptdult_alt,
                               'YYYYMMDD');

  --
update parm_perc_pgto_bonif
   set dfim_vgcia_parm = pdfim_vgcia_parm,
       dult_alt = pdult_alt,
       cresp_ult_alt = pcresp_ult_alt
       --
 where ccanal_vda_segur = pccanal_vda_segur
   and ctpo_apurc = pctpo_apurc
   and to_char(dinic_vgcia_parm, 'YYYYMMDD') = ptdinic_vgcia_parm
   and pmin_margm_contb = ppmin_margm_contb
   and ctpo_prfil_crrtr = pperfil_crrtr;

END SGPB0112;
/

