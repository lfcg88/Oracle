set serverout on 
set feedback off
set lines 1000
set buffer 99999
declare 
  Cursor c1 is
      select a.owner || '.' || a.name  Nome_Snapshot,
           a.rowner || '.' || a.rname  Nome_Grupo,
           replace(UPPER(a.interval),
                   'SYSDATE',
                   'to_date(''' ||
                   to_char(c.last_date, 'dd/mm/yyyy hh24:mi:ss') ||
                   ''',''dd/mm/yyyy hh24:mi:ss'')') next_date_gerado,
           decode(a.broken,'Y','Sim',a.broken)      Broken,
           c.last_date                 Ult_Execucao,
           a.next_date                 Prox_Execucao,
           a.interval                  Intervalo,
           a.job                       Num_Job,
           round(c.total_time / 60, 0) Tempo
      from dba_refresh_children        a
         , dba_snapshots               b
         , dba_jobs                    c
     where a.owner    = b.owner
       And a.name     = b.name
       And a.job      = c.job
       And b.last_refresh > sysdate -10
     order by Nome_Grupo;

  wrk_sql      varchar2(500);
  wrk_return   date;
  wrk_count_prob number := 0;
  wrk_banco    varchar2(100);
  
begin
  dbms_output.enable(9999999);
  For r1 in C1 Loop

    wrk_sql:= 'Select '||r1.next_date_gerado||' From Dual';

    Execute Immediate wrk_sql into wrk_return;
    
       If R1.Prox_Execucao < (wrk_return-20/1440) Or 
          R1.Prox_Execucao > (wrk_return+20/1440) Then
         wrk_count_prob := wrk_count_prob + 1;

         If wrk_count_prob = 1 Then

           Select global_name
             Into wrk_banco
             From global_name;

           dbms_output.put_line('Nome do Banco: '||wrk_banco);
           dbms_output.put_line('.');
           dbms_output.put_line('.');

           dbms_output.put_line('.              Relatorio de Snapshots com problemas');
           dbms_output.put_line('.              ====================================');
           dbms_output.put_line('.');
           dbms_output.put_line('.');

dbms_output.put_line('Nome do Banco: '||to_char(wrk_return-20/1440, 'dd/mm/yyyy hh24:mi:ss'));

           dbms_output.put_line(rpad('Nome do Grupo',35,' ')||
                                rpad('Nome do Snapshot',35,' ')||
                                rpad('Broken',7,' ')||
                                rpad('Prox. Exec. Calculada',22,' ')||
                                rpad('Prox. Execucao',22,' ')||
                                rpad('Ult. Execucao',22,' ')||
                                rpad('Intervalo',30,' ')||
                                rpad('Num.Job',8,' ')||
                                rpad('Tempo(Min)',10,' '));
                           
            dbms_output.put_line(rpad('------',34,'-')||' '||
                                rpad('------',34,'-')||' '||
                                rpad('------',6,'-')||' '||
                                rpad('------',21,'-')||' '||
                                rpad('------',21,'-')||' '||
                                rpad('------',21,'-')||' '||
                                rpad('------',29,'-')||' '||
                                rpad('------',7,'-')||' '||
                                rpad('------',9,'-'));

         End If;


         dbms_output.put_line(rpad(R1.Nome_Grupo,35,' ')||
                              rpad(R1.nome_snapshot,35,' ')||
                              rpad(R1.Broken,7,' ')||
                              rpad(to_char(wrk_return,'dd/mm/yyyy hh24:mi:ss'),22,' ')||
                              rpad(to_char(R1.Prox_Execucao,'dd/mm/yyyy hh24:mi:ss'),22,' ')||
                              rpad(to_char(R1.Ult_Execucao,'dd/mm/yyyy hh24:mi:ss'),22,' ')||
                              rpad(R1.Intervalo,30,' ')||
                              rpad(R1.Num_Job,8,' ')||
                              rpad(R1.Tempo,10,' '));

       End If;


  
    
  End Loop;
  
  If wrk_count_prob  = 0 Then
    dbms_output.put_line('NAOENVIAREMAIL');
  Else
    dbms_output.put_line('.');
    dbms_output.put_line('.');
    dbms_output.put_line('Total de Snapshots com problema: '||wrk_count_prob);
  End If;
  
end;
/

