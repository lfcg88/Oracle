




CREATE OR REPLACE
procedure OWNBMP.Expurgo_Coletado_Header ( cod_erro in out varchar2 ,mens_erro in out varchar2,	limite_reg integer )
as
--
begin
  loop
	delete from ebt_cdr_coletado_header where bilhetador like 'z%' and rownum < limite_reg;
	exit when sql%rowcount = 0;
	commit;
  end loop;
exception
   when others then
	cod_erro  := sqlcode;
	mens_erro := substr(sqlerrm,1,100);
end;
/

