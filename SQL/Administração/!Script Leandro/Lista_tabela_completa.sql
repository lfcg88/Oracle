Accept wrk_nome_obj prompt "Digite o Owner.Tabela : "
set heading off verify off feedback off pages 0 lines 200 trims on
set serveroutput on 
declare
--
  wtable varchar2(150) := substr('&wrk_nome_obj',instr('&wrk_nome_obj','.',1,1)+1);
  wuser  varchar2(100) := substr('&wrk_nome_obj',1,instr('&wrk_nome_obj','.',1,1)-1);
--
  wcount number := 0;
  wconstraint_name  varchar2(50);
--
  /*  Tables */
  cursor ctabs is 
     select table_name
          , owner
          , tablespace_name
          , initial_extent/1024 initial_extent
          , pct_free
          , ini_trans
          , next_extent/1024 next_extent
          , pct_increase
          , pct_used
          , max_trans
          , min_extents
          , max_extents
       from all_tables 
      where owner like upper(wuser)
        And table_name like upper(wtable);
--
  /* Table Columns */
  cursor ccols (o in varchar2, t in varchar2) is 
     select decode( column_id,1,'(',',')
            ||rpad( column_name,40)
            ||rpad( data_type,10)
            ||rpad( decode(data_type,'DATE'    ,' '
                                    ,'LONG'    ,' '
                                    ,'LONG RAW',' '
                                    ,'RAW'     ,decode(data_length,null,null
                                               ,'('||data_length||')')
                                    ,'CHAR'    ,decode(data_length,null,null
                                               ,'('||data_length||')')
                                    ,'VARCHAR' ,decode(data_length,null,null
                                               ,'('||data_length||')')
                                    ,'VARCHAR2',decode(data_length,null,null
                                               ,'('||data_length||')')
                                    ,'NUMBER'  ,decode(data_precision,null,'   '
                                               ,'('||data_precision||
                                                decode(data_scale,null,null,','
                                                ||data_scale)||')'),'unknown'),8,' ')
            ||decode(NULLABLE,'N',' NOT NULL','') cstr
       from all_tab_columns
      where table_name = upper(t)
        and owner = upper(o)
      order by column_id;
--
  /* Primary Key */
  cursor cpkey is 
     select 'alter table '||con.owner||'.'||con.TABLE_NAME||chr(10)||
            '  add constraint '||con.CONSTRAINT_NAME||' primary key ' const_01
          , '  )'||chr(10)||
            '  using index '||chr(10)||
            '  tablespace '||idx.tablespace_name||chr(10)||
            '  pctfree '|| idx.pct_free||chr(10)||
            '  initrans '||idx.ini_trans||chr(10)||
            '  maxtrans '||idx.max_trans||chr(10)||
            '  storage ('||chr(10)||
            '    initial '||idx.initial_extent/1024||'K'||chr(10)||
            '    next '||idx.next_extent/1024||'K'||chr(10)||
            '    minextents '||idx.min_extents||chr(10)||
            '    maxextents '||idx.max_extents||chr(10)||
            '    pctincrease '||idx.pct_increase||');' const_02
          , constraint_name
       from all_constraints con
          , all_indexes     idx
      where con.owner           = idx.owner
        And con.table_name      = idx.table_name
        And con.constraint_name = idx.index_name
        And con.owner           = wuser
        And con.table_name      = wtable
        And con.constraint_type = 'P';
--
  /* Constraints Columns */
  cursor cconstcols(par_constraint_name varchar2) is 
     Select decode(position,'1','( ',', ')||ccol.column_name const_column
       From all_cons_columns ccol
      Where ccol.owner = wuser
        And ccol.table_name = wtable
        And ccol.constraint_name = par_constraint_name
      order by position;
--
  /* Indexes */
  Cursor cind(par_constraint_name varchar2) is
     Select owner
          , table_owner
          , table_name
          , index_name
          , ini_trans
          , max_trans
          , tablespace_name
          , initial_extent/1024 initial_extent
          , next_extent/1024 next_extent
          , min_extents
          , max_extents
          , pct_increase
          , decode(uniqueness,'UNIQUE','UNIQUE') unq
       From dba_indexes
      Where table_owner = wuser
        And table_name  = wtable
        And index_name <> par_constraint_name;
--
  /* Index columns */
  Cursor ccol (o in varchar2, t in varchar2, i in varchar2) is
     Select decode(column_position,1,'(',',')||
            rpad(column_name,40) cl
       from dba_ind_columns
      where table_name = upper(t) 
        And index_name = upper(i) 
        And index_owner = upper(o)
      order by column_position;
--
Begin
 dbms_output.enable(999999);
   For rtabs in ctabs loop
     wcount := wcount + 1;
     dbms_output.put_line('create table ' || rtabs.owner || '.' || rtabs.table_name);
     For rcols  in ccols (rtabs.owner, rtabs.table_name) Loop
       dbms_output.put_line(rcols.cstr);
     End Loop;
     dbms_output.put_line(') pctfree ' || rtabs.pct_free || ' pctused ' || rtabs.pct_used);
     dbms_output.put_line('initrans ' || rtabs.ini_trans || ' maxtrans ' || rtabs.max_trans);
     dbms_output.put_line('tablespace ' || rtabs.tablespace_name);
     dbms_output.put_line('storage (initial ' || nvl(rtabs.initial_extent,128) || 'K next ' || nvl(rtabs.next_extent,128) || 'K pctincrease ' || rtabs.pct_increase);
     dbms_output.put_line('minextents ' || rtabs.min_extents || ' maxextents ' || rtabs.max_extents || ' )');
     dbms_output.put_line('/');
   End loop;
   If wcount = 0 Then
     dbms_output.put_line('******************************************************');
     dbms_output.put_line('*                                                    *');
     dbms_output.put_line('* Plese Verify Input Parameters... No Matches Found! *');
     dbms_output.put_line('*                                                    *');
     dbms_output.put_line('******************************************************');
   End if;
--
   For rpkey in cpkey Loop
     dbms_output.put_line(rpkey.const_01);
       For rcconstcols in cconstcols(rpkey.constraint_name) Loop
         dbms_output.put_line(rcconstcols.const_column);
       End Loop;
     dbms_output.put_line(rpkey.const_02);
     wconstraint_name := rpkey.constraint_name;
   End Loop;
--
   wcount := 0;
   For rind in cind(wconstraint_name) loop
     wcount := wcount + 1;
     dbms_output.put_line('------------------ '||wcount||'º INDICE  -------------------');
     dbms_output.put_line('Create '||rind.unq||' index '|| rind.owner || '.' || rind.index_name);
     dbms_output.put_line(' on  '||rind.table_owner||'.'|| rind.table_name);
     for rcol in ccol (rind.owner, rind.table_name, rind.index_name) loop
       dbms_output.put_line(rcol.cl);
     end loop;
     dbms_output.put_line(')');
     dbms_output.put_line(' initrans ' || rind.ini_trans );
     dbms_output.put_line(' maxtrans ' || rind.max_trans);
     dbms_output.put_line('tablespace ' || rind.tablespace_name);
     dbms_output.put_line('storage (');
     dbms_output.put_line('initial ' || rind.initial_extent || 'K ');
     dbms_output.put_line('next ' || rind.next_extent || 'K ');
     dbms_output.put_line('pctincrease ' || rind.pct_increase);
     dbms_output.put_line('minextents ' || rind.min_extents );
     dbms_output.put_line('maxextents '|| rind.max_extents || ' )');
     dbms_output.put_line('/');
   End loop;
--
End;
/

set feedback on verify on pages 999

