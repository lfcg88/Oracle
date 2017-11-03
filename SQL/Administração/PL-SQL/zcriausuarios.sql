declare
  userid int;
  existe int;
  responsavel char(20);
  grupoid int;	     
begin

  update DriveUSR set NomeK = upper(NomeK);  
  
  update DriveUSR set Flags = 144 where NomeK = 'M';
  
  update DriveUSR set Flags = 144 where NomeK = 'ADMDEMO';
  
  update DriveUSR set Flags = 144 where NomeK = 'SUPORTE';
  
   
  select nvl(max(ID), 0) into grupoid from DriveGRP;
  
  select nvl(min(ID), 0) into userid from DriveUSR;
  
  select count(1) into existe from DriveGRP where NomeK='ALL' ;
  
  if existe > 0 then
     select ID-1 
     into grupoid 
     from DriveGRP where NomeK='ALL' ; 
  else
     select nvl(max(ID), 0) 
     into grupoid 
     from DriveGRP ;

     insert into DriveGRP values (grupoid+1, 'ALL', 'ALL', 'TODAS AS PERMISSÕES', 'TODAS AS PERMISSÕES', 1, userid, sysdate, userid, sysdate, null, null, null);
     
  end if ;

  insert into DriveGRPxPRC select grupoid+1, ID, userid, sysdate from Processo
  where not exists (select ID from DriveGRPxPRC where GRPID = grupoid+1);

  insert into DriveGRPxCRT select distinct grupoid+1, Carteira, userid, sysdate from MC5
  where not exists (select Carteira from DriveGRPxCRT where GRPID = grupoid+1);
  
  insert into DriveGRPxLST select distinct grupoid+1, CodLista, userid, sysdate from Lista
  where not exists (select CodLista from DriveGRPxLST where GRPID = grupoid+1);
  
  insert into DriveGRPxPSS select IdPessoa, grupoid+1, userid, sysdate from Pessoa
  where not exists (select IdPessoa from DriveGRPxPSS where GRPID = grupoid+1) ;
 
  for regresp in (select responsavel from resp666) loop
  
    select count(1) into existe from DriveUSR where Upper(NomeK) = Upper(regresp.responsavel);

    if existe = 0 then
  
      select max(ID) into userid from DriveUSR;
  
      insert into DriveUSR values 
      (
      userid+1, regresp.responsavel, regresp.responsavel, 'USUÁRIO PARA SUPORTE DRIVE', 'SUPORTE AO CLIENTE', 8, 2,
      sysdate, 2, sysdate,
--      'A7ECDFBC0D94761C1D41A28EA29B294A984111E441BD22140929204386751ED7B4F6A15D70A8BAF8AB5776AEA0E2473410FD3F25C5EE9A6E1B9DC5D5BF6080A4',
        '877226D7C28942B749F14119975C41705A7DDE1C5D133341A15F065D7815A7451C4734100B1046CC0B64215C5E9791B2672FEAB02CE06F9537C1665A3932B40E',
      sysdate, 2, sysdate, null, 1243, sysdate, null, null, null, null);
	  
	  insert into DriveUSRxGRP values (userid+1, grupoid+1, userid+1, sysdate);

    end if;
  
  end loop;
  
  update DriveUSR set Flags = 9 where NomeK IN ('CRESO', 'FERNANDO', 'EDMUNDO', 'PERIN', 'RUICOBAS', 'ANDRADE', 'VILARDO');

/*  
  delete 
    from DriveUSRxGRP
   where UsrID in (select ID from DriveUSR where Flags = 9)
     and GrpID = grupoid+1;
	 
  delete DriveLog
   where UsuarioID in (select ID from DriveUSR where Flags = 64 and ID not in (select distinct Manager from MC4Boleta));

  delete DriveUSR
   where Flags = 64
     and ID not in (select distinct Manager from MC4Boleta);
*/	 
	      
  commit;

end;
/