DECLARE 
--
--  bulk_errors   EXCEPTION; 
--  PRAGMA EXCEPTION_INIT (bulk_errors,  -24381); 
  TYPE nmb_varray IS VARRAY (50000000) OF NUMBER(40); 
  TYPE dts_varray IS VARRAY (50000000) OF DATE; 
  TYPE chr_varray IS VARRAY (50000000) OF VARCHAR2(4000); 

--  V_rowid                   chr_varray; 
  V_account_key                   chr_varray; 
  V_account_type                  nmb_varray; 
  v_NUMEROCHECKOUT                chr_varray;
  v_SEQUENCIALOPERACAOCHECKOUT    nmb_varray;
  v_SEQUENCIALPAGAMENTO           nmb_varray;
  v_NUMEROPARCELA                 nmb_varray;
  v_CODIGOMOEDA                   chr_varray;
  v_INDICADORTC                   chr_varray;
  v_CODIGOADMINISTRADORACARTAO    chr_varray;
  v_NUMEROCARTAOCREDITO           chr_varray;
  v_VALIDADECARTAOCREDITO         dts_varray;
  v_VALORPGTOMOEDAORIGINAL        nmb_varray;
  v_VALORPGTOPARCELARECEBER       nmb_varray;
  v_VALORPGTOPARCELARECONHECIDA   nmb_varray;
  v_VALORPGTOPARCELARECEBIDA      nmb_varray;
  v_TAXACAMBIOVENDA               nmb_varray;
  v_TAXACAMBIOPAGAMENTO           nmb_varray;
  v_VALORPAGAMENTOUS$             nmb_varray;
  v_CODIGOEMPRESA                 chr_varray;
  v_CODIGOVIAAUTORIZACAO          chr_varray;
  v_DATAOPERACAOCHECKOUT          dts_varray;
  v_DATAPREVISTARECEBIMENTO       dts_varray;
  v_DATARECONHECIDORECEBIMENTO    dts_varray;
  v_DATAREALIZADORECEBIMENTO      dts_varray;
  v_DATAHORAREALOPERACAO          dts_varray;
  v_CODIGONEGOCIO                 chr_varray;
  v_SIGLAAEROPORTO                chr_varray;
  v_CODIGOLOJA                    chr_varray;
  v_CODIGOPONTOVENDA              chr_varray;
  v_INDICADORESTORNO              chr_varray;
  v_VALORCOMISSAOCARTAO           nmb_varray;
  v_TIPOPARCELAMENTOCARTAO        chr_varray;
  v_NUMEROPARCELASCARTAO          nmb_varray;
  v_CODIGOMOEDACARTAO             chr_varray;
  v_DATAPROCESSAMENTO             dts_varray;
  v_CODIGOAUTORIZACAOCC           chr_varray;
  v_NUMERODOCUMENTOSITEF          chr_varray;
  v_NUM_DOCUMENTO                 chr_varray;
  v_SEQ_DOCUMENTO                 chr_varray;
  v_DT_VENDA_EMISSAO              dts_varray;
  v_DIA_MES                       nmb_varray;
  
  CURSOR c_pgto IS (select   NUMEROCHECKOUT,
                             SEQUENCIALOPERACAOCHECKOUT,
                             SEQUENCIALPAGAMENTO,
                             NUMEROPARCELA,
                             CODIGOMOEDA,
                             INDICADORTC,
                             CODIGOADMINISTRADORACARTAO,
                             NUMEROCARTAOCREDITO,
                             VALIDADECARTAOCREDITO,
                             VALORPGTOMOEDAORIGINAL,
                             VALORPGTOPARCELARECEBER,
                             VALORPGTOPARCELARECONHECIDA,
                             VALORPGTOPARCELARECEBIDA,
                             TAXACAMBIOVENDA,
                             TAXACAMBIOPAGAMENTO,
                             VALORPAGAMENTOUS$,
                             CODIGOEMPRESA,
                             CODIGOVIAAUTORIZACAO,
                             DATAOPERACAOCHECKOUT,
                             DATAPREVISTARECEBIMENTO,
                             DATARECONHECIDORECEBIMENTO,
                             DATAREALIZADORECEBIMENTO,
                             DATAHORAREALOPERACAO,
                             CODIGONEGOCIO,
                             SIGLAAEROPORTO,
                             CODIGOLOJA,
                             CODIGOPONTOVENDA,
                             INDICADORESTORNO,
                             VALORCOMISSAOCARTAO,
                             TIPOPARCELAMENTOCARTAO,
                             NUMEROPARCELASCARTAO,
                             CODIGOMOEDACARTAO,
                             DATAPROCESSAMENTO,
                             CODIGOAUTORIZACAOCC,
                             NUMERODOCUMENTOSITEF,
                             NUM_DOCUMENTO,
                             SEQ_DOCUMENTO,
                             DT_VENDA_EMISSAO,
                             DIA_MES
                        From COMERCIAL.PGTOT015); 
--
  Reg c_pgto%ROWTYPE; 
  wrk_data   date;
  wrk_count  Number(10);
BEGIN 
  wrk_count :=0;
  wrk_data:= sysdate;
  dbms_output.put_line('Carrega PGTOT015_NOVA');
  dbms_output.put_line('Inicio Processamento: '||to_char(wrk_data,'dd-mm-yyyy hh24:mi'));
  EXECUTE IMMEDIATE 'SET TRANSACTION USE ROLLBACK SEGMENT RBKEYW';
  EXECUTE IMMEDIATE 'LOCK TABLE PGTOT015 IN EXCLUSIVE MODE';
  OPEN c_pgto; 
  LOOP 
    FETCH c_pgto BULK COLLECT INTO 
                 v_NUMEROCHECKOUT                
               , v_SEQUENCIALOPERACAOCHECKOUT    
               , v_SEQUENCIALPAGAMENTO           
               , v_NUMEROPARCELA                 
               , v_CODIGOMOEDA                   
               , v_INDICADORTC                   
               , v_CODIGOADMINISTRADORACARTAO    
               , v_NUMEROCARTAOCREDITO           
               , v_VALIDADECARTAOCREDITO         
               , v_VALORPGTOMOEDAORIGINAL        
               , v_VALORPGTOPARCELARECEBER       
               , v_VALORPGTOPARCELARECONHECIDA   
               , v_VALORPGTOPARCELARECEBIDA      
               , v_TAXACAMBIOVENDA               
               , v_TAXACAMBIOPAGAMENTO           
               , v_VALORPAGAMENTOUS$             
               , v_CODIGOEMPRESA                 
               , v_CODIGOVIAAUTORIZACAO          
               , v_DATAOPERACAOCHECKOUT          
               , v_DATAPREVISTARECEBIMENTO       
               , v_DATARECONHECIDORECEBIMENTO    
               , v_DATAREALIZADORECEBIMENTO      
               , v_DATAHORAREALOPERACAO          
               , v_CODIGONEGOCIO                 
               , v_SIGLAAEROPORTO                
               , v_CODIGOLOJA                    
               , v_CODIGOPONTOVENDA              
               , v_INDICADORESTORNO              
               , v_VALORCOMISSAOCARTAO           
               , v_TIPOPARCELAMENTOCARTAO        
               , v_NUMEROPARCELASCARTAO          
               , v_CODIGOMOEDACARTAO             
               , v_DATAPROCESSAMENTO             
               , v_CODIGOAUTORIZACAOCC           
               , v_NUMERODOCUMENTOSITEF          
               , v_NUM_DOCUMENTO                 
               , v_SEQ_DOCUMENTO                 
               , v_DT_VENDA_EMISSAO              
               , v_DIA_MES                       LIMIT 50000; 
  BEGIN 
    FORALL a IN 1..v_DATAOPERACAOCHECKOUT.count 
      Insert /*+APPEND*/ into COMERCIAL.PGTOT015_NOVA 
         values (  v_NUMEROCHECKOUT(a)                
                 , v_SEQUENCIALOPERACAOCHECKOUT(a)    
                 , v_SEQUENCIALPAGAMENTO(a)           
                 , v_NUMEROPARCELA(a)                 
                 , v_CODIGOMOEDA(a)                   
                 , v_INDICADORTC(a)                   
                 , v_CODIGOADMINISTRADORACARTAO(a)    
                 , v_NUMEROCARTAOCREDITO(a)           
                 , v_VALIDADECARTAOCREDITO(a)         
                 , v_VALORPGTOMOEDAORIGINAL(a)        
                 , v_VALORPGTOPARCELARECEBER(a)       
                 , v_VALORPGTOPARCELARECONHECIDA(a)   
                 , v_VALORPGTOPARCELARECEBIDA(a)      
                 , v_TAXACAMBIOVENDA(a)               
                 , v_TAXACAMBIOPAGAMENTO(a)           
                 , v_VALORPAGAMENTOUS$(a)             
                 , v_CODIGOEMPRESA(a)                 
                 , v_CODIGOVIAAUTORIZACAO(a)          
                 , v_DATAOPERACAOCHECKOUT(a)          
                 , v_DATAPREVISTARECEBIMENTO(a)       
                 , v_DATARECONHECIDORECEBIMENTO(a)    
                 , v_DATAREALIZADORECEBIMENTO(a)      
                 , v_DATAHORAREALOPERACAO(a)          
                 , v_CODIGONEGOCIO(a)                 
                 , v_SIGLAAEROPORTO(a)                
                 , v_CODIGOLOJA(a)                    
                 , v_CODIGOPONTOVENDA(a)              
                 , v_INDICADORESTORNO(a)              
                 , v_VALORCOMISSAOCARTAO(a)           
                 , v_TIPOPARCELAMENTOCARTAO(a)        
                 , v_NUMEROPARCELASCARTAO(a)          
                 , v_CODIGOMOEDACARTAO(a)             
                 , v_DATAPROCESSAMENTO(a)             
                 , v_CODIGOAUTORIZACAOCC(a)           
                 , v_NUMERODOCUMENTOSITEF(a)          
                 , v_NUM_DOCUMENTO(a)                 
                 , v_SEQ_DOCUMENTO(a)                 
                 , v_DT_VENDA_EMISSAO(a)              
                 , v_DIA_MES(a));
--
    wrk_count:= SQL%ROWCOUNT + wrk_count;
    COMMIT; 
    EXECUTE IMMEDIATE 'SET TRANSACTION USE ROLLBACK SEGMENT RBKEYW';
    EXECUTE IMMEDIATE 'LOCK TABLE PGTOT015 IN EXCLUSIVE MODE';
  END; 
  EXIT WHEN c_pgto%NOTFOUND; 
  END LOOP; 
  COMMIT; 
  CLOSE c_pgto; 
  wrk_data:= sysdate;
  dbms_output.put_line('Registro Inseridos   : '||wrk_count);
  dbms_output.put_line('Final  Processamento: '||to_char(wrk_data,'dd-mm-yyyy hh24:mi'));
END; 

