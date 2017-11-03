set serveroutput on
    DECLARE
	  
      l_xml SYS.XMLType;
    BEGIN
      l_xml :=  SYS.XMLType.createXML(
        '<?xml version="1.0" encoding="UTF-8"?>
         <ROWS>
           <ROW num="1">
              <ID>110044</ID>
			  <ID2>110045</ID2>
           </ROW>
		     <ROW num="2">
              <ID>110046</ID>
			  <ID2>110047</ID2>
           </ROW>
         </ROWS>');
       DBMS_OUTPUT.PUT_LINE('Name:'||
           XMLType(l_xml.extract('/ROWS/ROW[2]/*[1]').getStringVal()).getRootElement());
       DBMS_OUTPUT.PUT_LINE('Value:'||
                   l_xml.extract('/ROWS/ROW[2]/*[1]/text()').getStringVal());
       DBMS_OUTPUT.PUT_LINE('Value:'||
                   l_xml.extract('/ROWS/ROW[2]/*[2]/text()').getStringVal());
				   
    END;
    /
	
	
set serveroutput on
    DECLARE
	  
      l_xml SYS.XMLType;
    BEGIN
      l_xml :=  SYS.XMLType.createXML(
        '<?xml version="1.0" encoding="UTF-8"?>
         <ROWS>
           <ROW num="1">
              <ID>110044</ID>
			  <ID2>110045</ID2>
           </ROW>
		     <ROW num="4">
              <ID>110046</ID>
			  <ID2>110047</ID2>
           </ROW>
         </ROWS>');
       DBMS_OUTPUT.PUT_LINE('Name:'||
           XMLType(l_xml.extract('/ROWS/ROW[2]/*[1]').getStringVal()).getRootElement());
       DBMS_OUTPUT.PUT_LINE('Value:'||
                   l_xml.extract('/ROWS/ROW[2]/ID2/text()').getStringVal());
       DBMS_OUTPUT.PUT_LINE('Value:'||
                   l_xml.extract('/ROWS/ROW[2]/ID/text()').getStringVal());
				   
    END;
    /

	
set serveroutput on
    DECLARE
	  
      l_xml SYS.XMLType;
    BEGIN
      l_xml :=  SYS.XMLType.createXML(
        '<?xml version="1.0" encoding="UTF-8"?>
         <ROWS>
           <ROW num="1">
              <ID>110044</ID>
			  <ID>110045</ID>
              <ID>110046</ID>
           </ROW>
         </ROWS>');
	   if l_xml.extract('/ROWS/ROW/ID[1]/text()') is not null then 
	      DBMS_OUTPUT.PUT_LINE('Value:'||
                   l_xml.extract('/ROWS/ROW/ID[1]/text()').getStringVal());
       end if;
	   	   if l_xml.extract('/ROWS/ROW/ID[2]/text()') is not null then 
	      DBMS_OUTPUT.PUT_LINE('Value:'||
                   l_xml.extract('/ROWS/ROW/ID[2]/text()').getStringVal());
       end if;				   
	   if l_xml.extract('/ROWS/ROW/ID[3]/text()') is not null then 
	      DBMS_OUTPUT.PUT_LINE('Value:'||
                   l_xml.extract('/ROWS/ROW/ID[3]/text()').getStringVal());
       end if;				   
	   if l_xml.extract('/ROWS/ROW/ID[4]/text()') is not null then 
	      DBMS_OUTPUT.PUT_LINE('Value:'||
                   l_xml.extract('/ROWS/ROW/ID[4]/text()').getStringVal());
       else
	     DBMS_OUTPUT.PUT_LINE('Value: NULL');
       end if;				   
				   
    END;
    /
	