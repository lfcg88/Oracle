DECLARE 
--
--  bulk_errors   EXCEPTION; 
--  PRAGMA EXCEPTION_INIT (bulk_errors,  -24381); 
  TYPE nmb_varray IS VARRAY (50000000) OF NUMBER; 
  TYPE dts_varray IS VARRAY (50000000) OF DATE; 
  TYPE chr_varray IS VARRAY (50000000) OF VARCHAR2(4000); 
  TYPE char_varray IS VARRAY (50000000) OF CHAR(1); 
  V_account_key             chr_varray; 
  V_account_type            nmb_varray;
  v_ID_LINHA_TRANSACAO_SIA nmb_varray;                                          			
  v_ID_TRANSACAO_ESTOQUE_SIA nmb_varray;
  '';                                        			
  v_ID_ESTOQUE_SIA_VALOR nmb_varray;                                            			
  v_ID_ESTOQUE_SIA nmb_varray;                                               			
  v_VAL_FOB_DUFRY nmb_varray;                                                   			
  v_VAL_FOB_CONSIGNANTE nmb_varray;                                             			
  v_VAL_FRETE_DUFRY nmb_varray;                                                 			
  v_VAL_SEGURO_DUFRY nmb_varray;                                                			
  v_VAL_DESPESAS_DUFRY nmb_varray;                                              			
  v_VAL_ICMS_ST nmb_varray;                                                     			
  v_VAL_ICMS_ST_RET nmb_varray;                                                 			
  v_VAL_RECEITA nmb_varray;                                                     			
  v_VAL_II nmb_varray;                                                          			 
  v_VAL_PIS nmb_varray;                                                         			
  v_VAL_COFINS nmb_varray;                                                      			
   '';
  v_NUM_FAT_COMPLEM char_varray;                                                       			
  v_NUM_DI chr_varray;                                                             			
  v_NUM_BMM chr_varray;
  v_NUM_BVD chr_varray;                                                            			
  v_NUM_DTA chr_varray;                                                            			
  v_NUM_BAE chr_varray;                                                            			
  v_NUM_BVA chr_varray;                                                         			
  v_DE_HISTORICO chr_varray;                                                     			
  v_NUM_NOTA_VENDA chr_varray;                                                     			
  v_CD_ITEM_STYLE nmb_varray;                                                          			
  v_NUM_PEDIDO_CONSIGNACAO nmb_varray;                                                  		
  v_NUM_PEDIDO_VENDA chr_varray;                                                  			
  v_NUM_PEDIDO_FILIAL  nmb_varray ; 
  '';

  CURSOR c_trans IS (select  x.ID_LINHA_TRANSACAO_SIA,
      x.ID_TRANSACAO_ESTOQUE_SIA,
      x.ID_ESTOQUE_SIA_VALOR,
      x.ID_ESTOQUE_SIA,
      '',
      x.VAL_FOB_DUFRY,
      x.VAL_FOB_CONSIGNANTE,
      x.VAL_FRETE_DUFRY,
      x.VAL_SEGURO_DUFRY,
      x.VAL_DESPESAS_DUFRY,
      x.VAL_ICMS_ST,
      x.VAL_ICMS_ST_RET,
      x.VAL_RECEITA,
      x.VAL_II,
      x.VAL_PIS,
      x.VAL_COFINS,
      '',
      x.NUM_FAT_COMPLEM,
      x.NUM_DI,
      x.NUM_BMM,
      x.NUM_BVD,
      x.NUM_DTA,
      x.NUM_BAE,
      x.NUM_BVA,
      x.DE_HISTORICO,
      x.NUM_NOTA_VENDA,
      x.CD_ITEM_STYLE,
      x.NUM_PEDIDO_CONSIGNACAO,
      x.NUM_PEDIDO_VENDA,
      x.NUM_PEDIDO_FILIAL,
      ''
 from saftt001@rjd6_prod saft,
           (Select to_char(COMERCIAL.IL_TRANSACAO_ESTOQUE_SIA.DT_REFERENCIA, 'YYYYMMDD') DATA_REFERENCIA,
              to_char(COMERCIAL.FEURT001.DATADI, 'YYYYMMDD') DATA_DI,
              COMERCIAL.FEURT001.NUMEROFATURAEUROTRADE NUMEROFATURAEUROTRADE,
              COMERCIAL.FEURT001.NUMERODI NUMERO_DI,
              COMERCIAL.IL_LINHA_TRANSACAO_ESTOQUE_SIA.NUM_NTM,
              COMERCIAL.ITEM_ITEM_NOVA.COD_BRASIF_ITEM COD_BRASIF_ITEM,
              COMERCIAL.INST_INSTALACAO.SIGLAAEROPORTO,
              COMERCIAL.IL_LINHA_TRANSACAO_ESTOQUE_SIA.QTD_TRANSACAO,
              COMERCIAL.IL_LINHA_TRANSACAO_ESTOQUE_SIA.ID_LINHA_TRANSACAO_SIA,
              COMERCIAL.IL_TRANSACAO_ESTOQUE_SIA.ID_TRANSACAO_ESTOQUE_SIA,
              COMERCIAL.IL_LINHA_TRANSACAO_ESTOQUE_SIA.ID_ESTOQUE_SIA_VALOR,
              COMERCIAL.IL_LINHA_TRANSACAO_ESTOQUE_SIA.ID_ESTOQUE_SIA,
              COMERCIAL.IL_LINHA_TRANSACAO_ESTOQUE_SIA.VAL_FOB_DUFRY,
              COMERCIAL.IL_LINHA_TRANSACAO_ESTOQUE_SIA.VAL_FOB_CONSIGNANTE,
              COMERCIAL.IL_LINHA_TRANSACAO_ESTOQUE_SIA.VAL_FRETE_DUFRY,
              COMERCIAL.IL_LINHA_TRANSACAO_ESTOQUE_SIA.VAL_SEGURO_DUFRY,
              COMERCIAL.IL_LINHA_TRANSACAO_ESTOQUE_SIA.VAL_DESPESAS_DUFRY,
              COMERCIAL.IL_LINHA_TRANSACAO_ESTOQUE_SIA.VAL_ICMS_ST,
              COMERCIAL.IL_LINHA_TRANSACAO_ESTOQUE_SIA.VAL_ICMS_ST_RET,
              COMERCIAL.IL_LINHA_TRANSACAO_ESTOQUE_SIA.VAL_RECEITA,
              COMERCIAL.IL_LINHA_TRANSACAO_ESTOQUE_SIA.VAL_II,
              COMERCIAL.IL_LINHA_TRANSACAO_ESTOQUE_SIA.VAL_PIS,
              COMERCIAL.IL_LINHA_TRANSACAO_ESTOQUE_SIA.VAL_COFINS,
              COMERCIAL.IL_LINHA_TRANSACAO_ESTOQUE_SIA.NUM_FAT_EUROT,
              COMERCIAL.IL_LINHA_TRANSACAO_ESTOQUE_SIA.NUM_FAT_COMPLEM,
              COMERCIAL.IL_LINHA_TRANSACAO_ESTOQUE_SIA.NUM_DI,
              COMERCIAL.IL_LINHA_TRANSACAO_ESTOQUE_SIA.NUM_BMM,
              COMERCIAL.IL_LINHA_TRANSACAO_ESTOQUE_SIA.NUM_BVD,
              COMERCIAL.IL_LINHA_TRANSACAO_ESTOQUE_SIA.NUM_DTA,
              COMERCIAL.IL_LINHA_TRANSACAO_ESTOQUE_SIA.NUM_BAE,
              COMERCIAL.IL_LINHA_TRANSACAO_ESTOQUE_SIA.NUM_BVA,
              COMERCIAL.IL_LINHA_TRANSACAO_ESTOQUE_SIA.DE_HISTORICO,
              COMERCIAL.IL_LINHA_TRANSACAO_ESTOQUE_SIA.NUM_NOTA_VENDA,
              COMERCIAL.IL_LINHA_TRANSACAO_ESTOQUE_SIA.CD_ITEM_STYLE,
              COMERCIAL.IL_LINHA_TRANSACAO_ESTOQUE_SIA.NUM_PEDIDO_CONSIGNACAO,
              COMERCIAL.IL_LINHA_TRANSACAO_ESTOQUE_SIA.NUM_PEDIDO_VENDA,
              COMERCIAL.IL_LINHA_TRANSACAO_ESTOQUE_SIA.NUM_PEDIDO_FILIAL
         From COMERCIAL.INST_INSTALACAO@rjd6_prod,
              COMERCIAL.FEURT001@rjd6_prod,
              COMERCIAL.IL_TRANSACAO_ESTOQUE_SIA@rjd6_prod,
              COMERCIAL.ITEM_ITEM_NOVA@rjd6_prod,
              COMERCIAL.IL_ESTOQUE_SIA_VALOR@rjd6_prod,
              COMERCIAL.IL_ESTOQUE_SIA@rjd6_prod,
              COMERCIAL.IL_LINHA_TRANSACAO_ESTOQUE_SIA@rjd6_prod
        Where (((COMERCIAL.IL_TRANSACAO_ESTOQUE_SIA.DT_REFERENCIA > to_date('20100131', 'YYYYMMDD'))))
          AND (COMERCIAL.INST_INSTALACAO.SIGLAAEROPORTO LIKE 'AI%'
               OR COMERCIAL.INST_INSTALACAO.SIGLAAEROPORTO LIKE 'DI%')
          AND COMERCIAL.IL_LINHA_TRANSACAO_ESTOQUE_SIA.NUM_FAT_EUROT || COMERCIAL.IL_LINHA_TRANSACAO_ESTOQUE_SIA.NUM_FAT_COMPLEM = COMERCIAL.FEURT001.NUMEROFATURAEUROTRADE(+)
          AND COMERCIAL.IL_LINHA_TRANSACAO_ESTOQUE_SIA.ID_ESTOQUE_SIA = COMERCIAL.IL_ESTOQUE_SIA.ID_ESTOQUE_SIA(+)
          AND (COMERCIAL.IL_TRANSACAO_ESTOQUE_SIA.CD_TIPO_TRANSACAO = 'IMPT'
              or COMERCIAL.IL_TRANSACAO_ESTOQUE_SIA.CD_TIPO_TRANSACAO like 'AI%'
              or COMERCIAL.IL_TRANSACAO_ESTOQUE_SIA.CD_TIPO_TRANSACAO like 'DI%')
          AND COMERCIAL.IL_ESTOQUE_SIA.ID_ESTOQUE_SIA_VALOR = COMERCIAL.IL_ESTOQUE_SIA_VALOR.ID_ESTOQUE_SIA_VALOR
          AND COMERCIAL.IL_LINHA_TRANSACAO_ESTOQUE_SIA.ID_ESTOQUE_SIA_VALOR = COMERCIAL.IL_ESTOQUE_SIA_VALOR.ID_ESTOQUE_SIA_VALOR
          AND COMERCIAL.IL_ESTOQUE_SIA_VALOR.ID_AEROPORTO_DONO = COMERCIAL.INST_INSTALACAO.ID_INSTALACAO
          AND COMERCIAL.IL_ESTOQUE_SIA_VALOR.COD_ITEM = COMERCIAL.ITEM_ITEM_NOVA.COD_BRASIF_ITEM
          AND COMERCIAL.IL_LINHA_TRANSACAO_ESTOQUE_SIA.ID_TRANSACAO_ESTOQUE_SIA = COMERCIAL.IL_TRANSACAO_ESTOQUE_SIA.ID_TRANSACAO_ESTOQUE_SIA) x
where saft.CODIGOBRASIF(+) = x.COD_BRASIF_ITEM
  and saft.NUMEROFATURAEUROTRADE(+) = x.NUMEROFATURAEUROTRADE    ); 
--
  Reg c_trans%ROWTYPE; 
  wrk_data   date;
  wrk_count  Number(10);
BEGIN 
  wrk_count :=0;
  wrk_data:= sysdate;
  dbms_output.put_line('Carrega DADOS_IL_LINHA_TRANSACAO_ESTOQUE_SIA');
  dbms_output.put_line('Inicio Processamento: '||to_char(wrk_data,'dd-mm-yyyy hh24:mi'));
  EXECUTE IMMEDIATE 'SET TRANSACTION USE ROLLBACK SEGMENT BSIZE';
  OPEN c_trans; 
  LOOP 
    FETCH c_trans BULK COLLECT INTO 
           v_ID_LINHA_TRANSACAO_SIA,                                          			
v_ID_TRANSACAO_ESTOQUE_SIA,                                        			
v_ID_ESTOQUE_SIA_VALOR,                                            			
v_ID_ESTOQUE_SIA,  
'',                                             			
v_VAL_FOB_DUFRY,                                                   			
v_VAL_FOB_CONSIGNANTE,                                             			
v_VAL_FRETE_DUFRY,                                                 			
v_VAL_SEGURO_DUFRY,                                                			
v_VAL_DESPESAS_DUFRY,                                              			
v_VAL_ICMS_ST,                                                     			
v_VAL_ICMS_ST_RET,                                                 			
v_VAL_RECEITA,                                                     			
v_VAL_II,                                                          			
v_VAL_PIS,                                                         			
v_VAL_COFINS,   
'',                                                   			
v_NUM_FAT_COMPLEM,                                                       			
v_NUM_DI,                                                             			
v_NUM_BMM,
v_NUM_BVD,                                                            			
v_NUM_DTA,                                                            			
v_NUM_BAE,                                                            			
v_NUM_BVA,                                                         			
v_DE_HISTORICO,                                                     			
v_NUM_NOTA_VENDA,                                                     			
v_CD_ITEM_STYLE,                                                          			
v_NUM_PEDIDO_CONSIGNACAO,                                                  			
v_NUM_PEDIDO_VENDA,                                                  			
v_NUM_PEDIDO_FILIAL,
''   LIMIT 10000; 
  BEGIN 
    FORALL a IN 1..v_ID_LINHA_TRANSACAO_SIA.count 
      Insert /*+APPEND*/ into  COMERCIAL.IL_LINHA_TRANSACAO_ESTOQUE_SIA
         values (  v_ID_LINHA_TRANSACAO_SIA(a),                                          			
v_ID_TRANSACAO_ESTOQUE_SIA(a),                                        			
v_ID_ESTOQUE_SIA_VALOR(a),                                            			
v_ID_ESTOQUE_SIA(a),                                               			
v_VAL_FOB_DUFRY(a),                                                   			
v_VAL_FOB_CONSIGNANTE(a),                                             			
v_VAL_FRETE_DUFRY(a),                                                 			
v_VAL_SEGURO_DUFRY(a),                                                			
v_VAL_DESPESAS_DUFRY(a),                                              			
v_VAL_ICMS_ST(a),                                                     			
v_VAL_ICMS_ST_RET(a),                                                 			
v_VAL_RECEITA(a),                                                     			
v_VAL_II(a),                                                          			
v_VAL_PIS(a),                                                         			
v_VAL_COFINS(a),                                                      			
v_NUM_FAT_COMPLEM(a),                                                       			
v_NUM_DI(a),                                                             			
v_NUM_BMM(a),
v_NUM_BVD(a),                                                            			
v_NUM_DTA(a),                                                            			
v_NUM_BAE(a),                                                            			
v_NUM_BVA(a),                                                         			
v_DE_HISTORICO(a),                                                     			
v_NUM_NOTA_VENDA(a),                                                     			
v_CD_ITEM_STYLE(a),                                                          			
v_NUM_PEDIDO_CONSIGNACAO(a),                                                  			
v_NUM_PEDIDO_VENDA(a),                                                  			
v_NUM_PEDIDO_FILIAL(a)  );
--
    wrk_count:= SQL%ROWCOUNT + wrk_count;
    COMMIT; 
    EXECUTE IMMEDIATE 'SET TRANSACTION USE ROLLBACK SEGMENT BSIZE';
  END; 
  EXIT WHEN c_trans%NOTFOUND; 
  END LOOP; 
  COMMIT; 
  CLOSE c_trans; 
  wrk_data:= sysdate;
  dbms_output.put_line('Registro Inseridos   : '||wrk_count);
  dbms_output.put_line('Final  Processamento: '||to_char(wrk_data,'dd-mm-yyyy hh24:mi'));
END; 
/
