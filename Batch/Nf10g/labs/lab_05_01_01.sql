
connect / as sysdba

exec DBMS_AQADM.ADD_SUBSCRIBER('SYS.ALERT_QUE',-
AQ$_AGENT('ALERT_USR1','',0));

-- exec DBMS_AQADM.CREATE_AQ_AGENT(agent_name=>'ALERT_USR1');

exec DBMS_AQADM.ENABLE_DB_ACCESS(agent_name=>'ALERT_USR1',-
db_username=>'SYSTEM');

exec DBMS_AQADM.GRANT_QUEUE_PRIVILEGE(privilege=>'DEQUEUE',-
queue_name=>'ALERT_QUE',-
grantee=>'SYSTEM',grant_option=>FALSE);

-- DECLARE
--  reginfo     aq$_reg_info;
--  reginfolist aq$_reg_info_list;
-- BEGIN   
--  reginfo := AQ$_REG_INFO('ALERT_QUE:ALERT_USR1',
--  DBMS_AQ.NAMESPACE_AQ, 'mailto://yourname@yourcompany.com',NULL);
--  -- Create the registration info list 
--  reginfolist := AQ$_REG_INFO_LIST(reginfo);
--  -- Register the registration info list
--  DBMS_AQ.REGISTER(reginfolist, 1);
-- END;
-- /

-- BEGIN
--  DBMS_AQELM.SET_MAILHOST('yourmailhost.com');
--  DBMS_AQELM.SET_MAILPORT(25);
--  DBMS_AQELM.SET_SENDFROM('janedoe@yourcompany.com');
--  COMMIT;
-- END;
-- /

create or replace procedure sa_dequeue is 
  dequeue_options     dbms_aq.dequeue_options_t;
  message_properties  dbms_aq.message_properties_t;
  message             ALERT_TYPE;
  message_handle      RAW(16);
begin
   dequeue_options.consumer_name := 'ALERT_USR1';
   /* Never wait */
   dequeue_options.wait := DBMS_AQ.NO_WAIT;
   /* Always reset the position to the begining of the AQ */
   dequeue_options.navigation := DBMS_AQ.FIRST_MESSAGE;
   /* remove the message when done */
   dequeue_options.dequeue_mode := DBMS_AQ.REMOVE;

   DBMS_AQ.DEQUEUE(
      queue_name          =>    'SYS.ALERT_QUE',
      dequeue_options     =>    dequeue_options,
      message_properties  =>    message_properties,
      payload             =>    message,
      msgid               =>    message_handle);
   DBMS_OUTPUT.PUT_LINE('Alert message dequeued:');
   DBMS_OUTPUT.PUT_LINE('  Timestamp:         ' || 
                             message.timestamp_originating);
   DBMS_OUTPUT.PUT_LINE('  Organization Id:   ' || 
                             message.organization_id);
   DBMS_OUTPUT.PUT_LINE('  Component Id:      ' || 
                             message.component_id);
   DBMS_OUTPUT.PUT_LINE('  Hosting Client Id: ' || 
                             message.hosting_client_id);
   DBMS_OUTPUT.PUT_LINE('  Message Type:      ' || 
                             message.message_type);
   DBMS_OUTPUT.PUT_LINE('  Message Group:     ' || 
                             message.message_group);
   DBMS_OUTPUT.PUT_LINE('  Message Level:     ' || 
                             message.message_level);
   DBMS_OUTPUT.PUT_LINE('  Host id:           ' || 
                             message.host_id);
   DBMS_OUTPUT.PUT_LINE('  Host Network Addr: ' || 
                             message.host_nw_addr);
   DBMS_OUTPUT.PUT_LINE('  Module Id:         ' || 
                             message.module_id);
   DBMS_OUTPUT.PUT_LINE('  Process Id:        ' || 
                             message.process_id);
   DBMS_OUTPUT.PUT_LINE('  Execution Context: ' || 
                             message.execution_context_id);
   DBMS_OUTPUT.PUT_LINE('  Reason:            ' || 
     dbms_server_alert.expand_message(userenv('LANGUAGE'),
                                      message.message_id,
                                      message.reason_argument_1,
                                      message.reason_argument_2,
                                      message.reason_argument_3,
                                      message.reason_argument_4,
                                      message.reason_argument_5));
   DBMS_OUTPUT.PUT_LINE('  Sequence Id:       ' || 
                             message.sequence_id);
   DBMS_OUTPUT.PUT_LINE('  Reason Id:         ' || 
                             message.reason_id);
   DBMS_OUTPUT.PUT_LINE('  Object Owner:      ' || 
                             message.object_owner);
   DBMS_OUTPUT.PUT_LINE('  Object Name:       ' || 
                             message.object_name);
   DBMS_OUTPUT.PUT_LINE('  Subobject Name:    ' || 
                             message.subobject_name);
   DBMS_OUTPUT.PUT_LINE('  Object Type:       ' || 
                             message.object_type);
   DBMS_OUTPUT.PUT_LINE('  Instance Name:     ' || 
                             message.instance_name);
   DBMS_OUTPUT.PUT_LINE('  Instance Number:   ' || 
                             message.instance_number);
   DBMS_OUTPUT.PUT_LINE('  Suggested action:  ' ||
     dbms_server_alert.expand_message(userenv('LANGUAGE'),
                                      message.suggested_action_msg_id,
                                      message.action_argument_1,
                                      message.action_argument_2,
                                      message.action_argument_3,
                                      message.action_argument_4,
                                      message.action_argument_5));
   DBMS_OUTPUT.PUT_LINE('  Error instance id: ' || message.error_instance_id); 
   DBMS_OUTPUT.PUT_LINE('  Advisor Name:      ' || message.advisor_name);
   DBMS_OUTPUT.PUT_LINE('  Scope:             ' || message.scope);
end;
/

grant execute on sa_dequeue to system;
