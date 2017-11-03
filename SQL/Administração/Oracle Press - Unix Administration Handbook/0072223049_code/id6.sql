
alter index APPL_CUST.I_POS rebuild tablespace EDI_TB01;                                            
alter index APPL_CUST.I_POS_QTY rebuild tablespace EDI_IX01;                                        

analyze index APPL_CUST.I_POS compute statistics;                                                   
analyze index APPL_CUST.I_POS_QTY compute statistics;                                               
