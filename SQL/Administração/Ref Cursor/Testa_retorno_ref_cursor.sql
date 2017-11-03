DECLARE
TYPE CURSOR_TYPE_1 IS REF CURSOR;
v_cursor_cart_emit CURSOR_TYPE_1;

TYPE CURSOR_RETORNO IS RECORD (
  v_NR_PEDIDO IDT_PEDIDO.NR_PEDIDO%TYPE,
  v_NR_RG_ATRIB CIV_IDENT_CIVIL.nr_rg_atrib%TYPE,
  V_NM_IDENT IDT_IDENT.NM_IDENT%TYPE, 
  V_DT_FIM DATE,
  V_CD_OS WFL_OS.cd_os%TYPE,
  V_DS_TP_PEDIDO IDT_TP_PEDIDO.ds_tp_pedido%TYPE,
  V_NM_POSTO CIV_POSTO_IDENT.nm_posto%TYPE,
  V_NR_ESPELH CIV_ESPELH.nr_espelh%TYPE
  );
  
  LINHA_CURSOR CURSOR_RETORNO;

BEGIN

-- Now call the stored program
  civ.pkg_civ.sp_civ_lista_cart_emit(NULL,NULL,NULL,v_cursor_cart_emit);

LOOP
fetch v_cursor_cart_emit into LINHA_CURSOR;

exit when v_cursor_cart_emit%notfound;

dbms_output.put_line ('PEDIDO = ' || to_char (LINHA_CURSOR.v_nr_pedido) ||  ', ESPELHO = ' || TO_CHAR(LINHA_CURSOR.V_NR_ESPELH));

end loop; 


EXCEPTION
WHEN OTHERS THEN
  dbms_output.put_line(SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1, 255));
RAISE;
END;
