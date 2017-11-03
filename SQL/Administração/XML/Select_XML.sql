select xmlelement ("TP_PEDIDOS",xmlagg (xmlelement ("TP_PEDIDO",to_char(cd_tp_pedido)|| '-' ||  DS_TP_PEDIDO))) as xml from idt_tp_pedido
