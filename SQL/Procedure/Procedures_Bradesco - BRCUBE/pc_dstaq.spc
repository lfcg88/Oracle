CREATE OR REPLACE PACKAGE SGPB_PROC.PC_DSTAQ IS
---------------------------------------------------------------------------------------------------------
--  BRADESCO SEGUROS S.A.                                                            
--  DATA            : 11/01/2008
--  AUTOR           : WASSILY CHUK SEIBLITZ GUANAES (Genari PearTree Consultoria)
--  PROGRAMA        : SGPB6303                                               
--  OBJETIVO        : Definição De Variaveis Globais para a Campanha Destaque, de forma que não existam HArd Codes
--                    os programas desse sistema.
-----------------------------------------------------------------------------------------------------------

-- Origem dos Canais DWAT para Agrupamento ao conceito do Canal Extra Banco da Campanha Destaque Produção
-- ------------------------------------------------------------------------------------------------------
   V_EXTRA_BANCO       CONSTANT number := 3;
   V_CANAL_BANCO       CONSTANT number := 5;
   
-- Variaveis para calculo das Metas
-- --------------------------------

   -- Meta Minima DO PERIODO AUTO 
   -- Se o periodo for 3 meses, vide variavel V_QTD_META_MENSAL, o valor dessa variavel é igual a 3 vezes a V_META_MIN_MENSAL_AUTO)
   V_META_MINIMA_PERIODO_AUTO CONSTANT number := 30000;
      
   -- Meta Minima do PERIODO RE
   -- Se o periodo for 3 meses, vide variavel V_QTD_META_MENSAL, o valor dessa variavel é igual a 3 vezes a V_META_MIN_MENSAL_RE)
   V_META_MINIMA_PERIODO_RE  CONSTANT number := 9000;
    
   -- Meta Minima Mensal para o AUTO
   V_META_MIN_MENSAL_AUTO CONSTANT number := 10000;
   
   -- Meta Minima Mensal para o RE
   V_META_MIN_MENSAL_RE   CONSTANT number := 3000;       
   
   -- Percentuais de Crescimento para o Cálculo da Meta AUTO
   V_META_FAIXA_AUTO_1 CONSTANT number := 20; -- Se a Produção estiver até 300.000,00
   V_META_FAIXA_AUTO_2 CONSTANT number := 10; -- Se a Producao ficar entre 300.000,01 e 600.000,00
   V_META_FAIXA_AUTO_3 CONSTANT number :=  5; -- Se a Producao for maior do que 600.000,00
   
   -- Percentuais de Crescimento para Cálculo da Meta RE (Igual ao AUTO)
   V_META_FAIXA_RE_1   CONSTANT number := 20; -- Se a Produção estiver até 300.000,00
   V_META_FAIXA_RE_2   CONSTANT number := 10; -- Se a Producao ficar entre 300.000,01 e 600.000,00
   V_META_FAIXA_RE_3   CONSTANT number :=  5; -- Se a Producao for maior do que 600.000,00
   
   -- Valores de Producao, Usados para estipular qual será o PERCENTUAL de CRESCIMENTO do Corretor (Vide Variaveis Acima)
   V_PRODUCAO_AUTO_1   CONSTANT number := 300000;
   V_PRODUCAO_AUTO_2   CONSTANT number := 600000;
   V_PRODUCAO_RE_1     CONSTANT number := 300000;
   V_PRODUCAO_RE_2     CONSTANT number := 600000;
   
   -- Quantidade de METAS Mensais que serão calculadas a cada execução do calculo da meta
   V_QTD_META_MENSAL   CONSTANT number := 3;
   
   -- Tempo que o Corretor deve ter pelo menos uma EMISSAO para ser considerado como ATIVO na Bradesco
   V_TEMPO_CORRETOR_ATIVO	CONSTANT number := -12;
   
   -- Numero de Meses que serão diminuidos para que se obtenha a Produção Base para o Calculo da META
   V_MES_BASE_CALC_META CONSTANT number := -12;
   
   -- Metodos de Calculo da META
   
   V_METODO_META_IMPLANTACAO CONSTANT CHAR(01) := 'I'; -- Usado no metodo implantacao.
   V_METODO_META_DIARIA      CONSTANT CHAR(01) := 'D'; -- Usado no metodo de carga diaria.
       
-- Producao
-- --------
 
   -- Valor de Producao Minima Trimestral AUTO Para Premiação
   V_PROD_MIN_TRI_AUTO CONSTANT number := 20000;
   -- Valor de Producao Minima Trimestral RE Para Premiação
   V_PROD_MIN_TRI_RE   CONSTANT number := 12000;
 
-- Valor para indicar que a informação NAO SE APLICA
-- ------------------------------------------------- 
   V_NAO_SE_APLICA	   CONSTANT  NUMBER := null;
    
-- RANKING Default (a ser usado quando ainda não se tem RANKING, ou seja, em uma INCLUSAO)
-- ---------------------------------------------------------------------------------------
   V_RANKING_DEFAULT   CONSTANT number := 999999;
   
-- PENCENTUAL DE CRESCIMENTO DEFAULT (DE ATINGIMENTO)
   V_PERCENTUAL_CRESC_DEFAULT CONSTANT NUMBER := 0;
    
-- Indicativo DEFAULT de alcance da META (a ser usado quando ainda não se tem esse indicativo calculado, ou seja, em uma INCLUSAO)
-- -------------------------------------------------------------------------------------------------------------------------------
   V_CIND_ALCAN_META   CONSTANT varchar2(01) := 'N';

-- INDICA CONDIÇÃO DE BLOQUEIO DEFAULT
-- -----------------------------------
    V_CIND_BLOQUEIO_DEFAULT CONSTANT varchar2(01) := 'N';
    
-- Variaveis Que defininem os TIPOS DE PARAMETRO da tabela PARM_CARGA_DSTAQ
-- ------------------------------------------------------------------------

   -- Parametro indicativo dos registros das Sucursais Bloqueadas
   V_CPARM_SUCUR CONSTANT number := 2;
   -- Parametro indicativo dos Corretores Bloqueadas
   V_CPARM_CCRRTR CONSTANT number:= 3;
    
-- Contadores / Variaveis de Controle
-- ----------------------------------
       
    -- Total de Linhas para COMMIT
    V_TOT_REG_COMMIT	CONSTANT NUMBER := 5000;    
 	-- Total de Registros Correntes Processados
    V_CORRENTE_REG_PROC NUMBER := 0;                                
    -- Total de Regristros Processados em todo o processo
    V_TOT_REG_PROC      number := 0;   
    -- Indicativo de Ponto de Programa    
    V_PASSO				NUMBER;
          
END PC_DSTAQ;
/

