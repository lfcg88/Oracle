SCHEDULE_NAME SCH_SEG_SEX_0800
SCHEDULE_TYPE CALENDAR
START_DATE SYSDATE
REPEAT_INTERVAL FREQ=WEEKLY;BYDAY=MON,TUE,WED,THU,FRI;BYHOUR=8;BYMINUTE=00
COMMENTS Execucao de Segunda a Sexta as 08:00



BEGIN
    sys.DBMS_SCHEDULER.CREATE_SCHEDULE (
    	   
        repeat_interval  => 'FREQ=WEEKLY;BYDAY=MON,TUE,WED,THU,FRI;BYHOUR=8;BYMINUTE=00',     
        start_date => TO_TIMESTAMP_TZ('2012-08-23 13:17:44 America/Sao_Paulo','YYYY-MM-DD HH24.MI.SS TZR'),
        comments => 'Execucao de Segunda a Sexta as 08:00',
        schedule_name  => '"EAI"."SCH_SEG_SEX_0800"');
        
END;