CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB9030 IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB9030
  --      DATA            : 21/12/2006
  --      AUTOR           : vinícius Faria - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : chama 9030
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
                        'SGPB9030',
                        'R',
                        1,
                        VAR_IDTRIO_TRAB,
                        VAR_IARQ_TRAB );

   -- RECUPERA OS DADOS DE PARAMETRO DE CARGA
   PR_LE_PARAMETRO_CARGA(728, VAR_DCARGA, VAR_DPROX_CARGA);

   VAR_COMPETENCIA := to_number(to_char(VAR_DPROX_CARGA, 'YYYYMM'));

   SGPB0030(
     VAR_COMPETENCIA,
     VAR_IDTRIO_TRAB,
     VAR_IARQ_TRAB,
     'SGPB9030'
   );

END SGPB9030;
/

