CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB9043 IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB9043
  --      DATA            : 21/12/2006 09:38:13
  --      AUTOR           : Vinícius Faria - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : chama 9043
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
  VAR_DCARGA                 	date;
  VAR_DPROX_CARGA            	date;
  --VAR_IDTRIO_TRAB            	varchar2(100);
  --VAR_IARQ_TRAB              	varchar2(100);*/
  --VAR_CAMBTE                 	varchar2(100);           -- VAI SER ALIMENTADO PELO PARAMETRO DE AMBIENTE

  VAR_COMPETENCIA             number(6);

BEGIN

  --VAR_CAMBTE := FC_VERIFICA_AMBIENTE_ROTINA;

   -- RECUPERA OS DADOS DE diretorio e arquivo
/*  PR_DIRETORIO_ARQUIVO( VAR_CAMBTE,
                        'SGPB',
                        'SGPB9043',
                        'R',
                        1,
                        VAR_IDTRIO_TRAB,
                        VAR_IARQ_TRAB );*/

   -- RECUPERA OS DADOS DE PARAMETRO DE CARGA
   PR_LE_PARAMETRO_CARGA(pc_util_01.CPARM, VAR_DCARGA, VAR_DPROX_CARGA);

   VAR_COMPETENCIA := to_number(to_char(VAR_DPROX_CARGA, 'YYYYMM'));

   SGPB0043(
     VAR_COMPETENCIA,
     'SGPB9043'
   );

END SGPB9043;
/

