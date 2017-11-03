CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPBXXXX
-------------------------------------------------------------------------------------------------
--      BRADESCO SEGUROS S.A.
--      PROCEDURE       : SGPBXXXX
--      DATA            : 10/08/2007
--      AUTOR           : Alexandre Cysne Esteves
--      OBJETIVO        : Exemplo cursor
--      ALTERAÇÕES      : 
--                DATA  : 
--                AUTOR : 
--                OBS   : 
-------------------------------------------------------------------------------------------------
IS
  INT_DFIM_VGCIA_PARM      DATE;
  INT_DINIC_VGCIA_PARM     DATE;
  INT_CCANAL_VDA_SEGUR     NUMBER(1) := 0;

  TYPE T_CURSOR IS REF CURSOR;
  C_CURSOR T_CURSOR;
  
BEGIN
 
                 --abrindo cursor
               OPEN C_CURSOR FOR
                 --
             SELECT PCVS.DFIM_VGCIA_PARM,
                    PCVS.DINIC_VGCIA_PARM,
                    PCVS.CCANAL_VDA_SEGUR
               FROM PARM_CANAL_VDA_SEGUR PCVS
              WHERE PCVS.CCANAL_VDA_SEGUR IN(1,2,3)
                AND PCVS.DINIC_VGCIA_PARM < TO_DATE(20061212,'YYYYMMDD');
                 --
             LOOP
             --trazendo valor do cursor para variavel
             FETCH C_CURSOR INTO INT_DFIM_VGCIA_PARM,
                                 INT_DINIC_VGCIA_PARM,
                                 INT_CCANAL_VDA_SEGUR;
              --
              EXIT WHEN C_CURSOR%NOTFOUND;
 	            --              
                        --
                        --procedimento criado dentro do loop do cursor
                        --
                        BEGIN
                        --
                             UPDATE PARM_CANAL_VDA_SEGUR PCVS
                                SET PCVS.CCANAL_VDA_SEGUR = INT_CCANAL_VDA_SEGUR
                              WHERE PCVS.CCANAL_VDA_SEGUR = INT_CCANAL_VDA_SEGUR;
                        --               
                        EXCEPTION
                           WHEN OTHERS THEN
                           RAISE_APPLICATION_ERROR(-99971,'ERRO XYZ ' || SUBSTR(SQLERRM,1,100));
                           ROLLBACK;
                        END;
                        --              
              --
              END LOOP;
	            --
              COMMIT;
              CLOSE C_CURSOR;
 
 
END SGPBXXXX;
/

