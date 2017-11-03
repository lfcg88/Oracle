/* Mata sessao Oracle. Execute antes o "sel_sess" e anote o */
/* numero do Sid e Serial.                                  */

alter system kill session '&sid,&serial'
/
