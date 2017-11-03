create tablespace DW_COMPRAS_S_DAT
datafile '+DG_ODS_STG/odsstg/dw_compras_s_dat_01.dbf'
size 10M
autoextend on

create tablespace DW_COMPRAS_S_IDX
datafile '+DG_ODS_STG/odsstg/dw_compras_s_idx_01.dbf'
size 10M
autoextend on

create user DWCOMPRAS
identified by dwcompras
default tablespace DW_COMPRAS_S_DAT
quota unlimited on DW_COMPRAS_S_DAT
quota unlimited on DW_COMPRAS_S_IDX


create role ROLE_DWCOMPRAS_READ;
create role ROLE_DWCOMPRAS_WRITE;