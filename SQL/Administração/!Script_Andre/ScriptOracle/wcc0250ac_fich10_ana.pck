create or replace package wcc0250ac$fich is

   type NBT_REC is record
      ( PROC_SEL            varchar2(2000)
      , L_PRSE_PRSE_ABREV   PROCESSOS_SELETIVOS.PRSE_ABREV%type
      , L_PRSE_PRSE_NM      PROCESSOS_SELETIVOS.PRSE_NM%type
      , L_REPS_REPS_DT_INGRESSO REALIZACAO_PS.REPS_DT_INGRESSO%type
      , NOM_CPL             varchar2(2000)
      , L_CAND_CAND_NM      CANDIDATOS.CAND_NM%type
      , L_CAND_CAND_SOBRENOME CANDIDATOS.CAND_SOBRENOME%type
      , L_CAND_CAND_SENHA   CANDIDATOS.CAND_SENHA%type
      , INSC_CONFIRM        varchar2(2000)
      );

   NBT_VAL    NBT_REC;
   CURR_VAL   FICHAS_INSCRICAO%rowtype;


   procedure Startup(
             Z_DIRECT_CALL in boolean default false,
             Z_CHK in varchar2 default null,
             Z_FORM in varchar2 default null,
			 P_EMPRESA IN VARCHAR2 DEFAULT 'EAESP',
       P_PRSE_CD IN VARCHAR2 DEFAULT null);  --(++) 17/06/2009
   procedure ActionQuery(
            P_L_PRSE_PRSE_ABREV in varchar2 default null,
            P_L_REPS_REPS_DT_INGRESSO in varchar2 default null,
            P_FICH_NR_INSCRICAO in varchar2 default null,
            P_L_CAND_CAND_SENHA in varchar2 default null,
            P_TIPO_DOC in varchar2 default null,
            P_CAND_RG_NR in varchar2 default null,
            P_CAND_RG_UF in varchar2 default null,
            Z_DIRECT_CALL in boolean default false,
            Z_ACTION in varchar2 default null,
            Z_CHK in varchar2 default null ,
            P_EMPRESA IN VARCHAR2 DEFAULT 'EAESP',
            P_REPS_SEQ IN VARCHAR2 DEFAULT NULL);

            procedure FormQuery(
            Z_DIRECT_CALL in boolean default false,
            Z_CHK in varchar2 default null ,
            P_EMPRESA IN VARCHAR2 DEFAULT 'EAESP',
            P_PRSE_CD IN VARCHAR2 DEFAULT null);  --(++) 17/06/2009

   procedure ESTADO_LOV(
             Z_FILTER in varchar2,
             Z_MODE in varchar2,
             Z_CALLER_URL in varchar2,
             Z_FORMROW in number default 0,
             Z_LONG_LIST in varchar2 default null,
             Z_ISSUE_WAIT in varchar2 default null);

   procedure REPS_LOV(
             Z_FILTER in varchar2,
             Z_MODE in varchar2,
             Z_CALLER_URL in varchar2,
             P_L_PRSE_PRSE_ABREV in varchar2 default null,
             Z_FORMROW in number default 0,
             Z_LONG_LIST in varchar2 default null,
             Z_ISSUE_WAIT in varchar2 default null);
   procedure PRSE_LOV(
             Z_FILTER in varchar2,
             Z_MODE in varchar2,
             Z_CALLER_URL in varchar2,
             Z_FORMROW in number default 0,
             Z_LONG_LIST in varchar2 default null,
             Z_ISSUE_WAIT in varchar2 default null);

   procedure QueryView(
             K_PRSE_CD in varchar2 default null,
             K_REPS_SEQ in varchar2 default null,
             K_FICH_NR_INSCRICAO in varchar2 default null,
             K_CAND_CD in varchar2 default null,
             P_L_PRSE_PRSE_ABREV in varchar2 default null,
             P_L_REPS_REPS_DT_INGRESSO in varchar2 default null,
             P_FICH_NR_INSCRICAO in varchar2 default null,
             P_L_CAND_CAND_SENHA in varchar2 default null,
             Z_EXECUTE_QUERY in varchar2 default null,
             Z_POST_DML in boolean default false,
             Z_FORM_STATUS in number default WSGL.FORM_STATUS_OK,
             Z_DIRECT_CALL in boolean default false,
             Z_START in varchar2 default '1',
             Z_ACTION in varchar2 default null,
             Z_CHK in varchar2 default null,
			 P_EMPRESA IN VARCHAR2 DEFAULT 'EAESP');
   function QueryHits(
            P_L_PRSE_PRSE_ABREV in varchar2 default null,
            P_L_REPS_REPS_DT_INGRESSO in varchar2 default null,
            P_FICH_NR_INSCRICAO in varchar2 default null,
            P_L_CAND_CAND_SENHA in varchar2 default null) return number;

   procedure ActionView(
             P_PRSE_CD in owa_text.vc_arr,
             P_REPS_SEQ in owa_text.vc_arr,
             P_FICH_NR_INSCRICAO in owa_text.vc_arr,
             P_CAND_CD in owa_text.vc_arr,
             O_FICH_ISENTO_PAGTO in owa_text.vc_arr default WSGL.EmptyVCArrLong,
             O_FICH_INSCR_PAGA in owa_text.vc_arr default WSGL.EmptyVCArrLong,
             O_FICH_DT_PGTO in owa_text.vc_arr default WSGL.EmptyVCArrLong,
             O_FICH_MEDIA_FINAL in owa_text.vc_arr default WSGL.EmptyVCArrLong,
             O_FICH_CLASSIF_PS in owa_text.vc_arr default WSGL.EmptyVCArrLong,
             H_PROC_SEL in owa_text.vc_arr default WSGL.EmptyVCArrLong,
             H_L_REPS_REPS_DT_INGRESSO in owa_text.vc_arr default WSGL.EmptyVCArrLong,
             H_FICH_NR_INSCRICAO in owa_text.vc_arr default WSGL.EmptyVCArrLong,
             H_NOM_CPL in owa_text.vc_arr default WSGL.EmptyVCArrLong,
             H_INSC_CONFIRM in owa_text.vc_arr default WSGL.EmptyVCArrLong,
             H_FICH_DT_PGTO in owa_text.vc_arr default WSGL.EmptyVCArrLong,
             H_FICH_MEDIA_FINAL in owa_text.vc_arr default WSGL.EmptyVCArrLong,
             H_FICH_CLASSIF_PS in owa_text.vc_arr default WSGL.EmptyVCArrLong,
             Q_L_PRSE_PRSE_ABREV in varchar2 default null,
             Q_L_REPS_REPS_DT_INGRESSO in varchar2 default null,
             Q_FICH_NR_INSCRICAO in varchar2 default null,
             Q_L_CAND_CAND_SENHA in varchar2 default null,
             z_modified in owa_text.vc_arr,
             Z_ACTION in varchar2 default null,
             Z_START  in varchar2 default '1',
             Z_CHK in varchar2 default null );
   procedure QueryViewByKey(
             P_PRSE_CD in varchar2 default null,
             P_REPS_SEQ in varchar2 default null,
             P_FICH_NR_INSCRICAO in varchar2 default null,
             P_CAND_CD in varchar2 default null,
             Z_POST_DML in boolean default false,
             Z_FORM_STATUS in number default WSGL.FORM_STATUS_OK,
             Z_DIRECT_CALL in boolean default false,
             Z_CHK in varchar2 default null);

   function RestoreState
             ( Z_CURR_DEPTH          in number
             , Z_MAX_DEPTH           in number
             , Z_RESTORE_OWN_ROW     in boolean default true
             )  return boolean;
   procedure SaveState;

   procedure InitialiseDomain(P_ALIAS in varchar2);
--(++)
   D_TIPO_DOC            WSGL.typDVRecord;
--(++)
   D_FICH_ISENTO_PAGTO   WSGL.typDVRecord;
   D_FICH_INSCR_PAGA     WSGL.typDVRecord;

   FUNCTION FcDadosGerais(P_PRSE_CD in varchar2 default null,
                          P_REPS_SEQ in number default null,
                          P_CAND_CD in number default null)
return char;

   PROCEDURE Doctos(P_PRSE_CD   in varchar2 default null,
                    P_REPS_SEQ  in varchar2 default null,
                    P_INSCRICAO in varchar2 default null);

end;
/
create or replace package body wcc0250ac$fich is

   procedure FormView(Z_FORM_STATUS in number,
                      Q_L_PRSE_PRSE_ABREV in varchar2 default null,
                      Q_L_REPS_REPS_DT_INGRESSO in varchar2 default null,
                      Q_FICH_NR_INSCRICAO in varchar2 default null,
                      Q_L_CAND_CAND_SENHA in varchar2 default null,
                      Z_POST_DML in boolean default false,
                      Z_MULTI_PAGE  in boolean default true,
                      Z_ACTION in varchar2 default null,
                      Z_START in varchar2 default '1',
					  P_EMPRESA IN VARCHAR2 DEFAULT 'EAESP');
   function BuildSQL(
            P_L_PRSE_PRSE_ABREV in varchar2 default null,
            P_L_REPS_REPS_DT_INGRESSO in varchar2 default null,
            P_FICH_NR_INSCRICAO in varchar2 default null,
            P_L_CAND_CAND_SENHA in varchar2 default null,
            Z_QUERY_BY_KEY in boolean default false,
            Z_ROW_ID in ROWID default null,
            Z_BIND_ROW_ID in boolean default false,
            P_REPS_SEQ VARCHAR2 DEFAULT NULL) return boolean;

   procedure OpenZoneSql  ( I_CURSOR OUT integer );
   procedure AssignZoneRow( I_CURSOR IN  integer );

   function PreQuery(
            P_L_PRSE_PRSE_ABREV in varchar2 default null,
            P_L_REPS_REPS_DT_INGRESSO in varchar2 default null,
            P_FICH_NR_INSCRICAO in varchar2 default null,
            P_L_CAND_CAND_SENHA in varchar2 default null) return boolean;
   function PostQuery(Z_POST_DML in boolean, Z_UPDATE_ROW in out boolean) return boolean;

   QF_BODY_ATTRIBUTES     constant varchar2(500) := '';
   QF_QUERY_BUT_CAPTION   constant varchar2(100) := 'Localizar Candidato';
   QF_CLEAR_BUT_CAPTION   constant varchar2(100) := WSGL.MsgGetText(4,WSGLM.CAP004_QF_CLEAR);
   QF_QUERY_BUT_ACTION    constant varchar2(10)  := 'QUERY';
   QF_CLEAR_BUT_ACTION    constant varchar2(10)  := 'CLEAR';
   QF_NUMBER_OF_COLUMNS   constant number(4)	 := 1;
   VF_BODY_ATTRIBUTES     constant varchar2(500) := '';
   VF_UPDATE_BUT_CAPTION  constant varchar2(100) := WSGL.MsgGetText(6,WSGLM.CAP006_VF_UPDATE);
   VF_CLEAR_BUT_CAPTION   constant varchar2(100) := WSGL.MsgGetText(8,WSGLM.CAP008_VF_REVERT);
   VF_DELETE_BUT_CAPTION  constant varchar2(100) := WSGL.MsgGetText(7,WSGLM.CAP007_VF_DELETE);
   VF_NEXT_BUT_CAPTION    constant varchar2(100) := WSGL.MsgGetText(11,WSGLM.CAP011_RL_NEXT);
   VF_PREV_BUT_CAPTION    constant varchar2(100) := WSGL.MsgGetText(12,WSGLM.CAP012_RL_PREVIOUS);
   VF_FIRST_BUT_CAPTION   constant varchar2(100) := WSGL.MsgGetText(13,WSGLM.CAP013_RL_FIRST);
   VF_LAST_BUT_CAPTION    constant varchar2(100) := WSGL.MsgGetText(14,WSGLM.CAP014_RL_LAST);
   VF_COUNT_BUT_CAPTION   constant varchar2(100) := WSGL.MsgGetText(15,WSGLM.CAP015_RL_COUNT);
   VF_REQUERY_BUT_CAPTION constant varchar2(100) := WSGL.MsgGetText(16,WSGLM.CAP016_RL_REQUERY);
   VF_NTOM_BUT_CAPTION    constant varchar2(100) := '%s -> %e';
   VF_QUERY_BUT_CAPTION  constant varchar2(100)  := WSGL.MsgGetText(24,WSGLM.CAP024_RL_QUERY);
   VF_QUERY_BUT_ACTION    constant varchar2(10)  := 'QUERY';
   VF_UPDATE_BUT_ACTION   constant varchar2(10)  := 'UPDATE';
   VF_CLEAR_BUT_ACTION    constant varchar2(10)  := 'CLEAR';
   VF_DELETE_BUT_ACTION   constant varchar2(10)  := 'DELETE';
   VF_NEXT_BUT_ACTION     constant varchar2(10)  := 'NEXT';
   VF_PREV_BUT_ACTION     constant varchar2(10)  := 'PREV';
   VF_FIRST_BUT_ACTION    constant varchar2(10)  := 'FIRST';
   VF_LAST_BUT_ACTION     constant varchar2(10)  := 'LAST';
   VF_COUNT_BUT_ACTION    constant varchar2(10)  := 'COUNT';
   VF_REQUERY_BUT_ACTION  constant varchar2(10)  := 'REQUERY';
   VF_NTOM_BUT_ACTION     constant varchar2(10)  := 'NTOM';
   VF_VERIFIED_DELETE     constant varchar2(100) := 'VerifiedDelete';
   VF_NUMBER_OF_COLUMNS   constant number(4)	   := 1;
   VF_RECORD_SET_SIZE     constant number(5)     := 1;

   VF_TOTAL_COUNT_REQD    constant boolean       := FALSE;
   IF_BODY_ATTRIBUTES     constant varchar2(500) := '';
   RL_BODY_ATTRIBUTES     constant varchar2(500) := '';
   LOV_BODY_ATTRIBUTES    constant varchar2(500) := '';
   LOV_FIND_BUT_CAPTION   constant varchar2(100) := WSGL.MsgGetText(17,WSGLM.CAP017_LOV_FIND);
   LOV_CLOSE_BUT_CAPTION  constant varchar2(100) := WSGL.MsgGetText(18,WSGLM.CAP018_LOV_CLOSE);
   LOV_FIND_BUT_ACTION    constant varchar2(10)  := 'FIND';
   LOV_CLOSE_BUT_ACTION   constant varchar2(10)  := 'CLOSE';
   LOV_BUTTON_TEXT        constant varchar2(100) := htf.img('/ows-img/gv_lov.jpg', cattributes=>'border="0"');
   LOV_FRAME              constant varchar2(20)  := null;
   TF_BODY_ATTRIBUTES     constant varchar2(500) := '';
   DEF_BODY_ATTRIBUTES    constant varchar2(500) := '';

   type FORM_REC is record
        (PROC_SEL            varchar2(2000)
        ,PRSE_CD             varchar2(5)
        ,REPS_SEQ            varchar2(8)
        ,L_PRSE_PRSE_ABREV   varchar2(15)
        ,L_PRSE_PRSE_NM      varchar2(250) --(++) 30/08/2007
        ,L_REPS_REPS_DT_INGRESSO varchar2(12)
        ,FICH_NR_INSCRICAO   varchar2(10)
        ,NOM_CPL             varchar2(2000)
        ,L_CAND_CAND_NM      varchar2(50)
        ,L_CAND_CAND_SOBRENOME varchar2(30)
        ,L_CAND_CAND_SENHA   varchar2(30)
        ,CAND_CD             varchar2(10)
        ,FICH_ISENTO_PAGTO   varchar2(1)
        ,FICH_INSCR_PAGA     varchar2(1)
        ,INSC_CONFIRM        varchar2(2000)
        ,FICH_DT_PGTO        varchar2(12)
        ,FICH_MEDIA_FINAL    varchar2(20)
        ,FICH_CLASSIF_PS     varchar2(10)
        );
   FORM_VAL               FORM_REC;

   PROCESSING_VIEW        boolean := false;
   VF_ROWS_UPDATED        integer := 0;
   VF_ROWS_DELETED        integer := 0;
   VF_ROWS_ERROR          integer := 0;
   type CTX_REC is record
      ( FICH_NR_INSCRICAO   varchar2(10)
      );
   type CTX_REC_ARR is table of CTX_REC index by binary_integer;
   VF_DELETED_ROWS        CTX_REC_ARR;
   type ROW_REC is record
      ( F_PROC_SEL            varchar2(2000)
      , F_PRSE_CD             varchar2(5)
      , F_REPS_SEQ            varchar2(8)
      , F_L_PRSE_PRSE_ABREV   varchar2(15)
      , F_L_PRSE_PRSE_NM      varchar2(250) --(++) 30/08/2007
      , F_L_REPS_REPS_DT_INGRESSO varchar2(12)
      , F_FICH_NR_INSCRICAO   varchar2(10)
      , F_NOM_CPL             varchar2(2000)
      , F_L_CAND_CAND_NM      varchar2(50)
      , F_L_CAND_CAND_SOBRENOME varchar2(30)
      , F_L_CAND_CAND_SENHA   varchar2(30)
      , F_CAND_CD             varchar2(10)
      , F_FICH_ISENTO_PAGTO   varchar2(1)
      , F_FICH_INSCR_PAGA     varchar2(1)
      , F_INSC_CONFIRM        varchar2(2000)
      , F_FICH_DT_PGTO        varchar2(12)
      , F_FICH_MEDIA_FINAL    varchar2(9)
      , F_FICH_CLASSIF_PS     varchar2(10)
      , SUCCESS_FLAG          boolean
      , ROW_DELETED           boolean
      , ROW_NOT_LOCKED        boolean
      , ROW_ID                rowid
      );
   type ROW_SET_TYPE is table of ROW_REC index by binary_integer;
   VF_ROW_SET             ROW_SET_TYPE;
   ZONE_SQL               varchar2(32767) := null;
   ZONE_CHECKSUM          varchar2(10);




FUNCTION FcDadosGerais(P_PRSE_CD in varchar2 default null,
                       P_REPS_SEQ in number default null,
                       P_CAND_CD in number default null)
return char IS

-- FcDadosGerais
--
--



    cursor c0(P_FASE_CD in varchar2) is
        select B.FASE_CD,
               B.STAT_CD,
               B.FASE_IN_DIVULGA_LISTA,
               B.FASE_IN_DIVULGA_SALA,
               F.PRSE_TIPO,
               (nvl(E.REPS_QTD_ESPERA,0) + B.FASE_QTD_CLASS_TREIN + B.FASE_QTD_CLASS_NAO_TREIN) "TOT_VAGAS",
               B.FASE_NOTA_CORTE,
               C.STAT_IN_ENCERRAMENTO
          from CAND_FASES A,
               FASES_PS B,
               STATUS C,
               REALIZACAO_PS E,
               PROCESSOS_SELETIVOS F
         where E.PRSE_CD = P_PRSE_CD
           and E.REPS_SEQ = P_REPS_SEQ
           and F.PRSE_CD = E.PRSE_CD
           and B.PRSE_CD = E.PRSE_CD
           and B.REPS_SEQ = E.REPS_SEQ
           and B.FASE_CD = P_FASE_CD
           and C.STAT_CD(+) = B.STAT_CD
           and A.PRSE_CD = B.PRSE_CD
           and A.REPS_SEQ = B.REPS_SEQ
           and A.FASE_CD = B.FASE_CD
           and A.CAND_CD = P_CAND_CD;
        r0 c0%rowtype;

    cursor c1(P_FASE_CD in varchar2) is
        select A.CDSA_DT_REALIZ_PROVA,
		           B.FASE_CD,
               B.STAT_CD,
               B.FASE_IN_DIVULGA_LISTA,
               D.LCPS_NM,
               D.LCPS_ENDERECO,
               D.LCPS_NUM_ENDERECO,
               D.LCPS_COMPLEMENTO,
               D.LCPS_BAIRRO,
               D.LCPS_CIDADE,
               D.SG_UF,
               D.LCPS_CEP,
               C.SALO_NUM_SALA,
               C.SALO_BLOCO,
               C.SALO_ANDAR,
               b.fase_dt_inicio,  --(++) 21/10/2008
               b.fase_dt_fim      --(++) 21/10/2008
          from CAND_FASE_SALAS A,
               SALAS_LOCAL C,
               LOCALIDADE_PS D,
               FASES_PS B
         where B.PRSE_CD = P_PRSE_CD
           and B.REPS_SEQ = P_REPS_SEQ
           and B.FASE_CD = P_FASE_CD
           and A.PRSE_CD = B.PRSE_CD
           and A.REPS_SEQ = B.REPS_SEQ
           and A.FASE_CD = B.FASE_CD
           and A.CAND_CD = P_CAND_CD
           and C.LCPS_CD(+) = A.LCPS_CD
           and C.SALO_NUM_SALA(+) = A.SALO_NUM_SALA
           and D.LCPS_CD(+) = C.LCPS_CD
		   order by 1;
       r1 c1%rowtype;

    cursor c2(P_FASE_CD in varchar2,
              P_CAND_CD in varchar2) is
        select NOPR.TIPR_CD,
               L_PROV.PROV_TIPO,
               L_TIPR.TIPR_NM,
               L_PROV.PROV_DT_REALIZACAO,
               L_PROV.PROV_PESO,
               L_PROV.PROV_DESVIO_PADRAO,
               L_PROV.PROV_MEDIA,
               L_PROV.PROV_NOTA_CORTE,
               NOPR.NOPR_NOTA_BRUTA,
               NOPR.NOPR_NOTA_PADRON,
               NOPR.NOPR_IN_MANUAL,
			   L_PROV.PROV_SEQUENCIA
          from NOTAS_PROVA NOPR,
               PROVAS_FASES L_PROV,
               TIPOS_PROVA L_TIPR
         where NOPR.PRSE_CD = P_PRSE_CD
           and NOPR.REPS_SEQ = P_REPS_SEQ
           and NOPR.FASE_CD = P_FASE_CD
           and NOPR.CAND_CD = P_CAND_CD
           and NOPR.REPS_SEQ = L_PROV.REPS_SEQ
           and NOPR.PRSE_CD = L_PROV.PRSE_CD
           and NOPR.FASE_CD = L_PROV.FASE_CD
           and NOPR.TIPR_CD = L_PROV.TIPR_CD
           and exists (select 1
                         from PROVAS_FASES X
                        where X.PRSE_CD = NOPR.PRSE_CD
                          and X.REPS_SEQ = NOPR.REPS_SEQ
                          and X.TIPR_CD = L_TIPR.TIPR_CD)
           and L_PROV.TIPR_CD = L_TIPR.TIPR_CD
UNION ALL
         select A.TIPR_CD,
               L_PROV.PROV_TIPO,
               L_TIPR.TIPR_NM,
               L_PROV.PROV_DT_REALIZACAO,
               L_PROV.PROV_PESO,
               L_PROV.PROV_DESVIO_PADRAO,
               L_PROV.PROV_MEDIA,
               L_PROV.PROV_NOTA_CORTE,
               A.NTOP_NOTA,
               A.NTOP_NOTA,
               DECODE(A.FORMA_AVAL,'AUT','S','N'),
			   L_PROV.PROV_SEQUENCIA
          from NOTAS_OPCAO A,
               PROVAS_FASES L_PROV,
               TIPOS_PROVA L_TIPR ,
			   OPCOES_INSCRICAO B
         where A.PRSE_CD = P_PRSE_CD
           and A.REPS_SEQ = P_REPS_SEQ
           and A.FASE_CD = P_FASE_CD
           and A.CAND_CD = P_CAND_CD
		   AND A.PRSE_CD  = B.PRSE_CD
		   AND A.REPS_SEQ = B.REPS_SEQ
		   AND A.CAND_CD  = B.CAND_CD
		   AND A.CUCA_CD  = B.CUCA_CD
		   AND B.OPIN_NUM_OPCAO = 1
           and A.REPS_SEQ = L_PROV.REPS_SEQ
           and A.PRSE_CD = L_PROV.PRSE_CD
           and A.FASE_CD = L_PROV.FASE_CD
           and A.TIPR_CD = L_PROV.TIPR_CD
           and exists (select 1
                         from PROVAS_FASES X
                        where X.PRSE_CD = A.PRSE_CD
                          and X.REPS_SEQ = A.REPS_SEQ
                          and X.TIPR_CD = L_TIPR.TIPR_CD)
           and L_PROV.TIPR_CD = L_TIPR.TIPR_CD

       order by 12;


     cursor agendamento is
                        select caen_local_entrev           local,
                               caen_data_hora_inicio       data,
                               caen_data_hora_inicio       hora_i ,
                               caen_data_hora_fim          hora_f ,
                               cuca_cd opcao
                          from calend_entrev
                         where prse_cd  = p_prse_cd
                           and reps_seq = p_reps_seq
                           and cand_cd  = p_cand_cd ;

   r_agendamento agendamento%rowtype;




    v_endereco varchar2(500);
    v_tot_fase number;
    v_msg_nota varchar2(200) := 'As notas serão publicadas na data estabelecida no cronograma do processo seletivo.';
    v_msg_sala varchar2(200) := 'O processo de alocação de salas da fase ainda não foi concluído.';
    n number;
    i number;
-- (++) Josy 05/06/2003
	v_Simulado varchar2(200):= null;
	w_1opcao   varchar2(10);
    w_status         varchar2(50);
    w_media          number(15,10);
    w_posicao_class  number(5);
	w_qtd_espera     number(5);

    w_CDSA_DT_REALIZ_PROVA date;
 	w_LCPS_NM              varchar2(80);
	w_LCPS_ENDERECO        varchar2(80);
	w_LCPS_NUM_ENDERECO    varchar2(80);
	w_LCPS_COMPLEMENTO     varchar2(80);
	w_LCPS_BAIRRO          varchar2(80);
	w_LCPS_CEP             varchar2(80);
	w_LCPS_CIDADE          varchar2(80);
	w_SG_UF                varchar2(2);
    w_SALO_BLOCO           varchar2(80);
	w_SALO_ANDAR           varchar2(80);
	w_SALO_NUM_SALA        varchar2(80);
	w_dat_inscricao        date;
	w_status_inscricao     varchar2(40);
	w_fich_dt_completa     date;
	w_qtde_documentos      number(3);
    w_qtde_entrega         number(3);
    w_dat_entrega	       date;
    w_fich_inscr_paga      varchar2(1);
    w_fich_isento_pagto	   varchar2(1);
    w_cabecalho            number(1);
    w_fich_dt_pgto	       date;
    w_decimais             number;
    w_reps_emite_boleto    varchar2(1);
    w_1opcao_desc          cursos_cacr.cuca_nm%type;
    v_ct_entrev            number; --(++ 28/08/2009
    v_reps_ind_divulg_parcial realizacao_ps.reps_ind_divulg_parcial%type; --(++) 28/08/2009
    v_divulga_periodo      varchar2(1); --(++) 28/08/2009

BEGIN
    -- Se não veio processo seletivo, é pq não encontrou candidato nenhum
    -- apresentar mensagem de erro e retornar
    --
    if P_PRSE_CD is null then
        htp.br;
        htp.br;
        htp.br;
        htp.bold('Os critérios de consulta não retornaram nenhum candidato. Corrija e tente novamente.');

        htp.para;

        WSGL.RecordListButton(TRUE, 'Z_ACTION', 'Consultar novamente',p_dojs=>FALSE,
                           buttonJS => 'onClick="window.open(''wcc0250ac$.startup'', ''_top'');"',
                           p_type_button=>true);
        return '';
    end if;


   begin
       -- Buscar decimais
       begin
          select nvl(reps_qtd_casa_dec,0), reps_emite_boleto, reps_ind_divulg_parcial
            into w_decimais, w_reps_emite_boleto, v_reps_ind_divulg_parcial
            from realizacao_ps
           where prse_cd  = P_PRSE_CD
             and reps_seq = P_REPS_SEQ;
       exception
            when others then
                 htp.p('ERRO: ' || SQLERRM);
       end;

       if w_decimais = 0 then
          htp.p('<script>');
          htp.p('alert("Quantidade de casas decimais para cálculos não foi parametrizada"); ');
          htp.p('</script>');
          return '';
       end if;
   end;





    htp.p('
        <STYLE>
        .conts	{visibility:hidden}
        .tab	{	border-top:solid thin #E0E0E0;
        			border-right:solid thin gray;
        			border-left:solid thin #E0E0E0;
        			text-align:center;
        			font-weight:normal}

        .selTab	{	border-left:solid thin white;
        			border-top:solid thin white;
        			border-right:solid thin black;
        			font-weight:bold;
        			text-align:center}

        </STYLE>
        <SCRIPT LANGUAGE=JavaScript>');

    -- Descobrir quantas fases tem o processo seletivo
    --
    begin
        select count(*)
          into v_tot_fase
          from FASES_PS A
         where A.PRSE_CD = P_PRSE_CD
           and A.REPS_SEQ = P_REPS_SEQ;
    end;

    -- Monta as funções em javascript conforme a qtde de fases
    --
    if v_tot_fase = 1 then
        htp.p('
        function public_Labels(label1, label2){
        	t1.innerText = label1;
        	t2.innerText = label2;
        }

        function public_Contents(contents1, contents2){
        	t1Contents.innerHTML = contents1;
        	t2Contents.innerHTML = contents2;
        	init();
        }');
    elsif v_tot_fase = 2 then
        htp.p('
        function public_Labels(label1, label2, label3, label4){
        	t1.innerText = label1;
        	t2.innerText = label2;
        	t3.innerText = label3;
        	t4.innerText = label4;
        }

        function public_Contents(contents1, contents2, contents3, contents4){
        	t1Contents.innerHTML = contents1;
        	t2Contents.innerHTML = contents2;
        	t3Contents.innerHTML = contents3;
        	t4Contents.innerHTML = contents4;
        	init();
        }');
    else
        htp.p('
        function public_Labels(label1, label2, label3, label4, label5, label6,label7){
        	t1.innerText = label1;
        	t2.innerText = label2;
        	t3.innerText = label3;
        	t4.innerText = label4;
			t5.innerText = label5;
	    	t6.innerText = label6;
			t7.innerText = label7;
        }

        function public_Contents(contents1, contents2, contents3, contents4, contents5, contents6, contents7){
        	t1Contents.innerHTML = contents1;
        	t2Contents.innerHTML = contents2;
        	t3Contents.innerHTML = contents3;
        	t4Contents.innerHTML = contents4;
			t5Contents.innerHTML = contents5;
			t6Contents.innerHTML = contents6;
			t7Contents.innerHTML = contents7;
        	init();
        }');

    end if;

    htp.p('
        //sets the default display to tab 1
        function init(){
        	tabContents.innerHTML = t1Contents.innerHTML;
        }

        //this is the tab switching function
        var currentTab;
        var tabBase;
        var firstFlag = true;

        function changeTabs(){
        	if(firstFlag == true){
        		currentTab = t1;
        		tabBase = t1base;
        		firstFlag = false;
        	}
        	if(window.event.srcElement.className == "tab")
        	{
        		currentTab.className = "tab";
        		tabBase.style.backgroundColor = "white";
        		currentTab = window.event.srcElement;
        		tabBaseID = currentTab.id + "base";
        		tabContentID = currentTab.id + "Contents";
        		tabBase = document.all(tabBaseID);
        		tabContent = document.all(tabContentID);
        		currentTab.className = "selTab";
        		tabBase.style.backgroundColor = "";
        		tabContents.innerHTML = tabContent.innerHTML;
        	}
        }

        </SCRIPT>
        <BODY onclick="changeTabs()" onload="init()">

        <DIV STYLE="height:350; width:700; border:none thin gray">
        <TABLE BGCOLOR="#COCOCO" STYLE="width:100%; height:250" CELLPADDING=0 CELLSPACING=0>');

    --(++) 28/08/2009 Verifica se no processo seletivo existe agendamento de entrevista
    select count(*) into v_ct_entrev
      from opcoes_ps o
     where o.prse_cd  = p_prse_cd
       and o.reps_seq = p_reps_seq
       and o.opps_in_exige_entrev = 'S';
    --(++) 28/08/2009 Fim

    -- Monta as tabulaçoes
    --
/* --(++) 29/08/2009    if v_tot_fase = 1 then
        htp.p('
        	<TR>
  	        <TD ID=t1 CLASS=selTab HEIGHT=25>Andamento</TD>
        	<TD ID=t2 CLASS=tab>Fase 1 - Local de Prova</TD>
        	</TR>
        	<TR>
      	        <TD ID=t1base STYLE="height:2; border-left:solid thin white"></TD>
        	<TD ID=t2base STYLE="height:2; background-color:white"></TD>
        	</TR>');
    elsif v_tot_fase = 2 then
        htp.p('
        	<TR>
 	        <TD ID=t1 CLASS=selTab HEIGHT=25>Andamento</TD>
        	<TD ID=t2 CLASS=tab>Fase 1 - Local de Prova</TD>
        	<TD ID=t4 CLASS=tab>Fase 2 - Local de Prova</TD>
		<TD ID=t6 CLASS=tab>Agendamento Entrevista</TD>
        	</TR>
        	<TR>
       		<TD ID=t1base STYLE="height:2; border-left:solid thin white"></TD>
       		<TD ID=t2base STYLE="height:2; background-color:white"></TD>
       		<TD ID=t4base STYLE="height:2; background-color:white"></TD>
       		<TD ID=t6base STYLE="height:2; background-color:white; border-right:solid thin white"></TD>
        	</TR>');
    else
        htp.p('
        	<TR>
    	        <TD ID=t1 CLASS=selTab HEIGHT=25>Andamento</TD>
       		<TD ID=t2 CLASS=tab>Fase 1 - Local de Prova</TD>
        	<TD ID=t4 CLASS=tab>Fase 2 - Local de Prova</TD>
        	<TD ID=t6 CLASS=tab>Fase 3 - Local de Prova</TD>
		<TD ID=t8 CLASS=tab>Agendamento Entrevista</TD>
               </TR>
        	<TR>
       		<TD ID=t1base STYLE="height:2; border-left:solid thin white"></TD>
       		<TD ID=t2base STYLE="height:2; background-color:white"></TD>
       		<TD ID=t4base STYLE="height:2; background-color:white"></TD>
		<TD ID=t6base STYLE="height:2; background-color:white"></TD>
                <TD ID=t8base STYLE="height:2; background-color:white; border-right:solid thin white"></TD>
        	</TR>');
    end if;
*/
    if v_tot_fase = 1 and v_ct_entrev = 0 then  -- não tem entrevista
        htp.p('
        	<TR>
  	        <TD ID=t1 CLASS=selTab HEIGHT=25>Andamento</TD>
        	<TD ID=t2 CLASS=tab>Fase 1 - Local de Prova</TD>
        	</TR>
        	<TR>
      	        <TD ID=t1base STYLE="height:2; border-left:solid thin white"></TD>
        	<TD ID=t2base STYLE="height:2; background-color:white"></TD>
        	</TR>');
    elsif v_tot_fase = 1 and v_ct_entrev > 0 then  -- tem entrevista
        htp.p('
        	<TR>
 	        <TD ID=t1 CLASS=selTab HEIGHT=25>Andamento</TD>
        	<TD ID=t2 CLASS=tab>Fase 1 - Local de Prova</TD>
        	<TD ID=t4 CLASS=tab>Agendamento Entrevista</TD>
        	</TR>
        	<TR>
       		<TD ID=t1base STYLE="height:2; border-left:solid thin white"></TD>
       		<TD ID=t2base STYLE="height:2; background-color:white"></TD>
       		<TD ID=t4base STYLE="height:2; background-color:white; border-right:solid thin white"></TD>
        	</TR>');
    elsif v_tot_fase = 2 then
        htp.p('
        	<TR>
 	        <TD ID=t1 CLASS=selTab HEIGHT=25>Andamento</TD>
        	<TD ID=t2 CLASS=tab>Fase 1 - Local de Prova</TD>
        	<TD ID=t4 CLASS=tab>Fase 2 - Local de Prova</TD>
		      <TD ID=t6 CLASS=tab>Agendamento Entrevista</TD>
        	</TR>
        	<TR>
       		<TD ID=t1base STYLE="height:2; border-left:solid thin white"></TD>
       		<TD ID=t2base STYLE="height:2; background-color:white"></TD>
       		<TD ID=t4base STYLE="height:2; background-color:white"></TD>
       		<TD ID=t6base STYLE="height:2; background-color:white; border-right:solid thin white"></TD>
        	</TR>');
    else
        htp.p('
        	<TR>
    	        <TD ID=t1 CLASS=selTab HEIGHT=25>Andamento</TD>
       		<TD ID=t2 CLASS=tab>Fase 1 - Local de Prova</TD>
        	<TD ID=t4 CLASS=tab>Fase 2 - Local de Prova</TD>
        	<TD ID=t6 CLASS=tab>Fase 3 - Local de Prova</TD>
		      <TD ID=t8 CLASS=tab>Agendamento Entrevista</TD>
               </TR>
        	<TR>
       		<TD ID=t1base STYLE="height:2; border-left:solid thin white"></TD>
       		<TD ID=t2base STYLE="height:2; background-color:white"></TD>
       		<TD ID=t4base STYLE="height:2; background-color:white"></TD>
		<TD ID=t6base STYLE="height:2; background-color:white"></TD>
                <TD ID=t8base STYLE="height:2; background-color:white; border-right:solid thin white"></TD>
        	</TR>');
    end if;

    htp.p('<TR>
        		<TD HEIGHT="*" COLSPAN=8 ID=tabContents
    			STYLE="	border-left:solid thin white;
    			border-bottom:solid thin white;
  			border-right:solid thin white">&nbsp;</TD>

        	</TR>
        </TABLE>
        </DIV>');

    n := 0;

-- Montar agendamento
        n := n + 1;
        htp.div(CATTRIBUTES=>'CLASS=conts ID=t' || to_char(n) || 'Contents');

        htp.centeropen;
        htp.tableopen('BORDER=1', CATTRIBUTES=>'BGCOLOR="#FFFFFF" CELLPADDING="2%"');

        htp.tablerowopen;
        htp.tableheader('Itens do Processo');
        htp.tableheader('Data', 'CENTER');
        htp.tableheader('Status', 'center');
        htp.tablerowclose;

        begin
           select a.fich_dt_inscricao ,
		          decode(a.fich_in_completa,'S','Inscrição Completa','Inscrição Incompleta'),
				  fich_dt_completa,
				  fich_inscr_paga,
				  fich_isento_pagto,
				  fich_dt_pgto

		     into w_dat_inscricao     ,
			      w_status_inscricao  ,
				  w_fich_dt_completa  ,
				  w_fich_inscr_paga   ,
				  w_fich_isento_pagto ,
				  w_fich_dt_pgto

			 from fichas_inscricao a
			where a.prse_cd  = p_prse_cd
			  and a.reps_seq = p_reps_seq
			  and a.cand_cd  = p_cand_cd;
		exception
             when others then
			      w_dat_inscricao := sysdate;
		end;

        htp.tablerowopen;
        htp.tabledata('Cadastramento - Pré-Inscrição');
		if w_status_inscricao = 'Inscrição Completa' then
           htp.tabledata(to_char(w_fich_dt_completa, 'DD/MM/RRRR'), 'CENTER');
		else
          htp.tabledata(to_char(w_dat_inscricao, 'DD/MM/RRRR'), 'CENTER');
		end if;
        htp.tabledata(w_status_inscricao, 'CENTER');
        htp.tablerowclose;


		begin
 		   select nvl(count(*),0)
 		     into w_qtde_documentos
             from documentos_ps a
            where a.prse_cd              = p_prse_cd
              and a.reps_seq             = p_reps_seq
              and a.dops_ind_obrigatorio = 'S'		;
		exception
		     when no_data_found then
			      w_qtde_documentos := 0;
		     when others then
			      w_qtde_documentos := 0;
		end;


        if w_qtde_documentos > 0 then
           htp.tablerowopen;
           htp.tabledata('Recebimento de documentos obrigatório');

    	   begin
		     select nvl(count(*),0) ,
			        max(doin_dt_entrega)
		       into w_qtde_entrega,
			        w_dat_entrega
		  	   from docum_inscricao a,
                documentos_ps p  --(++) 15/09/2009 estava selecionando todos documentos, deveria selecionar somente os obrigatórios
			  where a.prse_cd  = p_prse_cd
			    and a.reps_seq = p_reps_seq
			    and a.cand_cd  = p_cand_cd
				  and a.doin_ind_entregue = 'S' --(++) 05/05/2008 esta data não é atualizada doin_dt_entrega is not null;
          and p.prse_cd = a.prse_cd
          and p.reps_seq = a.reps_seq
          and p.docm_cod = a.docm_cod
          and p.dops_ind_obrigatorio = 'S';
		   exception
   		        when others then
				     w_qtde_entrega := 0;
		   end;

		   if w_dat_entrega is not null then
              htp.tabledata(to_char(w_dat_entrega, 'DD/MM/RRRR'), 'CENTER');
		   else
              htp.tabledata(to_char(sysdate, 'DD/MM/RRRR'), 'CENTER');     --'&nbsp');
		   end if;

       htp.p('<script>

                function Doctos(){
                        window.open(''wcc0250ac$fich.doctos?p_inscricao='||FORM_VAL.FICH_NR_INSCRICAO||'&p_prse_cd='||FORM_VAL.PRSE_CD||'&p_reps_seq='||FORM_VAL.REPS_SEQ||''',''Doctos'',''height=430, width=620, scrollbars=yes, status=no, location=no, toolbar=no, menubar=no'');
                }
             </script>');

		   if w_qtde_entrega = 0 then
              --htp.tabledata('Documentação NÃO Recebida', 'CENTER');
              htp.tabledata('<a href="#" onclick="Doctos();">Documentação NÃO Recebida</a>','CENTER');
		   elsif (w_qtde_entrega < w_qtde_documentos and w_qtde_entrega > 0) then
              --htp.tabledata('Documentação Incompleta', 'CENTER');
              htp.tabledata('<a href="#" onclick="Doctos();">Documentação Incompleta</a>','CENTER');
		   elsif w_qtde_entrega = w_qtde_documentos then
                 --(++)htp.tabledata('Documentação Completa', 'CENTER');
                 htp.tabledata('<a href="#" onclick="Doctos();">Documentação Completa</a>','CENTER');
		   end if;
           htp.tablerowclose;
       end if;

       --(++) 05/05/2008 Para processo seletivo sem emissão de boleto não apresenta as informações abaixo
      if  w_reps_emite_boleto = 'S' then

        htp.tablerowopen;
        htp.tabledata('Recebimento do crédito da inscrição');

		  if w_fich_inscr_paga = 'S' then
		       htp.tabledata(to_char(w_fich_dt_pgto	, 'DD/MM/RRRR'), 'CENTER');
           htp.tabledata('Pago', 'CENTER');
		  elsif w_fich_isento_pagto = 'S' then
		       htp.tabledata(to_char(sysdate	, 'DD/MM/RRRR'), 'CENTER');
           htp.tabledata('Isento', 'CENTER');
      elsif w_fich_inscr_paga = 'N' then
		       htp.tabledata(to_char(sysdate	, 'DD/MM/RRRR'), 'CENTER');
		       htp.tabledata('Pendente', 'CENTER');
	    else
		       htp.tabledata(to_char(sysdate	, 'DD/MM/RRRR'), 'CENTER');
		       htp.tabledata('&nbsp', 'CENTER');
		  end if;

        htp.tablerowclose;
      end if; --(++) 05/05/2008 Fim

        htp.tableclose;




        htp.p('</DIV>');

    -- Abre cursor de local de prova com a fase
    --
    for i in 1..v_tot_fase loop
        open c0(i);
        fetch c0 into r0;

        n := n + 1;
        if c0%notfound then
            htp.div(CATTRIBUTES=>'CLASS=conts ID=t' || to_char(n) || 'Contents');
            htp.centeropen;
            htp.bold(v_msg_sala);
            htp.centerclose;
            htp.p('</DIV>');

            n := n + 1;
            htp.div(CATTRIBUTES=>'CLASS=conts ID=t' || to_char(n) || 'Contents');
            htp.centeropen;
            htp.bold(v_msg_nota);
            htp.centerclose;
            htp.p('</DIV>');
        else

            -- Verificar se pode mostrar os dados de sala
            --
            if r0.FASE_IN_DIVULGA_SALA = 'S' then

                htp.div(CATTRIBUTES=>'CLASS=conts ID=t' || to_char(n) || 'Contents');

                htp.centeropen;
                htp.tableopen('BORDER=1', CATTRIBUTES=>'BGCOLOR="#FFFFFF" CELLPADDING="2%"');

                htp.tablerowopen;
                htp.tableheader('Data Prova');
                htp.tableheader('Local', 'CENTER');
                htp.tableheader('Endereço', 'center');
                htp.tableheader('Bloco', 'center');
                htp.tableheader('Andar', 'center');
                htp.tableheader('Sala', 'center');
                htp.tablerowclose;

                open c1(i);

                loop
                 fetch c1 into r1;

                 exit when c1%notfound;
                -- Se não encontrou sala, apresentar mensagem
                --
                if c1%notfound then
                    htp.div(CATTRIBUTES=>'CLASS=conts ID=t' || to_char(n) || 'Contents');
                    htp.centeropen;

                    if r0.PRSE_TIPO = '1' then
                        htp.bold(v_msg_sala);
                    else
                        htp.bold('Processo realizado internamente.');
                    end if;
                    htp.centerclose;
                    htp.p('</DIV>');
					exit;
                else
			    w_CDSA_DT_REALIZ_PROVA := r1.CDSA_DT_REALIZ_PROVA;
					w_LCPS_NM              := r1.LCPS_NM;
					w_LCPS_ENDERECO        := r1.LCPS_ENDERECO;
					w_LCPS_NUM_ENDERECO    := r1.LCPS_NUM_ENDERECO;
					w_LCPS_COMPLEMENTO     := r1.LCPS_COMPLEMENTO;
					w_LCPS_BAIRRO          := r1.LCPS_BAIRRO;
					w_LCPS_CEP             := r1.LCPS_CEP;
					w_LCPS_CIDADE          := r1.LCPS_CIDADE;
					w_SG_UF                := r1.SG_UF;
			    w_SALO_BLOCO           := r1.SALO_BLOCO;
					w_SALO_ANDAR           := r1.SALO_ANDAR;
					w_SALO_NUM_SALA        := r1.SALO_NUM_SALA;

                    --------------------------


                    if w_salo_num_sala is null then
                       begin
                          select a.salo_num_sala,
    			                 D.LCPS_NM,
				                 D.LCPS_ENDERECO,
				                 D.LCPS_NUM_ENDERECO,
				                 D.LCPS_COMPLEMENTO,
				                 D.LCPS_BAIRRO,
				                 D.LCPS_CIDADE,
				                 D.SG_UF,
				                 D.LCPS_CEP,
				                 C.SALO_BLOCO,
				                 C.SALO_ANDAR
						    into w_salo_num_sala ,
                				 w_LCPS_NM         ,
					             w_LCPS_ENDERECO      ,
					             w_LCPS_NUM_ENDERECO  ,
					             w_LCPS_COMPLEMENTO   ,
					             w_LCPS_BAIRRO     ,
								 w_LCPS_CIDADE       ,
								 w_SG_UF             ,
					             w_LCPS_CEP         ,
				                 w_SALO_BLOCO      ,
					             w_SALO_ANDAR
							from cand_fase_salas a,
							     SALAS_LOCAL C,
                                 LOCALIDADE_PS D
						   where a.cand_cd                     = p_cand_cd
						     and a.CDSA_DT_REALIZ_PROVA        = w_CDSA_DT_REALIZ_PROVA
							 and a.salo_num_sala               is not null
                             and C.LCPS_CD                     = A.LCPS_CD
                             and C.SALO_NUM_SALA               = A.SALO_NUM_SALA
                             and D.LCPS_CD                     = C.LCPS_CD;

					   exception
					        when others then
							     w_salo_num_sala:= null;
					   end;


					end if;

					--------------------------



                    v_endereco := null;

                    htp.tablerowopen;

                    --(++) 21/10/2008 Para CGD a data da prova será apresentada o inicio e término da fase
                    if  P_PRSE_CD = 'CGD' then
                        htp.tabledata('<b>'||to_char(r1.fase_dt_inicio,'dd/mm/rrrr')||' e '||to_char(r1.fase_dt_fim,'dd/mm/rrrr') ||'</b>');
                    else
                        htp.tabledata('<b>'||to_char(w_CDSA_DT_REALIZ_PROVA,'dd/mm/rrrr')||'</b>');
                    end if;

          --(++) 21/10/2008 htp.tabledata('<b>'||to_char(w_CDSA_DT_REALIZ_PROVA,'dd/mm/rrrr')||'</b>');

					--Local
					if w_lcps_nm is not null then
                       htp.tabledata(w_LCPS_NM);
					else
					   htp.tabledata('&nbsp');
					end if;

                    if w_LCPS_COMPLEMENTO is null then
                        v_endereco := v_endereco || W_LCPS_ENDERECO || ', ' || W_LCPS_NUM_ENDERECO;
                    else
                        v_endereco := v_endereco || W_LCPS_ENDERECO || ', ' || W_LCPS_NUM_ENDERECO || ' - ' || W_LCPS_COMPLEMENTO;
                    end if;
                    v_endereco := v_endereco || '<BR>' || W_LCPS_BAIRRO || ' - CEP ' || W_LCPS_CEP ||
                                  '<BR>' || W_LCPS_CIDADE || ' - ' || W_SG_UF;

			        -- Endereco
					if v_endereco is not null then
                       htp.tabledata(v_endereco);
					else
					   htp.tabledata('&nbsp');
					end if;

					-- Bloco
					if w_salo_bloco is not null then
                       htp.tabledata(W_SALO_BLOCO);
					else
					   htp.tabledata('&nbsp');
					end if;

					--Andar
					if w_salo_andar is not null then
                       htp.tabledata(W_SALO_ANDAR);
					else
					   htp.tabledata('&nbsp');
					end if;

					-- Sala
					if w_salo_num_sala is not null then
					   htp.tabledata(W_SALO_NUM_SALA);
					else
					   htp.tabledata('&nbsp');
					end if;

                    htp.tablerowclose;

                end if;
			   end loop;

               htp.tableclose;
               htp.centerclose;
               htp.p('</DIV>');

               close c1;



            else
                htp.div(CATTRIBUTES=>'CLASS=conts ID=t' || to_char(n) || 'Contents');
                htp.centeropen;
                htp.bold(v_msg_sala);
                htp.centerclose;
                htp.p('</DIV>');
            end if;

            -- Monta pasta de notas
            --
            n := n + 1;
            htp.div(CATTRIBUTES=>'CLASS=conts ID=t' || to_char(n) || 'Contents');
            htp.centeropen;

            -- Se os cálculos da fase já foram encerrados E permitem apresentar notas, apresenta-las
            --
            if r0.STAT_IN_ENCERRAMENTO = 'S' and
               r0.FASE_IN_DIVULGA_LISTA = 'S' then

-- Solicitacao do usuario foi trocado o termo eliminado por desclassificado

                for r3 in (select C.FICH_CLASSIF_PS,
                                  C.FICH_IN_TREINEIRO,
                                  A.CFAS_POS_CLASS,
                                  decode(A.CFAS_IN_STATUS, 'C', 'Classificado',
                                                           'E', 'Desclassificado', 'Eliminado') "STATUS",

                                  A.CFAS_IN_STATUS,
                                  A.CFAS_MEDIA
                             from CAND_FASES A,
                                  REALIZACAO_PS B,
                                  FICHAS_INSCRICAO C
                            where B.PRSE_CD = P_PRSE_CD
                              and B.REPS_SEQ = P_REPS_SEQ
                              and A.PRSE_CD = B.PRSE_CD
                              and A.REPS_SEQ = B.REPS_SEQ
                              and A.FASE_CD = r0.FASE_CD
                              and A.CAND_CD = P_CAND_CD
                              and C.PRSE_CD = A.PRSE_CD
                              and C.REPS_SEQ = A.REPS_SEQ
                              and C.CAND_CD = A.CAND_CD) loop
                    htp.br;
                    htp.tableopen;
--(++)

                    if P_PRSE_CD in ('UESPC', 'CEAG') then -- Inclusão do processo seletivo CEAG
                       begin
                         select o.cuca_cd, c.cuca_nm
						               into w_1opcao, w_1opcao_desc
                           from opcoes_inscricao o, cursos_cacr c
                          where o.prse_cd  = p_prse_cd
                            and o.reps_seq = p_reps_seq
                            and o.cand_cd  = p_cand_cd
                            and o.opin_num_opcao = 1
                            and c.cuca_cd = o.cuca_cd;  --(++) incluido em 25/06/2008
					   exception
					        when others then
							     w_1opcao := null;
                   w_1opcao_desc := null;
					   end;


                       htp.tablerowopen;
                       htp.tabledata(htf.bold('1a.opção :'));
                       htp.tabledata(w_1opcao_desc); --(++) 25/06/2008 (w_1opcao);
                       htp.tablerowclose;


                       begin
                          select nvl(opps_qtd_vagas,0) + nvl(opps_qtd_espera,0)
						    into w_qtd_espera
							from opcoes_ps
						   where prse_cd  = p_prse_cd
						     and reps_seq = p_reps_seq
							 and cuca_cd  = w_1opcao;
					   exception
                            when others then
							     w_qtd_espera := null;
					   end;

					 end if;

-- Solicitacao do usuario foi trocado o termo eliminado por desclassificado

					if r0.FASE_CD = 2 and p_prse_cd in ('UESPC', 'CEAG') then -- Inclusão do processo seletivo CEAG
     				   begin
					      select decode(cfas_in_status, 'C', 'Classificado',
						                                'E', 'Desclassificado', 'Eliminado'),
                                 cfas_media        ,
                                 cfas_pos_class
						    into w_status ,
							     w_media  ,
								 w_posicao_class
							from cand_fases
						   where prse_cd   = p_prse_cd
						     and reps_seq  = p_reps_seq
							 and fase_cd   = r0.FASE_CD
							 and cand_cd   = p_cand_cd;
					   exception
					        when others then
							     w_status        := null;
								 w_media         := null;
								 w_posicao_class := null;
					   end;


--(++)
                       -- Verificar se está na lista de espera (somente última fase)
                       if w_status = 'Desclassificado'                  and
                          w_posicao_class <= w_qtd_espera         and
                          r3.FICH_IN_TREINEIRO = 'N'              then

                            w_status := 'Lista de espera';

                       end if;

--  w_posicao_class <= nvl(r0.TOT_VAGAS,0)  and
--(++)

	                   htp.tablerowopen;
                       htp.tabledata(htf.bold('Status da Fase :'));
                       htp.tabledata(w_status);
                       htp.tablerowclose;

                       htp.tablerowopen;
                       htp.tabledata(htf.bold('Posição de Classificação da Fase :'));
                       htp.tabledata(w_posicao_class);
                       htp.tablerowclose;

                       htp.tablerowopen;
                       htp.tabledata(htf.bold('Média da Fase:'));
                       htp.tabledata(to_char(w_media, '990D000000000'), 'RIGHT');
					   htp.tablerowclose;


				else
--(++)

                    htp.tablerowopen;
                    htp.tabledata(htf.bold('Status da Fase:'));
                    -- Verificar se está na lista de espera (somente última fase)
                    --
                    if r3.CFAS_IN_STATUS = 'E' and
                       r3.FICH_CLASSIF_PS <= r0.TOT_VAGAS and
                       r0.FASE_CD = v_tot_fase and
                       r3.FICH_IN_TREINEIRO = 'N' then

                        htp.tabledata('Lista de espera');

                    else
                        -- Se estiver classificado e for última fase, verificar qual opção
                        --
                        if r3.CFAS_IN_STATUS = 'C' and
                           r0.FASE_CD = v_tot_fase then
                          /*  declare
                                v_opcao CURSOS_CACR.CUCA_NM%type;
                            begin
                                select A.CUCA_NM
                                  into v_opcao
                                  from CURSOS_CACR A,
                                       OPCOES_INSCRICAO B,
                                       OPCOES_PS C
                                 where B.PRSE_CD  = P_PRSE_CD
                                   and B.REPS_SEQ = P_REPS_SEQ
                                   and B.CAND_CD  = P_CAND_CD
                                   and B.CUCA_CD  = A.CUCA_CD
                                   and C.PRSE_CD  = B.PRSE_CD
                                   and C.REPS_SEQ = B.REPS_SEQ
                                   and C.CUCA_CD  = B.CUCA_CD
                                   and B.OPIN_POS_CLASSIF <= C.OPPS_QTD_VAGAS;
							*/
-- 30/06/2003                              htp.tabledata(r3.STATUS || ' - ' || v_opcao);

                                htp.tabledata(r3.STATUS);

                          /*  exception
                                when NO_DATA_FOUND then
                                    htp.tabledata(r3.STATUS);
                            end;
						  */
                        else
                            htp.tabledata(r3.STATUS);
                        end if;
                    end if;
                    htp.tablerowclose;

                    if r0.PRSE_TIPO = '1' then
                        htp.tablerowopen;
                        htp.tabledata(htf.bold('Média da Fase:'));
                        htp.tabledata(round(to_char(r3.CFAS_MEDIA, '990D000000000'),w_decimais), 'RIGHT');
                        htp.tablerowclose;
                    end if;

                    if r0.FASE_CD = '1' and
                       r0.PRSE_TIPO = '2' then
                        null;
                    else
						-- (++) Josy 05/06/2003
						if nvl(r3.FICH_IN_TREINEIRO, 'N') = 'S' then
						   v_Simulado := ' - Simulado';
						else
						   v_Simulado := '';
						end if;

                        htp.tablerowopen;
                        htp.tabledata(htf.bold('Posição de Classificação da Fase:'));
                        if r0.FASE_CD = '1' then
						    -- (++) Josy 05/06/2003
                            htp.tabledata(to_char(r3.CFAS_POS_CLASS, '999G990') || htf.bold(v_Simulado) , 'LEFT');
                        elsif r0.FASE_CD = '2' then
							-- (++) Josy 05/06/2003
                            htp.tabledata(to_char(r3.FICH_CLASSIF_PS, '999G990') || htf.bold(v_Simulado), 'LEFT');
                        else
                            htp.tabledata(to_char(r3.CFAS_POS_CLASS, '999G990') || htf.bold(v_Simulado) , 'LEFT');

                        end if;
                        htp.tablerowclose;
                    end if;
                    htp.tableclose;
--(++)
                  end if;

                end loop;

                htp.tableopen('BORDER=1', CATTRIBUTES=>'BGCOLOR="#FFFFFF" CELLPADDING="2%"');

                htp.tablerowopen;
                htp.tableheader('Prova');
                htp.tableheader('Data de<br>Aplicação', 'CENTER');
                htp.tableheader('Nota<br>Bruta', 'RIGHT');

                if r0.PRSE_TIPO in ('1', '2') then  -- em 08/06/04 incluido especialização
                    htp.tableheader('Nota<br>Padronizada', 'RIGHT');
                end if;

                htp.tableheader('Nota de<br>Corte', 'RIGHT');
                htp.tablerowclose;

                for r2 in c2(r0.FASE_CD, P_CAND_CD) loop
                    htp.tablerowopen;
                    htp.tabledata(r2.TIPR_NM);
                    htp.tabledata(to_char(r2.PROV_DT_REALIZACAO, 'DD/MM/RRRR'), 'CENTER');
                    htp.tabledata(round(to_char(r2.NOPR_NOTA_BRUTA, '990D000000000'),w_decimais), 'RIGHT');

                    if r0.PRSE_TIPO in ('1', '2') then
                        htp.tabledata(round(to_char(r2.NOPR_NOTA_PADRON, '90D000000000'),w_decimais), 'RIGHT');
                    end if;

                    htp.tabledata(round(to_char(nvl(r2.PROV_NOTA_CORTE,0), '90D000000000'),w_decimais), 'RIGHT');
                    htp.tablerowclose;
                end loop;

                htp.tableclose;

                --
                -- Apresentar mensagens de rodapé
                --
                -- Se houver nota de corte, apresentá-la
                --
                if nvl(r0.FASE_NOTA_CORTE,0) > 0 then
                    htp.br;
                    htp.bold('Média de corte: ' || to_char(r0.FASE_NOTA_CORTE, '999D00'));
                    htp.br;
                end if;


            elsif r0.STAT_IN_ENCERRAMENTO = 'S'
              and r0.FASE_IN_DIVULGA_LISTA = 'N' then
                htp.bold('As notas serão publicadas na data estabelecida no cronograma do processo seletivo.');
            else
                htp.bold(v_msg_nota);
            end if;
            htp.centerclose;
            htp.p('</DIV>');

        end if;
        close c0;


    end loop;

--(++) Montar agendamento

            --(++) 28/08/2009 Verifica se divulgação de PS é parcial
            v_divulga_periodo := 'N';
            if  v_reps_ind_divulg_parcial = 'S' then
                begin
                  select v.vein_ind_divulga_agenda into v_divulga_periodo
                    from calend_entrev c, cacr_vencto_inscr_ps v
                   where v.prse_cd  = p_prse_cd
                     and v.reps_seq = p_reps_seq
                     and c.prse_cd  = p_prse_cd
                     and c.reps_seq = p_reps_seq
                     and c.cand_cd  = p_cand_cd
                     and v.vein_periodo = c.caen_nome_grupo;
                exception
                  when others then
                    v_divulga_periodo := 'N';
                end;
            end if;

        n := n + 1;
        htp.div(CATTRIBUTES=>'CLASS=conts ID=t' || to_char(n) || 'Contents');

        htp.centeropen;


--(++) Dados variaveis de agendamento de entrevista
        if  r0.FASE_IN_DIVULGA_SALA = 'S' or -- Divulda agendamento
            v_divulga_periodo       = 'S' then --(++) 28/08/2009
        w_cabecalho := 0;
        open agendamento;

           loop
   		     fetch agendamento
		      into r_agendamento;

             if agendamento%rowcount >  0 and w_cabecalho = 0 then
                htp.tableopen('BORDER=1', CATTRIBUTES=>'BGCOLOR="#FFFFFF" CELLPADDING="2%"');
     	        htp.tablerowopen;
    	        htp.tableheader('Local');
    	        htp.tableheader('Data', 'CENTER');
    	        htp.tableheader('Inicio', 'CENTER');
    	        htp.tableheader('Fim', 'center');
     	        htp.tablerowclose;
			 elsif agendamento%rowcount = 0 then
               htp.centeropen;
               htp.bold('Não existem agendamentos');
               htp.centerclose;
			 end if;

		     exit when agendamento%notfound;

             htp.tablerowopen;
             htp.tabledata(r_agendamento.local);
             htp.tabledata(to_char(r_agendamento.data, 'DD/MM/RRRR'), 'CENTER');
             htp.tabledata(to_char(r_agendamento.hora_i, 'hh24:mi'), 'CENTER');
             htp.tabledata(to_char(r_agendamento.hora_f, 'hh24:mi'), 'CENTER');
             htp.tablerowclose;
			 w_cabecalho := 1;

		end loop;
		close agendamento;

        else
                htp.bold(v_msg_sala);
        end if;
      htp.tableclose;
      htp.p('</DIV>');


    htp.p('<SCRIPT>init()</SCRIPT>');
    return '';
exception
    when others then
        htp.p(sqlerrm);
        return '';
END;
--(++)
--------------------------------------------------------------------------------
-- Name:        wcc0250ac$fich.ESTADO_LOV
--
-- Description: This procedure displays the 'ESTADO' LOV
--
--------------------------------------------------------------------------------
   procedure ESTADO_LOV(
             Z_FILTER in varchar2,
             Z_MODE in varchar2,
             Z_CALLER_URL in varchar2,
             Z_FORMROW in number,
             Z_LONG_LIST in varchar2,
             Z_ISSUE_WAIT in varchar2) is
      L_SEARCH_STRING     varchar2(1000);
      L_ABORT             boolean := FALSE;
      L_INVALID_DEPENDENT boolean := FALSE;
      L_ANY               boolean := FALSE;
      L_BODY_ATTRIBUTES   VarChar2 (1000) := LOV_BODY_ATTRIBUTES;
      L_SUCCESS           boolean := TRUE ;
   begin

      WSGL.RegisterURL('wcc0250ac$fich.ESTADO_LOV');
      WSGL.AddURLParam('Z_FILTER', Z_FILTER);
      WSGL.AddURLParam('Z_MODE', Z_MODE);
      WSGL.AddURLParam('Z_CALLER_URL', Z_CALLER_URL);
      WSGL.AddURLParam('Z_FORMROW', Z_FORMROW);


      WSGL.OpenPageHead;
      htp.p('
<SCRIPT>
      if (opener.current_lov_title == "")
      {
         var winTitle = "'||replace('Estados','$$CGLOV$$',WSGLM.DSP123_LOV_CAPTION)||'";
         document.write("<TITLE>" + winTitle + "</TITLE>");
      }
      else
      {
         document.write("<TITLE>" + opener.current_lov_title + "</TITLE>");
      }
</SCRIPT>
      ');
      if Z_ISSUE_WAIT is not null then

         htp.p ('<SCRIPT>
function RefreshMe()
{
  location.href = location.href.substring (0, location.href.length - 1);
};
</SCRIPT>');

         L_BODY_ATTRIBUTES := L_BODY_ATTRIBUTES || ' OnLoad="RefreshMe()"';

      else
         if Z_FORMROW = -1 then
            htp.p('<SCRIPT>
function PassBack(P_SG_UF) {
   if (opener.location.href != document.forms[0].Z_CALLER_URL.value) {
      alert("'||WSGL.MsgGetText(228,WSGLM.MSG228_LOV_NOT_IN_CONTEXT)||'");
      return;
   }');
   if Z_MODE = 'Q' then
      htp.p('
   opener.LOVForm.P_CAND_RG_UF.focus();
   opener.LOVForm.P_CAND_RG_UF.value = P_SG_UF;
   close();
');
   else
     htp.p('
   opener.LOVForm.P_CAND_RG_UF[0].focus();
   opener.LOVForm.P_CAND_RG_UF[0].value = P_SG_UF;
   if (opener.LOVForm.name.search(/VForm$/) == -1) {
   }
   else
   {
   }
   close();
');
   end if;
   htp.p('
}
function Find_OnClick() {
   document.forms[0].submit();
}');
         else
            htp.p('<SCRIPT>
function PassBack(P_SG_UF) {
   if (opener.location.href != document.forms[0].Z_CALLER_URL.value) {
      alert("'||WSGL.MsgGetText(228,WSGLM.MSG228_LOV_NOT_IN_CONTEXT)||'");
      return;
   }
   opener.LOVForm.P_CAND_RG_UF[' ||to_char(Z_FORMROW) || '].focus();
   opener.LOVForm.P_CAND_RG_UF[' ||to_char(Z_FORMROW) || '].value = P_SG_UF;
   if (opener.LOVForm.name.search(/VForm$/) == -1) {
        opener.JSLFlagRow(opener.LOVForm,'||to_char(Z_FORMROW)||' , true, "/ows-img/");
   }
   else
   {
      opener.LOVForm.z_modified[' ||to_char(Z_FORMROW) || '].value = "Y";
   }

   close();
}
function Find_OnClick() {
   document.forms[0].submit();
}');
         end if;
         if LOV_FRAME is null then
            htp.p('function Close_OnClick() {
      close();
}');
         end if;
         htp.p('</SCRIPT>');
      end if;

      wcc0082d$.TemplateHeader(TRUE,2);

      WSGL.ClosePageHead;

      WSGL.OpenPageBody(FALSE, p_attributes=>L_BODY_ATTRIBUTES);


      htp.p('
<SCRIPT>
      if (opener.current_lov_title == "")
      {
         var winTitle = "'||replace('Estados','$$CGLOV$$',WSGLM.DSP123_LOV_CAPTION)||'";
         document.write("<H2><I>" + winTitle + "</I></H2>");
      }
      else
      {
         document.write("<H2><I>" + opener.current_lov_title + "</I></H2>");
      }
</SCRIPT>
      ');

      if Z_ISSUE_WAIT is not null then
         htp.p(WSGL.MsgGetText(127,WSGLM.DSP127_LOV_PLEASE_WAIT));
         WSGL.ClosePageBody;
         return;
      end if;
      htp.formOpen(lower('wcc0250dac$fich.ESTADO_LOV'));
      WSGL.HiddenField('Z_CALLER_URL', Z_CALLER_URL);
      WSGL.HiddenField('Z_MODE', Z_MODE);
      SaveState;
      WSGL.HiddenField('Z_FORMROW',Z_FORMROW);

      L_SEARCH_STRING := rtrim(Z_FILTER);
      if L_SEARCH_STRING is not null then
         if ((instr(Z_FILTER,'%') = 0) and (instr(Z_FILTER,'_') = 0)) then
            L_SEARCH_STRING := L_SEARCH_STRING || '%';
         end if;
      else
         L_SEARCH_STRING := '%';
      end if;

      htp.para;
      htp.p(WSGL.MsgGetText(19,WSGLM.CAP019_LOV_FILTER_CAPTION,'Sigla do Estado'));
      htp.para;
      htp.formText('Z_FILTER', cvalue=>L_SEARCH_STRING);
      htp.p('<input type="button" value="'||LOV_FIND_BUT_CAPTION||'" onclick="Find_OnClick()">');
      if LOV_FRAME is null then
         htp.p('<input type="button" value="'||LOV_CLOSE_BUT_CAPTION||'" onclick="Close_OnClick()">');
      end if;
      htp.formClose;
      if L_INVALID_DEPENDENT then
         WSGL.DisplayMessage(WSGL.MESS_ERROR, cg$errors.GetErrors,
                             '', LOV_BODY_ATTRIBUTES);
      end if;

      if Z_LONG_LIST is not null then
         if  not L_ABORT and L_SEARCH_STRING is null then
            htp.p(WSGL.MsgGetText(124,WSGLM.DSP124_LOV_ENTER_SEARCH));
            L_ABORT := TRUE;
         end if;
      end if;

      if not L_ABORT then

         WSGL.LayoutOpen(WSGL.LAYOUT_TABLE, TRUE);

         WSGL.LayoutRowStart;
         WSGL.LayoutHeader(1, 'LEFT', 'Sigla do Estado');
         WSGL.LayoutHeader(1, 'LEFT', 'Nome do Estado');
         WSGL.LayoutRowEnd;
         declare
            cursor c_lov
               ( z_mode   in varchar2
               , z_filter in varchar2
               )
           is
              SELECT L_PAIS.PAIS_NOM L_PAIS_PAIS_NOM,
       ESTD.SG_UF SG_UF,
       ESTD.NM_ESTA NM_ESTA,
       ESTD.PAIS_COD PAIS_COD
FROM ESTADO_DISTRITO ESTD,
     PAISES L_PAIS
WHERE ESTD.PAIS_COD = L_PAIS.PAIS_COD AND
      /* CG$LOVI_WC_START ESTADO 60 */
      (L_PAIS.PAIS_NOM like '%BRASIL%')
      /* CG$LOVI_WC_END ESTADO 60 */  AND
      ESTD.SG_UF like upper(z_filter)
ORDER BY NM_ESTA
;
         begin
            for c1rec in c_lov(Z_MODE, L_SEARCH_STRING) loop
               WSGL.LayoutRowStart('TOP');
               WSGL.LayoutData('<a href="javascript:PassBack('''||
                               htf.escape_sc(replace(replace(c1rec.SG_UF,'\','\\'),'''','\'''))||''')">'||c1rec.SG_UF||'</a>');
               WSGL.LayoutData(replace(c1rec.NM_ESTA,'"','&quot;'));
               WSGL.LayoutRowEnd;
               l_any := true;
            end loop;
            WSGL.LayoutClose;
            if not l_any then
               htp.p(WSGL.MsgGetText(224,WSGLM.MSG224_LOV_NO_ROWS));
            end if;
         end;
      end if;

      htp.p('<SCRIPT>document.forms[0].Z_FILTER.focus()</SCRIPT>');

      WSGL.ClosePageBody;

   exception
      when others then
         WSGL.DisplayMessage(WSGL.MESS_EXCEPTION, SQLERRM, '',
                             LOV_BODY_ATTRIBUTES, 'wcc0250ac$fich.ESTADO_LOV');
   end;

--(++)

--------------------------------------------------------------------------------
-- Name:        wcc0250ac$fich.REPS_LOV
--
-- Description: This procedure displays the 'REPS' LOV
--
--------------------------------------------------------------------------------
   procedure REPS_LOV(
             Z_FILTER in varchar2,
             Z_MODE in varchar2,
             Z_CALLER_URL in varchar2,
             P_L_PRSE_PRSE_ABREV in varchar2,
             Z_FORMROW in number,
             Z_LONG_LIST in varchar2,
             Z_ISSUE_WAIT in varchar2) is
      L_SEARCH_STRING     varchar2(1000);
      L_ABORT             boolean := FALSE;
      L_INVALID_DEPENDENT boolean := FALSE;
      L_ANY               boolean := FALSE;
      L_BODY_ATTRIBUTES   VarChar2 (1000) := LOV_BODY_ATTRIBUTES;
      L_SUCCESS           boolean := TRUE ;

CURSOR C_INGRESSO IS
SELECT L_REPS.REPS_DT_INGRESSO REPS_DT_INGRESSO,
       L_REPS.EMPC_CD,
       L_REPS.PRSE_CD,
       L_REPS.REPS_SEQ,
       B.RV_LOW_VALUE,
       B.RV_MEANING,
       null dt_prova
  FROM REALIZACAO_PS L_REPS,
       CG_REF_CODES  B
 WHERE l_reps.reps_tp_per_ingr <> 'P'
   and UPPER(L_REPS.PRSE_CD) = UPPER(P_L_PRSE_PRSE_ABREV)
   /* CG$LOVI_WC_END REPS 10 */
   AND SYSDATE <= L_REPS.REPS_DT_LIMITE_PUBLICACAO
   AND B.RV_DOMAIN = 'PERIODO_CONCURSO'
   AND B.RV_LOW_VALUE = L_REPS.REPS_TP_PER_INGR
   AND L_REPS.REPS_DT_INGRESSO like upper(NVL(z_filter,'%%'))
union all
SELECT distinct L_REPS.REPS_DT_INGRESSO REPS_DT_INGRESSO,
       L_REPS.EMPC_CD,
       L_REPS.PRSE_CD,
       L_REPS.REPS_SEQ,
       B.RV_LOW_VALUE,
       B.RV_MEANING,
       to_char(c.prov_dt_realizacao,'dd/mm/rrrr')
  FROM REALIZACAO_PS L_REPS,
       CG_REF_CODES  B,
       PROVAS_FASES C
 WHERE l_reps.reps_tp_per_ingr = 'P'
   and UPPER(L_REPS.PRSE_CD) = UPPER(P_L_PRSE_PRSE_ABREV)
   /* CG$LOVI_WC_END REPS 10 */
   AND SYSDATE <= L_REPS.REPS_DT_LIMITE_PUBLICACAO
   and c.reps_seq = l_reps.reps_seq
   and c.prse_cd  = l_reps.prse_cd
   AND B.RV_DOMAIN = 'PERIODO_CONCURSO'
   AND B.RV_LOW_VALUE = L_REPS.REPS_TP_PER_INGR
   AND L_REPS.REPS_DT_INGRESSO like upper(NVL(z_filter,'%%'))
 ORDER BY REPS_DT_INGRESSO desc, 7 DESC;
/*SELECT L_REPS.REPS_DT_INGRESSO REPS_DT_INGRESSO,
       L_REPS.EMPC_CD,
       L_REPS.PRSE_CD,
       L_REPS.REPS_SEQ,
       B.RV_LOW_VALUE,
       B.RV_MEANING
  FROM REALIZACAO_PS L_REPS,
       CG_REF_CODES  B
 WHERE UPPER(L_REPS.PRSE_CD) = UPPER(P_L_PRSE_PRSE_ABREV)
   \* CG$LOVI_WC_END REPS 10 *\
   AND SYSDATE <= L_REPS.REPS_DT_LIMITE_PUBLICACAO
   AND B.RV_DOMAIN = 'PERIODO_CONCURSO'
   AND B.RV_LOW_VALUE = L_REPS.REPS_TP_PER_INGR
   AND L_REPS.REPS_DT_INGRESSO like upper(NVL(z_filter,'%%'))
 ORDER BY REPS_DT_INGRESSO DESC;*/

      P_MSG               VARCHAR2(1000);
      P_DATA_REALIZACAO   VARCHAR2(20);

   begin

      WSGL.RegisterURL('wcc0250ac$fich.REPS_LOV');
      WSGL.AddURLParam('Z_FILTER', Z_FILTER);
      WSGL.AddURLParam('Z_MODE', Z_MODE);
      WSGL.AddURLParam('Z_CALLER_URL', Z_CALLER_URL);
      WSGL.AddURLParam('P_L_PRSE_PRSE_ABREV', P_L_PRSE_PRSE_ABREV);
      WSGL.AddURLParam('Z_FORMROW', Z_FORMROW);


      WSGL.OpenPageHead;
      htp.p('
<SCRIPT>
      if (opener.current_lov_title == "")
      {
         var winTitle = "'||replace('Períodos de Ingresso','$$CGLOV$$',WSGLM.DSP123_LOV_CAPTION)||'";
         //document.write("<TITLE>" + winTitle + "</TITLE>");
      }
      else
      {
         document.write("<TITLE>" + opener.current_lov_title + "</TITLE>");
      }
</SCRIPT>
      ');
      if Z_ISSUE_WAIT is not null then

         htp.p ('<SCRIPT>
function RefreshMe()
{
  location.href = location.href.substring (0, location.href.length - 1);
};
</SCRIPT>');

         L_BODY_ATTRIBUTES := L_BODY_ATTRIBUTES || ' OnLoad="RefreshMe()"';

      else
         if Z_FORMROW = -1 then
            htp.p('<SCRIPT>
function PassBack(P_REPS_DT_INGRESSO, P_MSG) {
   if (opener.location.href != document.forms[0].Z_CALLER_URL.value) {
      alert("'||WSGL.MsgGetText(228,WSGLM.MSG228_LOV_NOT_IN_CONTEXT)||'");
      return;
   }');
   if Z_MODE = 'Q' then
      htp.p('
   //opener.LOVForm.P_L_REPS_REPS_DT_INGRESSO.focus();
   //opener.LOVForm.P_L_REPS_REPS_DT_INGRESSO.value = P_REPS_DT_INGRESSO;
   opener.LOVForm.P_L_REPS_REPS_DT_INGRESSO.focus();
   opener.LOVForm.P_L_REPS_REPS_DT_INGRESSO.value = P_MSG;
   opener.LOVForm.P_REPS_SEQ.value = P_REPS_DT_INGRESSO;
   close();
');
   else
     htp.p('
   if (opener.LOVForm.name.search(/VForm$/) == -1) {
   }
   else
   {
   }
   close();
');
   end if;
   htp.p('
}
function Find_OnClick() {
   document.forms[0].submit();
}');
         else
            htp.p('<SCRIPT>
function PassBack(P_REPS_DT_INGRESSO) {
   if (opener.location.href != document.forms[0].Z_CALLER_URL.value) {
      alert("'||WSGL.MsgGetText(228,WSGLM.MSG228_LOV_NOT_IN_CONTEXT)||'");
      return;
   }
   if (opener.LOVForm.name.search(/VForm$/) == -1) {
        opener.JSLFlagRow(opener.LOVForm,'||to_char(Z_FORMROW)||' , true, "/ows-img/");
   }
   else
   {
      opener.LOVForm.z_modified[' ||to_char(Z_FORMROW) || '].value = "Y";
   }

   close();
}
function Find_OnClick() {
   document.forms[0].submit();
}');
         end if;
         if LOV_FRAME is null then
            htp.p('function Close_OnClick() {
      close();
}');
         end if;
         htp.p('</SCRIPT>');
      end if;

      wcc0250ac$.TemplateHeader(TRUE,2);

      WSGL.ClosePageHead;

      WSGL.OpenPageBody(FALSE, p_attributes=>L_BODY_ATTRIBUTES);


      htp.p('
<SCRIPT>
      if (opener.current_lov_title == "")
      {
         var winTitle = "'||replace('Períodos de Ingresso','$$CGLOV$$',WSGLM.DSP123_LOV_CAPTION)||'";
         document.write("<H2><I>" + winTitle + "</I></H2>");
      }
      else
      {
         document.write("<H2><I>" + opener.current_lov_title + "</I></H2>");
      }
</SCRIPT>
      ');

      if Z_ISSUE_WAIT is not null then
         htp.p(WSGL.MsgGetText(127,WSGLM.DSP127_LOV_PLEASE_WAIT));
         WSGL.ClosePageBody;
         return;
      end if;
      htp.formOpen(lower('wcc0250ac$fich.REPS_LOV'));
      WSGL.HiddenField('Z_CALLER_URL', Z_CALLER_URL);
      WSGL.HiddenField('Z_MODE', Z_MODE);
      SaveState;
      WSGL.HiddenField('P_L_PRSE_PRSE_ABREV', P_L_PRSE_PRSE_ABREV);
      WSGL.HiddenField('Z_FORMROW',Z_FORMROW);

      L_SEARCH_STRING := rtrim(Z_FILTER);
      if L_SEARCH_STRING is not null then
         if ((instr(Z_FILTER,'%') = 0) and (instr(Z_FILTER,'_') = 0)) then
            L_SEARCH_STRING := L_SEARCH_STRING || '%';
         end if;
      else
         L_SEARCH_STRING := '%';
      end if;

      --htp.para;
      --htp.p(WSGL.MsgGetText(19,WSGLM.CAP019_LOV_FILTER_CAPTION,'Ingresso em ( MM/AAAA)'));
      --htp.para;
      htp.formText('Z_FILTER', cvalue=>L_SEARCH_STRING);
      htp.p('<input type="button" value="'||LOV_FIND_BUT_CAPTION||'" onclick="Find_OnClick()">');
      if LOV_FRAME is null then
         htp.p('<input type="button" value="'||LOV_CLOSE_BUT_CAPTION||'" onclick="Close_OnClick()">');
      end if;
      htp.formClose;
      if Z_MODE = 'Q' then
         NBT_VAL.L_PRSE_PRSE_ABREV := upper(P_L_PRSE_PRSE_ABREV); --(++) 12/04/2006 inclusão upper
      end if;
      if L_INVALID_DEPENDENT then
         WSGL.DisplayMessage(WSGL.MESS_ERROR, cg$errors.GetErrors,
                             '', LOV_BODY_ATTRIBUTES);
      end if;

      if Z_LONG_LIST is not null then
         if  not L_ABORT and L_SEARCH_STRING is null then
            htp.p(WSGL.MsgGetText(124,WSGLM.DSP124_LOV_ENTER_SEARCH));
            L_ABORT := TRUE;
         end if;
      end if;

      if not L_ABORT then

/*
         WSGL.LayoutOpen(WSGL.LAYOUT_TABLE, TRUE);

         WSGL.LayoutRowStart;
         WSGL.LayoutHeader(1, 'LEFT', 'Ingresso em ( MM/AAAA)');
         WSGL.LayoutRowEnd;
         declare
            cursor c_lov
               ( z_mode   in varchar2
               , z_filter in varchar2
               )
           is
              SELECT L_REPS.REPS_DT_INGRESSO REPS_DT_INGRESSO
                FROM REALIZACAO_PS L_REPS
               WHERE \* CG$LOVI_WC_START REPS 10 *\
                (L_REPS.PRSE_CD in (select X.PRSE_CD  from PROCESSOS_SELETIVOS X  where x.prse_cd \*X.PRSE_ABREV 27/08/2009*\ = wcc0250ac$fich.NBT_VAL.L_PRSE_PRSE_ABREV))
                     \* CG$LOVI_WC_END REPS 10 *\  AND
               L_REPS.REPS_DT_INGRESSO like upper(z_filter)
			   and sysdate <= l_reps.REPS_DT_LIMITE_PUBLICACAO
              ORDER BY REPS_DT_INGRESSO DESC
;
         begin
            for c1rec in c_lov(Z_MODE, L_SEARCH_STRING) loop
               WSGL.LayoutRowStart('TOP');
               WSGL.LayoutData('<a href="javascript:PassBack('''||
                               htf.escape_sc(replace(replace(to_char(c1rec.REPS_DT_INGRESSO,'mm/yyyy'),'\','\\'),'''','\'''))||''')">'||ltrim(to_char(c1rec.REPS_DT_INGRESSO, 'mm/yyyy'))||'</a>');
               WSGL.LayoutRowEnd;
               l_any := true;
            end loop;
            WSGL.LayoutClose;
            if not l_any then
               htp.p(WSGL.MsgGetText(224,WSGLM.MSG224_LOV_NO_ROWS));
            end if;
         end;
         */



/**********************************************************************************************************/
/*********************  VERIFICA O TIPO DO PROCESSO E CLASSIFICA O RETORDO DE ACORDO **********************/
/**********************************************************************************************************/

      htp.p('<TABLE  BORDER>
              <TR><TH align=left>Ingresso</TH></TR>');

      FOR IND IN C_INGRESSO LOOP

            IF IND.RV_LOW_VALUE = 'A' THEN

                     P_MSG := TO_CHAR(IND.REPS_DT_INGRESSO,'RRRR');

                     HTP.P('<TR VALIGN="TOP">
                               <TD ALIGN="LEFT"><a href="javascript:PassBack('''||IND.REPS_SEQ||''','''||P_MSG||''')">'||P_MSG||'</a></TD>
                            </TR>');

             ELSIF IND.RV_LOW_VALUE = 'M' THEN

                     P_MSG := DBASPGVC.FNC_MES(TO_CHAR(IND.REPS_DT_INGRESSO,'MM'))||' / '||TO_CHAR(IND.REPS_DT_INGRESSO,'RRRR');

                     HTP.P('<TR VALIGN="TOP">
                               <TD ALIGN="LEFT"><a href="javascript:PassBack('''||IND.REPS_SEQ||''','''||P_MSG||''')">'||P_MSG||'</a></TD>
                            </TR>');

             ELSIF IND.RV_LOW_VALUE = 'P' THEN

                   /*BEGIN
                     SELECT DISTINCT min(TO_CHAR(A.PROV_DT_REALIZACAO,'DD/MM/RRRR')) P_DATA_REALIZACAO
                       INTO P_DATA_REALIZACAO
                       FROM PROVAS_FASES A
                      WHERE A.REPS_SEQ = IND.REPS_SEQ
                        AND A.PRSE_CD  = IND.PRSE_CD
                        ORDER BY 1 DESC;

                   EXCEPTION
                   WHEN OTHERS THEN
                        P_DATA_REALIZACAO := '';
                   END;*/

                     IF TO_CHAR(IND.REPS_DT_INGRESSO,'MM') <= 6 THEN
                       P_MSG := '1° Sem. ' || TO_CHAR(IND.REPS_DT_INGRESSO,'RRRR');
                     ELSE
                       P_MSG := '2° Sem. ' || TO_CHAR(IND.REPS_DT_INGRESSO,'RRRR');
                     END IF;
                     P_MSG := P_MSG || ' prova em ' || ind.dt_prova;

                     HTP.P('<TR VALIGN="TOP">
                               <TD ALIGN="LEFT"><a href="javascript:PassBack('''||IND.REPS_SEQ||''','''||P_MSG||''')">'||P_MSG||'</a></TD>
                            </TR>');

            ELSIF IND.RV_LOW_VALUE = 'S' THEN

                     IF TO_CHAR(IND.REPS_DT_INGRESSO,'MM') <= 6 THEN
                       P_MSG := '1° Semestre de ' || TO_CHAR(IND.REPS_DT_INGRESSO,'RRRR');
                     ELSE
                       P_MSG := '2° Semestre de ' || TO_CHAR(IND.REPS_DT_INGRESSO,'RRRR');
                     END IF;

                     HTP.P('<TR VALIGN="TOP">
                               <TD ALIGN="LEFT"><a href="javascript:PassBack('''||IND.REPS_SEQ||''','''||P_MSG||''')">'||P_MSG||'</a></TD>
                            </TR>');
             END IF;

       END LOOP;

 htp.p('</TABLE>');

/**********************************************************************************************************/
/**********************************************************************************************************/
/**********************************************************************************************************/


      end if;

      htp.p('<SCRIPT>document.forms[0].Z_FILTER.focus()</SCRIPT>');

      WSGL.ClosePageBody;

   exception
      when others then
         WSGL.DisplayMessage(WSGL.MESS_EXCEPTION, SQLERRM, '',
                             LOV_BODY_ATTRIBUTES, 'wcc0250ac$fich.REPS_LOV');
   end;

--------------------------------------------------------------------------------
-- Name:        wcc0250ac$fich.PRSE_LOV
--
-- Description: This procedure displays the 'PRSE' LOV
--
--------------------------------------------------------------------------------
   procedure PRSE_LOV(
             Z_FILTER in varchar2,
             Z_MODE in varchar2,
             Z_CALLER_URL in varchar2,
             Z_FORMROW in number,
             Z_LONG_LIST in varchar2,
             Z_ISSUE_WAIT in varchar2) is
      L_SEARCH_STRING     varchar2(1000);
      L_ABORT             boolean := FALSE;
      L_INVALID_DEPENDENT boolean := FALSE;
      L_ANY               boolean := FALSE;
      L_BODY_ATTRIBUTES   VarChar2 (1000) := LOV_BODY_ATTRIBUTES;
      L_SUCCESS           boolean := TRUE ;
   begin

      WSGL.RegisterURL('wcc0250ac$fich.PRSE_LOV');
      WSGL.AddURLParam('Z_FILTER', Z_FILTER);
      WSGL.AddURLParam('Z_MODE', Z_MODE);
      WSGL.AddURLParam('Z_CALLER_URL', Z_CALLER_URL);
      WSGL.AddURLParam('Z_FORMROW', Z_FORMROW);


      WSGL.OpenPageHead;
      htp.p('
<SCRIPT>
      if (opener.current_lov_title == "")
      {
         var winTitle = "'||replace('Processo Seletivo','$$CGLOV$$',WSGLM.DSP123_LOV_CAPTION)||'";
         document.write("<TITLE>" + winTitle + "</TITLE>");
      }
      else
      {
         document.write("<TITLE>" + opener.current_lov_title + "</TITLE>");
      }
</SCRIPT>
      ');
      if Z_ISSUE_WAIT is not null then

         htp.p ('<SCRIPT>
function RefreshMe()
{
  location.href = location.href.substring (0, location.href.length - 1);
};
</SCRIPT>');

         L_BODY_ATTRIBUTES := L_BODY_ATTRIBUTES || ' OnLoad="RefreshMe()"';

      else
         if Z_FORMROW = -1 then
            htp.p('<SCRIPT>
function PassBack(P_PRSE_ABREV) {
   if (opener.location.href != document.forms[0].Z_CALLER_URL.value) {
      alert("'||WSGL.MsgGetText(228,WSGLM.MSG228_LOV_NOT_IN_CONTEXT)||'");
      return;
   }');
   if Z_MODE = 'Q' then
      htp.p('
   opener.LOVForm.P_L_PRSE_PRSE_ABREV.focus();
   opener.LOVForm.P_L_PRSE_PRSE_ABREV.value = P_PRSE_ABREV;
   close();
');
   else
     htp.p('
   if (opener.LOVForm.name.search(/VForm$/) == -1) {
   }
   else
   {
   }
   close();
');
   end if;
   htp.p('
}
function Find_OnClick() {
   document.forms[0].submit();
}');
         else
            htp.p('<SCRIPT>
function PassBack(P_PRSE_ABREV) {
   if (opener.location.href != document.forms[0].Z_CALLER_URL.value) {
      alert("'||WSGL.MsgGetText(228,WSGLM.MSG228_LOV_NOT_IN_CONTEXT)||'");
      return;
   }
   if (opener.LOVForm.name.search(/VForm$/) == -1) {
        opener.JSLFlagRow(opener.LOVForm,'||to_char(Z_FORMROW)||' , true, "/ows-img/");
   }
   else
   {
      opener.LOVForm.z_modified[' ||to_char(Z_FORMROW) || '].value = "Y";
   }

   close();
}
function Find_OnClick() {
   document.forms[0].submit();
}');
         end if;
         if LOV_FRAME is null then
            htp.p('function Close_OnClick() {
      close();
}');
         end if;
         htp.p('</SCRIPT>');
      end if;

      wcc0250ac$.TemplateHeader(TRUE,2);

      WSGL.ClosePageHead;

      WSGL.OpenPageBody(FALSE, p_attributes=>L_BODY_ATTRIBUTES);


      htp.p('
<SCRIPT>
      if (opener.current_lov_title == "")
      {
         var winTitle = "'||replace('Processo Seletivo','$$CGLOV$$',WSGLM.DSP123_LOV_CAPTION)||'";
         document.write("<H2><I>" + winTitle + "</I></H2>");
      }
      else
      {
         document.write("<H2><I>" + opener.current_lov_title + "</I></H2>");
      }
</SCRIPT>
      ');

      if Z_ISSUE_WAIT is not null then
         htp.p(WSGL.MsgGetText(127,WSGLM.DSP127_LOV_PLEASE_WAIT));
         WSGL.ClosePageBody;
         return;
      end if;
      htp.formOpen(lower('wcc0250ac$fich.PRSE_LOV'));
      WSGL.HiddenField('Z_CALLER_URL', Z_CALLER_URL);
      WSGL.HiddenField('Z_MODE', Z_MODE);
      SaveState;
      WSGL.HiddenField('Z_FORMROW',Z_FORMROW);

      L_SEARCH_STRING := rtrim(Z_FILTER);
      if L_SEARCH_STRING is not null then
         if ((instr(Z_FILTER,'%') = 0) and (instr(Z_FILTER,'_') = 0)) then
            L_SEARCH_STRING := L_SEARCH_STRING || '%';
         end if;
      else
         L_SEARCH_STRING := '%';
      end if;

      htp.para;
      htp.p(WSGL.MsgGetText(19,WSGLM.CAP019_LOV_FILTER_CAPTION,'Abreviatura'));
      htp.para;
      htp.formText('Z_FILTER', cvalue=>L_SEARCH_STRING);
      htp.p('<input type="button" value="'||LOV_FIND_BUT_CAPTION||'" onclick="Find_OnClick()">');
      if LOV_FRAME is null then
         htp.p('<input type="button" value="'||LOV_CLOSE_BUT_CAPTION||'" onclick="Close_OnClick()">');
      end if;
      htp.formClose;
      if L_INVALID_DEPENDENT then
         WSGL.DisplayMessage(WSGL.MESS_ERROR, cg$errors.GetErrors,
                             '', LOV_BODY_ATTRIBUTES);
      end if;

      if Z_LONG_LIST is not null then
         if  not L_ABORT and L_SEARCH_STRING is null then
            htp.p(WSGL.MsgGetText(124,WSGLM.DSP124_LOV_ENTER_SEARCH));
            L_ABORT := TRUE;
         end if;
      end if;

      if not L_ABORT then

         WSGL.LayoutOpen(WSGL.LAYOUT_TABLE, TRUE);

         WSGL.LayoutRowStart;
         WSGL.LayoutHeader(1, 'LEFT', 'Abreviatura');
         WSGL.LayoutHeader(1, 'LEFT', 'Nome');
         WSGL.LayoutRowEnd;
         declare
            cursor c_lov
               ( z_mode   in varchar2
               , z_filter in varchar2
               )
           is
              SELECT distinct PRSE.PRSE_ABREV PRSE_ABREV,
                     PRSE.PRSE_NM PRSE_NM,
                     PRSE.PRSE_CD PRSE_CD
                FROM PROCESSOS_SELETIVOS PRSE
               WHERE PRSE.PRSE_ABREV like upper(z_filter)
			     and exists (select a.prse_cd
				               from realizacao_ps a
							  where a.prse_cd = prse.prse_cd
							    and sysdate <= a.REPS_DT_LIMITE_PUBLICACAO)

               ORDER BY 1

;
         begin
            for c1rec in c_lov(Z_MODE, L_SEARCH_STRING) loop
               WSGL.LayoutRowStart('TOP');
               WSGL.LayoutData('<a href="javascript:PassBack('''||
                               htf.escape_sc(replace(replace(c1rec.PRSE_ABREV,'\','\\'),'''','\'''))||''')">'||c1rec.PRSE_ABREV||'</a>');
               WSGL.LayoutData(replace(c1rec.PRSE_NM,'"','&quot;'));
               WSGL.LayoutRowEnd;
               l_any := true;
            end loop;
            WSGL.LayoutClose;
            if not l_any then
               htp.p(WSGL.MsgGetText(224,WSGLM.MSG224_LOV_NO_ROWS));
            end if;
         end;
      end if;

      htp.p('<SCRIPT>document.forms[0].Z_FILTER.focus()</SCRIPT>');

      WSGL.ClosePageBody;

   exception
      when others then
         WSGL.DisplayMessage(WSGL.MESS_EXCEPTION, SQLERRM, '',
                             LOV_BODY_ATTRIBUTES, 'wcc0250ac$fich.PRSE_LOV');
   end;

--------------------------------------------------------------------------------
-- Name:        wcc0250ac$fich.InitialiseDomain
--
-- Description: Initialises the Domain Record for the given Column Usage
--
-- Parameters:  P_ALIAS   The alias of the column usage
--
--------------------------------------------------------------------------------
   procedure InitialiseDomain(P_ALIAS in varchar2) is
   begin

--(++)
      if P_ALIAS = 'TIPO_DOC' and not D_TIPO_DOC.Initialised then
         D_TIPO_DOC.ColAlias := 'TIPO_DOC';
         D_TIPO_DOC.ControlType := WSGL.DV_RADIO_ACROSS;
         D_TIPO_DOC.DispWidth := 30;
         D_TIPO_DOC.DispHeight := 1;
         D_TIPO_DOC.MaxWidth := 32760;
         D_TIPO_DOC.UseMeanings := True;
         D_TIPO_DOC.ColOptional := False;
         D_TIPO_DOC.Vals(1) := 'G';
         D_TIPO_DOC.Meanings(1) := 'RG';
         D_TIPO_DOC.Abbreviations(1) := '';
         D_TIPO_DOC.Vals(2) := 'N';
         D_TIPO_DOC.Meanings(2) := 'RNE';
         D_TIPO_DOC.Abbreviations(2) := '';
         D_TIPO_DOC.NumOfVV := 2;
         D_TIPO_DOC.Initialised := True;
      end if;


--(++)


      if P_ALIAS = 'FICH_ISENTO_PAGTO' and not D_FICH_ISENTO_PAGTO.Initialised then
         D_FICH_ISENTO_PAGTO.ColAlias := 'FICH_ISENTO_PAGTO';
         D_FICH_ISENTO_PAGTO.ControlType := WSGL.DV_LIST;
         D_FICH_ISENTO_PAGTO.DispWidth := 1;
         D_FICH_ISENTO_PAGTO.DispHeight := 1;
         D_FICH_ISENTO_PAGTO.MaxWidth := 1;
         D_FICH_ISENTO_PAGTO.UseMeanings := False;
         D_FICH_ISENTO_PAGTO.ColOptional := False;
         WSGL.LoadDomainValues('CG_REF_CODES', 'SIM_NAO', D_FICH_ISENTO_PAGTO);
         D_FICH_ISENTO_PAGTO.Initialised := True;
      end if;

      if P_ALIAS = 'FICH_INSCR_PAGA' and not D_FICH_INSCR_PAGA.Initialised then
         D_FICH_INSCR_PAGA.ColAlias := 'FICH_INSCR_PAGA';
         D_FICH_INSCR_PAGA.ControlType := WSGL.DV_LIST;
         D_FICH_INSCR_PAGA.DispWidth := 1;
         D_FICH_INSCR_PAGA.DispHeight := 1;
         D_FICH_INSCR_PAGA.MaxWidth := 1;
         D_FICH_INSCR_PAGA.UseMeanings := False;
         D_FICH_INSCR_PAGA.ColOptional := False;
         WSGL.LoadDomainValues('CG_REF_CODES', 'SIM_NAO', D_FICH_INSCR_PAGA);
         D_FICH_INSCR_PAGA.Initialised := True;
      end if;

   exception
      when others then
         WSGL.DisplayMessage(WSGL.MESS_EXCEPTION, SQLERRM, ''||' : '||'Status da Inscrição',
                             DEF_BODY_ATTRIBUTES, 'wcc0250ac$fich.InitialseDomain');
   end;

--------------------------------------------------------------------------------
-- Name:        wcc0250ac$fich.Startup
--
-- Description: Entry point for the 'FICH' module
--              component  (Status da Inscrição).
--
-- Parameters:
--
--------------------------------------------------------------------------------
   procedure Startup(
             Z_DIRECT_CALL in boolean,
             Z_CHK in varchar2,
             Z_FORM in varchar2,
			 P_EMPRESA IN VARCHAR2,
       P_PRSE_CD IN VARCHAR2) is
      l_Foundform boolean        := FALSE;
      l_fs_text   varchar2(32767) := '' ;
   begin

      WSGL.RegisterURL('wcc0250ac$fich.startup');
      WSGL.AddURLParam('Z_CHK', Z_CHK);


      WSGL.StoreURLLink(1, 'Status da Inscrição');

      -- Either no frames are being used or the query form is on a
      -- separate page.
      if Z_FORM is not null then
         null;
         -- Work out which form is required, and check if that is possible
         if Z_FORM = 'QUERY' then
            FormQuery(
             Z_DIRECT_CALL=>TRUE,
			 P_EMPRESA => P_EMPRESA,
       P_PRSE_CD => P_PRSE_CD);  --(++) 17/06/2009
            l_Foundform := TRUE;
         end if;
      end if;
      if l_Foundform = FALSE then
         FormQuery(
              Z_DIRECT_CALL=>TRUE,
			  P_EMPRESA => P_EMPRESA,
        P_PRSE_CD => P_PRSE_CD);  --(++) 17/06/2009
      end if;

   exception
      when others then
         WSGL.DisplayMessage(WSGL.MESS_EXCEPTION, SQLERRM, ''||' : '||'Status da Inscrição',
                             DEF_BODY_ATTRIBUTES, 'wcc0250ac$fich.Startup');
   end;

--------------------------------------------------------------------------------
-- Name:        wcc0250ac$fich.ActionQuery
--
-- Description: Called when a Query form is subitted to action the query request.
--
-- Parameters:
--
--------------------------------------------------------------------------------
   procedure ActionQuery(
             P_L_PRSE_PRSE_ABREV in varchar2,
             P_L_REPS_REPS_DT_INGRESSO in varchar2,
             P_FICH_NR_INSCRICAO in varchar2,
             P_L_CAND_CAND_SENHA in varchar2,
             P_TIPO_DOC in varchar2,
             P_CAND_RG_NR in varchar2,
             P_CAND_RG_UF in varchar2,
       	     Z_DIRECT_CALL in boolean default false,
             Z_ACTION in varchar2,
             Z_CHK in varchar2  ,
             P_EMPRESA IN VARCHAR2 DEFAULT 'EAESP',
             P_REPS_SEQ IN VARCHAR2 DEFAULT NULL
			 ) is

     L_CHK varchar2(10) := Z_CHK;
     L_BUTCHK varchar2(100):= null;
     l_dummy_bool boolean := false;
     v_cand_rg_nr   varchar2(50);
     v_cand_rne     varchar2(50);
     v_cand_rg_uf   varchar2(2);
     v_PAIS_COD_END_RES varchar2(2);
     v_cand_senha       varchar2(30);
     w_nr_inscricao     number;
     v_reps_seq         number;

     W_L_REPS_REPS_DT_INGRESSO  VARCHAR2(10);

   begin

    if not Z_DIRECT_CALL then
      null;
    end if;
-- (++)


    if p_fich_nr_inscricao is null then

       if nvl(P_TIPO_DOC, 'G') = 'G' then
          v_cand_rg_nr := upper(replace(replace(replace(replace(P_CAND_RG_NR, '.'), '-'), '/'), ' '));
       else
           v_cand_rne := upper(replace(replace(replace(replace(P_CAND_RG_NR, '.'), '-'), '/'), ' '));
       end if;

       if (nvl(P_TIPO_DOC, 'G') = 'G') then
           v_cand_rg_uf := upper(P_CAND_RG_UF);

           begin
               select A.PAIS_COD
                 into v_PAIS_COD_END_RES
                 from ESTADO_DISTRITO A,
                      PAISES B
                where A.SG_UF = upper(P_CAND_RG_UF)
                  and A.PAIS_COD = B.PAIS_COD
                  and B.PAIS_NOM LIKE '%BRASIL%';
           exception
                when OTHERS then
                     htp.p('<SCRIPT>alert("Código do estado incorreto.")</SCRIPT>');
                     startup(p_empresa=>p_empresa,p_prse_cd=>P_L_PRSE_PRSE_ABREV); --(++) 31/08/2009 startup;
                    return;
           end;
       end if;

       declare
          v_cand_cd CANDIDATOS.CAND_CD%TYPE;
       begin
           begin
              select A.CAND_CD, a.cand_senha
                into v_cand_cd , v_cand_senha
                from CANDIDATOS A
               where ((nvl(P_TIPO_DOC, 'G') = 'G'  and A.CAND_RG_NR  = v_cand_rg_nr) or
                      (nvl(P_TIPO_DOC, 'G') = 'N'  and A.CAND_RNE    = v_cand_rne ))
                  and ((nvl(P_TIPO_DOC, 'G') = 'G' and A.CAND_RG_UF  = upper(P_CAND_RG_UF)) or
                       (nvl(P_TIPO_DOC, 'G') = 'N'))
              and rownum = 1;

	  exception
               when no_data_found then
                    startup(p_empresa=>p_empresa,p_prse_cd=>P_L_PRSE_PRSE_ABREV); --(++) 31/08/2009 startup;
                    htp.p('<SCRIPT>alert("Dados Inválidos")</SCRIPT>');
                    return;
	  end;
         /*begin  --(++) Recupera reps_seq do processo seletivo
           select r.reps_seq
             into v_reps_seq
             from realizacao_ps r, processos_seletivos p
            where p.prse_cd \*--(++)27/08/2009 p.prse_abrev*\ = upper(P_L_PRSE_PRSE_ABREV)  --(++) 09/10/2006 r.prse_cd = upper(P_L_PRSE_PRSE_ABREV)
              and p.prse_cd    = r.prse_cd  --(++) 09/10/2006
              AND TO_CHAR(r.REPS_DT_INGRESSO,'MM/RRRR') = P_L_REPS_REPS_DT_INGRESSO;
         exception
              when others then
                   startup(p_empresa=>p_empresa,p_prse_cd=>P_L_PRSE_PRSE_ABREV); --(++) 31/08/2009 startup;
                   htp.p('<SCRIPT>alert("Processo Seletivo Inválido")</SCRIPT>');
                   return;
         end;*/
          begin  --(++) 12/04/2006 Recupera nro da inscrição quando a entrada for por documento
            select f.fich_nr_inscricao into w_nr_inscricao
              from fichas_inscricao f, processos_seletivos p
             where p.prse_cd /*--(++) 28/08/2009 p.prse_abrev*/ = upper(P_L_PRSE_PRSE_ABREV)  --(++) 09/10/2006 f.prse_cd  = upper(P_L_PRSE_PRSE_ABREV)
               and p.prse_cd    = f.prse_cd  --(++) 09/10/2006
               and f.reps_seq   = P_REPS_SEQ
               and f.cand_cd    = v_cand_cd;
          exception
              when others then
                   startup(p_empresa=>p_empresa,p_prse_cd=>P_L_PRSE_PRSE_ABREV); --(++) 31/08/2009 startup;
                   htp.p('<SCRIPT>alert("Inscrição do candidato não encontrada")</SCRIPT>');
                   return;
          end;
       end;
      else
        /* begin
           select r.reps_seq
             into v_reps_seq
             from realizacao_ps r, processos_seletivos p
            where p.prse_cd \* --(++) 28/08/2009 p.prse_abrev*\ = upper(P_L_PRSE_PRSE_ABREV)  --(++) 09/10/2006  r.prse_cd = upper(P_L_PRSE_PRSE_ABREV)
              and p.prse_cd    = r.prse_cd  --(++) 09/10/2006
              AND TO_CHAR(r.REPS_DT_INGRESSO,'MM/RRRR') = P_L_REPS_REPS_DT_INGRESSO;
         exception
              when others then
                   startup(p_empresa=>p_empresa,p_prse_cd=>P_L_PRSE_PRSE_ABREV); --(++) 31/08/2009 startup;
                   htp.p('<SCRIPT>alert("Processo Seletivo Inválido")</SCRIPT>');
                   return;
         end;*/

         begin
            select b.cand_senha
              into v_cand_senha
              from fichas_inscricao a ,
                   candidatos       b , processos_seletivos p
             where a.cand_cd           = b.cand_cd
               and p.prse_cd /* --(++) 28/08/2009 p.prse_abrev*/        = upper(P_L_PRSE_PRSE_ABREV)  --(++) 09/10/2006  a.prse_cd           = upper(P_L_PRSE_PRSE_ABREV)
               and p.prse_cd           = a.prse_cd  --(++) 09/10/2006
               and a.reps_seq          = P_REPS_SEQ
               and a.fich_nr_inscricao = P_FICH_NR_INSCRICAO;
         exception
              when others then
                   startup(p_empresa=>p_empresa,p_prse_cd=>P_L_PRSE_PRSE_ABREV); --(++) 31/08/2009 startup;
                   htp.p('<SCRIPT>alert("Número de Inscrição Inválido")</SCRIPT>');
                   return;
         end;

         w_nr_inscricao := P_FICH_NR_INSCRICAO; --(++) 12/04/2006

      end if;


--(++)




      QueryView(
                P_L_PRSE_PRSE_ABREV=>P_L_PRSE_PRSE_ABREV,
                P_L_REPS_REPS_DT_INGRESSO=>NULL,
                P_FICH_NR_INSCRICAO=>w_nr_inscricao, --(++) 12/04/2006  P_FICH_NR_INSCRICAO,
                P_L_CAND_CAND_SENHA=>v_cand_senha,
                Z_EXECUTE_QUERY=>'Y',
                Z_DIRECT_CALL=>TRUE ,
        				P_EMPRESA => P_EMPRESA,
                K_REPS_SEQ => P_REPS_SEQ
               );

   exception
      when others then
         WSGL.DisplayMessage(WSGL.MESS_EXCEPTION, SQLERRM, ''||' : '||'Status da Inscrição',
                             DEF_BODY_ATTRIBUTES, 'wcc0250ac$fich.ActionQuery');
   end;

--------------------------------------------------------------------------------
-- Name:        wcc0250ac$fich.QueryHits
--
-- Description: Returns the number or rows which matches the given search
--              criteria (if any).
--
-- Parameters:
--
--------------------------------------------------------------------------------
   function QueryHits(
            P_L_PRSE_PRSE_ABREV in varchar2,
            P_L_REPS_REPS_DT_INGRESSO in varchar2,
            P_FICH_NR_INSCRICAO in varchar2,
            P_L_CAND_CAND_SENHA in varchar2) return number is
      I_QUERY     varchar2(32767) := '';
      I_CURSOR    integer;
      I_VOID      integer;
      I_FROM_POS  integer := 0;
      I_COUNT     number(10);
   begin

      if not BuildSQL(P_L_PRSE_PRSE_ABREV,
                      P_L_REPS_REPS_DT_INGRESSO,
                      P_FICH_NR_INSCRICAO,
                      P_L_CAND_CAND_SENHA) then
         return -1;
      end if;

      if not PreQuery(P_L_PRSE_PRSE_ABREV,
                      P_L_REPS_REPS_DT_INGRESSO,
                      P_FICH_NR_INSCRICAO,
                      P_L_CAND_CAND_SENHA) then
         WSGL.DisplayMessage(WSGL.MESS_ERROR, cg$errors.GetErrors,
                             ''||' : '||'Status da Inscrição', DEF_BODY_ATTRIBUTES);
         return -1;
      end if;

      I_FROM_POS := instr(upper(ZONE_SQL), ' FROM ');

      if I_FROM_POS = 0 then
         return -1;
      end if;

      I_QUERY := 'SELECT count(*)' ||
                 substr(ZONE_SQL, I_FROM_POS);

      I_CURSOR := dbms_sql.open_cursor;
      dbms_sql.parse(I_CURSOR, I_QUERY, dbms_sql.v7);
      dbms_sql.define_column(I_CURSOR, 1, I_COUNT);
      I_VOID := dbms_sql.execute(I_CURSOR);
      I_VOID := dbms_sql.fetch_rows(I_CURSOR);
      dbms_sql.column_value(I_CURSOR, 1, I_COUNT);
      dbms_sql.close_cursor(I_CURSOR);

      return I_COUNT;

   exception
      when others then
         WSGL.DisplayMessage(WSGL.MESS_EXCEPTION, SQLERRM, ''||' : '||'Status da Inscrição',
                             DEF_BODY_ATTRIBUTES, 'wcc0250ac$fich.QueryHits');
         return -1;
   end;
--------------------------------------------------------------------------------
-- Name:        wcc0250ac$fich.BuildSQL
--
-- Description: Builds the SQL for the 'FICH' module component (Status da Inscrição).
--              This incorporates all query criteria and Foreign key columns.
--
-- Parameters:
--
--------------------------------------------------------------------------------
   function BuildSQL(
            P_L_PRSE_PRSE_ABREV in varchar2,
            P_L_REPS_REPS_DT_INGRESSO in varchar2,
            P_FICH_NR_INSCRICAO in varchar2,
            P_L_CAND_CAND_SENHA in varchar2,
            Z_QUERY_BY_KEY in boolean default false,
            Z_ROW_ID in ROWID default null,
            Z_BIND_ROW_ID in boolean default false,
            P_REPS_SEQ varchar2 default null) return boolean is

      I_WHERE varchar2(32767);
      row_idx     integer;
   begin


      -- Build up the Where clause
      if Z_QUERY_BY_KEY then
         I_WHERE := 'WHERE PRSE_CD = ''' || replace(CURR_VAL.PRSE_CD, '''','''''') || ''' AND REPS_SEQ = ' || to_char(CURR_VAL.REPS_SEQ) || ' AND FICH_NR_INSCRICAO = ' || to_char(CURR_VAL.FICH_NR_INSCRICAO) || ' AND CAND_CD = ' || to_char(CURR_VAL.CAND_CD) || ' ';
      elsif Z_ROW_ID is not null then
         I_WHERE := 'WHERE CG$ROW_ID = ''' || rowidtochar( Z_ROW_ID ) || '''';
      elsif Z_BIND_ROW_ID then
         I_WHERE := 'WHERE CG$ROW_ID = :b_row_id';
      else
          WSGL.BuildWhere(P_L_PRSE_PRSE_ABREV, 'PRSE_CD' /*--(++) 28/08/2009 'L_PRSE_PRSE_ABREV'*/, WSGL.TYPE_CHAR_UPPER, I_WHERE);

          I_WHERE := I_WHERE || ' AND REPS_SEQ  = ' || P_REPS_SEQ;

        /* begin
            WSGL.BuildWhere(P_L_REPS_REPS_DT_INGRESSO, 'L_REPS_REPS_DT_INGRESSO', WSGL.TYPE_DATE, I_WHERE, 'mm/yyyy');
         exception
            when others then
            WSGL.DisplayMessage(WSGL.MESS_ERROR_QRY, SQLERRM,
                                ''||' : '||'Status da Inscrição', DEF_BODY_ATTRIBUTES, NULL,
                                WSGL.MsgGetText(210,WSGLM.MSG210_INVALID_QRY,'Ingresso em  ( (MM/AAAA))'),
                                WSGL.MsgGetText(211,WSGLM.MSG211_EXAMPLE_TODAY,to_char(sysdate, 'mm/yyyy')));
            return false;
         end;*/


         begin
            WSGL.BuildWhere(P_FICH_NR_INSCRICAO, 'FICH_NR_INSCRICAO', WSGL.TYPE_NUMBER, I_WHERE);
         exception
            when others then
            WSGL.DisplayMessage(WSGL.MESS_ERROR_QRY, SQLERRM,
                                ''||' : '||'Status da Inscrição', DEF_BODY_ATTRIBUTES, NULL,
                                WSGL.MsgGetText(210,WSGLM.MSG210_INVALID_QRY,'Número Inscrição'));
            return false;
         end;
            if(P_L_CAND_CAND_SENHA is null) then
               WSGL.BuildWhere(WSGL.MsgGetText(1,WSGLM.CAP001_UNKNOWN), 'L_CAND_CAND_SENHA', WSGL.TYPE_CHAR, I_WHERE);
            else
               WSGL.BuildWhere(P_L_CAND_CAND_SENHA, 'L_CAND_CAND_SENHA', WSGL.TYPE_CHAR, I_WHERE);
            end if;

      end if;


      ZONE_SQL := 'SELECT PROC_SEL,
                         PRSE_CD,
                         REPS_SEQ,
                         L_PRSE_PRSE_ABREV,
                         L_PRSE_PRSE_NM,
                         L_REPS_REPS_DT_INGRESSO,
                         FICH_NR_INSCRICAO,
                         NOM_CPL,
                         L_CAND_CAND_NM,
                         L_CAND_CAND_SOBRENOME,
                         L_CAND_CAND_SENHA,
                         CAND_CD,
                         FICH_ISENTO_PAGTO,
                         FICH_INSCR_PAGA,
                         INSC_CONFIRM,
                         FICH_DT_PGTO,
                         FICH_MEDIA_FINAL,
                         FICH_CLASSIF_PS
                  FROM   ( SELECT L_PRSE.PRSE_ABREV || '' - '' || L_PRSE.PRSE_NM PROC_SEL,
       FICH.PRSE_CD PRSE_CD,
       FICH.REPS_SEQ REPS_SEQ,
       L_PRSE.PRSE_ABREV L_PRSE_PRSE_ABREV,
       L_PRSE.PRSE_NM L_PRSE_PRSE_NM,
       L_REPS.REPS_DT_INGRESSO L_REPS_REPS_DT_INGRESSO,
       FICH.FICH_NR_INSCRICAO FICH_NR_INSCRICAO,
       L_CAND.CAND_NM || '' '' || L_CAND.CAND_SOBRENOME NOM_CPL,
       L_CAND.CAND_NM L_CAND_CAND_NM,
       L_CAND.CAND_SOBRENOME L_CAND_CAND_SOBRENOME,
       L_CAND.CAND_SENHA L_CAND_CAND_SENHA,
       FICH.CAND_CD CAND_CD,
       FICH.FICH_ISENTO_PAGTO FICH_ISENTO_PAGTO,
       FICH.FICH_INSCR_PAGA FICH_INSCR_PAGA,
       decode(FICH.FICH_INSCR_PAGA, ''S'', ''Confirmada'', decode(FICH.FICH_ISENTO_PAGTO, ''S'', ''Confirmada'', ''<font color=red>Não Confirmada</font>'')) INSC_CONFIRM,
       FICH.FICH_DT_PGTO FICH_DT_PGTO,
       FICH.FICH_MEDIA_FINAL FICH_MEDIA_FINAL,
       FICH.FICH_CLASSIF_PS FICH_CLASSIF_PS
FROM FICHAS_INSCRICAO FICH,
     REALIZACAO_PS L_REPS,
     PROCESSOS_SELETIVOS L_PRSE,
     CANDIDATOS L_CAND
WHERE FICH.PRSE_CD = L_REPS.PRSE_CD AND
      FICH.REPS_SEQ = L_REPS.REPS_SEQ AND
      L_REPS.PRSE_CD = L_PRSE.PRSE_CD AND
      FICH.CAND_CD = L_CAND.CAND_CD) ';

      ZONE_SQL := ZONE_SQL || I_WHERE;
      ZONE_SQL := ZONE_SQL || ' ORDER BY 1';

--htp.p(ZONE_SQL);

      return true;

   exception
      when others then
         WSGL.DisplayMessage(WSGL.MESS_EXCEPTION, SQLERRM, ''||' : '||'Status da Inscrição',
                             DEF_BODY_ATTRIBUTES, 'wcc0250ac$fich.BuildSQL');
         return false;
   end;

--------------------------------------------------------------------------------
-- Name:        wcc0250ac$fich.OpenZoneSql
--
-- Description: Open's the cursor for the zone SQL of
--              'FICH' module component (Status da Inscrição).
--
-- Parameters:
--
--------------------------------------------------------------------------------
   procedure OpenZoneSql
   ( I_CURSOR OUT integer
   )
   is
   begin
      I_CURSOR := dbms_sql.open_cursor;
      dbms_sql.parse(I_CURSOR, ZONE_SQL, dbms_sql.v7);
      dbms_sql.define_column(I_CURSOR, 1, NBT_VAL.PROC_SEL, 2000);
      dbms_sql.define_column(I_CURSOR, 2, CURR_VAL.PRSE_CD, 5);
      dbms_sql.define_column(I_CURSOR, 3, CURR_VAL.REPS_SEQ);
      dbms_sql.define_column(I_CURSOR, 4, NBT_VAL.L_PRSE_PRSE_ABREV, 15);
      dbms_sql.define_column(I_CURSOR, 5, NBT_VAL.L_PRSE_PRSE_NM, 250); --(++) 30/08/2007
      dbms_sql.define_column(I_CURSOR, 6, NBT_VAL.L_REPS_REPS_DT_INGRESSO);
      dbms_sql.define_column(I_CURSOR, 7, CURR_VAL.FICH_NR_INSCRICAO);
      dbms_sql.define_column(I_CURSOR, 8, NBT_VAL.NOM_CPL, 2000);
      dbms_sql.define_column(I_CURSOR, 9, NBT_VAL.L_CAND_CAND_NM, 50);
      dbms_sql.define_column(I_CURSOR, 10, NBT_VAL.L_CAND_CAND_SOBRENOME, 30);
      dbms_sql.define_column(I_CURSOR, 11, NBT_VAL.L_CAND_CAND_SENHA, 30);
      dbms_sql.define_column(I_CURSOR, 12, CURR_VAL.CAND_CD);
      dbms_sql.define_column(I_CURSOR, 13, CURR_VAL.FICH_ISENTO_PAGTO, 1);
      dbms_sql.define_column(I_CURSOR, 14, CURR_VAL.FICH_INSCR_PAGA, 1);
      dbms_sql.define_column(I_CURSOR, 15, NBT_VAL.INSC_CONFIRM, 2000);
      dbms_sql.define_column(I_CURSOR, 16, CURR_VAL.FICH_DT_PGTO);
      dbms_sql.define_column(I_CURSOR, 17, CURR_VAL.FICH_MEDIA_FINAL);
      dbms_sql.define_column(I_CURSOR, 18, CURR_VAL.FICH_CLASSIF_PS);
   exception
      when others then
         WSGL.DisplayMessage(WSGL.MESS_EXCEPTION, SQLERRM, ''||' : '||'Status da Inscrição',
                             '', 'wcc0250ac$fich.OpenZoneSql');
         raise;
   end;

--------------------------------------------------------------------------------
-- Name:        wcc0250ac$fich.AssignZoneRow
--
-- Description: Assign's a row of data and calculates the check sum from the
--              zone SQL of 'FICH' module component (Status da Inscrição).
--
-- Parameters:
--
--------------------------------------------------------------------------------
   procedure AssignZoneRow
   ( I_CURSOR IN integer
   )
   is
   begin
      dbms_sql.column_value(I_CURSOR, 1, NBT_VAL.PROC_SEL);
      dbms_sql.column_value(I_CURSOR, 2, CURR_VAL.PRSE_CD);
      dbms_sql.column_value(I_CURSOR, 3, CURR_VAL.REPS_SEQ);
      dbms_sql.column_value(I_CURSOR, 4, NBT_VAL.L_PRSE_PRSE_ABREV);
      dbms_sql.column_value(I_CURSOR, 5, NBT_VAL.L_PRSE_PRSE_NM);
      dbms_sql.column_value(I_CURSOR, 6, NBT_VAL.L_REPS_REPS_DT_INGRESSO);
      dbms_sql.column_value(I_CURSOR, 7, CURR_VAL.FICH_NR_INSCRICAO);
      dbms_sql.column_value(I_CURSOR, 8, NBT_VAL.NOM_CPL);
      dbms_sql.column_value(I_CURSOR, 9, NBT_VAL.L_CAND_CAND_NM);
      dbms_sql.column_value(I_CURSOR, 10, NBT_VAL.L_CAND_CAND_SOBRENOME);
      dbms_sql.column_value(I_CURSOR, 11, NBT_VAL.L_CAND_CAND_SENHA);
      dbms_sql.column_value(I_CURSOR, 12, CURR_VAL.CAND_CD);
      dbms_sql.column_value(I_CURSOR, 13, CURR_VAL.FICH_ISENTO_PAGTO);
      dbms_sql.column_value(I_CURSOR, 14, CURR_VAL.FICH_INSCR_PAGA);
      dbms_sql.column_value(I_CURSOR, 15, NBT_VAL.INSC_CONFIRM);
      dbms_sql.column_value(I_CURSOR, 16, CURR_VAL.FICH_DT_PGTO);
      dbms_sql.column_value(I_CURSOR, 17, CURR_VAL.FICH_MEDIA_FINAL);
      dbms_sql.column_value(I_CURSOR, 18, CURR_VAL.FICH_CLASSIF_PS);
      ZONE_CHECKSUM := to_char(WSGL.Checksum
         (   ''
          || CURR_VAL.PRSE_CD
          || CURR_VAL.REPS_SEQ
          || CURR_VAL.FICH_NR_INSCRICAO
          || CURR_VAL.CAND_CD
         ) );
   exception
      when others then
         WSGL.DisplayMessage(WSGL.MESS_EXCEPTION, SQLERRM, ''||' : '||'Status da Inscrição',
                             '', 'wcc0250ac$fich.AssignZoneRow');
         raise;
   end;




--------------------------------------------------------------------------------
-- Name:        wcc0250ac$fich.FormQuery
--
-- Description: This procedure builds an HTML form for entry of query criteria.
--              The criteria entered are to restrict the query of the 'FICH'
--              module component (Status da Inscrição).
--
-- Parameters:
--
--------------------------------------------------------------------------------
   procedure FormQuery(
             Z_DIRECT_CALL in boolean,
             Z_CHK in varchar2   ,
			 P_EMPRESA IN VARCHAR2,
       P_PRSE_CD IN VARCHAR2) is  --(++) 17/06/2009
      L_SUCCESS  boolean := TRUE;
      v_prse_nm  varchar2(500);  --(++) 17/06/2009


CURSOR C_INGRESSO IS
SELECT L_REPS.REPS_DT_INGRESSO REPS_DT_INGRESSO,
       L_REPS.EMPC_CD,
       L_REPS.PRSE_CD,
       L_REPS.REPS_SEQ,
       B.RV_LOW_VALUE,
       B.RV_MEANING,
       null dt_prova
  FROM REALIZACAO_PS L_REPS,
       CG_REF_CODES  B
 WHERE l_reps.reps_tp_per_ingr <> 'P'
   and UPPER(L_REPS.PRSE_CD) = UPPER(P_PRSE_CD)
   /* CG$LOVI_WC_END REPS 10 */
   AND SYSDATE <= L_REPS.REPS_DT_LIMITE_PUBLICACAO
   AND B.RV_DOMAIN = 'PERIODO_CONCURSO'
   AND B.RV_LOW_VALUE = L_REPS.REPS_TP_PER_INGR
union all
SELECT distinct L_REPS.REPS_DT_INGRESSO REPS_DT_INGRESSO,
       L_REPS.EMPC_CD,
       L_REPS.PRSE_CD,
       L_REPS.REPS_SEQ,
       B.RV_LOW_VALUE,
       B.RV_MEANING,
       to_char(c.prov_dt_realizacao,'dd/mm/rrrr')
  FROM REALIZACAO_PS L_REPS,
       CG_REF_CODES  B,
       PROVAS_FASES C
 WHERE l_reps.reps_tp_per_ingr = 'P'
   and UPPER(L_REPS.PRSE_CD) = UPPER(P_PRSE_CD)
   /* CG$LOVI_WC_END REPS 10 */
   AND SYSDATE <= L_REPS.REPS_DT_LIMITE_PUBLICACAO
   and c.reps_seq = l_reps.reps_seq
   and c.prse_cd  = l_reps.prse_cd
   AND B.RV_DOMAIN = 'PERIODO_CONCURSO'
   AND B.RV_LOW_VALUE = L_REPS.REPS_TP_PER_INGR
 ORDER BY REPS_DT_INGRESSO desc, 7 DESC;
       P_MSG varchar2(100);
   begin

      htp.p('<script>
                     function SetaRepsSeq(Obj){
                           document.all.P_REPS_SEQ.value = Obj.value;
                     }
             </script>');

      if not Z_DIRECT_CALL then

         null;
      end if;

      WSGL.OpenPageHead(''||' : '||'Status da Inscrição');
      wcc0250ac$.TemplateHeader(TRUE,1);
      WSGL.ClosePageHead;

      WSGL.OpenPageBody(FALSE, p_attributes=>QF_BODY_ATTRIBUTES || 'onLoad="return FICH_OnLoad()"');
      wcc0250ac$js$fich.CreateQueryJavaScript(LOV_FRAME,QF_BODY_ATTRIBUTES);

      wcc0250ac$.FirstPage(Z_DIRECT_CALL => TRUE

                         );

      htp.para;


      htp.p('
'||pk_cacr.fc_header_internet(null,P_EMPRESA)||htf.centeropen||htf.br||htf.bold('Informe seu ingresso no processo seletivo, seu número de inscrição ou RG e UF expedidor.')||'
'||htf.br||htf.bold('Depois, clique no botão "Localizar Candidato"')||''||htf.line);
      htp.para;
      htp.para;
      WSGL.ResetForMultipleForms ;
      htp.formOpen(curl => 'wcc0250ac$fich.actionquery', cattributes => 'NAME="wcc0250ac$fich$QForm"', cmethod => 'post');
      HTP.P('<INPUT TYPE="hidden" NAME="P_REPS_SEQ" value="">');

      SaveState;
      WSGL.LayoutOpen(WSGL.LAYOUT_TABLE);
      WSGL.LayoutRowStart;
      for i in 1..QF_NUMBER_OF_COLUMNS loop
	      WSGL.LayoutHeader(18, 'LEFT', NULL);
	      WSGL.LayoutHeader(15, 'LEFT', NULL);
      end loop;
      WSGL.LayoutRowEnd;

      --(++) 17/06/2009
      begin
        select p_prse_cd || ' - ' || p.prse_nm into v_prse_nm
          from processos_seletivos p
         where p.prse_cd = p_prse_cd;
      exception
        when others then
          v_prse_nm := null;
      end;
      --(++) 17/06/2009 Fim

      WSGL.LayoutRowStart('TOP');
      --(++) 17/06/2009
      htp.p('<TR VALIGN="TOP">
                 <TD ALIGN="LEFT"><B>Processo Seletivo:</B></TD>
                 <TD ALIGN="LEFT"><INPUT TYPE="hidden" NAME="P_L_PRSE_PRSE_ABREV" SIZE="10" MAXLENGTH="15" value="'||P_PRSE_CD||'">'||v_prse_nm||'</TD>
             </TR>');
--      WSGL.LayoutData(htf.bold('Processo Seletivo:'));
--      WSGL.LayoutData(WSGL.BuildQueryControl('L_PRSE_PRSE_ABREV', '10', FALSE, p_maxlength=>'15') || ' ' ||
--                      WSGJSL.LOVButton('L_PRSE_PRSE_ABREV',LOV_BUTTON_TEXT,'wcc0250ac$fich$QForm'));
      WSGL.LayoutRowEnd;

/*      WSGL.LayoutRowStart('TOP');
      WSGL.LayoutData(htf.bold('Ingresso em :'));
      WSGL.LayoutData(WSGL.BuildQueryControl('L_REPS_REPS_DT_INGRESSO', '35', FALSE, p_maxlength=>'7') ||
                      htf.bold('&nbsp;') ||
                      WSGJSL.LOVButton('L_REPS_REPS_DT_INGRESSO',LOV_BUTTON_TEXT,'wcc0250ac$fich$QForm'));
      WSGL.LayoutRowEnd;*/



      /***********************************************************************/
      htp.p('<tr>
                 <td><b>Ingresso em:</b></td>
                 <td>
                     <select name="P_L_REPS_REPS_DT_INGRESSO" onchange="SetaRepsSeq(this)">');

                        for ind in C_INGRESSO loop

                           IF IND.RV_LOW_VALUE = 'A' THEN
                                   P_MSG := TO_CHAR(IND.REPS_DT_INGRESSO,'RRRR');
                           ELSIF IND.RV_LOW_VALUE = 'M' THEN
                                   P_MSG := DBASPGVC.FNC_MES(TO_CHAR(IND.REPS_DT_INGRESSO,'MM'))||' / '||TO_CHAR(IND.REPS_DT_INGRESSO,'RRRR');
                                   HTP.P('<TR VALIGN="TOP">
                                             <TD ALIGN="LEFT"><a href="javascript:PassBack('''||IND.REPS_SEQ||''','''||P_MSG||''')">'||P_MSG||'</a></TD>
                                          </TR>');
                           ELSIF IND.RV_LOW_VALUE = 'P' THEN
                                   IF TO_CHAR(IND.REPS_DT_INGRESSO,'MM') <= 6 THEN
                                     P_MSG := '1° Sem. ' || TO_CHAR(IND.REPS_DT_INGRESSO,'RRRR');
                                   ELSE
                                     P_MSG := '2° Sem. ' || TO_CHAR(IND.REPS_DT_INGRESSO,'RRRR');
                                   END IF;
                                   P_MSG := P_MSG || ' prova em ' || ind.dt_prova;
                           ELSIF IND.RV_LOW_VALUE = 'S' THEN
                                   IF TO_CHAR(IND.REPS_DT_INGRESSO,'MM') <= 6 THEN
                                     P_MSG := '1° Semestre de ' || TO_CHAR(IND.REPS_DT_INGRESSO,'RRRR');
                                   ELSE
                                     P_MSG := '2° Semestre de ' || TO_CHAR(IND.REPS_DT_INGRESSO,'RRRR');
                                   END IF;
                           END IF;

                        htp.p('<option value="'||IND.REPS_SEQ||'">'||P_MSG||'</option>');
                     end loop;
               htp.p('</select>
           </td>
       </tr>');

       htp.p('<script> document.all.P_REPS_SEQ.value = document.all.P_L_REPS_REPS_DT_INGRESSO.value;</script>');
       /***********************************************************************/

      WSGL.LayoutRowStart('TOP');
      WSGL.LayoutData(htf.bold('Número Inscrição:'));
      WSGL.LayoutData(WSGL.BuildQueryControl('FICH_NR_INSCRICAO', '8', FALSE, p_maxlength=>'10'));
      WSGL.LayoutRowEnd;

---(++)
      InitialiseDomain('TIPO_DOC');
      WSGL.LayoutRowStart('TOP');
      WSGL.LayoutData(htf.bold(WSGL.BuildDVControl(D_TIPO_DOC, WSGL.CTL_QUERY, p_alwaysquery=>TRUE)));
      WSGL.LayoutData(WSGL.BuildQueryControl('CAND_RG_NR', '15', FALSE, p_maxlength=>'15') ||
                      '&nbsp;&nbsp;' || htf.bold('UF Expedidor: ') ||
                      WSGL.BuildQueryControl('CAND_RG_UF', '2', FALSE, p_maxlength=>'2') || ' ' ||
                      WSGJSL.LOVButton('CAND_RG_UF',LOV_BUTTON_TEXT,'wcc0250ac$fich$QForm'));
      WSGL.LayoutRowEnd;
--(++)



      WSGL.LayoutClose;

      WSGL.SubmitButton('Z_ACTION', QF_QUERY_BUT_CAPTION, 'btnQFQ', 'this.form.Z_ACTION.value=\''' || QF_QUERY_BUT_ACTION || '\''');
      htp.formReset(QF_CLEAR_BUT_CAPTION);


      WSGL.HiddenField('Z_CHK', to_char(WSGL.Checksum('')));

	  WSGL.HiddenField('P_EMPRESA',P_EMPRESA);

      htp.formClose;


      WSGL.ClosePageBody;

   exception
      when others then
         WSGL.DisplayMessage(WSGL.MESS_EXCEPTION, SQLERRM, ''||' : '||'Status da Inscrição',
                             QF_BODY_ATTRIBUTES, 'wcc0250ac$fich.FormQuery');
         WSGL.ClosePageBody;
   end;

--------------------------------------------------------------------------------
-- Name:        wcc0250ac$fich.FormView
--
-- Description: This procedure builds an HTML form for view/update of fields in
--              the 'FICH' module component (Status da Inscrição).
--
-- Parameters:  Z_FORM_STATUS  Status of the form
--
--------------------------------------------------------------------------------
   procedure FormView(Z_FORM_STATUS in number,
                      Q_L_PRSE_PRSE_ABREV in varchar2,
                      Q_L_REPS_REPS_DT_INGRESSO in varchar2,
                      Q_FICH_NR_INSCRICAO in varchar2,
                      Q_L_CAND_CAND_SENHA in varchar2,
                      Z_POST_DML in boolean,
                      Z_MULTI_PAGE  in boolean,
                      Z_ACTION in varchar2,
                      Z_START in varchar2 ,
					  P_EMPRESA IN VARCHAR2 DEFAULT 'EAESP') is



      I_CURSOR      integer;
      I_VOID        integer;
      I_COUNT       integer;
      l_row         integer := 0;
      l_rowset_row  integer := null;
      l_error       varchar2(2000);
      l_rows_ret    integer;
      l_row_deleted boolean := false;
      l_row_no_lock boolean := false;
      l_total_rows  integer := 0;
      I_START       number(38) := to_number(Z_START);
      I_PREV_BUT    boolean := false;
      I_NEXT_BUT    boolean := false;
      l_total_text  varchar2(200) := '';
      l_ntom_butstr varchar2(2000) := VF_NTOM_BUT_CAPTION;
      l_force_upd   boolean := false;
      l_success     boolean := true;
      l_skip_data   boolean := false;
--(++)
      w_arquivo     varchar2(50);
      w_opcao_1     varchar2(100);
      w_opcao_2     varchar2(100);
      w_decimais    number;
      v_divulga_sala varchar2(2);
      v_divulga_sala2 varchar2(2);
--(++)
      w_opcao_1_desc cursos_cacr.cuca_nm%type;
      w_opcao_2_desc cursos_cacr.cuca_nm%type;
      v_ingresso     varchar2(500);
      v_ct_entrev    number;

   begin

      l_success := RestoreState
      ( Z_CURR_DEPTH      => 0
      , Z_MAX_DEPTH       => 0
      , Z_RESTORE_OWN_ROW => false
      );





      WSGL.OpenPageHead(''||' : '||'Status da Inscrição');
      htp.script('FormType = "Update";');
      wcc0250ac$.TemplateHeader(TRUE,1);
      WSGL.ClosePageHead;

      WSGL.OpenPageBody(FALSE, p_attributes=>VF_BODY_ATTRIBUTES || 'onLoad="return FICH_OnLoad()"');

      wcc0250ac$js$fich.CreateViewJavaScript(
                                           VF_ROWS_UPDATED,
                                           VF_ROWS_DELETED,
                                           VF_ROWS_ERROR,
                                           VF_BODY_ATTRIBUTES,
			                                     LOV_FRAME
																					 );


      htp.para;
      htp.p('
'||pk_cacr.fc_header_internet(null,P_EMPRESA)||htf.centeropen);

      InitialiseDomain('FICH_ISENTO_PAGTO');
      InitialiseDomain('FICH_INSCR_PAGA');




     if Z_FORM_STATUS = WSGL.FORM_STATUS_ERROR then
         WSGL.DisplayMessage(WSGL.MESS_ERROR, cg$errors.GetErrors,
                             ''||' : '||'Status da Inscrição', VF_BODY_ATTRIBUTES);
		 htp.script('DataChangeErrors = true;');
      elsif Z_FORM_STATUS = WSGL.FORM_STATUS_UPD then
         WSGL.DisplayMessage(WSGL.MESS_SUCCESS, WSGL.MsgGetText(207, WSGLM.MSG207_ROW_UPDATED),
                             ''||' : '||'Status da Inscrição', VF_BODY_ATTRIBUTES);
		 htp.script('DataChange = true;');
      elsif Z_FORM_STATUS = WSGL.FORM_STATUS_INS then
         WSGL.DisplayMessage(WSGL.MESS_SUCCESS, WSGL.MsgGetText(208, WSGLM.MSG208_ROW_INSERTED),
                             ''||' : '||'Status da Inscrição', VF_BODY_ATTRIBUTES);
      elsif Z_FORM_STATUS = WSGL.FORM_STATUS_NO_UPD then
         htp.p( '<B>'||WSGL.MsgGetText(136,WSGLM.DSP136_NO_ROW_UPDATED)||'</B><br>' );
     end if;
     if VF_ROWS_UPDATED > 0 then
        htp.p(htf.bold(htf.br || WSGL.MsgGetText(137,WSGLM.DSP137_ROWS_UPDATED)) || ' ' ||to_char(VF_ROWS_UPDATED) );
     end if;
     if VF_ROWS_ERROR > 0 then
        htp.p(htf.bold(htf.br || WSGL.MsgGetText(138,WSGLM.DSP138_ERRORS)) || ' ' ||to_char(VF_ROWS_ERROR) );
     end if;
     if VF_ROWS_DELETED > 0 then
        htp.p(htf.bold(htf.br || WSGL.MsgGetText(139,WSGLM.DSP139_ROWS_DELETED)) || ' ' ||to_char(VF_ROWS_DELETED) );
     end if;
      WSGL.ResetForMultipleForms ;
      htp.formOpen(curl => 'wcc0250ac$fich.actionview', cattributes => 'NAME="wcc0250ac$fich$VForm"');
      SaveState;
     WSGL.LayoutOpen(WSGL.LAYOUT_TABLE);

     WSGL.LayoutRowStart;
     for i in 1..VF_NUMBER_OF_COLUMNS loop
        WSGL.LayoutHeader(28, 'LEFT', NULL);
        WSGL.LayoutHeader(30, 'LEFT', NULL);
     end loop;


     WSGL.LayoutHeader(2,'LEFT',null);

     WSGL.LayoutRowEnd;
     if Z_MULTI_PAGE then
        if (Z_ACTION = VF_LAST_BUT_ACTION) or (Z_ACTION = VF_LAST_BUT_CAPTION) or
           (Z_ACTION = VF_COUNT_BUT_ACTION) or (Z_ACTION = VF_COUNT_BUT_CAPTION) or
           (VF_TOTAL_COUNT_REQD)
          then

            I_COUNT := QueryHits(
                       P_L_PRSE_PRSE_ABREV=>Q_L_PRSE_PRSE_ABREV,
                       P_L_REPS_REPS_DT_INGRESSO=>Q_L_REPS_REPS_DT_INGRESSO,
                       P_FICH_NR_INSCRICAO=>Q_FICH_NR_INSCRICAO,
                       P_L_CAND_CAND_SENHA=>Q_L_CAND_CAND_SENHA);
            if I_COUNT = -1 then
               WSGL.ClosePageBody;
               return;
            end if;
         end if;

         if (Z_ACTION = VF_COUNT_BUT_ACTION) or (Z_ACTION = VF_COUNT_BUT_CAPTION) or (VF_TOTAL_COUNT_REQD) then
            l_total_text := ' '||WSGL.MsgGetText(111,WSGLM.DSP111_OF_TOTAL, to_char(I_COUNT));
         end if;

         if Z_START IS NULL or (Z_ACTION = VF_FIRST_BUT_ACTION) or (Z_ACTION = VF_FIRST_BUT_CAPTION) then
            I_START := 1;
         elsif (Z_ACTION = VF_NEXT_BUT_ACTION) or (Z_ACTION = VF_NEXT_BUT_CAPTION) then
            I_START := I_START + VF_RECORD_SET_SIZE;
         elsif (Z_ACTION = VF_PREV_BUT_ACTION) or (Z_ACTION = VF_PREV_BUT_CAPTION) then
            I_START := I_START - VF_RECORD_SET_SIZE;
         elsif (Z_ACTION = VF_LAST_BUT_ACTION) or (Z_ACTION = VF_LAST_BUT_CAPTION) then
            I_START := 1 + (floor((I_COUNT-1)/VF_RECORD_SET_SIZE)*VF_RECORD_SET_SIZE);
         end if;

         if I_START < 1 then
            I_START := 1;
         end if;

         I_PREV_BUT := TRUE;
         I_NEXT_BUT := FALSE;
         if I_START = 1 or Z_ACTION IS NULL then
            I_PREV_BUT := FALSE;
         end if;
      end if;
      OpenZoneSql(I_CURSOR);
      l_row := 0;
      if VF_ROW_SET.count = 0 then
         I_VOID := dbms_sql.execute(I_CURSOR);
      end if;
      while true loop
         if not l_row_deleted then
            l_row := l_row + 1;
         end if;

         l_row_deleted := false;
         l_row_no_lock := false;
         if VF_ROW_SET.count > 0 then
            if l_rowset_row is null then
               l_rowset_row := VF_ROW_SET.first;
            else
               l_rowset_row := VF_ROW_SET.next( l_rowset_row );
            end if;
            if l_rowset_row is not null then
               if not VF_ROW_SET( l_rowset_row ).ROW_DELETED then
                  dbms_sql.bind_variable(I_CURSOR, 'b_row_id', rowidtochar(VF_ROW_SET( l_rowset_row ).ROW_ID));
                  I_VOID := dbms_sql.execute(I_CURSOR);
               else
                  l_row_deleted := true;
               end if;
               if VF_ROW_SET( l_rowset_row ).SUCCESS_FLAG then
                  htp.script('DataChange = true;');
               end if;
               if not VF_ROW_SET( l_rowset_row ).SUCCESS_FLAG and cg$errors.pop_head( l_error ) then
                  htp.script('DataChangeErrors = true;');
                  WSGL.LayoutTextLine(htf.bold('<font color="ff4040">'||htf.italic(WSGL.MsgGetText(122,WSGLM.DSP122_ERROR))|| '</font>  '||l_error));
               end if;
            else
               exit;
            end if;
         end if;

         if not (l_row_deleted) then
            if Z_MULTI_PAGE then
               while l_total_rows < I_START - 1 loop
                  l_rows_ret := dbms_sql.fetch_rows(I_CURSOR);
                  l_total_rows := l_total_rows + l_rows_ret;
                  if l_rows_ret = 0 then
                     exit;
                  end if;
               end loop;
            end if;
            l_rows_ret := dbms_sql.fetch_rows(I_CURSOR);
            l_total_rows := l_total_rows + l_rows_ret;

            if (l_rows_ret > 0) and (l_total_rows < (I_START + VF_RECORD_SET_SIZE)) then
               AssignZoneRow(I_CURSOR);
            else
               exit;
            end if;
         end if;
         FORM_VAL.PROC_SEL := NBT_VAL.PROC_SEL;
         FORM_VAL.PRSE_CD := CURR_VAL.PRSE_CD;
         FORM_VAL.REPS_SEQ := CURR_VAL.REPS_SEQ;
         FORM_VAL.L_PRSE_PRSE_ABREV := NBT_VAL.L_PRSE_PRSE_ABREV;
         FORM_VAL.L_PRSE_PRSE_NM := NBT_VAL.L_PRSE_PRSE_NM;
         FORM_VAL.L_REPS_REPS_DT_INGRESSO := ltrim(to_char(NBT_VAL.L_REPS_REPS_DT_INGRESSO, 'mm/yyyy'));
         FORM_VAL.FICH_NR_INSCRICAO := ltrim(to_char(CURR_VAL.FICH_NR_INSCRICAO, '9G999G990'));
         FORM_VAL.NOM_CPL := NBT_VAL.NOM_CPL;
         FORM_VAL.L_CAND_CAND_NM := NBT_VAL.L_CAND_CAND_NM;
         FORM_VAL.L_CAND_CAND_SOBRENOME := NBT_VAL.L_CAND_CAND_SOBRENOME;
         FORM_VAL.L_CAND_CAND_SENHA := NBT_VAL.L_CAND_CAND_SENHA;
         FORM_VAL.CAND_CD := CURR_VAL.CAND_CD;
         FORM_VAL.FICH_ISENTO_PAGTO := WSGL.DomainMeaning(D_FICH_ISENTO_PAGTO, CURR_VAL.FICH_ISENTO_PAGTO);
         FORM_VAL.FICH_INSCR_PAGA := WSGL.DomainMeaning(D_FICH_INSCR_PAGA, CURR_VAL.FICH_INSCR_PAGA);
         FORM_VAL.INSC_CONFIRM := NBT_VAL.INSC_CONFIRM;
         FORM_VAL.FICH_DT_PGTO := ltrim(to_char(CURR_VAL.FICH_DT_PGTO, 'DD/MM/RRRR'));
         FORM_VAL.FICH_MEDIA_FINAL := ltrim(to_char(CURR_VAL.FICH_MEDIA_FINAL, '990D000000000'));
         FORM_VAL.FICH_CLASSIF_PS := ltrim(to_char(CURR_VAL.FICH_CLASSIF_PS, '9G999G990'));


         if l_row > 1 then
            WSGL.Separator('class = cgupseparator');
         end if;
         l_force_upd := false;
         if not PostQuery(Z_POST_DML, l_force_upd) then
            if cg$errors.pop(l_error) then
               WSGL.LayoutTextLine(htf.bold('<font color="ff4040">'||
                                   htf.italic(WSGL.MsgGetText(122,WSGLM.DSP122_ERROR))|| '</font>  '||l_error));
            end if;
         end if;
         if not l_row_deleted then
            WSGL.HiddenField('P_PRSE_CD', CURR_VAL.PRSE_CD);
            WSGL.HiddenField('P_REPS_SEQ', CURR_VAL.REPS_SEQ);
            WSGL.HiddenField('P_FICH_NR_INSCRICAO', CURR_VAL.FICH_NR_INSCRICAO);
            WSGL.HiddenField('P_CAND_CD', CURR_VAL.CAND_CD);
         end if;
         l_skip_data := false;
         WSGL.HiddenField('H_PROC_SEL', NBT_VAL.PROC_SEL);
         WSGL.LayoutRowStart('CENTER');
         WSGL.LayoutData(htf.bold('Processo Seletivo:'));
         WSGL.LayoutData(FORM_VAL.PROC_SEL);
         WSGL.LayoutRowEnd;
         if ( l_skip_data ) then
            WSGL.SkipData;
         else
            WSGL.LayoutData('&nbsp');
         end if;
         WSGL.LayoutRowEnd;
         l_skip_data := false;
         WSGL.HiddenField('H_L_REPS_REPS_DT_INGRESSO', to_char(NBT_VAL.L_REPS_REPS_DT_INGRESSO,'JSSSSS'));


         --(++) Eduardo 16/09/2009
         v_ingresso := FC_INGRESSO(P_PRSE_CD => CURR_VAL.PRSE_CD,P_REPS_SEQ => CURR_VAL.REPS_SEQ);
         htp.p('<tr><td><b>Ingresso em :</b></td>');
         htp.p('<td>');
             HTP.P(v_ingresso); --(++) 14/10/2009 FC_INGRESSO(P_PRSE_CD => CURR_VAL.PRSE_CD,P_REPS_SEQ => CURR_VAL.REPS_SEQ));
         htp.p('</td></tr>');

/*         WSGL.LayoutRowStart('CENTER');
         WSGL.LayoutData(htf.bold('Ingresso em :'));
         WSGL.LayoutData(FORM_VAL.L_REPS_REPS_DT_INGRESSO || htf.bold('  (MM/AAAA)'));
         WSGL.LayoutRowEnd;*/

/*         if ( l_skip_data ) then
            WSGL.SkipData;
         else
            WSGL.LayoutData('&nbsp');
         end if;*/
--         WSGL.LayoutRowEnd;
         l_skip_data := false;
         WSGL.HiddenField('H_FICH_NR_INSCRICAO', CURR_VAL.FICH_NR_INSCRICAO);
         WSGL.LayoutRowStart('CENTER');
         WSGL.LayoutData(htf.bold('Número Inscrição:'));
         WSGL.LayoutData(replace(FORM_VAL.FICH_NR_INSCRICAO,',','.'));  --(++) 14/10/2009 substituida a virgula por ponto
         WSGL.LayoutRowEnd;
         if ( l_skip_data ) then
            WSGL.SkipData;
         else
            WSGL.LayoutData('&nbsp');
         end if;
         WSGL.LayoutRowEnd;
         l_skip_data := false;
         WSGL.HiddenField('H_NOM_CPL', NBT_VAL.NOM_CPL);
         WSGL.LayoutRowStart('CENTER');
         WSGL.LayoutData(htf.bold('Nome Completo:'));
         WSGL.LayoutData(FORM_VAL.NOM_CPL);
         WSGL.LayoutRowEnd;
         if ( l_skip_data ) then
            WSGL.SkipData;
         else
            WSGL.LayoutData('&nbsp');
         end if;
         WSGL.LayoutRowEnd;
         l_skip_data := false;
         WSGL.HiddenField('H_INSC_CONFIRM', NBT_VAL.INSC_CONFIRM);
--(++)
--         WSGL.LayoutRowStart('CENTER');
--         WSGL.LayoutData(htf.bold('Status da Inscrição:'));
--         WSGL.LayoutData(htf.bold(FORM_VAL.INSC_CONFIRM));
--         WSGL.LayoutRowEnd;
--         if ( l_skip_data ) then
--            WSGL.SkipData;
--         else
--            WSGL.LayoutData('&nbsp');
--         end if;
--         WSGL.LayoutRowEnd;
--(++)
         l_skip_data := false;
         WSGL.HiddenField('H_FICH_DT_PGTO', to_char(CURR_VAL.FICH_DT_PGTO,'JSSSSS'));
--(++)
--         WSGL.LayoutRowStart('CENTER');
--         WSGL.LayoutData(htf.bold('Inscrição confirmada em:'));
--         WSGL.LayoutData(FORM_VAL.FICH_DT_PGTO);
--         WSGL.LayoutRowEnd;
--
--         if ( l_skip_data ) then
--            WSGL.SkipData;
--         else
--            WSGL.LayoutData('&nbsp');
--         end if;

--         WSGL.LayoutRowEnd;
-----------------
      begin
          select nvl(reps_qtd_casa_dec,0)
            into w_decimais
            from realizacao_ps
           where prse_cd  = curr_val.prse_cd
             and reps_seq = curr_val.reps_seq;
       exception
            when others then
                 htp.p('ERRO: ' || SQLERRM);
       end;

       if w_decimais = 0 then
          htp.p('<script>');
          htp.p('alert("Quantidade de casas decimais para cálculos não foi parametrizada"); ');
          htp.p('</script>');
          return;
       end if;


--(++)   Buscar Opções do candidato
         begin
            select o.cuca_cd, c.cuca_nm
    		      into w_opcao_1, w_opcao_1_desc
              from opcoes_inscricao o, cursos_cacr c
             where o.prse_cd  = CURR_VAL.PRSE_CD
               AND o.REPS_SEQ = CURR_VAL.REPS_SEQ
               AND o.OPIN_NUM_OPCAO = 1
               AND o.FICH_NR_INSCRICAO = CURR_VAL.FICH_NR_INSCRICAO
               and c.cuca_cd = o.cuca_cd;  --(++) 25/06/2008
		 exception
		      when others then
			       w_opcao_1 := null;
             w_opcao_1_desc := null;
		 end;
		l_skip_data := false;

		 if w_opcao_1 is not null then

            htp.tablerowopen;
            htp.tabledata(htf.bold('1a.opção :'));
            htp.tabledata(w_opcao_1_desc); --(++) 25/06/2008 (w_opcao_1);
            htp.tablerowclose;
		 end if;

         begin
            select o.cuca_cd, c.cuca_nm
              into w_opcao_2, w_opcao_2_desc
              from opcoes_inscricao o, cursos_cacr c
             where o.prse_cd = CURR_VAL.PRSE_CD
               AND o.REPS_SEQ = CURR_VAL.REPS_SEQ
               AND o.OPIN_NUM_OPCAO = 2
               AND o.FICH_NR_INSCRICAO = CURR_VAL.FICH_NR_INSCRICAO
               and c.cuca_cd = o.cuca_cd; --(++) 25/06/2008
	 exception
	      when others then
	           w_opcao_2 := null;
             w_opcao_2_desc := null;
	 end;
	 l_skip_data := false;

	 if w_opcao_2 is not null then

            htp.tablerowopen;
            htp.tabledata(htf.bold('2a.opção :'));
            htp.tabledata(w_opcao_2_desc); --(++) 25/06/2008 (w_opcao_2);
            htp.tablerowclose;
	 end if;



-- (++) Inicio
         declare
             v_div number := 1;
         begin
             select 0
               into v_div
               from FASES_PS
              where PRSE_CD = CURR_VAL.PRSE_CD
                and REPS_SEQ = CURR_VAL.REPS_SEQ
                and FASE_IN_DIVULGA_LISTA = 'N'
                and rownum = 1;

             if v_div = 1 then
                 raise NO_DATA_FOUND;
             end if;

             WSGL.LayoutRowStart('CENTER');
             WSGL.LayoutData('&nbsp');
             WSGL.LayoutData('&nbsp');
             WSGL.LayoutRowEnd;
             WSGL.SkipData;
             WSGL.LayoutRowEnd;
             WSGL.LayoutRowStart('CENTER');
             WSGL.LayoutData('&nbsp');
             WSGL.LayoutData('&nbsp');
             WSGL.LayoutRowEnd;
         exception
             when NO_DATA_FOUND then
                 declare
                     v_tot number;
                     v_media number;
                     v_pos   number;
                 begin
                     select count(*)
                       into v_tot
                       from FASES_PS
                      where PRSE_CD = CURR_VAL.PRSE_CD
                        and REPS_SEQ = CURR_VAL.REPS_SEQ;

                     if v_tot = 1 then
                         select CFAS_POS_CLASS,
                                CFAS_MEDIA
                           into v_pos,
                                v_media
                           from CAND_FASES
                          where PRSE_CD = CURR_VAL.PRSE_CD
                            and REPS_SEQ = CURR_VAL.REPS_SEQ
                            and CAND_CD = CURR_VAL.CAND_CD
                            and FASE_CD = 1;
                     end if;

		    if curr_val.prse_cd in ('UESPC', 'CEAG') then -- Inclusão do processo seletivo CEAG
		       begin
                         select CFAS_POS_CLASS,
                                CFAS_MEDIA
                           into v_pos,
                                v_media
                           from CAND_FASES
                          where PRSE_CD  = CURR_VAL.PRSE_CD
                            and REPS_SEQ = CURR_VAL.REPS_SEQ
                            and CAND_CD  = CURR_VAL.CAND_CD
                            and FASE_CD  = 2;
			exception
			     when others then
		 	          v_pos   := 0;
			          v_media := 0;
			end;

			l_skip_data := false;
                        WSGL.HiddenField('H_FICH_MEDIA_FINAL', CURR_VAL.FICH_MEDIA_FINAL);
                        WSGL.LayoutRowStart('CENTER');
                        WSGL.LayoutData('&nbsp');
                        WSGL.LayoutData('&nbsp');
                        WSGL.LayoutRowEnd;
                        if ( l_skip_data ) then
                           WSGL.SkipData;
                        else
                           WSGL.LayoutData('&nbsp');
                        end if;
                        WSGL.LayoutRowEnd;

                        l_skip_data := false;
                        WSGL.HiddenField('H_FICH_CLASSIF_PS', CURR_VAL.FICH_CLASSIF_PS);
                        WSGL.LayoutRowStart('CENTER');
                        WSGL.LayoutData('&nbsp');
                        WSGL.LayoutData('&nbsp');
                        WSGL.LayoutRowEnd;


		 else
		    l_skip_data := false;
                    WSGL.HiddenField('H_FICH_MEDIA_FINAL', CURR_VAL.FICH_MEDIA_FINAL);
                    WSGL.LayoutRowStart('CENTER');
                    WSGL.LayoutData('&nbsp');
                    if v_tot = 1 then
                       WSGL.LayoutData('&nbsp');
                    else
                       WSGL.LayoutData('&nbsp');
                    end if;
                    WSGL.LayoutRowEnd;
                    if ( l_skip_data ) then
                        WSGL.SkipData;
                    else
                       WSGL.LayoutData('&nbsp');
                    end if;
                    WSGL.LayoutRowEnd;

                    l_skip_data := false;
                    WSGL.HiddenField('H_FICH_CLASSIF_PS', CURR_VAL.FICH_CLASSIF_PS);
                    WSGL.LayoutRowStart('CENTER');
                    WSGL.LayoutData('&nbsp');

                    if v_tot = 1 then
                        WSGL.LayoutData('&nbsp');
                    else
                        WSGL.LayoutData('&nbsp');
                    end if;
                    WSGL.LayoutRowEnd;
   		  end if;
                 end;
         end;
-- (++) Fim
         if (l_row_deleted) then
            WSGL.LayoutData('&nbsp');
         else
            WSGL.LayoutData('<NOSCRIPT>' || htf.formSelectOpen('z_modified') ||
                            '<OPTION value=N>' || WSGL.MsgGetText(135,WSGLM.CAP027_DONT_UPDATE)|| '<OPTION value=Y>' ||
                            WSGL.MsgGetText(135,WSGLM.CAP026_DO_UPDATE) ||
                            htf.formSelectClose || '</NOSCRIPT>');
         end if;
         WSGL.LayoutRowEnd;

         if not (l_row_deleted) then
            htp.p(WSGJSL.OpenScript);
            if l_force_upd then
              htp.p('document.write(''<INPUT TYPE="hidden" NAME="z_modified" VALUE="Y">'');');
            else
              htp.p('document.write(''<INPUT TYPE="hidden" NAME="z_modified" VALUE="N">'');');
            end if;
            htp.p(WSGJSL.CloseScript);
            WSGL.HiddenField('O_FICH_ISENTO_PAGTO', CURR_VAL.FICH_ISENTO_PAGTO);
            WSGL.HiddenField('O_FICH_INSCR_PAGA', CURR_VAL.FICH_INSCR_PAGA);
            WSGL.HiddenField('O_FICH_DT_PGTO', to_char(CURR_VAL.FICH_DT_PGTO,'JSSSSS'));
            WSGL.HiddenField('O_FICH_MEDIA_FINAL', CURR_VAL.FICH_MEDIA_FINAL);
            WSGL.HiddenField('O_FICH_CLASSIF_PS', CURR_VAL.FICH_CLASSIF_PS);

         end if;

      end loop;
      WSGL.LayoutClose;

      if l_row < 3 then
         WSGL.HiddenField('P_PRSE_CD','');
         WSGL.HiddenField('P_REPS_SEQ','');
         WSGL.HiddenField('P_FICH_NR_INSCRICAO','');
         WSGL.HiddenField('P_CAND_CD','');
         WSGL.HiddenField('O_FICH_ISENTO_PAGTO', '');
         WSGL.HiddenField('O_FICH_INSCR_PAGA', '');
         WSGL.HiddenField('O_FICH_DT_PGTO', '');
         WSGL.HiddenField('O_FICH_MEDIA_FINAL', '');
         WSGL.HiddenField('O_FICH_CLASSIF_PS', '');
         WSGL.HiddenField('H_PROC_SEL','');
         WSGL.HiddenField('H_L_REPS_REPS_DT_INGRESSO','');
         WSGL.HiddenField('H_FICH_NR_INSCRICAO','');
         WSGL.HiddenField('H_NOM_CPL','');
         WSGL.HiddenField('H_INSC_CONFIRM','');
         WSGL.HiddenField('H_FICH_DT_PGTO','');
         WSGL.HiddenField('H_FICH_MEDIA_FINAL','');
         WSGL.HiddenField('H_FICH_CLASSIF_PS','');
         WSGL.HiddenField('z_modified','dummy_row');
      end if;

      dbms_sql.close_cursor(I_CURSOR);

      if l_rows_ret > 0 then
         I_NEXT_BUT := true;
      end if;


      WSGL.HiddenField('Z_ACTION','');

      if Z_MULTI_PAGE and VF_ROW_SET.count = 0 then
         WSGL.RecordListButton(I_PREV_BUT, 'Z_ACTION', VF_FIRST_BUT_CAPTION,                            WSGL.MsgGetText(213,WSGLM.MSG213_AT_FIRST),			    FALSE,
                            'onClick="return JSLCheckModified( this.form, \''' || VF_FIRST_BUT_ACTION || '\'', true)"',
                            p_type_button=>true);
         WSGL.RecordListButton(I_PREV_BUT, 'Z_ACTION', VF_PREV_BUT_CAPTION,                            WSGL.MsgGetText(213,WSGLM.MSG213_AT_FIRST),			    FALSE,
                            'onClick="return JSLCheckModified( this.form, \''' || VF_PREV_BUT_ACTION || '\'', true)"',
                            p_type_button=>true);
         WSGL.RecordListButton(I_NEXT_BUT,'Z_ACTION', VF_NEXT_BUT_CAPTION,                            WSGL.MsgGetText(214,WSGLM.MSG214_AT_LAST),			    FALSE,
                           'onClick="return JSLCheckModified( this.form, \''' || VF_NEXT_BUT_ACTION || '\'', true)"',
                           p_type_button=>true);
         WSGL.RecordListButton(I_NEXT_BUT,'Z_ACTION', VF_LAST_BUT_CAPTION,                            WSGL.MsgGetText(214,WSGLM.MSG214_AT_LAST),			    FALSE,
                           'onClick="return JSLCheckModified( this.form, \''' || VF_LAST_BUT_ACTION || '\'', true)"',
                           p_type_button=>true);
-- (++)
--         htp.para;
--
--         WSGL.RecordListButton(TRUE, 'Z_ACTION', VF_QUERY_BUT_CAPTION,p_dojs=>FALSE,
--                            buttonJS => 'onClick="return JSLCheckModified( this.form, \''' || VF_QUERY_BUT_ACTION || '\'', true)"',
--                            p_type_button=>true);
-- (++)
      end if;

      WSGL.HiddenField('Z_CHK',
                     to_char(WSGL.Checksum(''||CURR_VAL.PRSE_CD||CURR_VAL.REPS_SEQ||CURR_VAL.FICH_NR_INSCRICAO||CURR_VAL.CAND_CD)));

      WSGL.HiddenField('Q_L_PRSE_PRSE_ABREV', Q_L_PRSE_PRSE_ABREV);
      WSGL.HiddenField('Q_L_REPS_REPS_DT_INGRESSO', Q_L_REPS_REPS_DT_INGRESSO);
      WSGL.HiddenField('Q_FICH_NR_INSCRICAO', Q_FICH_NR_INSCRICAO);
      WSGL.HiddenField('Q_L_CAND_CAND_SENHA', Q_L_CAND_CAND_SENHA);

      WSGL.HiddenField('Z_START', to_char(I_START));

      htp.formClose;

      WSGL.ResetForMultipleForms ;
      htp.formOpen(curl => 'wcc0250ac$fich.actionview', ctarget=>'_parent', cattributes => 'NAME="wcc0250ac$fich$VFormQry"');
      SaveState;
      htp.p ('<SCRIPT><!--');
      htp.p ('document.write (''<input type=hidden name="Z_ACTION">'')');
      htp.p ('//-->');
      htp.p ('</SCRIPT>');
      WSGL.HiddenField('z_modified','dummy_row');
      WSGL.HiddenField('P_PRSE_CD','');
      WSGL.HiddenField('P_REPS_SEQ','');
      WSGL.HiddenField('P_FICH_NR_INSCRICAO','');
      WSGL.HiddenField('P_CAND_CD','');
      if VF_ROW_SET.count = 0 and not Z_MULTI_PAGE then
         WSGL.RecordListButton(TRUE, 'Z_ACTION', VF_QUERY_BUT_CAPTION, p_dojs=>FALSE,
                            buttonJS => 'onClick="return JSLCheckModified( this.form, \''' || VF_QUERY_BUT_ACTION || '\'', true)"',
                            p_type_button=>true);
      end if;
      htp.formClose;
      --(++) 29/04/2008 Apresenta Cartão de Confirmação
      if  curr_val.FICH_ISENTO_PAGTO = 'S' or
          curr_val.FICH_INSCR_PAGA   = 'S' then
          begin
             select f.fase_in_divulga_sala
               into v_divulga_sala
               from FASES_PS f
              where f.PRSE_CD  = CURR_VAL.PRSE_CD
                and f.REPS_SEQ = CURR_VAL.REPS_SEQ
                and f.fase_cd  = 1; -- quando tiver alocação na segunda fase o forms tem este check se pode divulgar local
          exception
            when others then
              v_divulga_sala := 'N';
          end;
          if  v_divulga_sala = 'S' then
          htp.p('<a target="" href="#" onclick="
                   window.open(''wcc0120$.prcimprimecartao?p_prse_cd=' || CURR_VAL.PRSE_CD ||
                                '&p_reps_seq=' || CURR_VAL.REPS_SEQ ||
                                '&p_cand_cd=' || CURR_VAL.CAND_CD ||
                                '&p_fich_nr_inscricao=' || CURR_VAL.FICH_NR_INSCRICAO || ''', ''_blank'', ''resizable=yes,location=no,toolbar=no,status=no,menubar=no,scrollbars=yes'');" ><b>Cartão de Confirmação da Inscrição</b></a>' ||'&nbsp'||'&nbsp'||'&nbsp'||'&nbsp'||'&nbsp'||'&nbsp'||'&nbsp'||'&nbsp'||'&nbsp'||'&nbsp'||'&nbsp'||'&nbsp'||'&nbsp'||'&nbsp'||'&nbsp'||'&nbsp'||'&nbsp'||'&nbsp'||'&nbsp'||'&nbsp'||'&nbsp'||'&nbsp'||'&nbsp'||'&nbsp'||'&nbsp'||'&nbsp'||'&nbsp'||'&nbsp'||'&nbsp'||'&nbsp'||'&nbsp'||'&nbsp'||'&nbsp'||'&nbsp'||'&nbsp'||'&nbsp'||'&nbsp'||'&nbsp'||'&nbsp'||'&nbsp'||'&nbsp'||'&nbsp');
          end if;
      end if;
      --(++) 29/04/2008 Fim

      --(++) 10/11/2010
      select count(*) into v_ct_entrev
        from calend_entrev e
       where e.prse_cd  = CURR_VAL.PRSE_CD
         and e.reps_seq = CURR_VAL.REPS_SEQ
         and e.cand_cd  = CURR_VAL.CAND_CD;
         
      begin
             select f.fase_in_divulga_sala
               into v_divulga_sala2
               from FASES_PS f
              where f.PRSE_CD  = CURR_VAL.PRSE_CD
                and f.REPS_SEQ = CURR_VAL.REPS_SEQ
                and f.fase_cd  = 2; -- Exame Oral CGD
          exception
            when others then
              v_divulga_sala2 := 'N';
          end;
         
      if  nvl(v_ct_entrev,0) > 0 and
          v_divulga_sala2 = 'S'  then
          --(++) Imprime cartão de confirmação
          htp.p(WSGJSL.OpenScript);
                htp.p(
          '
          function imprime(prse, reps, cand) {
          lixo = window.open("", "_blank", "scrollbars=yes,status=no,resizable=yes");
          lixo.document.write("<HTML><HEAD><TITLE>Relatórios</TITLE>");
          lixo.document.write("<meta http-equiv=pragma content=no-cache>");
          lixo.document.write("<meta http-equiv=expires content=1>");
          lixo.document.write("</HEAD>");
          lixo.document.write("<FRAMESET ROWS=100,0>");
          lixo.document.write("<FRAME NAME=LIXO SRC=/reports/rwservlet?gvrelcacrpdf+report=wccr007e+p_prse_cd=" + prse + "+p_reps_seq=" + reps + "+p_cand_cd=" + cand +">");
          lixo.document.write("</FRAMESET></HTML>");
          }
          ');
          htp.p(WSGJSL.CloseScript);
          htp.p('
          '||htf.bold(htf.anchor2('javascript:imprime(''' || CURR_VAL.PRSE_CD || ''',''' || CURR_VAL.REPS_SEQ || ''',''' || CURR_VAL.CAND_CD || ''')', 'Cartão de Confirmação da Entrevista'))
          ||'
          ');
          htp.br;
      end if;
      --(++) 10/11/2010 Fim

	    -- Fale Conosco

      htp.p('<script>

                function FaleConosco(){
                        window.open(''wcc2001$.prc_fale_conosco?p_inscricao='||FORM_VAL.FICH_NR_INSCRICAO||'&p_nome='||replace(FORM_VAL.NOM_CPL,'''','')||'&p_curso='||replace(FORM_VAL.PROC_SEL,'''','')||'&p_ingresso='||v_ingresso||'&p_origem=Acompanhamentos de Inscrição'',''FaleConosco'',''height=330, width=520, scrollbars=no, status=no, location=no, toolbar=no, menubar=no'');
                }

             </script>');
	  -- Fale Conosco
    htp.p('<a href="#" onclick="FaleConosco();">Fale Conosco</a>');
    -- htp.mailto(caddress =>'fgv.vestibulares@fgvsp.br' ,ctext =>'Fale Conosco');

      htp.para;
      htp.p('
'||wcc0250ac$fich.FcDadosGerais(CURR_VAL.PRSE_CD, CURR_VAL.REPS_SEQ, CURR_VAL.CAND_CD)||'
'||htf.centerclose);
      htp.para;

      WSGL.ClosePageBody;

   exception
      when others then
         WSGL.DisplayMessage(WSGL.MESS_EXCEPTION, SQLERRM, ''||' : '||'Status da Inscrição',
                             VF_BODY_ATTRIBUTES, 'wcc0250ac$fich.FormView');
         WSGL.ClosePageBody;
   end;

--------------------------------------------------------------------------------
-- Name:        wcc0250ac$fich.QueryView
--
-- Description: Queries the details of a single row in preparation for display.
--
-- Parameters:
--
--------------------------------------------------------------------------------
   procedure QueryView(
             K_PRSE_CD in varchar2,
             K_REPS_SEQ in varchar2,
             K_FICH_NR_INSCRICAO in varchar2,
             K_CAND_CD in varchar2,
             P_L_PRSE_PRSE_ABREV in varchar2,
             P_L_REPS_REPS_DT_INGRESSO in varchar2,
             P_FICH_NR_INSCRICAO in varchar2,
             P_L_CAND_CAND_SENHA in varchar2,
             Z_EXECUTE_QUERY in varchar2,
             Z_POST_DML in boolean,
             Z_FORM_STATUS in number,
             Z_DIRECT_CALL in boolean,
             Z_START in varchar2,
             Z_ACTION in varchar2,
             Z_CHK in varchar2 ,
			       P_EMPRESA IN VARCHAR2 DEFAULT 'EAESP') is
      L_ROW_ID  ROWID;
   begin

      if (not Z_DIRECT_CALL) then
        WSGL.RegisterURL('wcc0250ac$fich.queryview');
        WSGL.AddURLParam('K_PRSE_CD', K_PRSE_CD);
        WSGL.AddURLParam('K_REPS_SEQ', K_REPS_SEQ);
        WSGL.AddURLParam('K_FICH_NR_INSCRICAO', K_FICH_NR_INSCRICAO);
        WSGL.AddURLParam('K_CAND_CD', K_CAND_CD);
        WSGL.AddURLParam('P_L_PRSE_PRSE_ABREV', P_L_PRSE_PRSE_ABREV);
        WSGL.AddURLParam('P_L_REPS_REPS_DT_INGRESSO', P_L_REPS_REPS_DT_INGRESSO);
        WSGL.AddURLParam('P_FICH_NR_INSCRICAO', P_FICH_NR_INSCRICAO);
        WSGL.AddURLParam('P_L_CAND_CAND_SENHA', P_L_CAND_CAND_SENHA);
        WSGL.AddURLParam('Z_EXECUTE_QUERY', Z_EXECUTE_QUERY);
        WSGL.AddURLParam('Z_START', Z_START);
        WSGL.AddURLParam('Z_ACTION', Z_ACTION);
        WSGL.AddURLParam('Z_CHK', Z_CHK);
      end if;
      if not Z_DIRECT_CALL then

         null;

      end if;

      if (not Z_DIRECT_CALL) then

        null;
      end if;

      if K_PRSE_CD is not null then
         CURR_VAL.PRSE_CD := K_PRSE_CD;
      end if;
      if K_REPS_SEQ is not null then
         CURR_VAL.REPS_SEQ := K_REPS_SEQ;
      end if;
      if K_FICH_NR_INSCRICAO is not null then
         CURR_VAL.FICH_NR_INSCRICAO := K_FICH_NR_INSCRICAO;
      end if;
      if K_CAND_CD is not null then
         CURR_VAL.CAND_CD := K_CAND_CD;
      end if;

      if Z_EXECUTE_QUERY is null then
         if VF_ROW_SET.count = 0 then
            if  BuildSQL( Z_QUERY_BY_KEY=>true) then
               FormView(Z_FORM_STATUS=>Z_FORM_STATUS,
                        Q_L_PRSE_PRSE_ABREV=>P_L_PRSE_PRSE_ABREV,
                       Q_L_REPS_REPS_DT_INGRESSO=>P_L_REPS_REPS_DT_INGRESSO,
                       Q_FICH_NR_INSCRICAO=>P_FICH_NR_INSCRICAO,
                       Q_L_CAND_CAND_SENHA=>P_L_CAND_CAND_SENHA,
                       Z_POST_DML=>Z_POST_DML, Z_MULTI_PAGE=>false, Z_ACTION=>Z_ACTION, Z_START=>Z_START,
					   P_EMPRESA => P_EMPRESA);
            end if;
          else
            if BuildSQL( z_bind_row_id=>true ) then
               FormView(Z_FORM_STATUS=>Z_FORM_STATUS,
                        Q_L_PRSE_PRSE_ABREV=>P_L_PRSE_PRSE_ABREV,
                       Q_L_REPS_REPS_DT_INGRESSO=>P_L_REPS_REPS_DT_INGRESSO,
                       Q_FICH_NR_INSCRICAO=>P_FICH_NR_INSCRICAO,
                       Q_L_CAND_CAND_SENHA=>P_L_CAND_CAND_SENHA,
                       Z_POST_DML=>Z_POST_DML, Z_MULTI_PAGE=>false, Z_ACTION=>Z_ACTION, Z_START=>Z_START,
					   P_EMPRESA => P_EMPRESA);
            end if;
          end if;

      else
         if not PreQuery(
                       P_L_PRSE_PRSE_ABREV=>P_L_PRSE_PRSE_ABREV,
                       P_L_REPS_REPS_DT_INGRESSO=>P_L_REPS_REPS_DT_INGRESSO,
                       P_FICH_NR_INSCRICAO=>P_FICH_NR_INSCRICAO,
                       P_L_CAND_CAND_SENHA=>P_L_CAND_CAND_SENHA) then
            WSGL.DisplayMessage(WSGL.MESS_ERROR, cg$errors.GetErrors,
                                ''||' : '||'Status da Inscrição', VF_BODY_ATTRIBUTES);
            return;
         end if;

         if BuildSQL
             (P_L_PRSE_PRSE_ABREV=>P_L_PRSE_PRSE_ABREV
             ,P_L_REPS_REPS_DT_INGRESSO=>P_L_REPS_REPS_DT_INGRESSO
             ,P_FICH_NR_INSCRICAO=>P_FICH_NR_INSCRICAO
             ,P_L_CAND_CAND_SENHA=>P_L_CAND_CAND_SENHA
             ,P_REPS_SEQ => K_REPS_SEQ
                    )
                    then
            FormView(Z_FORM_STATUS=>Z_FORM_STATUS,
                       Q_L_PRSE_PRSE_ABREV=>P_L_PRSE_PRSE_ABREV,
                       Q_L_REPS_REPS_DT_INGRESSO=>P_L_REPS_REPS_DT_INGRESSO,
                       Q_FICH_NR_INSCRICAO=>P_FICH_NR_INSCRICAO,
                       Q_L_CAND_CAND_SENHA=>P_L_CAND_CAND_SENHA,
                        Z_POST_DML=>Z_POST_DML, Z_MULTI_PAGE=>true, Z_ACTION=>Z_ACTION, Z_START=>Z_START,
						P_EMPRESA => P_EMPRESA);
         end if;

      end if;

   exception
      when NO_DATA_FOUND then
         WSGL.DisplayMessage(WSGL.MESS_ERROR, WSGL.MsgGetText(204, WSGLM.MSG204_ROW_DELETED),
                             ''||' : '||'Status da Inscrição', VF_BODY_ATTRIBUTES);
      when others then
         WSGL.DisplayMessage(WSGL.MESS_EXCEPTION, SQLERRM, ''||' : '||'Status da Inscrição',
                             VF_BODY_ATTRIBUTES, 'wcc0250ac$fich.QueryView');
   end;
--------------------------------------------------------------------------------
-- Name:        wcc0250ac$fich.QueryViewByKey
--
-- Description: Queries the details of a single row in preparation for display.
--
-- Parameters:
--
--------------------------------------------------------------------------------
   procedure QueryViewByKey(
             P_PRSE_CD in varchar2,
             P_REPS_SEQ in varchar2,
             P_FICH_NR_INSCRICAO in varchar2,
             P_CAND_CD in varchar2,
             Z_POST_DML in boolean,
             Z_FORM_STATUS in number,
             Z_DIRECT_CALL in boolean,
             Z_CHK in varchar2) is
begin

    QueryView(
              K_PRSE_CD=>P_PRSE_CD,
              K_REPS_SEQ=>P_REPS_SEQ,
              K_FICH_NR_INSCRICAO=>P_FICH_NR_INSCRICAO,
              K_CAND_CD=>P_CAND_CD,
              Z_EXECUTE_QUERY=>null,
              Z_POST_DML=>Z_POST_DML,
              Z_FORM_STATUS=>Z_FORM_STATUS,
              Z_DIRECT_CALL=>Z_DIRECT_CALL,
              Z_CHK=>Z_CHK);
end;

--------------------------------------------------------------------------------
-- Name:        wcc0250ac$fich.ActionView
--
-- Description: This procedure is called when the View Form is submitted to
--              action an update, delete or requery request.
--
-- Parameters:
--
--------------------------------------------------------------------------------
   procedure ActionView(
             P_PRSE_CD in owa_text.vc_arr,
             P_REPS_SEQ in owa_text.vc_arr,
             P_FICH_NR_INSCRICAO in owa_text.vc_arr,
             P_CAND_CD in owa_text.vc_arr,
             O_FICH_ISENTO_PAGTO in owa_text.vc_arr,
             O_FICH_INSCR_PAGA in owa_text.vc_arr,
             O_FICH_DT_PGTO in owa_text.vc_arr,
             O_FICH_MEDIA_FINAL in owa_text.vc_arr,
             O_FICH_CLASSIF_PS in owa_text.vc_arr,
             H_PROC_SEL in owa_text.vc_arr,
             H_L_REPS_REPS_DT_INGRESSO in owa_text.vc_arr,
             H_FICH_NR_INSCRICAO in owa_text.vc_arr,
             H_NOM_CPL in owa_text.vc_arr,
             H_INSC_CONFIRM in owa_text.vc_arr,
             H_FICH_DT_PGTO in owa_text.vc_arr,
             H_FICH_MEDIA_FINAL in owa_text.vc_arr,
             H_FICH_CLASSIF_PS in owa_text.vc_arr,
             Q_L_PRSE_PRSE_ABREV in varchar2,
             Q_L_REPS_REPS_DT_INGRESSO in varchar2,
             Q_FICH_NR_INSCRICAO in varchar2,
             Q_L_CAND_CAND_SENHA in varchar2,
             z_modified in owa_text.vc_arr,
             Z_ACTION in varchar2,
             Z_START  in varchar2,
             Z_CHK in varchar2 ) is
--
      l_row         integer;
      l_row_failed  boolean := false;
      l_success     boolean;
      l_rowset_row  integer := 1;
      l_delset_row  integer := 1;
      l_cbcount     integer;
      l_do_delete   boolean := false;
      l_record_lck  boolean := false;
      l_dummy_bool  boolean := false;

   begin


      l_dummy_bool := RestoreState
      ( Z_CURR_DEPTH      => 0
      , Z_MAX_DEPTH       => 0
      , Z_RESTORE_OWN_ROW => false
      );

if (Z_ACTION = VF_COUNT_BUT_ACTION or Z_ACTION = VF_COUNT_BUT_CAPTION) or
   (Z_ACTION = VF_FIRST_BUT_ACTION or Z_ACTION = VF_FIRST_BUT_CAPTION) or
   (Z_ACTION = VF_PREV_BUT_ACTION  or Z_ACTION = VF_PREV_BUT_CAPTION)  or
   (Z_ACTION = VF_NEXT_BUT_ACTION  or Z_ACTION = VF_NEXT_BUT_CAPTION)  or
   (Z_ACTION = VF_LAST_BUT_ACTION  or Z_ACTION = VF_LAST_BUT_CAPTION)  or
   (Z_ACTION = VF_REQUERY_BUT_ACTION or Z_ACTION = VF_REQUERY_BUT_CAPTION) or
   (Z_ACTION = VF_NTOM_BUT_ACTION or Z_ACTION = VF_NTOM_BUT_CAPTION)       then
         QueryView(Z_EXECUTE_QUERY=>'Y',
                   P_L_PRSE_PRSE_ABREV=>Q_L_PRSE_PRSE_ABREV,
                   P_L_REPS_REPS_DT_INGRESSO=>Q_L_REPS_REPS_DT_INGRESSO,
                   P_FICH_NR_INSCRICAO=>Q_FICH_NR_INSCRICAO,
                   P_L_CAND_CAND_SENHA=>Q_L_CAND_CAND_SENHA,
                   Z_POST_DML=>FALSE,
                   Z_DIRECT_CALL=>TRUE,
                   Z_ACTION=>Z_ACTION,
                   Z_START=>Z_START);
end if;

if (Z_ACTION = VF_QUERY_BUT_ACTION) or (Z_ACTION = VF_QUERY_BUT_CAPTION) then
     FormQuery(
         Z_DIRECT_CALL=>TRUE);
end if;


   exception
      when others then
         WSGL.DisplayMessage(WSGL.MESS_EXCEPTION, SQLERRM, ''||' : '||'Status da Inscrição',
                             VF_BODY_ATTRIBUTES, 'wcc0250ac$fich.ActionView');
   end;
--------------------------------------------------------------------------------
-- Name:        wcc0250ac$fich.RestoreState
--
-- Description: Restore the data state and optional meta data for the
--              'FICH' module component (Status da Inscrição).
--
-- Parameters:
--
--------------------------------------------------------------------------------
   function RestoreState
     ( Z_CURR_DEPTH          in number
     , Z_MAX_DEPTH           in number
     , Z_RESTORE_OWN_ROW     in boolean ) return boolean
   is
      I_REMAINING_DEPTH integer;
      I_CURSOR          integer;
      I_VOID            integer;
      I_ROWS_FETCHED    integer;
      I_FETCH_ERROR     boolean := FALSE;
      I_SUCCESS         boolean := TRUE;
   begin
     if Z_RESTORE_OWN_ROW then
        if ( CURR_VAL.PRSE_CD is null or  CURR_VAL.REPS_SEQ is null or  CURR_VAL.FICH_NR_INSCRICAO is null or  CURR_VAL.CAND_CD is null
           ) then
           return FALSE;
        end if;
     end if;

      if ( Z_RESTORE_OWN_ROW ) then

         -- Use the CURR_VAL fields for UID to get the other values

         if not BuildSQL( Z_QUERY_BY_KEY => true ) then
            return FALSE;
         end if;

         OpenZoneSql(I_CURSOR);
         I_VOID := dbms_sql.execute(I_CURSOR);
         I_ROWS_FETCHED := dbms_sql.fetch_rows(I_CURSOR);

         if I_ROWS_FETCHED = 0 then
            I_FETCH_ERROR := TRUE;
         else

            AssignZoneRow(I_CURSOR);
            I_ROWS_FETCHED := dbms_sql.fetch_rows(I_CURSOR);

            if I_ROWS_FETCHED != 0 then
              I_FETCH_ERROR := TRUE;
            end if;

         end if;

         dbms_sql.close_cursor(I_CURSOR);
         if I_FETCH_ERROR then
            return FALSE;
         end if;

      end if;
      return TRUE;

   exception
      when others then
         WSGL.DisplayMessage(WSGL.MESS_EXCEPTION, SQLERRM, ''||' : '||'Status da Inscrição',
                             '', 'wcc0250ac$fich.RestoreState');
         raise;
         return FALSE;
   end;

--------------------------------------------------------------------------------
-- Name:        wcc0250ac$fich.SaveState
--
-- Description: Saves the data state for the 'FICH' module component (Status da Inscrição).
--
-- Parameters:
--
--------------------------------------------------------------------------------
   procedure SaveState
   is
   begin


      null;

   exception
      when others then
         WSGL.DisplayMessage(WSGL.MESS_EXCEPTION, SQLERRM, ''||' : '||'Status da Inscrição',
                             '', 'wcc0250ac$fich.SaveState');
         raise;
   end;




--------------------------------------------------------------------------------
-- Name:        wcc0250ac$fich.PreQuery
--
-- Description: Provides place holder for code to be run prior to a query
--              for the 'FICH' module component  (Status da Inscrição).
--
-- Parameters:  None
--
-- Returns:     True           If success
--              False          Otherwise
--
--------------------------------------------------------------------------------
   function PreQuery(
            P_L_PRSE_PRSE_ABREV in varchar2,
            P_L_REPS_REPS_DT_INGRESSO in varchar2,
            P_FICH_NR_INSCRICAO in varchar2,
            P_L_CAND_CAND_SENHA in varchar2) return boolean is
      L_RET_VAL boolean := TRUE;
   begin
      return L_RET_VAL;
   exception
      when others then
         WSGL.DisplayMessage(WSGL.MESS_EXCEPTION, SQLERRM, ''||' : '||'Status da Inscrição',
                             DEF_BODY_ATTRIBUTES, 'wcc0250ac$fich.PreQuery');
         return FALSE;
   end;

--------------------------------------------------------------------------------
-- Name:        wcc0250ac$fich.PostQuery
--
-- Description: Provides place holder for code to be run after a query
--              for the 'FICH' module component  (Status da Inscrição).
--
-- Parameters:  Z_POST_DML   Flag indicating if Query after insert or update
--              Z_UPDATE_ROW Can be set to mark that row as modified when a
--                           multirow form is displayed, causing it to be
--                           updated when the form is submitted.
--
-- Returns:     True           If success
--              False          Otherwise
--
--------------------------------------------------------------------------------
   function PostQuery(Z_POST_DML in boolean, Z_UPDATE_ROW in out boolean) return boolean is
      L_RET_VAL boolean := TRUE;
   begin
       return L_RET_VAL;
   exception
      when others then
         WSGL.DisplayMessage(WSGL.MESS_EXCEPTION, SQLERRM, ''||' : '||'Status da Inscrição',
                             DEF_BODY_ATTRIBUTES, 'wcc0250ac$fich.PostQuery');
          return FALSE;
   end;

   PROCEDURE Doctos(P_PRSE_CD   in varchar2 default null,
                    P_REPS_SEQ  in varchar2 default null,
                    P_INSCRICAO in varchar2 default null) is
   cursor doctos is
     select d.docm_nom, i.doin_ind_entregue ind, to_char(i.doin_dt_entrega,'dd/mm/rrrr') entrega,
            to_char(i.doin_dt_devol,'dd/mm/rrrr') devol, d.docm_cod
       from docum_inscricao i, documentos d, documentos_ps p
      where i.prse_cd           = p_prse_cd
        and i.reps_seq          = p_reps_seq
        and i.fich_nr_inscricao = replace(p_inscricao,',','')
        and d.docm_cod          = i.docm_cod
        and p.prse_cd           = i.prse_cd
        and p.reps_seq          = i.reps_seq
        and p.docm_cod          = i.docm_cod
        order by fc_retirar_acento(d.docm_nom);
   doc doctos%rowtype;

   P_COUNT_DOC NUMBER(10);
   P_DATA_MNT  VARCHAR2(10);

   Begin

     htp.p('<HEAD>
            <TITLE>Documentação</TITLE>
            <LINK REL=StyleSheet HREF="/ows-css/cacr_internet.css" TYPE="text/css">');

     htp.p('<center><b><h3>Documentação</h3></b></center>');
     htp.p('<table border=1 cellspacing="0" cellspading="0" width="100%">
                   <tr>
                       <td width="60%" align=center><b>Documento</b></td>
                       <td width="20%" align=center><b>Confirmação Entrega</b></td>');

                   SELECT COUNT(*) INTO P_COUNT_DOC FROM DOCUMENTOS_PS J WHERE J.PRSE_CD = P_PRSE_CD AND J.REPS_SEQ = P_REPS_SEQ AND J.DOPS_IND_ANEXA = 'S';

                   IF P_COUNT_DOC > 0 THEN
                      htp.p('<td width="20%" align=center><b>Anexado em</b></td>');
                   END IF;

                   htp.p('</tr>');


open doctos;
     loop
       fetch doctos into doc;
         exit when doctos%notfound;

         htp.p('<tr>
                    <td>'||nvl(doc.docm_nom,'&nbsp;')||'</td>
                    <td align=center>'||nvl(doc.entrega,'&nbsp;')||'</td>');

              IF P_COUNT_DOC > 0 THEN
                 BEGIN

                   SELECT TO_CHAR(A.DCIN_DT_MNT,'DD/MM/RRRR') DCIN_DT_MNT
                     INTO P_DATA_MNT
                     FROM CACR_DOCUM_INSCR A
                    WHERE A.PRSE_CD   = P_PRSE_CD
                      AND A.REPS_SEQ  = P_REPS_SEQ
                      AND A.FICH_NR_INSCRICAO = replace(p_inscricao,',','')
                      and a.docm_cod = doc.docm_cod;

                    EXCEPTION
                    when others then
                         P_DATA_MNT := NULL;
                    END;

                 htp.p('<td align=center>'||nvl(P_DATA_MNT,'&nbsp;')||'</td>');

              END IF;

              htp.p('</tr>');

     end loop;
     close doctos;

            htp.p('</table><br>

            <center><b>A entrega da documentação só será confirmada após a sua análise.</b><br><br><input type=button value="   Fechar   " onclick="javascript:window.close();"></center>');

   end;

end;
/
