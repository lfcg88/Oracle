create or replace package body sgpb_proc.PC_GE_MASSA is

  lint_compt              integer;
  lint_ano                integer;
  lint_compt_inicial      integer;
  lint_compt_final        integer;
  lint_compt_guia_inicial integer;
  lint_compt_guia_final   integer;

  procedure LimpaTabelas is
  begin
  
    delete from hist_distr_pgto
    commit;

    delete from papel_apurc_pgto
    commit;

    delete from pgto_bonus_crrtr
    commit;

    delete from apurc_movto_ctbil
    commit;

    delete from apurc_prod_crrtr
    commit;

  --  delete from MARGM_CONTB_AGPTO_ECONM_CRRTR;
    commit;
  
    delete from SGPB.Rsumo_Objtv_Agpto_Econm_Crrtr;
    commit;

--    DELETE FROM OBJTV_PROD_AGPTO_ECONM_CRRTR;
    commit;

--    delete from CRRTR_PARTC_AGPTO_ECONM t;
    commit;
  
--    delete from SGPB.AGPTO_ECONM_CRRTR;
    commit;
  
  end LimpaTabelas;

  procedure AjustesPosInsert is
  begin
    /*depois*/
    update SGPB.AGPTO_ECONM_CRRTR
       set DFIM_VGCIA_AGPTO_ECONM_CRRTR = null
     where to_char(DFIM_VGCIA_AGPTO_ECONM_CRRTR, 'yyyy') = 2006;
    commit;
  
    update SGPB.AGPTO_ECONM_CRRTR
       set DFIM_VGCIA_AGPTO_ECONM_CRRTR = null
     where DFIM_VGCIA_AGPTO_ECONM_CRRTR > to_date(20080101, 'yyyymmdd');
    commit;
  
    UPDATE CRRTR_PARTC_AGPTO_ECONM CPAE
       SET CPAE.DFIM_VGCIA_PRTCP_AGPTO_ECONM = NULL
     WHERE CPAE.DFIM_VGCIA_PRTCP_AGPTO_ECONM > to_date(20080101, 'yyyymmdd');
    commit;
  
    UPDATE CRRTR_PARTC_AGPTO_ECONM CPAE
       SET CPAE.DFIM_VGCIA_PRTCP_AGPTO_ECONM = NULL
     WHERE to_char(CPAE.DFIM_VGCIA_PRTCP_AGPTO_ECONM, 'yyyy') = 2006;
    commit;
  
    /*DELETE para os corretores que estao em mais de uma holding*/
  /*  delete from crrtr_partc_agpto_econm cpae
     where (cpae.ccpf_cnpj_base, cpae.ctpo_pssoa) in (select cpaei.ccpf_cnpj_base,
                                                             cpaei.ctpo_pssoa
                                                        from crrtr_partc_agpto_econm cpaei
                                                       group by cpaei.ccpf_cnpj_base,
                                                                cpaei.ctpo_pssoa
                                                      having count(*) > 1);
                                                      
    delete from crrtr_partc_agpto_econm cpae
    where (cpae.ccpf_cnpj_agpto_econm_crrtr, cpae.ctpo_pssoa_agpto_econm_crrtr) in (select aeci.ccpf_cnpj_agpto_econm_crrtr, aeci.ctpo_pssoa_agpto_econm_crrtr
                                                        from agpto_econm_crrtr aeci
                                                       group by aeci.ccpf_cnpj_agpto_econm_crrtr, aeci.ctpo_pssoa_agpto_econm_crrtr
                                                      having count(*) > 1);

    delete from agpto_econm_crrtr aec
    where (aec.ccpf_cnpj_agpto_econm_crrtr, aec.ctpo_pssoa_agpto_econm_crrtr) in (select aeci.ccpf_cnpj_agpto_econm_crrtr, aeci.ctpo_pssoa_agpto_econm_crrtr
                                                        from agpto_econm_crrtr aeci
                                                       group by aeci.ccpf_cnpj_agpto_econm_crrtr, aeci.ctpo_pssoa_agpto_econm_crrtr
                                                      having count(*) > 1);
*/    commit;
  
  end AjustesPosInsert;

  procedure margem is
  begin
  
    lint_compt_guia_inicial := 200601;
    lint_compt_guia_final   := 200612;
  
    --1 LOOP PARA CADA ANO
    for lint_ano in 0 .. 2 loop
    
      --200601 + 0 * 100 = 200601
      --200601 + 1 * 100 = 200701
      --200601 + 2 * 100 = 200801      
      lint_compt_inicial := lint_compt_guia_inicial + (lint_ano * 100);
      lint_compt_final   := lint_compt_guia_final + (lint_ano * 100);
    
      --A CADA LOOP INSERE O MES DO LOOP PARA TODOS AS G.E. CADASTRADAS NA agpto_econm_crrtr
      for lint_compt in lint_compt_inicial .. lint_compt_final loop
      
        insert into sgpb.margm_contb_agpto_econm_crrtr
          (ctpo_pssoa_agpto_econm_crrtr,
           ccpf_cnpj_agpto_econm_crrtr,
           dinic_agpto_econm_crrtr,
           ccanal_vda_segur,
           ccompt_margm,
           pmargm_contb,
           cresp_ult_alt,
           dincl_reg,
           dalt_reg)
        
          select ctpo_pssoa_agpto_econm_crrtr,
                 ccpf_cnpj_agpto_econm_crrtr,
                 dinic_agpto_econm_crrtr,
                 1,
                 lint_compt,
                 trunc(dbms_random.value(1000, 4000)) / 100,
                 'k' || trunc(dbms_random.value(100000, 999999)),
                 sysdate - dbms_random.value(0, 12),
                 sysdate - dbms_random.value(0, 12)
            from sgpb.agpto_econm_crrtr aec
            where last_day(to_date(200803, 'YYYYMM')) between aec.dinic_agpto_econm_crrtr and nvl(aec.dfim_vgcia_agpto_econm_crrtr, to_date(99991231, 'YYYYMMDD'));

      end loop;
    
      commit;
    
    end loop;
  
  end margem;

  procedure objetivo is
  begin
  
    lint_compt_guia_inicial := 200601;
    lint_compt_guia_final   := 200612;
  
    --1 LOOP PARA CADA ANO
    for lint_ano in 0 .. 2 loop
    
      --200601 + 0 * 100 = 200601
      --200601 + 1 * 100 = 200701
      --200601 + 2 * 100 = 200801      
      lint_compt_inicial := lint_compt_guia_inicial + (lint_ano * 100);
      lint_compt_final   := lint_compt_guia_final + (lint_ano * 100);
    
      --A CADA LOOP INSERE O MES DO LOOP PARA TODOS AS G.E. CADASTRADAS NA agpto_econm_crrtr
      for lint_compt in lint_compt_inicial .. lint_compt_final loop
      
        insert into sgpb.objtv_prod_agpto_econm_crrtr
          (ctpo_pssoa_agpto_econm_crrtr,
           ccpf_cnpj_agpto_econm_crrtr,
           dinic_agpto_econm_crrtr,
           cgrp_ramo_plano,
           ccanal_vda_segur,
           cano_mes_compt_objtv,
           vobjtv_prod_agpto_econm_orign,
           vobjtv_prod_agpto_econm_alt,
           cresp_ult_alt,
           dincl_reg,
           dult_alt)
          select ctpo_pssoa_agpto_econm_crrtr,
                 ccpf_cnpj_agpto_econm_crrtr,
                 dinic_agpto_econm_crrtr,
                 grp.cgrp_ramo_plano,
                 1,
                 lint_compt,
                 case
                   when grp.cgrp_ramo_plano = 120 then
                    trunc(dbms_random.value(800000, 1800000)) / 100
                   when grp.cgrp_ramo_plano = 810 then
                    9000
                   when grp.cgrp_ramo_plano = 999 then
                    9000
                 end,
                 1,
                 'k' || trunc(dbms_random.value(100000, 999999)),
                 sysdate - dbms_random.value(0, 12),
                 sysdate - dbms_random.value(0, 12)
          --
            from sgpb.agpto_econm_crrtr aec,
                 GRP_RAMO_PLANO         grp
           where last_day(to_date(200803, 'YYYYMM')) between aec.dinic_agpto_econm_crrtr and nvl(aec.dfim_vgcia_agpto_econm_crrtr, to_date(99991231, 'YYYYMMDD'));

      end loop;
    
      commit;
    
    end loop;
  
    --coloca o vobjtv_prod_agpto_econm_alt identico ao vobjtv_prod_agpto_econm_orign
    update sgpb.objtv_prod_agpto_econm_crrtr
       set vobjtv_prod_agpto_econm_alt = vobjtv_prod_agpto_econm_orign;
    commit;
  
  end objetivo;

  procedure producao is
  begin

    --LIMPA APOLC
    update sgpb.apolc_prod_crrtr
       SET cgrp_ramo_plano = NULL,
           ccompt_prod     = NULL,
           ctpo_comis      = NULL,
           ccrrtr          = NULL
    
     where (ccrrtr, cund_prod) in (
                                   
                                   select c.ccrrtr,
                                           c.cund_prod
                                   
                                     from agpto_econm_crrtr aec
                                   
                                     join crrtr_partc_agpto_econm cpae on cpae.ctpo_pssoa_agpto_econm_crrtr = aec.ctpo_pssoa_agpto_econm_crrtr
                                                                      and cpae.ccpf_cnpj_agpto_econm_crrtr = aec.ccpf_cnpj_agpto_econm_crrtr
                                                                      and cpae.dinic_agpto_econm_crrtr = aec.dinic_agpto_econm_crrtr
                                   
                                     join crrtr c on c.ccpf_cnpj_base = cpae.ccpf_cnpj_base
                                                 and c.ctpo_pssoa = cpae.ctpo_pssoa
                                                 AND C.CCRRTR BETWEEN 100000 AND 200000
                                   
                                   );
  
    commit;
  
    --EXCLUI PRODU??O
    delete from sgpb.prod_crrtr pc
     where (pc.ccrrtr, pc.cund_prod) in (
                                         
                                         select c.ccrrtr,
                                                 c.cund_prod
                                         
                                           from agpto_econm_crrtr aec
                                         
                                           join crrtr_partc_agpto_econm cpae on cpae.ctpo_pssoa_agpto_econm_crrtr = aec.ctpo_pssoa_agpto_econm_crrtr
                                                                            and cpae.ccpf_cnpj_agpto_econm_crrtr = aec.ccpf_cnpj_agpto_econm_crrtr
                                                                            and cpae.dinic_agpto_econm_crrtr = aec.dinic_agpto_econm_crrtr
                                         
                                           join crrtr c on c.ccpf_cnpj_base = cpae.ccpf_cnpj_base
                                                       and c.ctpo_pssoa = cpae.ctpo_pssoa
                                                       AND C.CCRRTR BETWEEN 100000 AND 200000
                                         
                                         );
    commit;
  
  
  
    lint_compt_guia_inicial := 200601;
    lint_compt_guia_final   := 200612;
  
    --1 LOOP PARA CADA ANO
    for lint_ano in 0 .. 2 loop
    
      --200601 + 0 * 100 = 200601
      --200601 + 1 * 100 = 200701
      --200601 + 2 * 100 = 200801      
      lint_compt_inicial := lint_compt_guia_inicial + (lint_ano * 100);
      lint_compt_final   := lint_compt_guia_final + (lint_ano * 100);
    
      --A CADA LOOP INSERE O MES DO LOOP PARA TODOS AS G.E. CADASTRADAS NA agpto_econm_crrtr
      for lint_compt in lint_compt_inicial .. lint_compt_final loop
      
        insert into sgpb.prod_crrtr
          (qtot_item_prod,
           ctpo_comis,
           ccrrtr,
           cgrp_ramo_plano,
           ccompt_prod,
           cund_prod,
           vprod_crrtr)
        
          select case
                   when grp.cgrp_ramo_plano = 120 then
                    trunc(dbms_random.value(-2, 10))
                   when grp.cgrp_ramo_plano = 810 then
                    trunc(dbms_random.value(-2, 20))
                   when grp.cgrp_ramo_plano = 999 then
                    trunc(dbms_random.value(-2, 15))
                 end,
                 CM.ctpo_comis,
                 c.ccrrtr,
                 grp.cgrp_ramo_plano,
                 lint_compt,
                 c.cund_prod,
                 case
                   when grp.cgrp_ramo_plano = 120 then
                    trunc(dbms_random.value(-100000, 400000)) / 100
                   when grp.cgrp_ramo_plano = 810 then
                    trunc(dbms_random.value(-50000, 80000)) / 100
                   when grp.cgrp_ramo_plano = 999 then
                    trunc(dbms_random.value(-50000, 50000)) / 100
                 end
          
            from agpto_econm_crrtr aec
          
            join crrtr_partc_agpto_econm cpae on cpae.ctpo_pssoa_agpto_econm_crrtr = aec.ctpo_pssoa_agpto_econm_crrtr
                                             and cpae.ccpf_cnpj_agpto_econm_crrtr = aec.ccpf_cnpj_agpto_econm_crrtr
                                             and cpae.dinic_agpto_econm_crrtr = aec.dinic_agpto_econm_crrtr
                                             and last_day(to_date(200803, 'YYYYMM')) between cpae.dinic_vgcia_prtcp_agpto_econm and nvl(cpae.dfim_vgcia_prtcp_agpto_econm, to_date(99991231, 'YYYYMMDD'))
          
            join crrtr c on c.ccpf_cnpj_base = cpae.ccpf_cnpj_base
                        and c.ctpo_pssoa = cpae.ctpo_pssoa
                        AND C.CCRRTR BETWEEN 100000 AND 200000
          
            JOIN (SELECT 'CN' ctpo_comis
                    FROM DUAL
                  UNION
                  SELECT 'CE' ctpo_comis
                    FROM DUAL) CM ON 1 = 1
          
            JOIN GRP_RAMO_PLANO grp ON 1 = 1
           where last_day(to_date(200803, 'YYYYMM')) between aec.dinic_agpto_econm_crrtr and nvl(aec.dfim_vgcia_agpto_econm_crrtr, to_date(99991231, 'YYYYMMDD'));

      
      end loop;
    
      commit;
    
    end loop;
  
  end producao;

  procedure resumo_em_branco is
  begin
    lint_compt_guia_inicial := 200601;
    lint_compt_guia_final   := 200612;
  
    --1 LOOP PARA CADA ANO
    for lint_ano in 0 .. 2 loop
    
      --200601 + 0 * 100 = 200601
      --200601 + 1 * 100 = 200701
      --200601 + 2 * 100 = 200801      
      lint_compt_inicial := lint_compt_guia_inicial + (lint_ano * 100);
      lint_compt_final   := lint_compt_guia_final + (lint_ano * 100);
    
      --A CADA LOOP INSERE O MES DO LOOP PARA TODOS AS G.E. CADASTRADAS NA agpto_econm_crrtr
      for lint_compt in lint_compt_inicial .. lint_compt_final loop
      
        insert into sgpb.rsumo_objtv_agpto_econm_crrtr
          (ctpo_pssoa_agpto_econm_crrtr,
           ccpf_cnpj_agpto_econm_crrtr,
           dinic_agpto_econm_crrtr,
           cgrp_ramo_plano,
           ccanal_vda_segur,
           ccompt,
           ctpo_comis,
           vprod_grp_econm,
           vobjtv_prod_agpto_econm_orign,
           vobjtv_prod_agpto_econm_alt,
           qtot_item_prod,
           dincl_reg,
           dalt_reg)
        
          select aec.ctpo_pssoa_agpto_econm_crrtr,
                 aec.ccpf_cnpj_agpto_econm_crrtr,
                 aec.dinic_agpto_econm_crrtr,
                 grp.cgrp_ramo_plano,
                 1,
                 lint_compt,
                 'CN',
                 0,
                 0,
                 0,
                 0,
                 sysdate,
                 sysdate
          
            from sgpb.agpto_econm_crrtr aec

            JOIN GRP_RAMO_PLANO grp ON 1 = 1
            where last_day(to_date(200803, 'YYYYMM')) between aec.dinic_agpto_econm_crrtr and nvl(aec.dfim_vgcia_agpto_econm_crrtr, to_date(99991231, 'YYYYMMDD'));
      
      end loop;
    
      commit;
    
    end loop;
  
  end resumo_em_branco;

  procedure resumo_objetivo is
  begin
  
    for c in (select ctpo_pssoa_agpto_econm_crrtr,
                     ccpf_cnpj_agpto_econm_crrtr,
                     dinic_agpto_econm_crrtr,
                     cgrp_ramo_plano,
                     ccanal_vda_segur,
                     cano_mes_compt_objtv as ccompt,
                     'CN' as ctpo_comis,
                     
                     vobjtv_prod_agpto_econm_orign,
                     vobjtv_prod_agpto_econm_alt
              
                from objtv_prod_agpto_econm_crrtr OPAEC)
    
     loop
    
      update rsumo_objtv_agpto_econm_crrtr a
      
         set vobjtv_prod_agpto_econm_orign = c.vobjtv_prod_agpto_econm_orign,
             vobjtv_prod_agpto_econm_alt   = c.vobjtv_prod_agpto_econm_alt
      
       where ctpo_pssoa_agpto_econm_crrtr = c.ctpo_pssoa_agpto_econm_crrtr
         and ccpf_cnpj_agpto_econm_crrtr = c.ccpf_cnpj_agpto_econm_crrtr
         and dinic_agpto_econm_crrtr = c.dinic_agpto_econm_crrtr
         and cgrp_ramo_plano = c.cgrp_ramo_plano
         and ccanal_vda_segur = c.ccanal_vda_segur
         and ccompt = c.ccompt
         and ctpo_comis = c.ctpo_comis;
    
    end loop;
    commit;
  
  end resumo_objetivo;

  procedure resumo_producao is
  begin
  
    for c in (select aec.ctpo_pssoa_agpto_econm_crrtr,
                     aec.ccpf_cnpj_agpto_econm_crrtr,
                     aec.dinic_agpto_econm_crrtr,
                     pc.cgrp_ramo_plano,
                     1 as ccanal_vda_segur,
                     pc.ccompt_prod ccompt,
                     pc.ctpo_comis,
                     
                     sum(pc.vprod_crrtr) as vprod_crrtr,
                     sum(pc.qtot_item_prod) as qtot_item_prod
              
                from agpto_econm_crrtr aec
              
                join crrtr_partc_agpto_econm cpae on cpae.ctpo_pssoa_agpto_econm_crrtr = aec.ctpo_pssoa_agpto_econm_crrtr
                                                 and cpae.ccpf_cnpj_agpto_econm_crrtr = aec.ccpf_cnpj_agpto_econm_crrtr
                                                 and cpae.dinic_agpto_econm_crrtr = aec.dinic_agpto_econm_crrtr
                                                 and last_day(to_date(200803, 'YYYYMM')) between cpae.dinic_vgcia_prtcp_agpto_econm and nvl(cpae.dfim_vgcia_prtcp_agpto_econm, to_date(99991231, 'YYYYMMDD'))
              
                join crrtr c on c.ccpf_cnpj_base = cpae.ccpf_cnpj_base
                            and c.ctpo_pssoa = cpae.ctpo_pssoa
                            AND C.CCRRTR BETWEEN 100000 AND 200000
              
                join prod_crrtr pc on pc.ccrrtr = c.ccrrtr
                                  and pc.cund_prod = c.cund_prod
              
               where pc.ctpo_comis = 'CN'
                 and last_day(to_date(200803, 'YYYYMM')) between aec.dinic_agpto_econm_crrtr and nvl(aec.dfim_vgcia_agpto_econm_crrtr, to_date(99991231, 'YYYYMMDD'))

               group by aec.ctpo_pssoa_agpto_econm_crrtr,
                        aec.ccpf_cnpj_agpto_econm_crrtr,
                        aec.dinic_agpto_econm_crrtr,
                        pc.cgrp_ramo_plano,
                        pc.ccompt_prod,
                        pc.ctpo_comis)
    
     loop
    
      update rsumo_objtv_agpto_econm_crrtr a
      
         set a.vprod_grp_econm = c.vprod_crrtr,
             a.qtot_item_prod  = c.qtot_item_prod
      
       where ctpo_pssoa_agpto_econm_crrtr = c.ctpo_pssoa_agpto_econm_crrtr
         and ccpf_cnpj_agpto_econm_crrtr = c.ccpf_cnpj_agpto_econm_crrtr
         and dinic_agpto_econm_crrtr = c.dinic_agpto_econm_crrtr
         and cgrp_ramo_plano = c.cgrp_ramo_plano
         and ccanal_vda_segur = c.ccanal_vda_segur
         and ccompt = c.ccompt
         and ctpo_comis = c.ctpo_comis;
    
    end loop;
    commit;
  
  end resumo_producao;

  procedure elegeCorretore is
  begin
  
      delete sgpb.crrtr_eleit_campa
     where (ccanal_vda_segur, --
            dinic_vgcia_parm, --
            ctpo_pssoa, --
            ccpf_cnpj_base) --
           in --
           (select pic.ccanal_vda_segur,
                   pic.dinic_vgcia_parm,
                   cpae.ctpo_pssoa,
                   cpae.ccpf_cnpj_base
            
              from agpto_econm_crrtr aec
            
              join crrtr_partc_agpto_econm cpae on cpae.ctpo_pssoa_agpto_econm_crrtr = aec.ctpo_pssoa_agpto_econm_crrtr
                                               and cpae.ccpf_cnpj_agpto_econm_crrtr = aec.ccpf_cnpj_agpto_econm_crrtr
                                               and cpae.dinic_agpto_econm_crrtr = aec.dinic_agpto_econm_crrtr
            
              join parm_info_campa pic on pic.ccanal_vda_segur = 1
                                      and pic.dfim_vgcia_parm is null
            
             where aec.dfim_vgcia_agpto_econm_crrtr is null);
    commit;

  
    insert into sgpb.crrtr_eleit_campa
      (ccanal_vda_segur,
       dinic_vgcia_parm,
       dcrrtr_selec_campa,
       ctpo_pssoa,
       ccpf_cnpj_base)
    --
      select pic.ccanal_vda_segur,
             pic.dinic_vgcia_parm,
             to_date(20080101, 'yyyymmdd'),
             cpae.ctpo_pssoa,
             cpae.ccpf_cnpj_base
      
        from agpto_econm_crrtr aec
      
        join crrtr_partc_agpto_econm cpae on cpae.ctpo_pssoa_agpto_econm_crrtr = aec.ctpo_pssoa_agpto_econm_crrtr
                                         and cpae.ccpf_cnpj_agpto_econm_crrtr = aec.ccpf_cnpj_agpto_econm_crrtr
                                         and cpae.dinic_agpto_econm_crrtr = aec.dinic_agpto_econm_crrtr
      
        join parm_info_campa pic on pic.ccanal_vda_segur = 1
                                and pic.dfim_vgcia_parm is null
      
       where aec.dfim_vgcia_agpto_econm_crrtr is null;
  
    commit;
  
  end elegeCorretore;

  procedure adicionaPrincComoParticipante is
  begin
  
    insert into sgpb.crrtr_partc_agpto_econm
      (ctpo_pssoa_agpto_econm_crrtr,
       ccpf_cnpj_agpto_econm_crrtr,
       dinic_agpto_econm_crrtr,
       ctpo_pssoa,
       ccpf_cnpj_base,
       dinic_vgcia_prtcp_agpto_econm,
       dfim_vgcia_prtcp_agpto_econm)
    
      select aec.ctpo_pssoa_agpto_econm_crrtr,
             aec.ccpf_cnpj_agpto_econm_crrtr,
             aec.dinic_agpto_econm_crrtr,
             aec.ctpo_pssoa_agpto_econm_crrtr,
             aec.ccpf_cnpj_agpto_econm_crrtr, 
             aec.dinic_agpto_econm_crrtr,
             null
                  
        from agpto_econm_crrtr aec;
  
    commit;
  
  end adicionaPrincComoParticipante;

  procedure Main is
  begin
    LimpaTabelas;
--    ge_insert_ge_crrtrge; --externo por conta de lentid?o de compila??o 
    --adicionaPrincComoParticipante;
--    AjustesPosInsert;
--    margem;
--    objetivo;
    producao;
    elegeCorretore;
--    resumo_em_branco;
--    resumo_objetivo;
--    resumo_producao;
    commit;
  end Main;

  procedure gera_carga_grp_fnasa_dstaq is
  begin
          insert into sgpb.grp_fnasa_dstaq
          (ccampa_dstaq,
           ctpo_pssoa,
           ccpf_cnpj_base,
           cgrp_fnasa,
           igrp_fnasa,
           dincl_reg,
           dalt_reg)
        
          select 200603,
                 CUC.CTPO_PSSOA,
                 CUC.CCPF_CNPJ_BASE,
                 TRUNC(DBMS_RANDOM.value(1,4)),
                 'DF',
                 SYSDATE,
                 SYSDATE         
          FROM CRRTR_UNFCA_CNPJ CUC;
          
          
          update sgpb.grp_fnasa_dstaq
             set igrp_fnasa = 'Grupo Finasa ummm'
           where Cgrp_fnasa = 1;
           
             update sgpb.grp_fnasa_dstaq
             set igrp_fnasa = 'Grupo Finasa doiss'
           where Cgrp_fnasa = 2;
           
             update sgpb.grp_fnasa_dstaq
             set igrp_fnasa = 'Grupo Finasa tress'
           where Cgrp_fnasa = 3;
           
/*        select ccampa_dstaq || 
               ctpo_pssoa || 
               lpad(ccpf_cnpj_base,9,0) || 
               lpad(cgrp_fnasa,6,0) || 
               rpad(igrp_fnasa,20,' ') 
          from sgpb.grp_fnasa_dstaq 
*/
  end gera_carga_grp_fnasa_dstaq;

end PC_GE_MASSA;
/

