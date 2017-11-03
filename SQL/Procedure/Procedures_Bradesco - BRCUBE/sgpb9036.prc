CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB9036 IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB9036
  --      DATA            : 15/3/2006 09:38:13
  --      AUTOR           : Flávio Peruggia - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : chama 0036
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
  VAR_DCARGA                 	date;
  VAR_DPROX_CARGA            	date;
  VAR_IDTRIO_TRAB            	varchar2(100);
  VAR_IARQ_TRAB              	varchar2(100);
  VAR_CAMBTE                 	varchar2(100);           -- VAI SER ALIMENTADO PELO PARAMETRO DE AMBIENTE

  VAR_COMPETENCIA             number(6);

BEGIN

  VAR_CAMBTE := FC_VERIFICA_AMBIENTE_ROTINA;

   -- RECUPERA OS DADOS DE diretorio e arquivo
  PR_DIRETORIO_ARQUIVO( VAR_CAMBTE,
                        'SGPB',
                        'SGPB9036',
                        'R',
                        1,
                        VAR_IDTRIO_TRAB,
                        VAR_IARQ_TRAB );

   -- RECUPERA OS DADOS DE PARAMETRO DE CARGA
   PR_LE_PARAMETRO_CARGA(727, VAR_DCARGA, VAR_DPROX_CARGA);

   VAR_COMPETENCIA := to_number(to_char(VAR_DPROX_CARGA, 'YYYYMM'));

   SGPB0036(
     VAR_COMPETENCIA,
     VAR_IDTRIO_TRAB,
     VAR_IARQ_TRAB,
     'SGPB9036'
   );

END SGPB9036;
/

