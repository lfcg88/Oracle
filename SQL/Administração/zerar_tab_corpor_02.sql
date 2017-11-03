---- # Efetua limpesa dos backups tab Corporativas contbdeptst ( (Bdep/berilo)SIRCS, SCP) 

TRUNCATE TABLE contbdeptst.autorizacoes_cbe 
TRUNCATE TABLE contbdeptst.programa_cbe     
TRUNCATE TABLE contbdeptst.bacias_programa_cbe 
TRUNCATE TABLE contbdeptst.empresa_cbe         
TRUNCATE TABLE contbdeptst.natureza_aquisicao_cbe 
TRUNCATE TABLE contbdeptst.tecnologia_cbe         
TRUNCATE TABLE contbdeptst.tecnologia_versao_cbe  
TRUNCATE TABLE contbdeptst.unidades_cbe           
TRUNCATE TABLE contbdeptst.versao_cbe             
TRUNCATE TABLE contbdeptst.perf_real_especiais_cbe
TRUNCATE TABLE contbdeptst.bacias_cbe             
TRUNCATE TABLE contbdeptst.perf_real_durante_perf_cbe 
TRUNCATE TABLE contbdeptst.perf_real_convencionais_cbe
TRUNCATE TABLE contbdeptst.concessionarios_cbe        
TRUNCATE TABLE contbdeptst.perf_realizadas_cbe        
TRUNCATE TABLE contbdeptst.pocos_logs_inter_pbk_cbe   
TRUNCATE TABLE contbdeptst.estados_cbe                
TRUNCATE TABLE contbdeptst.operador_contrato_cbe      
TRUNCATE TABLE contbdeptst.pocos_cbe                  
TRUNCATE TABLE contbdeptst.pocos_logs_pbk_cbe  

exit;