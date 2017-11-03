create or replace procedure sgpb_proc.A_SGPB0121_FINASA is
  DIA DECIMAL(8) := 20060700;
begin

  --M�s de Janeiro
 DIA := 20070100;
 for i in 19 .. 31 loop
    begin
      pc_util_01.Sgpb0028('In�cio data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121'); commit;
      SGPB0121(TO_DATE(DIA + I, 'YYYYMMDD'), pc_util_01.Finasa,'SGPB0121-Finasa');
      pc_util_01.Sgpb0028('fim data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121-Finasa'); commit;
    exception
      when others then
        pc_util_01.Sgpb0028('EEERRRROOOO data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121-Finasa'); commit;
      end;
  end loop;

  --M�s de Fevereiro
  DIA := 20070200;
  for i in 1 .. 22 loop
    begin
      pc_util_01.Sgpb0028('In�cio data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121'); commit;
      SGPB0121(TO_DATE(DIA + I, 'YYYYMMDD'), pc_util_01.Finasa,'SGPB0121-Finasa');
      pc_util_01.Sgpb0028('fim data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121-Finasa'); commit;
    exception
      when others then
        pc_util_01.Sgpb0028('EEERRRROOOO data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121-Finasa'); commit;
      end;
  end loop;
            /*
  --M�s de Agosto
  DIA := 20060800;
  for i in 1 .. 31 loop begin
    pc_util_01.Sgpb0028('In�cio data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121-Finasa'); commit;
    SGPB0121(TO_DATE(DIA + I, 'YYYYMMDD'), pc_util_01.Finasa,'SGPB0121-Finasa');
    pc_util_01.Sgpb0028('fim data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121-Finasa'); commit;
    exception
      when others then
        pc_util_01.Sgpb0028('EEERRRROOOO data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121-Finasa'); commit;
      end;
  end loop;
  
  --M�s de Setembro
  DIA := 20060900;
  for i in 1 .. 30 loop begin
    pc_util_01.Sgpb0028('In�cio data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121-Finasa'); commit;
    SGPB0121(TO_DATE(DIA + I, 'YYYYMMDD'), pc_util_01.Finasa,'SGPB0121-Finasa');
    pc_util_01.Sgpb0028('fim data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121-Finasa'); commit;
    exception
      when others then
        pc_util_01.Sgpb0028('EEERRRROOOO data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121-Finasa'); commit;
      end;
  end loop;

  --M�s de Outubro
  DIA := 20061000;
  for i in 1 .. 31 loop begin
    pc_util_01.Sgpb0028('In�cio data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121-Finasa'); commit;
    SGPB0121(TO_DATE(DIA + I, 'YYYYMMDD'), pc_util_01.Finasa,'SGPB0121-Finasa');
    pc_util_01.Sgpb0028('fim data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121-Finasa'); commit;
    exception
      when others then
        pc_util_01.Sgpb0028('EEERRRROOOO data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121-Finasa'); commit;
      end;
  end loop;

  --M�s de Novembro
  DIA := 20061100;
  for i in 1 .. 30 loop begin
    pc_util_01.Sgpb0028('In�cio data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121-Finasa'); commit;
    SGPB0121(TO_DATE(DIA + I, 'YYYYMMDD'), pc_util_01.Finasa,'SGPB0121-Finasa');
    pc_util_01.Sgpb0028('fim data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121-Finasa'); commit;
    exception
      when others then
        pc_util_01.Sgpb0028('EEERRRROOOO data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121-Finasa'); commit;
      end;
  end loop;


  --M�s de Dezembro
  DIA := 20061200;
  for i in 1 .. 31 loop begin
    pc_util_01.Sgpb0028('In�cio data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121-Finasa'); commit;

    SGPB0121(TO_DATE(DIA + I, 'YYYYMMDD'), pc_util_01.Finasa,'SGPB0121-Finasa');

    pc_util_01.Sgpb0028('fim data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121-Finasa'); commit;
    exception
      when others then
        pc_util_01.Sgpb0028('EEERRRROOOO data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121-Finasa'); commit;
      end;
  end loop;

  --M�s de Janeiro
  DIA := 20060100;
  for i in 1 .. 31 loop begin
    pc_util_01.Sgpb0028('In�cio data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121-Finasa'); commit;
    SGPB0121(TO_DATE(DIA + I, 'YYYYMMDD'), pc_util_01.Finasa,'SGPB0121-Finasa');
    pc_util_01.Sgpb0028('fim data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121-Finasa'); commit;
    exception
      when others then
        pc_util_01.Sgpb0028('EEERRRROOOO data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121-Finasa'); commit;
      end;
  end loop;

  --M�s de Fevereiro
  DIA := 20060200;
  for i in 1 .. 28 loop begin
    pc_util_01.Sgpb0028('In�cio data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121-Finasa'); commit;
    SGPB0121(TO_DATE(DIA + I, 'YYYYMMDD'), pc_util_01.Finasa,'SGPB0121-Finasa');
    pc_util_01.Sgpb0028('fim data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121-Finasa'); commit;
    exception
      when others then
        pc_util_01.Sgpb0028('EEERRRROOOO data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121-Finasa'); commit;
      end;
  end loop;

  --M�s de Mar�o
  DIA := 20060300;
  for i in 1 .. 31 loop begin
    pc_util_01.Sgpb0028('In�cio data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121-Finasa'); commit;
    SGPB0121(TO_DATE(DIA + I, 'YYYYMMDD'), pc_util_01.Finasa,'SGPB0121-Finasa');
    pc_util_01.Sgpb0028('fim data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121-Finasa'); commit;
    exception
      when others then
        pc_util_01.Sgpb0028('EEERRRROOOO data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121-Finasa'); commit;
      end;
  end loop;
  
    --M�s de Janeiro
  DIA := 20070100;
  for i in 1 .. 31 loop begin
    pc_util_01.Sgpb0028('In�cio data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121-Finasa'); commit;
    SGPB0121(TO_DATE(DIA + I, 'YYYYMMDD'), pc_util_01.Finasa,'SGPB0121-Finasa');
    pc_util_01.Sgpb0028('fim data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121-Finasa'); commit;
    exception
      when others then
        pc_util_01.Sgpb0028('EEERRRROOOO data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121-Finasa'); commit;
      end;
  end loop;

  --M�s de Abril
  DIA := 20060400;
  for i in 1 .. 30 loop begin
    pc_util_01.Sgpb0028('In�cio data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121-Finasa'); commit;
    SGPB0121(TO_DATE(DIA + I, 'YYYYMMDD'), pc_util_01.Finasa,'SGPB0121-Finasa');
    pc_util_01.Sgpb0028('fim data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121-Finasa'); commit;
    exception
      when others then
        pc_util_01.Sgpb0028('EEERRRROOOO data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121-Finasa'); commit;
      end;
  end loop;

  --M�s de Maio
  DIA := 20060500;
  for i in 1 .. 31 loop begin
    pc_util_01.Sgpb0028('In�cio data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121-Finasa'); commit;
    SGPB0121(TO_DATE(DIA + I, 'YYYYMMDD'), pc_util_01.Finasa,'SGPB0121-Finasa');
    pc_util_01.Sgpb0028('fim data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121-Finasa'); commit;
    exception
      when others then
        pc_util_01.Sgpb0028('EEERRRROOOO data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121-Finasa'); commit;
      end;
  end loop;
  
    --M�s de Junho
  DIA := 20070600;
  for i in 1 .. 31 loop begin
    pc_util_01.Sgpb0028('In�cio data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121-Finasa'); commit;
    SGPB0121(TO_DATE(DIA + I, 'YYYYMMDD'), pc_util_01.Finasa,'SGPB0121-Finasa');
    pc_util_01.Sgpb0028('fim data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121-Finasa'); commit;
    exception
      when others then
        pc_util_01.Sgpb0028('EEERRRROOOO data: '||to_char( DIA + I)||' hora '||to_char(current_timestamp), 'SGPB0121-Finasa'); commit;
      end;
  end loop;   
      */
end A_SGPB0121_FINASA;
/

