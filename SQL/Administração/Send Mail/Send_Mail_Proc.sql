CREATE OR REPLACE PROCEDURE usp_send_mail (sender    IN VARCHAR2, 
                     recipient IN VARCHAR2,
      subject   IN VARCHAR2, 
                     message   IN VARCHAR2,
      mailhost  in VARCHAR2:= 'SMTP.MONTREAL.COM.BR'
      )
IS
 tcp_port pls_integer:= 25;
 mail_conn  utl_smtp.connection;
 header varchar(1000);
 
BEGIN
 header:= 'MIME-version: 1.0' || utl_tcp.crlf || 
    'Content-Type: text/plain; charset=iso-8859-1' || utl_tcp.crlf ||
    'Content-Transfer-Encoding: 8bit' || utl_tcp.crlf ||
    'Date: ' || TO_CHAR( SYSDATE, 'dd Mon yy hh24:mi:ss' ) || utl_tcp.crlf || 
    'From: ' || sender || utl_tcp.crlf ||
    'Subject: ' || subject || utl_tcp.crlf ||
    'To: ' || recipient || utl_tcp.crlf;
   
    
    mail_conn := utl_smtp.open_connection(mailhost, tcp_port);
    utl_smtp.helo(mail_conn, mailhost);
    utl_smtp.mail(mail_conn, sender);
    utl_smtp.rcpt(mail_conn, recipient);
    utl_smtp.open_data(mail_conn);
    utl_smtp.write_data (mail_conn, header);
    utl_smtp.write_raw_data(mail_conn, utl_raw.cast_to_raw(message));
    utl_smtp.close_data (mail_conn);
    utl_smtp.quit(mail_conn);

END usp_send_mail;
/
