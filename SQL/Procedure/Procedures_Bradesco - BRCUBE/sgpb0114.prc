CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0114
(
   ptdinic_vgcia_parm        in varchar2, --parm_per_apurc_canal.dinic_vgcia_parm %type,
   pccanal_vda_segur         in parm_per_apurc_canal.ccanal_vda_segur %type,
   pctpo_apurc               in parm_per_apurc_canal.ctpo_apurc %type
)
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0114
  --      DATA            : 16/03/2006
  --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : delete em parm_per_apurc_canal relativo a classe ParamPeriodoProcessosVO
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
 IS
   pdinic_vgcia_parm        parm_per_apurc_canal.dinic_vgcia_parm %type;
BEGIN
  --
  /*Formata a data adequadamente*/
  pdinic_vgcia_parm := To_date(ptdinic_vgcia_parm,
                               'YYYYMMDD');
  --
delete from parm_per_apurc_canal

 where ccanal_vda_segur = pccanal_vda_segur
   and ctpo_apurc = pctpo_apurc
   and dinic_vgcia_parm = pdinic_vgcia_parm;
  --
END SGPB0114;
/

