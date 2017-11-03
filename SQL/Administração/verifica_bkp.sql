prompt "Se retornar alguma linha executar o comando de END BACKUP para o datafile."

select file# , status from v$backup where status = 'ACTIVE';

exit