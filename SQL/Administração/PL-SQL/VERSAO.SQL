prompt PL/SQL Developer import file
prompt Created on quinta-feira, 3 de setembro de 2009 by Vilardo
set feedback off
set define off
prompt Creating VERSAO...
create table VERSAO
(
  ID                 NUMBER(11) not null,
  VERSAO             VARCHAR2(255) not null,
  BETA               VARCHAR2(255),
  TIPO               CHAR(1),
  STATUS             CHAR(1),
  DATA_PLANEJADA     DATE,
  DATA_HORA_LIBERADA DATE,
  INCLUIDO_EM        DATE not null,
  INCLUIDO_POR       VARCHAR2(60) not null,
  ALTERADO_EM        DATE not null,
  ALTERADO_POR       VARCHAR2(60) not null,
  DELETED            CHAR(1) default '0' not null
)
tablespace USERS
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
alter table VERSAO
  add constraint VERSAO_PK primary key (ID)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
alter table VERSAO
  add constraint VERSAO_AK1 unique (VERSAO)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );

prompt Creating VERSAO_ITEM...
create table VERSAO_ITEM
(
  ID              NUMBER(11) not null,
  VERSAO_ID       NUMBER(11) not null,
  TIPO_ITEM       CHAR(1),
  ITEM            VARCHAR2(255) not null,
  TIPO_REG        CHAR(1),
  INCLUIDO_EM     DATE,
  INCLUIDO_POR    VARCHAR2(60),
  ALTERADO_EM     DATE,
  ALTERADO_POR    VARCHAR2(60),
  NOME_ITEM       VARCHAR2(255),
  DELETED         CHAR(1) default '0' not null,
  ID_ITEM_EXTERNO VARCHAR2(255)
)
tablespace USERS
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
alter table VERSAO_ITEM
  add constraint VERSAO_ITEM_PK primary key (ID)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
alter table VERSAO_ITEM
  add constraint VERSAO_ITEM_AK1 unique (VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );

prompt Disabling triggers for VERSAO...
alter table VERSAO disable all triggers;
prompt Disabling triggers for VERSAO_ITEM...
alter table VERSAO_ITEM disable all triggers;
prompt Loading VERSAO...
insert into VERSAO (ID, VERSAO, BETA, TIPO, STATUS, DATA_PLANEJADA, DATA_HORA_LIBERADA, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, DELETED)
values (113, 'net 08.82', 'f', 'V', 'L', to_date('13-10-2009', 'dd-mm-yyyy'), to_date('02-09-2009', 'dd-mm-yyyy'), to_date('27-08-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', '0');
commit;
prompt 1 records loaded
prompt Loading VERSAO_ITEM...
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1756, 113, 'B', '5314', 'P', to_date('02-09-2009', 'dd-mm-yyyy'), 'Edmundo', to_date('02-09-2009', 'dd-mm-yyyy'), 'Edmundo', 'Q2582.2 - Av. Conform. Planejamento Inicial - Estrutura Analítica do Projeto', '0', '5314');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1757, 113, 'P', '2611.14', 'P', to_date('02-09-2009', 'dd-mm-yyyy'), 'Edmundo', to_date('02-09-2009', 'dd-mm-yyyy'), 'Edmundo', 'Migração dos Processos Utilizados no POC', '0', 'ca346459-be4e-a565-1fd2-49db95177b79');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1759, 113, 'B', '14994', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'Diário Geral - Base Diária - Data Contábil', '0', '14994');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1760, 113, 'B', '15184', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'Navegador de Aluguel de Ações - Help Português', '0', '15184');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1761, 113, 'B', '15386', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'CDA 3.0 x Emissão anterior a data limite reabertura', '0', '15386');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1762, 113, 'B', '15665', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'Cadastro de Ativo Externo - Papel Privado', '0', '15665');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1763, 113, 'B', '15836', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'Relatório Previsão de Fluxo de Caixa x Flag -Mostra Swap-', '0', '15836');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1764, 113, 'B', '15852', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'Performance do Apropriação de Aluguel de Ações BDia x BOpe', '0', '15852');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1765, 113, 'B', '15865', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'Extrato Mensal - Layout (Fontes diferentes )', '0', '15865');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1766, 113, 'B', '15923', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'Operação a Termo x Regime de Caixa', '0', '15923');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1767, 113, 'B', '15924', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'Navegador de Ativos Ocultos CDA x Busca por Lista', '0', '15924');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1768, 113, 'B', '15947', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'CDA 3.0 x Totalizador do Relatório', '0', '15947');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1769, 113, 'B', '15955', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'Navegador de rentabilidade por cota - Títulos de passivo apresenta patrimônio', '0', '15955');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1770, 113, 'B', '15970', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'DNP - Relatorio gerado por lista não apresenta todos os meses e duplica', '0', '15970');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1771, 113, 'B', '15973', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'C5598: CDA - Opções flexiveis', '0', '15973');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1772, 113, 'B', '15987', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'C5586: Movimentação Consolidada de Cotistas x Resgate Total', '0', '15987');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1773, 113, 'B', '15995', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'C5319 - Relatório Divergência Não Planejada x Acumulado em 12 meses', '0', '15995');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1774, 113, 'B', '16030', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'PETROS - uso excessivo da tablespace temporário durante processo de Segregação de Planos (P0711)', '0', '16030');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1775, 113, 'B', '16044', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'C5606 - Cadastro Série Carteira - Carteira Espelho CA', '0', '16044');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1776, 113, 'B', '16054', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'Mapa de Conferência de Índices / Cotações - Ora x WebSphere - HTTP {Ricardo: (SQL e Oracle)}', '0', '16054');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1777, 113, 'B', '16056', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'Cliente ELITE - DirveAMnet - Rateio de Corretagem (P0273) não compatível com MSSQL2008', '0', '16056');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1778, 113, 'B', '16059', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'Recuperação da Base Diária x Reabertura de Carteira - ERRO (Oracle x SQL) {Ricardo: (SQL e Oracle)}', '0', '16059');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1779, 113, 'B', '16093', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'Navegador de rentabilidade por cota - Provisão e liquidação de proventos - MANUAL', '0', '16093');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1780, 113, 'B', '16098', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'Navegador de Modelo Contábil - Alteração (Feito e Conferido) - {Ricardo: SQL e Oracle}', '0', '16098');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1781, 113, 'B', '16119', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'Carteira de simulação traz o flag de Operações Comuns marcada', '0', '16119');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1782, 113, 'B', '16130', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'Central de Cotista - Mensagem errada', '0', '16130');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1783, 113, 'B', '16131', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'Cadastro de Índices - ORA x Websphere', '0', '16131');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1784, 113, 'B', '16137', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'Exportação XML ANBID - Campo codcntcor - CT27', '0', '16137');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1785, 113, 'B', '16141', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'Relatório de Informe de Rendimentos PF - Oracle - CT30', '0', '16141');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1786, 113, 'B', '16149', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'Enquadramento Fundação - Filtro de Regra: Apresenta Totais Zerados', '0', '16149');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1787, 113, 'B', '16155', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'Erro na volta do Cadastro de Séries - Oracle', '0', '16155');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1788, 113, 'B', '16162', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'Cadastro de Modelo de Classificação SWAP - Clonagem', '0', '16162');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1789, 113, 'B', '16171', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'Importação de Carteira (Formato XML ANBID) x Emprestimo de Ações', '0', '16171');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1790, 113, 'B', '16176', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'Relatorio Posição de Carteira Externa - Carteira Adm - percentual com duas decimais', '0', '16176');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1791, 113, 'B', '16190', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'Cadastro de Usuário - Expiração de Senha DriveAMnet', '0', '16190');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1792, 113, 'B', '16199', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'Exportação Tipo P: Consolidação de movimentos de Empréstimo de Ações', '0', '16199');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1793, 113, 'B', '16216', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'Importação de Indices', '0', '16216');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1794, 113, 'B', '16218', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'C5669 - Importação de Boletas SELIC - Nova tag', '0', '16218');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1795, 113, 'B', '16257', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'Navegador de Renda Fixa - Erro no Log do Jboss', '0', '16257');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1796, 113, 'B', '16263', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'Cadastro de Banco - Exclusão x WebSphere', '0', '16263');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1797, 113, 'B', '16287', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'Cadastros de  Modelo Contábil Default por Carteira - Erro no Log _ Ora x WebSphere', '0', '16287');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1798, 113, 'B', '16301', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'Movimentação de Renda Variável - Erro no log do WebSphere', '0', '16301');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1799, 113, 'C', '4370', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'PETROS - Implantação', '0', 'cacd5555-0fa6-c0ab-de34-484d91db3646');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1800, 113, 'C', '5319', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'Relatório Divergência Não Planejada x Desvio Padrão', '0', '1cf7e251-c4fb-d1bb-7779-49f9a9ded61e');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1801, 113, 'C', '5586', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'MR2 do P3627 - Exportação de Movimentação de Cotista Citibank x Western', '0', '18268d33-e5be-94c6-7018-4a71c7498318');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1802, 113, 'C', '5598', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'B15973 - CDA - Opções flexiveis', '0', '91ac8363-6c20-48a7-e47a-4a80246d66d4');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1803, 113, 'C', '5606', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'B16044 - Cadastro Série Carteira', '0', '65d569aa-fd2a-52b6-c068-4a831016291c');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1804, 113, 'C', '5656', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'Posição de Carteira C x Layout CSV por lista', '0', '17b96c11-a696-213e-8f98-4a8dc00947b8');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1805, 113, 'C', '5669', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'Alteração de lay-out de operações definitivas Selic', '0', 'b007f7e3-dd78-0fa7-feb1-4a941e4b36ff');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1806, 113, 'M', '14228', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'Cadastro Gerência de Fundos', '0', '14228');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1807, 113, 'M', '15992', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'Boletagem de Cotista via Central de Carteira', '0', '15992');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1808, 113, 'M', '16068', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'Relatório Posição de Proventos de RV (Flag "Apenas a Liquidar") x Base Diária sem Posição em D0', '0', '16068');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1809, 113, 'M', '16237', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'C5656 - Salvar Como CSV por lista', '0', '16237');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1810, 113, 'M', '16299', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'Alteração na versão do layout dos arquivos CFEN e CENR', '0', '16299');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1811, 113, 'P', '2611.14', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'Migração dos Processos Utilizados no POC', '0', 'ca346459-be4e-a565-1fd2-49db95177b79');
insert into VERSAO_ITEM (ID, VERSAO_ID, TIPO_ITEM, ITEM, TIPO_REG, INCLUIDO_EM, INCLUIDO_POR, ALTERADO_EM, ALTERADO_POR, NOME_ITEM, DELETED, ID_ITEM_EXTERNO)
values (1812, 113, 'P', '5314', 'L', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', to_date('02-09-2009', 'dd-mm-yyyy'), 'usraut', 'Automação dos Processos de Centralização Financeira', '0', '2e03ea1f-f833-bc3a-63f3-49f227857529');
commit;
prompt 56 records loaded
prompt Enabling triggers for VERSAO...
alter table VERSAO enable all triggers;
prompt Enabling triggers for VERSAO_ITEM...
alter table VERSAO_ITEM enable all triggers;
set feedback on
set define on
prompt Done.
