CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0154
(
    situacaoApuracao     IN tpo_apurc_canal_vda.csit_apurc_canal%type,
    usuario              IN tpo_apurc_canal_vda.cresp_ult_alt%type,
    canal                IN tpo_apurc_canal_vda.ccanal_vda_segur%type,
    inicioVigencia       varchar2,
    tipoApuracao         IN tpo_apurc.ctpo_apurc%type
)
-------------------------------------------------------------------------------------------------
  --      bradesco seguros s.a.
  --      procedure       : SGPB0154
  --      data            : 31/01/07 14:03:18
  --      autor           : Paulo Boccaletti - analise e desenvolvimento de sistemas
  --      objetivo        : Altera o tipo de apuração do canal
  --      alterações      :
  --                data  : -
  --                autor : -
  --                obs   : -
  -------------------------------------------------------------------------------------------------
 IS
 contador integer;
 v_inicioVigencia tpo_apurc_canal_vda.dinic_vgcia_parm%type;
BEGIN
  --
  v_inicioVigencia := to_date(inicioVigencia, 'YYYYMMDD');
  -- passo ZERO na aplicação quando não for para filtrar pelo tipo de apuração
 IF(tipoApuracao = 0) THEN
   update tpo_apurc_canal_vda tacv
      set tacv.csit_apurc_canal = situacaoApuracao,
          tacv.dult_alt         = sysdate,
          tacv.cresp_ult_alt    = usuario
    where tacv.ccanal_vda_segur = canal
      and tacv.dinic_vgcia_parm = v_inicioVigencia;

  ELSE
      select nvl(count(*),0)
        into contador
      from tpo_apurc_canal_vda
     where ccanal_vda_segur = canal
       and dinic_vgcia_parm = v_inicioVigencia
       and ctpo_apurc = 1 -- código do tipo de apuração normal
       AND csit_apurc_canal = 'S';

      IF(tipoApuracao = 2 AND situacaoApuracao = 'A' AND contador > 0) THEN
                RAISE NO_DATA_FOUND;
      ELSE
          IF(tipoApuracao = 1 AND situacaoApuracao = 'S') THEN
             update tpo_apurc_canal_vda tacv
                set tacv.csit_apurc_canal = situacaoApuracao,
                    tacv.dult_alt         = sysdate,
                    tacv.cresp_ult_alt    = usuario
              where tacv.ccanal_vda_segur = canal
                and tacv.dinic_vgcia_parm = v_inicioVigencia;
          ELSE
              update tpo_apurc_canal_vda tacv
                 set tacv.csit_apurc_canal = situacaoApuracao,
                     tacv.dult_alt         = sysdate,
                     tacv.cresp_ult_alt    = usuario
               where tacv.ccanal_vda_segur = canal
                 and tacv.dinic_vgcia_parm = v_inicioVigencia
                and  tacv.ctpo_apurc = tipoApuracao;
          END IF;
      END IF;
  END IF;
  --
END SGPB0154;
/

