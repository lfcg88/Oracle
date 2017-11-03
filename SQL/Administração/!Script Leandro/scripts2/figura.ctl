load data


infile '/mnt/hd_c/tst_migra_161210/tb_figura_aleatoria.txt'
insert
continueif last preserve != '|'
into table TB_FIGURA_ALEATORIA

fields terminated by '|' optionally enclosed by '"' trailing nullcols 
NM_FIGURA     VARCHAR2(20),
IM_FIGURA     BLOB,
QT_BYTEFIGURA NUMBER(38))

