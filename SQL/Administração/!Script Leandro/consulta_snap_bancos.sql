Prompt ###############################################
Prompt #                                             #
Prompt #              SNAP MASTER BANCOS             #
Prompt #               EM TODAS AS BASES             #
Prompt #                                             #
Prompt ###############################################


ACCEPT SENHA CHAR PROMPT 'Digite a senha do SYSTEM:' HIDE
SET LINESIZE 500


conn system/&senha@mia0
@onde
select owner, name, master, master_view, master_owner, master, master_link from dba_snapshots where master like '%ITEM_VENDA_ABC%'
/

conn system/&senha@mia2
@onde
select owner, name, master, master_view, master_owner, master, master_link from dba_snapshots where master like '%ITEM_VENDA_ABC%'
/

conn system/&senha@mia1
@onde
select owner, name, master, master_view, master_owner, master, master_link from dba_snapshots where master like '%ITEM_VENDA_ABC%'
/

conn system/&senha@rjd20
@onde
select owner, name, master, master_view, master_owner, master, master_link from dba_snapshots where master like '%ITEM_VENDA_ABC%'
/

conn system/&senha@bhd1
@onde
select owner, name, master, master_view, master_owner, master, master_link from dba_snapshots where master like '%ITEM_VENDA_ABC%'
/

conn system/&senha@dftpux01
@onde
select owner, name, master, master_view, master_owner, master, master_link from dba_snapshots where master like '%ITEM_VENDA_ABC%'
/

conn system/&senha@fzd0
@onde
select owner, name, master, master_view, master_owner, master, master_link from dba_snapshots where master like '%ITEM_VENDA_ABC%'
/

conn system/&senha@rjd12
@onde
select owner, name, master, master_view, master_owner, master, master_link from dba_snapshots where master like '%ITEM_VENDA_ABC%'
/

conn system/&senha@rjd13
@onde
select owner, name, master, master_view, master_owner, master, master_link from dba_snapshots where master like '%ITEM_VENDA_ABC%'
/

conn system/&senha@rjd19
@onde
select owner, name, master, master_view, master_owner, master, master_link from dba_snapshots where master like '%ITEM_VENDA_ABC%'
/

conn system/&senha@rjd6
@onde
select owner, name, master, master_view, master_owner, master, master_link from dba_snapshots where master like '%ITEM_VENDA_ABC%'
/

conn system/&senha@fld0
@onde
select owner, name, master, master_view, master_owner, master, master_link from dba_snapshots where master like '%ITEM_VENDA_ABC%'
/

conn system/&senha@ped0
@onde
select owner, name, master, master_view, master_owner, master, master_link from dba_snapshots where master like '%ITEM_VENDA_ABC%'
/

conn system/&senha@rjd10
@onde
select owner, name, master, master_view, master_owner, master, master_link from dba_snapshots where master like '%ITEM_VENDA_ABC%'
/

conn system/&senha@rjd11
@onde
select owner, name, master, master_view, master_owner, master, master_link from dba_snapshots where master like '%ITEM_VENDA_ABC%'
/

conn system/&senha@rjd14
@onde
select owner, name, master, master_view, master_owner, master, master_link from dba_snapshots where master like '%ITEM_VENDA_ABC%'
/

conn system/&senha@bod0
@onde
select owner, name, master, master_view, master_owner, master, master_link from dba_snapshots where master like '%ITEM_VENDA_ABC%'
/

conn system/&senha@dif02
@onde
select owner, name, master, master_view, master_owner, master, master_link from dba_snapshots where master like '%ITEM_VENDA_ABC%'
/

conn system/&senha@dif01
@onde
select owner, name, master, master_view, master_owner, master, master_link from dba_snapshots where master like '%ITEM_VENDA_ABC%'
/

conn system/&senha@rsd0
@onde
select owner, name, master, master_view, master_owner, master, master_link from dba_snapshots where master like '%ITEM_VENDA_ABC%'
/

conn system/&senha@rjd5
@onde
select owner, name, master, master_view, master_owner, master, master_link from dba_snapshots where master like '%ITEM_VENDA_ABC%'
/

conn system/&senha@rjd9
@onde
select owner, name, master, master_view, master_owner, master, master_link from dba_snapshots where master like '%ITEM_VENDA_ABC%'
/

conn system/&senha@dfd0
@onde
select owner, name, master, master_view, master_owner, master, master_link from dba_snapshots where master like '%ITEM_VENDA_ABC%'
/

conn system/&senha@rjd3
@onde
select owner, name, master, master_view, master_owner, master, master_link from dba_snapshots where master like '%ITEM_VENDA_ABC%'
/

conn system/&senha@spd1
@onde
select owner, name, master, master_view, master_owner, master, master_link from dba_snapshots where master like '%ITEM_VENDA_ABC%'
/

conn system/&senha@bad0
@onde
select owner, name, master, master_view, master_owner, master, master_link from dba_snapshots where master like '%ITEM_VENDA_ABC%'
/






