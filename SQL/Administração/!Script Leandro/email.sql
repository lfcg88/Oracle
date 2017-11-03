
create or replace
  PROCEDURE send_mail_dba (p_sender       IN VARCHAR2,
                       p_recipient IN VARCHAR2,
                       p_message   IN VARCHAR2)
  IS
     l_mailhost VARCHAR2(255) := '172.16.130.60';
     l_mail_conn sys.utl_smtp.connection;
  BEGIN
     l_mail_conn := sys.utl_smtp.open_connection(l_mailhost, 25);
     SYS.utl_smtp.helo(l_mail_conn, l_mailhost);
     SYS.utl_smtp.mail(l_mail_conn, p_sender);
     SYS.utl_smtp.rcpt(l_mail_conn, p_recipient);
     SYS.utl_smtp.open_data(l_mail_conn );
     SYS.utl_smtp.write_data(l_mail_conn, p_message);
     SYS.utl_smtp.close_data(l_mail_conn );
     SYS.utl_smtp.quit(l_mail_conn);
  end;
  /
