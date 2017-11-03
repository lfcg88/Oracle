DECLARE 
--
--  bulk_errors   EXCEPTION; 
--  PRAGMA EXCEPTION_INIT (bulk_errors,  -24381); 
  TYPE nmb_varray IS VARRAY (50000000) OF NUMBER(40); 
  TYPE dts_varray IS VARRAY (50000000) OF DATE; 
  TYPE chr_varray IS VARRAY (50000000) OF VARCHAR2(4000); 

--  V_rowid                   chr_varray; 
  V_account_key             chr_varray; 
  V_account_type            nmb_varray; 
  v_SIGLAAEROPORTOFILIAL    chr_varray; 
  v_SIGLAAEROPORTO          chr_varray; 
  v_CODIGOLOJA              chr_varray; 
  v_CODIGOPONTOVENDA        chr_varray; 
  v_DATAVALIDADE            dts_varray;
  v_CODIGOBRASIF            chr_varray; 
  v_DATATRANSACAO           dts_varray;
  v_QUANTIDADEFINALDATA     nmb_varray; 
  v_QT_QUEBRADA             nmb_varray; 
  v_QT_EXPIRADA             nmb_varray; 
  v_QT_IMPEDIDA             nmb_varray; 
  v_QT_DIPS_PEDIDOS         nmb_varray; 
  v_QT_DIPS_CONFIRMADAS     nmb_varray; 
  v_QT_RESERVADA_INVENTARIO nmb_varray; 
  v_CODIGONEGOCIO           chr_varray; 
  v_QT_TRANSITO_INTERNO     nmb_varray; 
  v_INDICADORMODIFICACAO    dts_varray;
  
  CURSOR c_saldt IS (select  SIGLAAEROPORTOFILIAL,
                             SIGLAAEROPORTO,
                             CODIGOLOJA,
                             CODIGOPONTOVENDA,
                             DATAVALIDADE,
                             CODIGOBRASIF,
                             DATATRANSACAO,
                             QUANTIDADEFINALDATA,
                             QT_QUEBRADA,
                             QT_EXPIRADA,
                             QT_IMPEDIDA,
                             QT_DIPS_PEDIDOS,
                             QT_DIPS_CONFIRMADAS,
                             QT_RESERVADA_INVENTARIO,
                             CODIGONEGOCIO,
                             QT_TRANSITO_INTERNO,
                             INDICADORMODIFICACAO
                        From COMERCIAL.SALDT030
                       Where DATATRANSACAO = to_date('15-07-2009','dd-mm-yyyy')); 
--
  Reg c_saldt%ROWTYPE; 
  wrk_data   date;
  wrk_count  Number(10);
BEGIN 
  wrk_count :=0;
  wrk_data:= sysdate;
  dbms_output.put_line('Carrega SALDT030_NOVA');
  dbms_output.put_line('Inicio Processamento: '||to_char(wrk_data,'dd-mm-yyyy hh24:mi'));
  EXECUTE IMMEDIATE 'SET TRANSACTION USE ROLLBACK SEGMENT BSIZE';
  OPEN c_saldt; 
  LOOP 
    FETCH c_saldt BULK COLLECT INTO 
           v_SIGLAAEROPORTOFILIAL   
         , v_SIGLAAEROPORTO         
         , v_CODIGOLOJA             
         , v_CODIGOPONTOVENDA       
         , v_DATAVALIDADE           
         , v_CODIGOBRASIF           
         , v_DATATRANSACAO          
         , v_QUANTIDADEFINALDATA    
         , v_QT_QUEBRADA            
         , v_QT_EXPIRADA            
         , v_QT_IMPEDIDA            
         , v_QT_DIPS_PEDIDOS        
         , v_QT_DIPS_CONFIRMADAS    
         , v_QT_RESERVADA_INVENTARIO
         , v_CODIGONEGOCIO          
         , v_QT_TRANSITO_INTERNO    
         , v_INDICADORMODIFICACAO  LIMIT 50000; 
  BEGIN 
    FORALL a IN 1..v_DATATRANSACAO.count 
      Insert /*+APPEND*/ into COMERCIAL.SALDT030_NOVA 
         values (  v_SIGLAAEROPORTOFILIAL(a)
                 , v_SIGLAAEROPORTO(a)
                 , v_CODIGOLOJA(a)      
                 , v_CODIGOPONTOVENDA(a)       
                 , v_DATAVALIDADE(a)           
                 , v_CODIGOBRASIF(a)           
                 , v_DATATRANSACAO(a)          
                 , v_QUANTIDADEFINALDATA(a)    
                 , v_QT_QUEBRADA(a)            
                 , v_QT_EXPIRADA(a)            
                 , v_QT_IMPEDIDA(a)            
                 , v_QT_DIPS_PEDIDOS(a)        
                 , v_QT_DIPS_CONFIRMADAS(a)    
                 , v_QT_RESERVADA_INVENTARIO(a)
                 , v_CODIGONEGOCIO(a)          
                 , v_QT_TRANSITO_INTERNO(a)    
                 , v_INDICADORMODIFICACAO(a)  );
--
    wrk_count:= SQL%ROWCOUNT + wrk_count;
    COMMIT; 
    EXECUTE IMMEDIATE 'SET TRANSACTION USE ROLLBACK SEGMENT BSIZE';
  END; 
  EXIT WHEN c_saldt%NOTFOUND; 
  END LOOP; 
  COMMIT; 
  CLOSE c_saldt; 
  wrk_data:= sysdate;
  dbms_output.put_line('Registro Inseridos   : '||wrk_count);
  dbms_output.put_line('Final  Processamento: '||to_char(wrk_data,'dd-mm-yyyy hh24:mi'));
END; 
/
