CREATE OR REPLACE PACKAGE SGPB_PROC.Pc_Util_01 IS

  CPARM number := 34;

  DESENVOLVIMENTO CONSTANT VARCHAR2(1):= 'D';
  PRODUCAO CONSTANT VARCHAR2(1) := 'P';

  -- FAÇA AQUI O SWITCH DE DESENVOLVIMENTO PARA PRODUCAO E VICE-VERSA 
  -- Alinha abaixo foi documentada a pedido do Vitor para que esse fonte seja colocado em Produção. Wassily.
  -- Obs: Foi alterado o valor da variavel AMBIENTE (estava com DESENVOLVIMENTO e ficou PRODUÇÂO).
  -- AMBIENTE CONSTANT VARCHAR2(1) := DESENVOLVIMENTO;
  AMBIENTE CONSTANT VARCHAR2(1) := PRODUCAO;

  -- Canais
  Extra_Banco CONSTANT NUMBER := 1;
  Banco CONSTANT NUMBER := 2;
  Finasa CONSTANT NUMBER := 3;

  --TIPOS DE DOCUMENTO
  ENDOSSO VARCHAR2(1) := 'D';
  EMISSAO VARCHAR2(1) := 'M';
  CANCELAMENTO VARCHAR2(1) := 'C';

  -- Grupo Ramos
  Auto CONSTANT NUMBER := 120;
  Re CONSTANT NUMBER := 810;
  ReTodos CONSTANT NUMBER := 999;

  -- tipo de comissao
  COMISSAO_NORMAL VARCHAR2(2) := 'CN';
  COMISSAO_ESPECIAL VARCHAR2(2) := 'CE';

  -- Tipo Apuração
  Normal CONSTANT NUMBER := 1;

  Extra CONSTANT NUMBER := 2;

  -- Usuário Padrão Responsável pelas alterações
  Usuario_Responsavel CONSTANT VARCHAR2(5) := 'CARGA';

  -- Situacao dos Canais
  Ativo CONSTANT CHAR(1) := 'A';

  Encerrado CONSTANT CHAR(1) := 'E';

  Suspenso CONSTANT CHAR(1) := 'S';

  -- Tipo de Período
  Mensal CONSTANT CHAR(1) := 'M';

  Periodo CONSTANT CHAR(1) := 'P';

  -- Tipo de Pessoa
  Fisica CONSTANT CHAR(2) := 'PF';

  Juridica CONSTANT CHAR(2) := 'PJ';

  -- Tipos de log de execução
  Var_Log_Processo CONSTANT CHAR(1) := 'P';

  Var_Log_Dado CONSTANT CHAR(1) := 'D';

  -- Tamanho da mensagem de erro
  Var_Log_Erro VARCHAR2(2000);

  Var_Tam_Msg_Erro CONSTANT NUMBER := 1999;

  -- Avalia se foi ou não retido
  Var_Retido_Sim CONSTANT NUMBER := 1;

  Var_Retido_Nao CONSTANT NUMBER := 0;

  -- discrimina se foi menos ou maior que o minimo
  Var_Abaixo_Minimo CONSTANT NUMBER := 0;

  Var_Acima_Minimo CONSTANT NUMBER := 1;

  -- código do erro encontrado no SQL
  Unique_Constraint_violated CONSTANT NUMBER := -1;

  -- VARIAVEIS PARA ALTERACAO DA SITUACAO DA ROTINA
  Var_Rotna_Ap CONSTANT CHAR(2) := 'AP'; -- A PROCESSAR
  Var_Rotna_Pc CONSTANT CHAR(2) := 'PC'; -- PROCESSANDO
  Var_Rotna_Po CONSTANT CHAR(2) := 'PO'; -- PROCESSADO OK
  Var_Rotna_Pe CONSTANT CHAR(2) := 'PE'; -- PROCESSADO COM ERRO
  -- Variaveis de tipo de apuração
  Var_Apurc_Ap CONSTANT CHAR(2) := 'AP'; -- apurada
  Var_Apurc_Pg CONSTANT CHAR(2) := 'PG'; -- Pago
  Var_Apurc_Lm CONSTANT CHAR(2) := 'LM'; -- No limite
  Var_Apurc_Lg CONSTANT CHAR(2) := 'LG'; -- Liberado pelo gestor
  -- Variaveis de tipo de aprovisionamento
  Var_Aprov_Ap CONSTANT CHAR(2) := 'AP'; -- aprovisionado
  Var_Aprov_Rz CONSTANT CHAR(2) := 'RZ'; -- Realizado
  Var_Aprov_Pg CONSTANT CHAR(2) := 'PG'; -- Pagamento
  Var_Aprov_Es CONSTANT CHAR(2) := 'ES'; -- Estornado
  --
  --
  TYPE Colecaosituacao IS TABLE OF CHAR(2);

  TYPE Sgpb_Cursor IS REF CURSOR;

  TYPE Strutpag IS RECORD(
    Ccpf_Cnpj_Base Crrtr_Unfca_Cnpj.Ccpf_Cnpj_Base%TYPE,
    Ctpo_Pssoa     Crrtr_Unfca_Cnpj.Ctpo_Pssoa%TYPE,
    Iatual_Crrtr   Crrtr_Unfca_Cnpj.Iatual_Crrtr%TYPE,
    Valor_Bonif_At NUMBER(14, 2),
    Valor_Bonif_Rt NUMBER(14, 2),
    Comp_Ret       VARCHAR2(50),
    Comp_At        VARCHAR2(20),
    Flag_Mini      NUMBER);

  TYPE file_type IS RECORD (id BINARY_INTEGER,
                            datatype BINARY_INTEGER,
                            byte_mode BOOLEAN);

  TYPE Cur_Strut_Pag IS REF CURSOR RETURN Strutpag;

  /* diretorio desenvolvimento */
  Diretorio_Padrao CONSTANT VARCHAR2(30) := '/x0305/D001/sgpb/arquivo';
  
  /* diretorio produçao */
  --Diretorio_Padrao CONSTANT VARCHAR2(30) := '/x0205/P002/sgpb/arquivo';
  
  /* diretorio fabrica stefanini */
  --Diretorio_Padrao CONSTANT VARCHAR2(30) := 'LOCAL';

  ParametrosInvalidos Exception;
  CanalNaoAtivoException Exception;

  -- Variaveis ------------*************************--**********************--********
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0001
  --      DATA            : 7/3/2006 09:03:55
  --      AUTOR           : Mariano Aloi - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      PROGRAMA        : PC_UTIL_01.SQL
  --      OBJETIVO        : Procedure para retorno do estado do canal
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
  PROCEDURE Sgpb0001(Chrrestado   OUT tpo_apurc_canal_vda.csit_apurc_canal%TYPE, -- Retorno do Estado
                     Intrcanal    IN Canal_Vda_Segur.Ccanal_Vda_Segur%TYPE, -- Canal que deve ser avaliado
                     IntrTipoApurc IN Tpo_Apurc.Ctpo_Apurc %type,
                     Intrvigencia IN Prod_Crrtr.Ccompt_Prod%TYPE -- Data para vigencia de ana
                     );

  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0002
  --      DATA            : 7/3/2006 09:04:36
  --      AUTOR           : Mariano Aloi - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      PROGRAMA        : PC_UTIL_01.SQL
  --      OBJETIVO        : Procedure que retornará a margem de contribuição minima para o corretor em um determindado canal
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
  PROCEDURE Sgpb0002(Dblrmargem   OUT Parm_Canal_Vda_Segur.Pmargm_Contb_Min%TYPE,
                     Intrcanal    IN Canal_Vda_Segur.Ccanal_Vda_Segur%TYPE,
                     Intrvigencia IN Prod_Crrtr.Ccompt_Prod%TYPE);

  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0003
  --      DATA            : 7/3/2006 09:05:00
  --      AUTOR           : Mariano Aloi - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      PROGRAMA        : PC_UTIL_01.SQL
  --      OBJETIVO        : Procedure para retorno da faixa correspondente a um corretor de um determinado canal
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
  PROCEDURE Sgpb0003(Intrfaixainicial OUT Parm_Canal_Vda_Segur. Cinic_Faixa_Crrtr %TYPE,
                     Intrfaixafinal   OUT Parm_Canal_Vda_Segur. Cfnal_Faixa_Crrtr %TYPE,
                     Intrcanal        IN Canal_Vda_Segur. Ccanal_Vda_Segur %TYPE,
                     Intrvigencia     IN Prod_Crrtr.Ccompt_Prod%TYPE);

  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0003
  --      DATA            : 7/3/2006 09:05:00
  --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      PROGRAMA        : PC_UTIL_01.SQL
  --      OBJETIVO        : Procedure para retorno da faixa correspondente a um corretor de um determinado canal
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
  PROCEDURE Sgpb0003(Intrfaixainicial OUT Parm_Canal_Vda_Segur. Cinic_Faixa_Crrtr %TYPE,
                     Intrfaixafinal   OUT Parm_Canal_Vda_Segur. Cfnal_Faixa_Crrtr %TYPE,
                     Intrcanal        IN Canal_Vda_Segur. Ccanal_Vda_Segur %TYPE,
                     IntrDia          IN date);

  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0004
  --      DATA            : 7/3/2006 09:05:19
  --      AUTOR           : Mariano Aloi - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      PROGRAMA        : PC_UTIL_01.SQL
  --      OBJETIVO        : Procedure que retornará a meta minima para quantidade de apolises e valor minimo para ser elegivel no Plano de Bonus
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
  PROCEDURE Sgpb0004(Dblrvalmin        OUT Parm_Prod_Min_Crrtr. Vmin_Prod_Crrtr %TYPE,
                     Intrqtdmin        OUT Parm_Prod_Min_Crrtr. Qitem_Min_Prod_Crrtr %TYPE,
                     Intrcanal         IN Canal_Vda_Segur. Ccanal_Vda_Segur %TYPE,
                     Intrvigencia      IN Prod_Crrtr.Ccompt_Prod%TYPE,
                     Intrramo          IN Parm_Prod_Min_Crrtr.Cgrp_Ramo_Plano%TYPE,
                     Chrrperiodicidade IN Parm_Prod_Min_Crrtr.Ctpo_Per %TYPE,
                     Chrrtppessoa      IN Parm_Prod_Min_Crrtr.Ctpo_Pssoa%TYPE);

  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0005
  --      DATA            : 7/3/2006 09:05:45
  --      AUTOR           : Mariano Aloi - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      PROGRAMA        : PC_UTIL_01.SQL
  --      OBJETIVO        : Procedure para retorno da quantidade de meses de aptidão para analise de seleção
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
  PROCEDURE Sgpb0005(Intrqtmesanlse OUT Parm_Per_Apurc_Canal. Qmes_Anlse %TYPE,
                     Intrcanal      IN Canal_Vda_Segur. Ccanal_Vda_Segur %TYPE,
                     Intrvigencia   IN Prod_Crrtr.Ccompt_Prod%TYPE,
                     Intrtpapurc    IN Tpo_Apurc.Ctpo_Apurc %TYPE);

  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0006
  --      DATA            : 7/3/2006 09:06:23
  --      AUTOR           : Mariano Aloi - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      PROGRAMA        : PC_UTIL_01.SQL
  --      OBJETIVO        : Procedure para retorno o tempo minimo de relacionamento com o canal
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
  PROCEDURE Sgpb0006(Intrqttemprelcto OUT Parm_Canal_Vda_Segur. Qtempo_Min_Rlcto %TYPE,
                     Intrcanal        IN Canal_Vda_Segur. Ccanal_Vda_Segur %TYPE,
                     Intrvigencia     IN Prod_Crrtr.Ccompt_Prod%TYPE);

  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0007
  --      DATA            : 7/3/2006 09:07:51
  --      AUTOR           : Mariano Aloi - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      PROGRAMA        : PC_UTIL_01.SQL
  --      OBJETIVO        : Procedure que retornará a quantidade de meses (intervalo) para que seja feita a apuração
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
  PROCEDURE Sgpb0007(Intrqtmesapurc OUT Parm_Per_Apurc_Canal.Qmes_Perdc_Apurc %TYPE,
                     Intrcanal      IN Canal_Vda_Segur. Ccanal_Vda_Segur %TYPE,
                     Intrvigencia   IN Prod_Crrtr.Ccompt_Prod%TYPE,
                     Intrtpapurc    IN Tpo_Apurc.Ctpo_Apurc %TYPE);

  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0017
  --      DATA            : 7/3/2006 09:03:55
  --      AUTOR           : Mariano Aloi - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      PROGRAMA        : PC_UTIL_01.SQL
  --      OBJETIVO        : Função que converte uma data para a uma competencia sendo retuzida de "n" meses
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
  FUNCTION Sgpb0017(Dtmvvigencia DATE, Intvqtmesanlse NUMBER)
    RETURN Prod_Crrtr.Ccompt_Prod%TYPE;

  FUNCTION Sgpb0017(Dtmvvigencia   Prod_Crrtr.Ccompt_Prod%TYPE,
                    Intvqtmesanlse NUMBER) RETURN Prod_Crrtr.Ccompt_Prod%TYPE;

  PROCEDURE Sgpb0028(Var_Log_Erro_Ori VARCHAR2, Var_Crotna_Ori VARCHAR2);

  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPBSGPB0031
  --      DATA            : 13/03/06 15:18:40
  --      AUTOR           : Mariano Aloi - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      PROGRAMA        : PC_BANCO_01.SQL
  --      OBJETIVO        : Definir qual é a data final de Vigencia
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
  FUNCTION Sgpb0031(Intvvigencia IN DATE) RETURN DATE;

  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0032
  --      DATA            : 14/03/06 09:05:44
  --      AUTOR           : Mariano Aloi - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      PROGRAMA        : PC_BANCO_01.SQL
  --      OBJETIVO        : Deletar informações da tabela temporaria
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
  PROCEDURE Sgpb0032(Intrvigencia IN Prod_Crrtr.Ccompt_Prod%TYPE,
                     Intrcanal    IN Canal_Vda_Segur. Ccanal_Vda_Segur %TYPE);

  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPBSGPB0068
  --      DATA            : 24/03/06 18:25:23
  --      AUTOR           : Mariano Aloi - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Conferir se o corretor se apresenta na faixa durante uma determinada quantidade de meses
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
  FUNCTION Sgpb0068(Vprod           NUMBER,
                    Qprod           NUMBER,
                    Intrcompetencia Margm_Contb_Crrtr.Ccompt_Margm %TYPE,
                    Ccrrtr          Prod_Crrtr.Ccrrtr %TYPE,
                    Cund_Prod       Prod_Crrtr.Cund_Prod %TYPE,
                    Intrqtmesanlse  Parm_Per_Apurc_Canal.Qmes_Anlse %TYPE)
    RETURN INTEGER;

  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0069
  --      DATA            : 7/3/2006 09:07:51
  --      AUTOR           : Mariano Aloi - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      PROGRAMA        : PC_UTIL_01.SQL
  --      OBJETIVO        : Procedure que retornará a quantidade de meses (intervalo) para que seja feita o pagamento
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
  PROCEDURE Sgpb0069(Intrqtmespgto OUT Parm_Per_Apurc_Canal.Qmes_Perdc_Apurc %TYPE,
                     Intrcanal     IN Canal_Vda_Segur. Ccanal_Vda_Segur %TYPE,
                     Intrvigencia  IN Prod_Crrtr.Ccompt_Prod%TYPE,
                     Intrtpapurc   IN Tpo_Apurc.Ctpo_Apurc %TYPE);

  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0079
  --      DATA            : 30/05/2006 11:51:09 AM
  --      AUTOR           : Mariano Aloi - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Buscar contas para movimento contabil, por canal
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
  PROCEDURE Sgpb0079(Intrcontacredora  OUT Parm_Canal_Vda_Segur.Ccta_Ctbil_Credr %TYPE,
                     Intrcontadevedora OUT Parm_Canal_Vda_Segur.Ccta_Ctbil_Dvdor %TYPE,
                     Intrvigencia      Margm_Contb_Crrtr.Ccompt_Margm %TYPE,
                     Intrcanal         Canal_Vda_Segur.Ccanal_Vda_Segur %TYPE);

END Pc_Util_01;
/

