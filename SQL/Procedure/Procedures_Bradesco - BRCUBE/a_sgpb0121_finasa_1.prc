create or replace procedure sgpb_proc.A_SGPB0121_FINASA_1 is
  DIA DECIMAL(8) := 20060100;
begin


  DIA := 20060400;

  for i in 1 .. 9 loop begin
    pc_util_01.Sgpb0028('Início data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121_1'); commit;
    SGPB0121(TO_DATE(DIA + I, 'YYYYMMDD'), pc_util_01.Finasa,'SGPB0121_1');
    pc_util_01.Sgpb0028('fim data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121_1'); commit;
    exception
      when others then
        pc_util_01.Sgpb0028('EEERRRROOOO data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121_1'); commit;
      end;
  end loop;

  for i in 11 .. 30 loop begin
    pc_util_01.Sgpb0028('Início data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121_1'); commit;
    SGPB0121(TO_DATE(DIA + I, 'YYYYMMDD'), pc_util_01.Finasa,'SGPB0121_1');
    pc_util_01.Sgpb0028('fim data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121_1'); commit;
    exception
      when others then
        pc_util_01.Sgpb0028('EEERRRROOOO data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121_1'); commit;
      end;
  end loop;


  DIA := 20060500;

  for i in 1 .. 28 loop begin
    pc_util_01.Sgpb0028('Início data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121_1'); commit;
    SGPB0121(TO_DATE(DIA + I, 'YYYYMMDD'), pc_util_01.Finasa,'SGPB0121_1');
    pc_util_01.Sgpb0028('fim data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121_1'); commit;
    exception
      when others then
        pc_util_01.Sgpb0028('EEERRRROOOO data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121_1'); commit;
      end;
  end loop;

end A_SGPB0121_FINASA_1;
/

