create or replace procedure sgpb_proc.SGPB6204(
RESULSET           OUT SYS_REFCURSOR
)
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB6204
  --      NEGOCIO         : SGPB DESTAQUE PLUS INTERNET - SITE CORRETOR
  --      DATA            : 12/10/2007
  --      AUTOR           : ALEXANDRE CYSNE ESTEVES
  --      OBJETIVO        : RETORNAR O VALOR DO PREMIO A PRODUZIR
  --      ALTERAÇÕES      :
  --                DATA  :
  --                AUTOR :
  --                OBS   :
  -------------------------------------------------------------------------------------------------
 IS

BEGIN

     OPEN RESULSET FOR

        SELECT 'valorMargem',
               CD.VPRMIO_DSTAQ 
            --
          FROM CAMPA_DSTAQ CD
            --
         WHERE CD.CCAMPA_DSTAQ = 1;

  EXCEPTION
  WHEN OTHERS THEN
    --
    PC_UTIL_01.SGPB0028('SGPB INTERNET DESTAQUE PLUS: ERROR: '||
    SUBSTR(SQLERRM,1,100), 'SGPB6204');
    --
    ROLLBACK;
    --
    RAISE_APPLICATION_ERROR(-20000,'SGPB INTERNET DESTAQUE PLUS' || SUBSTR(SQLERRM,1,100));

END SGPB6204;
/

