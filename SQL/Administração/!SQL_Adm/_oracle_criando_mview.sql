ODSPRD - RECRIADO - EXISTENTE
ODSSTG - PDBQAS - USER ODSUPDT PDBQAS_112 --> fazer refresh nas filas - EXISTENTE
PSPRD - NOVO -- 
PSSTG - NOVO -- 



--criar o mview log no banco origem (ARIBAPDB)

CREATE MATERIALIZED VIEW LOG ON CADADMIN.EMPRESA_COMPLEMENTO
TABLESPACE MLOG_DAT
WITH PRIMARY KEY EXCLUDING NEW VALUES;

--grant de select na tabela e select, insert, update e delete no log no banco de origem para o usuario do dblink (ARIBAPDB - usuario ODSUPDT)

GRANT INSERT, UPDATE, DELETE ON CADADMIN.MLOG$_EMPRESA_COMPLEMENTO TO ROLE_ODSUPDT_WRITE;
GRANT SELECT ON CADADMIN.MLOG$_EMPRESA_COMPLEMENTO TO ROLE_ODSUPDT_READ;
GRANT SELECT ON CADADMIN.EMPRESA_COMPLEMENTO TO ROLE_ODSUPDT_READ;



--mview (ODSPRD)

CREATE MATERILIZED VIEW CADADMIN.EMPRESA_COMPLEMENTO (pessoa_id, dat_alteracao, telefone, email, data_criacao, fk_contato_comercial_id, codigo_erp, ddd_fixo, status_erp, cadastro_id, nome_fantasia, razao_social, razao_social_altern, num_cnpj, tipo_fornecedor, cod_tipo_empresa)
TABLESPACE "CADADMIN_S_DAT"
USING INDEX TABLESPACE "CADADMIN_S_IDX"
REFRESH FORCE ON DEMAND
AS
select pessoa_id,
       dat_alteracao,
       telefone,
       email,
       data_criacao,
       fk_contato_comercial_id,
       codigo_erp,
       ddd_fixo,
       status_erp,
       cadastro_id,
       nome_fantasia,
       razao_social,
       razao_social_altern,
       num_cnpj,
       tipo_fornecedor,
       cod_tipo_empresa
  from cadadmin.empresa_complemento@cw;
COMMENT ON MATERIALIZED VIEW "CADADMIN"."EMPRESA_COMPLEMENTO"
IS
  'snapshot table for snapshot CADADMIN.EMPRESA_COMPLEMENTO';




-- grant de select no banco destino
GRANT SELECT on CADADMIN.EMPRESA_COMPLEMENTO TO ROLE_CADADMIN_READ;









GRUPO REFRESH

PSPRD -> CW -> PDBPRD - USER PS8UPDT
PSSGT -> CW -> PDBQAS - USER PS8UPDT ->


ALTER PUBLIC DATABASE LINK 'CW'
  CONNECT TO 'ODSUPDT' IDENTIFIED BY '053FB7F26AF58C3667270A5BDB9B275FED' USING 'PDBQAS_112';






CREATE MATERILIZED VIEW CADADMIN.CADASTRO (pessoa_id, dat_alteracao, telefone, email, data_criacao, fk_contato_comercial_id, codigo_erp, ddd_fixo, status_erp, cadastro_id, nome_fantasia, razao_social, razao_social_altern, num_cnpj, tipo_fornecedor, cod_tipo_empresa)
TABLESPACE "CADADMIN_S_DAT"
USING INDEX TABLESPACE "CADADMIN_S_IDX"
REFRESH FORCE ON DEMAND
AS

select cadastro_id, produto_id, pessoa_id
  from cadadmin.cadastro@cw; 




SEGUNDA MW


ODSPRD - EXISTENTE - RECRIADO
ODSSTG - NOVO - CRIADO
PSPRD - EXISTENTE --  RECRIADO
PSSTG - EXISTENTE -- RECRIADO


CREATE MATERIALIZED VIEW LOG ON CADADMIN.CADASTRO
TABLESPACE MLOG_DAT
WITH PRIMARY KEY EXCLUDING NEW VALUES;



GRANT INSERT, UPDATE, DELETE ON CADADMIN.MLOG$_CADASTRO TO ROLE_ODSUPDT_WRITE;
GRANT SELECT ON CADADMIN.MLOG$_CADASTRO TO ROLE_ODSUPDT_READ;
GRANT SELECT ON CADADMIN.CADASTRO TO ROLE_ODSUPDT_READ;



CREATE MATERILIZED VIEW CADADMIN.CADASTRO (cadastro_id, produto_id, pessoa_id)
TABLESPACE "CADADMIN_S_DAT"
USING INDEX TABLESPACE "CADADMIN_S_IDX"
REFRESH FORCE ON DEMAND
AS
select cadastro_id, produto_id, pessoa_id
  from cadadmin.cadastro@cw; 


-- STG -- TABLESPACE "ODS_TBS_01" USING INDEX TABLESPACE "ODS_IDX_01"


GRANT SELECT on CADADMIN.EMPRESA_COMPLEMENTO TO ROLE_CADADMIN_READ;



PESQUISAR GRUPOS DE REPLICAÇÃO E INCLUIR OS NOVOS
FORÇAR NO ODSSTG REFRESH DAS MVIEWS

ODSPRD - ADICIONADO AO GRUPO DE REFRESH GRUPO_01
ODSSTG - ADICIONADO AO GRUPO DE REFRESH GRUPO_01
PSPRD -  ADICIONADO AO GRUPO DE REFRESH GRUPO_01
PSSTG - NÃO POSSUI NENHUM GRUPO DE REFRESH

BEGIN
DBMS_REFRESH.ADD (
NAME => '"CADADMIN"."GRUPO_01"', 
LIST => '"CADADMIN"."CADASTRO"',
lax => TRUE);
END;
/
BEGIN
DBMS_REFRESH.ADD (
NAME => '"CADADMIN"."GRUPO_01"', 
LIST => '"CADADMIN"."EMPRESA_COMPLEMENTO"',
lax => TRUE);
END;

begin
DBMS_REFRESH.REFRESH (name => '"CADADMIN"."GRUPO_01"');
end;