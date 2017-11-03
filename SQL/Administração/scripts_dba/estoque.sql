set serveroutput on size 1000000

declare

west   number(20);
wres   number(20);
wdisp  number(20);
wind   varchar2(20);
wcod   number(20);

begin

sho_reservas_pkg.SHO_PROC_OBTER_ESTOQUE(46,&Codigo,west,wres,wdisp,wind,wcod);

dbms_output.put_line('Estoque: '||TO_CHAR(west)||'  Reserva: '||TO_CHAR(wres)||'  Disponivel: '||TO_CHAR(wdisp)||'  Status: '||wind||'      '||TO_CHAR(wcod));


end;
/