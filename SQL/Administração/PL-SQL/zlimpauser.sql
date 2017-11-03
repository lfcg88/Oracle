declare vTemp_ID number(10)
   declare cursor cC1 is 
 
 Select ID from DriveUSR where Nome NOT IN ('DRIVE','DRIVEAMNET','DRIVEAMS','COSTA','LENUNES')
 

open cC1

LOOP
fetch cC1 into vTemp_ID   
exit when cC1%notfound
begin
 
 delete from DriveUSREml where ID = vTemp_ID;
 delete from MsgUsr where IdUsrRmt = vTemp_ID or IdUsrDest = vTemp_ID;
 delete from ParmFavt where IdUsr = vTemp_ID;
 delete from PendCfr where IdUsr = vTemp_ID;
 delete from PrefUSR where UsuarioID = vTemp_ID;
 delete from DriveUSRxCOT where USRID = vTemp_ID;
 delete from DriveUSRxCRT where USRID = vTemp_ID;
 delete from DriveUSRxLST where USRID = vTemp_ID;
 delete from DriveLog where UsuarioID = vTemp_ID;
 delete from DriveUSRxGRP where USRID = vTemp_ID;
 delete from DrivePWHST where USRID = vTemp_ID;
 delete from DriveSession where UsrID = vTemp_ID;
 delete from DriveUSRxPRC where USRID = vTemp_ID;
 delete from DriveUSR where ID = vTemp_ID;
 
 
 end loop;
   close cC1
  end;
