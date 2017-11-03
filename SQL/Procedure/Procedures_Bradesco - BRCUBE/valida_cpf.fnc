CREATE OR REPLACE FUNCTION SGPB_PROC.valida_cpf(
P_CPF IN VARCHAR2
)RETURN VARCHAR2 IS
-------------------------------------------------------------------------------------------------
--      BRADESCO SEGUROS S.A.
--              SISTEMA : SGPB - INTRANET
--       FUNCIONALIDADE : VALIDA CPF (ESTA FUNCTION NÃO VAI PARA PRODUÇÃO)
--             FUNCTION : VALIDA_CPF
--                 DATA : 27/08/2007
--                AUTOR : ALEXANDRE CYSNE ESTEVES
--             OBJETIVO : FUNCAO QUE VALIDA O CPF
--          ALTERAÇÕES  :
--
--              LOGICA  :
--                DATA  : -
--               AUTOR  : -
--                 OBS  : -
-------------------------------------------------------------------------------------------------
RETORNO  VARCHAR2(100) := 'CPF VALIDO';
V_TOTAL  NUMBER(30) := 0;
V_RESTO  NUMBER(02) := 0;
V_INDICE NUMBER(02) := 1;
V_NR     NUMBER(01) := 1;

BEGIN

        if length(P_CPF) != 11 then
           RETORNO := 'CPF COM QUANTIDADE DE DIGITOS ERRADA';
           RETURN RETORNO;
        end if;
               
        --validando numeros repetidos       
        WHILE (V_INDICE <= 11)
        LOOP
           if (Substr(P_CPF,V_INDICE,1) != Substr(P_CPF,1,1)) then
             V_NR := 0;
           end if;
           V_INDICE := V_INDICE +1;
        END LOOP;
             
        if V_NR = 1 then
           RETORNO := 'CPF COM TODOS OS DIGITOS IGUAIS';
           RETURN RETORNO;
        end if;           
                        
        --somando para validar primeiro digito    
        V_TOTAL := V_TOTAL + To_number(Substr(To_char(P_CPF),01,1)) * 1;
        V_TOTAL := V_TOTAL + To_number(Substr(To_char(P_CPF),02,1)) * 2;
        V_TOTAL := V_TOTAL + To_number(Substr(To_char(P_CPF),03,1)) * 3;
        V_TOTAL := V_TOTAL + To_number(Substr(To_char(P_CPF),04,1)) * 4;
        V_TOTAL := V_TOTAL + To_number(Substr(To_char(P_CPF),05,1)) * 5;
        V_TOTAL := V_TOTAL + To_number(Substr(To_char(P_CPF),06,1)) * 6;
        V_TOTAL := V_TOTAL + To_number(Substr(To_char(P_CPF),07,1)) * 7;
        V_TOTAL := V_TOTAL + To_number(Substr(To_char(P_CPF),08,1)) * 8;
        V_TOTAL := V_TOTAL + To_number(Substr(To_char(P_CPF),09,1)) * 9;        
              
        --validando se o resto e 10 
        if mod(V_TOTAL,11) = 10 then
           V_RESTO := 0;
        else
           V_RESTO := mod(V_TOTAL,11);
        end if;
        
        if V_RESTO != Substr(P_CPF,10,1) then
           RETORNO := 'CPF INVALIDO';
           RETURN RETORNO;
        end if;       
        
        V_TOTAL := 0;

        --somando para validar segundo digito
        V_TOTAL := V_TOTAL + To_number(Substr(To_char(P_CPF),01,1)) * 0;
        V_TOTAL := V_TOTAL + To_number(Substr(To_char(P_CPF),02,1)) * 1;
        V_TOTAL := V_TOTAL + To_number(Substr(To_char(P_CPF),03,1)) * 2;
        V_TOTAL := V_TOTAL + To_number(Substr(To_char(P_CPF),04,1)) * 3;
        V_TOTAL := V_TOTAL + To_number(Substr(To_char(P_CPF),05,1)) * 4;
        V_TOTAL := V_TOTAL + To_number(Substr(To_char(P_CPF),06,1)) * 5;
        V_TOTAL := V_TOTAL + To_number(Substr(To_char(P_CPF),07,1)) * 6;
        V_TOTAL := V_TOTAL + To_number(Substr(To_char(P_CPF),08,1)) * 7;
        V_TOTAL := V_TOTAL + To_number(Substr(To_char(P_CPF),09,1)) * 8;
        V_TOTAL := V_TOTAL + To_number(Substr(To_char(P_CPF),10,1)) * 9;

        --validando se o resto e 10 
        if mod(V_TOTAL,11) = 10 then
           V_RESTO := 0;
        else
           V_RESTO := mod(V_TOTAL,11);
        end if;
        
        if V_RESTO != Substr(P_CPF,11,1) then
           RETORNO := 'CPF INVALIDO';
           RETURN RETORNO;
        end if; 

        RETURN RETORNO;
    
END valida_cpf;
/

