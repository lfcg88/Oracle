create or replace function sgpb_proc.SGPB0084
	(
	  pPeriodicidade      IN NUMBER,
    pCompetencia        IN NUMBER
	)
	return NUMBER
IS
	vRetorno  number := 0;
  i         number := 0;
  vMes      number(2);
BEGIN
  --  200605 - 200600 = 05
  vMes := pCompetencia - trunc(pCompetencia/100)*100;
  --
  BEGIN
    --
    while i <= 12
    loop
      --
      i := i + pPeriodicidade;
      --
      if vMes = i then
        vRetorno := 1;
        exit;
      end if;
      --
    end loop;
    --
  EXCEPTION
    WHEN OTHERS THEN
      --
      vRetorno := 0;
      --
  END;
  --
  --
  RETURN vRetorno;
  --
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    RAISE;
    --
END SGPB0084;
/

