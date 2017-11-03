--
-- Cria DDL para tabelas
--
create or replace package gen_tab_struct is

   --
   -- Cria scripts para todas as tabelas
   --
   procedure CreateAllTables(s_dir varchar,
                               s_owner varchar2,
                               gen_drop boolean);
   --
   -- Cria all Primary Keys
   --
   procedure CreateAllPks(sDir varchar,
                          sOwner varchar2,
                          bGenDrop boolean);
   --
   -- Cria all Unique Constraints
   --
   procedure CreateAllUniqConst(sDir varchar,
                                sOwner varchar2,
                                bGenDrop boolean);
   --
   -- Cria unique contraints
   --
   procedure CreateUniqConst(sDir varchar2, 
                            sOwner varchar2, 
                            sTable varchar2, 
                            bGenDrop boolean);
   --
   -- Cria all Check Constraints
   --
   procedure CreateAllCheckConst(sDir varchar,
                                sOwner varchar2,
                                bGenDrop boolean);
   --
   -- Cria check constraints
   --
   procedure CreateCheckConst(sDir varchar2, 
                             sOwner varchar2, 
                             sTable varchar2, 
                             bGenDrop boolean);
   --
   -- Cria script para uma tabela
   --
   procedure CreateTable(s_dir varchar2, 
                         s_owner varchar2, 
                         s_table varchar2, 
                         gen_drop boolean);

   --
   -- Cria Primary Keys
   --
   procedure CreatePk(sDir varchar2, 
                      sOwner varchar2, 
                      sTable varchar2, 
                      bGenDrop boolean);
   --
   -- Cria all Foreign Keys
   --
   procedure CreateAllFk(sDir varchar,
                         sOwner varchar2,
                         bGenDrop boolean);
   --
   -- Cria Foreign Keys
   --
   procedure CreateFk(sDir varchar2, 
                      sOwner varchar2, 
                      sTable varchar2, 
                      bGenDrop boolean);
   --
   -- Cria all Indices
   --
   procedure CreateAllIndexes(sDir varchar,
                         sOwner varchar2,
                         bGenDrop boolean);

   --
   -- Cria Indice
   --
   procedure CreateIndex(sDir varchar2, 
                      sOwner varchar2, 
                      sTable varchar2, 
                      bGenDrop boolean);
end gen_tab_struct; 
/

create or replace package body gen_tab_struct is

   bAllTables Boolean := false;

   f_file utl_file.file_type;
   
   TableNotFound Exception;
   OpenOutputFailed Exception;
   
   procedure ShowOpenError is
   begin
      dbms_output.put_line('Nao consegue abrir arquivo de script');
      dbms_output.new_line;
      dbms_output.put_line('Verifique diretorio/permissoes');
   end;

   procedure PutLine(f_File utl_file.file_type, s_string varchar2) is
   begin
      utl_file.put_line(f_file,s_string);
   end;

   procedure StartSpool(fFile utl_file.file_type, sFile Varchar2) is
      sLine Varchar2(60);
   begin
      PutLine(fFile,'--');
      sLine := 'spool '||sFile||'.log';
      PutLine(fFile,sLine);
      PutLine(fFile,'--');
   end;

   procedure StopSpool(fFile utl_file.file_type) is
   begin
      PutLine(fFile,'spool off');
   end;

   procedure ExitTool(fFile utl_file.file_type) is
   begin
      PutLine(fFile,'exit');
   end;

   function IsNullConst(sString Varchar2) return Boolean is
   begin
      if Instr(sString,'NOT NULL') = 0 then
         return false;
      else
         return true;
      end if;
   end;

   procedure SetErrAction(f_file utl_file.file_type) is
      sLine  Varchar2(100);
   begin
      sLine := 'WHENEVER SQLERROR EXIT 1';
      PutLine(f_file,sLine);
   end;
      
   procedure SetParams(f_file utl_file.file_type) is
      sLine Varchar2(100);
   begin
      sLine := 'SET VERIFY OFF';
      PutLine(f_file,sLine);
   end;

   procedure CreateHeader(fFile utl_file.file_type,sFile Varchar2) is
      sLine Varchar2(80);
      sLineAux Varchar2(80);
   begin
      sLine := '-';
      sLine := rpad(sLine,59,'-');
      PutLine(fFile,sLine);
      sLineAux := '--              ScriptGenerator Versao 1.0.B.1  06/07/1998';
      PutLine(fFile,sLineAux);
      sLineAux := '-- Nome do Script.: '||sFile;
      PutLine(fFile,sLineAux);
      sLineAux := '-- Data de Geracao: '||to_char(sysdate,'yyyy.mm.dd');
      PutLine(fFile,sLineAux);
      sLineAux := '-- Solicitante....: '||user;
      PutLine(fFile,sLineAux);
      PutLine(fFile,'--');
      PutLine(fFile,sLine);
      SetParams(fFile);
      SetErrAction(fFile);
   end;
 
   procedure ExecCommand(fFile utl_file.file_type) is
      sLine Char(1);
   begin
      sLine := '/';
      PutLine(fFile,sLine);
   end;

   procedure OpenScriptFile(sDir Varchar2,sFile Varchar2,Modo Varchar2) is
   begin
      f_file := utl_file.fopen(sDir,sFile,Modo);

      exception
         -- Nao abriu arquivo
         when others then
            raise OpenOutputFailed;
   end;


   procedure SetStoragePar is
      sLinha varchar(100); 
   begin
      sLinha := 'TABLESPACE &'||'1';
      PutLine(f_file,sLinha);
      sLinha :='STORAGE(INITIAL &'||'2 MINEXTENTS &'||'3 NEXT &'||'4';
      PutLine(f_file, sLinha);
      sLinha := 'PCTINCREASE 0 MAXEXTENTS 100)';
      PutLine(f_file, sLinha);
   end;
 

   procedure GenCreateScript(s_dir varchar2,
                        s_owner varchar2, 
                        s_table varchar2, 
                        gen_drop boolean) is
   --
   -- Types
   --
   Type TCurRec is record
      (column_name all_tab_columns.column_name%type,
       data_type all_tab_columns.data_type%type,
       data_length all_tab_columns.data_length%type,
       data_precision all_tab_columns.data_precision%type,
       data_scale all_tab_columns.data_scale%type,
       data_default Varchar2(1000),
       nullable all_tab_columns.nullable%type);
   --
   -- Variaveis
   --
   sDefault Varchar2(1000);
   sLineOut Varchar2(2000);
   bFirstTime boolean;
   bFecha boolean;
   sOutFileName varchar2(40);
   sDirect Varchar2(300); 
   cursor c_tab_columns (tabela varchar2,dono varchar2) is
      select 
         atc.column_name,
         atc.data_type,
         atc.data_length,
	 atc.data_precision,
	 atc.data_scale,
         atc.data_default,
	 atc.nullable
      from
	 all_tab_columns atc
      where
	 atc.owner = upper(dono) and
	 atc.table_name = upper(tabela)
      order by
	 column_id;

   AuxCursor TCurRec;
   SaveCursor TCurRec;

   cursor c_cons_columns (sTabela Varchar2,sColuna Varchar2, sOwner Varchar2) is
      select
         ac.constraint_name,
         ac.search_condition
      from
         all_cons_columns acc,
         all_constraints ac
      where
         ac.owner = acc.owner and
         ac.table_name = acc.table_name and
         ac.constraint_name = acc.constraint_name and
         acc.column_name = upper(sColuna) and
         ac.constraint_type = 'C' and
         ac.table_name = upper(sTabela) and
         ac.owner = upper(sOwner);

   IntoCheck c_cons_columns%rowtype;
   --
   --
   begin
      dbms_output.enable;
      -- abre cursor com todas as colunas da tabela
      --
      open c_tab_columns(upper(s_table),upper(s_owner));
      fetch  
         c_tab_columns 
      into 
         AuxCursor;

      bFirstTime := true;

      if c_tab_columns%notfound then
         Raise TableNotFound; 
      else
         --
         -- Monta nome de arquivo com nome da tabela
         --
         sDirect := s_dir||'/crt';
         sOutFileName := upper(s_table)||'.tab';
         OpenScriptFile(sDirect,sOutFileName,'w');
         CreateHeader(f_file, sOutFileName);
         StartSpool(f_file, sOutFileName);
         --
         -- Monta linha com create table
         --
         PutLine(f_File, 'CREATE TABLE '||upper(s_table));

         while c_tab_columns%found
         loop
            SaveCursor := AuxCursor;
            fetch 
               c_tab_columns
            into
               AuxCursor;

            if bFirstTime then
               PutLine(f_file, '(');
               bFirstTime := false;
            end if;

            sLineOut := rpad(SaveCursor.column_name,30,' ');
            PutLine(f_file,sLineOut);

            sLineOut := '     '||SaveCursor.data_type;

            bFecha := false;
            if SaveCursor.data_type = 'NUMBER' then
               if SaveCursor.data_precision != 0 then
                  sLineOut := sLineOut||'('||to_char(SaveCursor.data_precision);
                  bFecha := true;
               end if;
               if SaveCursor.data_scale != 0 then
                  sLineOut := sLineOut||','||to_char(SaveCursor.data_scale);
                  bFecha := true;
               end if;
               if bFecha then
                  sLineOut := sLineOut||')';
               end if;
            end if;

            --Varchar2

            if SaveCursor.data_type = 'VARCHAR2' or
               SaveCursor.data_type = 'CHAR' then
               if SaveCursor.data_length != 0 then
                 sLineOut := sLineOut||'('||to_char(SaveCursor.data_length)||')';
               end if;
            end if;

            if SaveCursor.data_type = 'FLOAT' then
               if SaveCursor.data_precision != 0 then
                 sLineOut := sLineOut||'('||to_char(SaveCursor.data_precision)||')';
               end if;
            end if;
 
            sDefault := SaveCursor.data_default;
            if nvl(sDefault,'x') != 'x'  then
               sLineOut := sLineOut||chr(10)||
                           '     DEFAULT '||rtrim(SaveCursor.data_default,' ');
            end if;
            
            
            if SaveCursor.nullable = 'N' then
               sLineOut := sLineOut||chr(10)||'     NOT NULL'; 
            end if;

            open c_cons_columns(s_table,SaveCursor.column_name,s_owner);
            fetch c_cons_columns into IntoCheck;
            while c_cons_columns%found
            loop
               -- 
               -- So cria constraint no CREATE TABLE se nome foi dado pelo
               -- Banco
               --
               if instr(IntoCheck.constraint_name,'SYS_') > 0 then
                  if instr(IntoCheck.search_condition,'NOT NULL') = 0 then
                     sLineOut := sLineOut||chr(10)||
                     '     CHECK ('||IntoCheck.search_condition||')';
                  end if;
               end if;
               fetch c_cons_columns into IntoCheck;
            end loop;

            close c_cons_columns;

            if c_tab_columns%found then
               sLineOut := sLineOut || ',';
            end if;
            PutLine(f_file,sLineOut);
            sLineOut := '';
         end loop;
         PutLine(f_file,')');
         --
         -- Gera Storage parameters
         --
         sLineOut := '';
         SetStoragePar;
         --
         -- Pct Free/Used
         --
         sLineOut := 'PCTFREE &'||'5'||' PCTUSED &'||'6'||' INITRANS &'||'7'; 
         PutLine(f_file,sLineOut);
         ExecCommand(f_file);
         sLineOut := 'GRANT SELECT, INSERT, UPDATE, DELETE ON '||s_table||
            ' TO BSCS_ROLE';
         PutLine(f_file,sLineOut);
         ExecCommand(f_file);
         sLineOut := 'CREATE PUBLIC SYNONYM '||s_table||' FOR '||s_owner||
         '.'||s_table;
         PutLine(f_file,sLineOut);
         ExecCommand(f_file);
         StopSpool(f_file);
         ExitTool(f_file);
         utl_file.fclose(f_file);
      end if;
      close c_tab_columns;
      exception
         when TableNotFound then
            dbms_output.put_line('Tabela '||s_table||' nao existe');

         when OpenOutputFailed then
            ShowOpenError;
            if bAllTables then
               Raise;
            end if;
   end;

procedure CreateAllTables(s_dir varchar,
                            s_owner varchar2,
                            gen_drop boolean) is

   --
   -- Variaveis
   --
   cursor c_SchemaTables (s_schema varchar2) is
      select
         table_name
      from
         all_tables
      where
         owner = upper(s_schema);

   into_cursor c_SchemaTables%rowtype;
   --
   --
   begin
      bAllTables := true;
      open c_SchemaTables(s_owner);
      fetch c_SchemaTables into into_cursor;
      while c_SchemaTables%Found
      loop
         CreateTable(s_dir,s_owner,into_cursor.table_name,false);
         fetch c_SchemaTables into into_cursor;
      end loop;
      bAllTables := false;
      exception
         when OpenOutputFailed then
            bAllTables := false;
      
   end;




   procedure CreateAllPks(sDir varchar,
                       sOwner varchar2,
                       bGenDrop boolean) is
   --
   -- Variaveis
   --
   cursor c_SchemaTables (s_schema varchar2) is
      select
         table_name
      from
         all_constraints
      where
         constraint_type = 'P' and
         owner = upper(s_schema);

   into_cursor c_SchemaTables%rowtype;
   --
   --
   begin
      bAllTables := true;
      open c_SchemaTables(sOwner);
      fetch c_SchemaTables into into_cursor;
      while c_SchemaTables%Found
      loop
         CreatePk(sDir,sOwner,into_cursor.table_name,false);
         fetch c_SchemaTables into into_cursor;
      end loop;
      bAllTables := false;

      exception
         when others then
            bAllTables := false;

   end; -- CreateAllPks


   procedure CreateAllUniqConst(sDir varchar,
                                sOwner varchar2,
                                bGenDrop boolean) is
   --
   -- Variaveis
   --
   cursor c_SchemaTables (s_schema varchar2) is
      select
         distinct table_name
      from
         all_constraints
      where
         owner = upper(s_schema) and
         constraint_type = 'U';

   into_cursor c_SchemaTables%rowtype;
   --
   --
   begin
      open c_SchemaTables(sOwner);
      fetch c_SchemaTables into into_cursor;
      while c_SchemaTables%Found
      loop
         CreateUniqConst(sDir,sOwner,into_cursor.table_name,false);
         fetch c_SchemaTables into into_cursor;
      end loop;
   end; -- CreateAllUniqConst

   procedure CreatePk(sDir varchar2, 
                      sOwner varchar2, 
                      sTable varchar2, 
                      bGenDrop boolean) is
   --
   -- Variaveis
   --
   sLineOut varchar2(80);
   sLineAux varchar2(100); 
   bFirstTime boolean; 
   bFecha boolean; 
   sDirect Varchar2(200);
   sOutFileName varchar2(40); 
   cursor cPkColumns (tabela varchar2,dono varchar2) is
   select
      a.constraint_name,
      a.table_name,
      c.column_name
   from
      all_cons_columns c,
      all_constraints a
   where
      a.constraint_name = c.constraint_name and
      a.owner = c.owner and
      a.constraint_type = 'P' and
      a.owner = upper(dono) and
      a.table_name = upper(tabela) 
   order by
      c.position;

   AuxCursor cPkColumns%rowtype;
   SaveCursor cPkColumns%rowtype;
   --
   --
   begin
      -- abre cursor com todas as colunas da tabela
      --
      open cPkColumns(upper(sTable),upper(sOwner));
      fetch  
         cPkColumns 
      into 
         AuxCursor;

      bFirstTime := true;

      if cPkColumns%found then
         --
         -- Monta nome de arquivo com nome da tabela
         --
         sDirect := sDir||'/pk';

         sOutFileName := upper(AuxCursor.constraint_name)||'.pk';

         OpenScriptFile(sDirect,sOutFileName,'w');
         CreateHeader(f_file,sOutFileName);
         StartSpool(f_file,sOutFileName);
         --
         -- Monta linha com alter table
         --
         sLineAux := 'ALTER TABLE '||upper(sTable);
         PutLine(f_File, sLineAux);
         sLineAux := 'ADD CONSTRAINT '||
                     AuxCursor.constraint_name||' PRIMARY KEY '; 

         PutLine(f_File, sLineAux);

         while cPkColumns%found
         loop
            SaveCursor := AuxCursor;
            fetch 
               cPkColumns
            into
               AuxCursor;
            if bFirstTime then
               sLineOut := '(';
               bFirstTime := false;
            end if;

            sLineOut := sLineOut||SaveCursor.column_name;
            bFecha := false;

            if cPkColumns%notfound then
               sLineOut := sLineOut || ')';
            else
               sLineOut := sLineOut || ',';
            end if;
            PutLine(f_file,sLineOut);
            sLineOut := '';
         end loop;

         --
         -- Gera Storage parameters
         --
         sLineOut := 'USING INDEX';
         PutLine(f_file,sLineOut);
         /*' TABLESPACE &'||'1';
         PutLine(f_file,sLineOut); 
         sLineOut := 'STORAGE(INITIAL &'||'2 NEXT &'||'3 PCTINCREASE 0 '||
                     'MAXEXTENTS 100)';
         PutLine(f_file,sLineOut); 
         */
         SetStoragePar;
         sLineOut := 'PCTFREE &'||'5'||' INITRANS &'||'6';
         PutLine(f_file,sLineOut);
         ExecCommand(f_file);
         StopSpool(f_file);
         ExitTool(f_file);
         utl_file.fclose(f_file);
      end if;
      close cPkColumns;

      exception
         when OpenOutputFailed then
            ShowOpenError;
            if bAllTables then
               Raise;
            end if;
   end;
--
--
--
--
--

   procedure CreateUniqConst(sDir varchar2, 
                            sOwner varchar2, 
                            sTable varchar2, 
                            bGenDrop boolean) is
   --
   -- Variaveis
   --
   sLineOut varchar2(80);
   sLineAux varchar2(100); 
   bFirstTime boolean; 
   bFecha boolean; 
   sOutFileName varchar2(40); 
   sDirect Varchar2(200);
   sConstraintAnt Varchar(30);
   cursor cPkColumns (tabela varchar2,dono varchar2) is
   select
      a.constraint_name,
      a.table_name,
      c.column_name
   from
      all_cons_columns c,
      all_constraints a
   where
      a.owner = c.owner and
      a.constraint_name = c.constraint_name and
      a.constraint_type = 'U' and
      a.owner = upper(dono) and
      a.table_name = upper(tabela) 
   order by
      a.constraint_name,
      c.position;

   AuxCursor cPkColumns%rowtype;
   SaveCursor cPkColumns%rowtype;
   --
   --
   begin
      --
      -- abre cursor com todas as colunas da tabela
      --
      open cPkColumns(upper(sTable),upper(sOwner));

      bFirstTime := true;
      fetch 
         cPkColumns
      into
         AuxCursor;

      if cPkColumns%found then
         --
         -- Monta nome de arquivo com nome da tabela
         --
         sOutFileName := sTable||'.unq';

         sDirect := sDir||'/unq';
         sConstraintAnt := AuxCursor.constraint_name;
         while cPkColumns%found
         loop
            sOutFileName := upper(AuxCursor.constraint_name)||'.unq';
            OpenScriptFile(sDirect,sOutFileName,'w');
            CreateHeader(f_file,sOutFileName);
            StartSpool(f_file,sOutFileName);
            --
            -- Monta linha com alter table
            --
            sLineAux := 'ALTER TABLE '||upper(sTable);
            PutLine(f_File, sLineAux);
            sLineAux := 'ADD CONSTRAINT '||
                        AuxCursor.constraint_name||' UNIQUE '; 
   
            PutLine(f_File, sLineAux);
   
            bFirstTime := true;
            while cPkColumns%found and
                  sConstraintAnt = AuxCursor.constraint_name
            loop
               SaveCursor := AuxCursor;
               fetch 
                  cPkColumns
               into
                  AuxCursor;
   
                  if bFirstTime then
                     sLineOut := '(';
                     bFirstTime := false;
                  end if;
   
                  sLineOut := sLineOut||SaveCursor.column_name;
                  bFecha := false;
   
                  if cPkColumns%notfound or
                     sConstraintAnt != AuxCursor.constraint_name then
                     sLineOut := sLineOut || ')';
                  else
                     sLineOut := sLineOut || ',';
                  end if;
                  PutLine(f_file,sLineOut);
                  sLineOut := '';
            end loop;

            --
            -- Gera Storage parameters
            --
            sLineOut := '';
            sLineOut := 'USING INDEX';
            PutLine(f_file,sLineOut); 
            SetStoragePar;
            sLineOut := 'PCTFREE &'||'5'||' INITRANS 12';
            PutLine(f_file,sLineOut); 
            ExecCommand(f_file);
            StopSpool(f_file);
            ExitTool(f_file);
            utl_file.fclose(f_file);
            sConstraintAnt := AuxCursor.constraint_name;
         end loop;
         utl_file.fclose(f_file);
      end if;
      close cPkColumns;
   end;
--
--
--
--

   procedure CreateAllCheckConst(sDir varchar,
                                 sOwner varchar2,
                                 bGenDrop boolean) is
   --
   -- Variaveis
   --
   cursor c_SchemaTables (s_schema varchar2) is
      select distinct
         table_name
      from
         all_constraints
      where
         constraint_type = 'C' and
         owner = upper(s_schema);

   into_cursor c_SchemaTables%rowtype;
   --
   --
   begin
      dbms_output.put_line(' cheguei ');
      open c_SchemaTables(sOwner);
      fetch c_SchemaTables into into_cursor;
      while c_SchemaTables%Found
      loop
         CreateCheckConst(sDir,sOwner,into_cursor.table_name,false);
         fetch c_SchemaTables into into_cursor;
      end loop;
   end; -- CreateAllUniqConst

   --
   --
   --
   procedure CreateCheckConst(sDir varchar2, 
                             sOwner varchar2, 
                             sTable varchar2, 
                             bGenDrop boolean) is
   --
   -- Variaveis
   --
   sLineOut varchar2(200);
   sLineAux varchar2(200); 
   bFirstTime boolean; 
   bFecha boolean; 
   sOutFileName varchar2(40); 
   sDirect Varchar2(200);
   cursor cCheckConst (tabela varchar2,dono varchar2) is
   select
      a.constraint_name,
      a.table_name,
      a.search_condition,
      ac.column_name
   from
      all_cons_columns ac,
      all_constraints a
   where
      a.owner = ac.owner and
      a.constraint_name = ac.constraint_name and
      a.owner = upper(dono) and
      a.table_name = upper(tabela) and
      a.constraint_type = 'C';

   AuxCursor cCheckConst%rowtype;
   SaveCursor cCheckConst%rowtype;
   --
   --
   begin
      --
      -- abre cursor com todas as colunas da tabela
      --
      open cCheckConst(upper(sTable),upper(sOwner));
      fetch  
         cCheckConst 
      into 
         AuxCursor;

      bFirstTime := true;

      if cCheckConst%found then
         --
         -- Monta nome de arquivo com nome da tabela
         --
         sOutFileName := upper(sTable)||'.chk';

         sDirect := sDir||'/chk';
         --
         -- Monta linha com alter table
         --
         while cCheckConst%found
         loop
            if not IsNullConst(AuxCursor.search_condition) then
               if not utl_file.is_open(f_file) then
                  OpenScriptFile(sDirect,sOutFileName,'w');
                  CreateHeader(f_file,sOutFileName);
                  StartSpool(f_file,sOutFileName);
               end if;
               sLineAux := 'ALTER TABLE '||upper(sTable);
               PutLine(f_file,sLineAux);
               sLineAux := '';
               if instr(AuxCursor.constraint_name,'SYS_',1,1) = 0 then
                  sLineAux := 'ADD CONSTRAINT '||AuxCursor.constraint_name;
                  PutLine(f_file,sLineAux);
                  sLineAux := 'CHECK('|| AuxCursor.search_condition||')' ; 
               else
                  sLineAux := ' MODIFY '||AuxCursor.column_name;
                  sLineAux := sLineAux||' CHECK ('||rtrim(AuxCursor.search_condition)||')';
               end if;
               PutLine(f_file,sLineAux);
               ExecCommand(f_file);
            end if;
 
            fetch 
               cCheckConst
            into
               AuxCursor;
         end loop;
         if utl_file.is_open(f_file) then
            StopSpool(f_file);
            ExitTool(f_file);
            utl_file.fclose(f_file);
         end if;
      end if;
      close cCheckConst;
   end;

   procedure CreateAllFk(sDir varchar,
                         sOwner varchar2,
                         bGenDrop boolean) is
   --
   -- Variaveis
   --
   cursor c_SchemaTables (s_schema varchar2) is
      select distinct
         table_name
      from
         all_constraints
      where
         constraint_type = 'R' and
         owner = upper(s_schema);

   into_cursor c_SchemaTables%rowtype;
   --
   --
   begin
      open c_SchemaTables(sOwner);
      fetch c_SchemaTables into into_cursor;
      while c_SchemaTables%Found
      loop
         CreateFk(sDir,sOwner,into_cursor.table_name,false);
         fetch c_SchemaTables into into_cursor;
      end loop;
   end; -- CreateFk

   procedure CreateFk(sDir varchar2, 
                      sOwner varchar2, 
                      sTable varchar2, 
                      bGenDrop boolean) is
   --
   -- Variaveis
   --
   sLineOut varchar2(200);
   sLineAux varchar2(100); 
   bFirstTime boolean; 
   bFecha boolean; 
   sDirect Varchar2(200);
   sOutFileName varchar2(40); 
   sConstraintAnt Varchar2(30);
   sReferencedColumns Varchar2(2000); 
   -- 
   -- Cursor com tabelas e colunas envolvidas 
   -- 
   cursor cFkColumns (tabela varchar2,dono varchar2) is 
   select
      fk.constraint_name fk_constraint,
      fk.r_constraint_name pk_constraint,
      fk.table_name fk_table,
      fk.delete_rule,
      pk.table_name pk_table,
      cc.column_name fk_column,
      pkc.column_name pk_column
   from
      all_cons_columns cc,
      all_cons_columns pkc,
      all_constraints pk,
      all_constraints fk
   where
      fk.owner = pk.owner and
      fk.r_constraint_name = pk.constraint_name and 
      fk.owner = cc.owner and
      fk.constraint_name = cc.constraint_name and
      fk.table_name = cc.table_name and
      pk.owner = pkc.owner and
      pk.constraint_name = pkc.constraint_name and
      pk.table_name = pkc.table_name and
      cc.position = pkc.position and
      fk.constraint_type = 'R' and
      fk.table_name = upper(tabela) and
      fk.owner = upper(dono)
   order by
      fk_constraint,
      cc.position;

   AuxCursor cFkColumns%rowtype;
   SaveCursor cFkColumns%rowtype;
   --
   --
   begin
      --
      -- abre cursor 
      --
      open cFkColumns(upper(sTable),upper(sOwner));
      fetch  
         cFkColumns 
      into 
         AuxCursor;

      bFirstTime := true;

      if cFkColumns%found then
         --
         -- Monta nome de diretorio/arquivo
         --
         sDirect := sDir||'/fk';
         sOutFileName := upper(sTable)||'.fk';
         --
         -- Abre arquivo de Script
         --
         OpenScriptFile(sDirect,sOutFileName,'w');

         CreateHeader(f_file,sOutFileName);
         StartSpool(f_file,sOutFileName);
         sConstraintAnt := AuxCursor.fk_constraint;
         while cFkColumns%found
         loop 
            --
            -- Monta linha com alter table
            --
            sLineAux := 'ALTER TABLE '||upper(sTable)||' ADD CONSTRAINT '||
                        AuxCursor.fk_constraint||' FOREIGN KEY '; 

            PutLine(f_File, sLineAux);

            bFirstTime := true;
            --
            -- Adiciona colunas que fazem parte da FK
            --
            while cFkColumns%found and
                  sConstraintAnt = AuxCursor.fk_constraint
            loop
               SaveCursor := AuxCursor;
               fetch 
                  cFkColumns
               into
                  AuxCursor;

               if bFirstTime then
                  sLineOut := '(';
                  sReferencedColumns := '     (';
                  bFirstTime := false;
               end if;

               sLineOut := sLineOut||SaveCursor.fk_column;
               sReferencedColumns := sReferencedColumns||SaveCursor.pk_column; 
               if cFkColumns%notfound or
                  sConstraintAnt != AuxCursor.fk_constraint then
                  sLineOut := sLineOut || ')';
                  sReferencedColumns := sReferencedColumns||')';
               else
                  sLineOut := sLineOut || ',';
                  sReferencedColumns := sReferencedColumns||','||chr(10)||'     ';
               end if;
   
               PutLine(f_file,'     '||sLineOut);
               sLineOut := '';
            end loop;
   
            --
            -- Adiciona Tabela referenciada
            --
            sLineOut := 'REFERENCES '||SaveCursor.pk_table;
            PutLine(f_file,sLineOut);
            sLineOut := sReferencedColumns;
            PutLine(f_file,sLineOut);
            sReferencedColumns := ''; 
            --
            -- Adiciona regra de integridade --
            --
            if upper(SaveCursor.delete_rule) = 'CASCADE' then
               sLineOut := 'ON DELETE CASCADE';
               PutLine(f_file,sLineOut);
            end if;
            ExecCommand(f_file);
            sConstraintAnt := AuxCursor.fk_constraint;
            
         end loop;
         StopSpool(f_file);
         ExitTool(f_file);
         utl_file.fclose(f_file);
      end if;
      close cFkColumns;
   end; -- CreateFk


   procedure CreateAllIndexes(sDir varchar,
                         sOwner varchar2,
                         bGenDrop boolean) is
   --
   -- Variaveis
   --
   cursor c_SchemaTables (s_schema varchar2) is
      select distinct
         ai.table_name,
         ai.index_name
      from
         all_indexes ai
      where
         ai.owner = upper(s_schema)
      minus
      select
         ac.table_name,
         ac.constraint_name
      from
         all_indexes ai,
         all_constraints ac
      where
         ac.constraint_name = ai.index_name and
         ac.constraint_type in ('P','U') and
         ac.owner = upper(s_schema);


   into_cursor c_SchemaTables%rowtype;
   --
   --
   begin
      bAllTables := true;
      dbms_output.enable(2000);
      open c_SchemaTables(sOwner);
      fetch c_SchemaTables into into_cursor;
      while c_SchemaTables%Found
      loop
         CreateIndex(sDir,sOwner,into_cursor.table_name,false);
         fetch c_SchemaTables into into_cursor;
      end loop;
      bAllTables := false;
      exception
         when OpenOutputFailed then
            bAllTables := false;
   end; -- CreateAllIndexes

   procedure CreateIndex(sDir varchar2, 
                      sOwner varchar2, 
                      sTable varchar2, 
                      bGenDrop boolean) is
   --
   -- Variaveis
   --
   sLineOut varchar2(80);
   sLineAux varchar2(100); 
   bFirstTime boolean; 
   bFecha boolean; 
   sDirect Varchar2(200);
   sOutFileName varchar2(40); 
   sConstraintAnt Varchar2(30);
   --
   -- Cursor com tabelas e colunas envolvidas
   --
   cursor cIndexes (tabela varchar2,dono varchar2) is
   select
      ai.index_name,
      ai.table_name,
      ai.uniqueness,
      ac.column_name
   from
      all_ind_columns ac,
      all_indexes ai
   where
      ai.owner = ac.index_owner and
      ai.index_name = ac.index_name and
      ai.table_owner = ac.table_owner and
      ai.table_name = ac.table_name and
      ai.table_name = upper(tabela) and
      ai.owner = upper(dono) and
      (ai.owner,ai.index_name) not in
      (select owner,constraint_name from all_constraints where
       constraint_type in ('P','U'))
   order by
      ai.index_name,
      ac.column_position;

   AuxCursor cIndexes%rowtype;
   SaveCursor cIndexes%rowtype;
   --
   --
   begin
      --
      -- abre cursor 
      --
      open cIndexes(upper(sTable),upper(sOwner));
      fetch  
         cIndexes 
      into 
         AuxCursor;

      bFirstTime := true;

      if cIndexes%found then
         --
         -- Monta nome de diretorio/arquivo
         --
         sDirect := sDir||'/idx';
         sOutFileName := sTable||'.idx';

         sConstraintAnt := AuxCursor.index_name;
         while cIndexes%found
         loop 
            sOutFileName := upper(AuxCursor.index_name)||'.idx';
            --
            -- Abre arquivo de Script
            --
            OpenScriptFile(sDirect,sOutFileName,'w');
            CreateHeader(f_file,sOutFileName);
            StartSpool(f_file,sOutFileName);
            
            --
            -- Monta linha com create
            --
            sLineAux := 'CREATE';
            if AuxCursor.uniqueness = 'UNIQUE' then
               sLineAux := sLineAux||' '||AuxCursor.uniqueness;
            end if;
            sLineAux := sLineAux ||' INDEX '||upper(AuxCursor.index_name);
            sLineAux := sLineAux||' ON '||AuxCursor.table_name;
            PutLine(f_File, sLineAux);

            bFirstTime := true;
            --
            -- Adiciona colunas que fazem parte do indice 
            --
            while cIndexes%found and
                  sConstraintAnt = AuxCursor.index_name
            loop
               SaveCursor := AuxCursor;
               fetch 
                  cIndexes
               into
                  AuxCursor;

               if bFirstTime then
                  sLineOut := '(';
                  bFirstTime := false;
               end if;

               sLineOut := sLineOut||SaveCursor.column_name;
   
               if cIndexes%notfound or
                  sConstraintAnt != AuxCursor.index_name then
                  sLineOut := sLineOut || ')';
               else
                  sLineOut := sLineOut || ',';
               end if;
   
               PutLine(f_file,sLineOut);
               sLineOut := '';
            end loop;
            SetStoragePar; 
            sLineOut := 'PCTFREE &'||'5'||' INITRANS 12';
            PutLine(f_file,sLineOut);
            ExecCommand(f_file);
            sConstraintAnt := AuxCursor.index_name;
            StopSpool(f_file);
            ExitTool(f_file);
            utl_file.fclose(f_file); 
         end loop;
      end if;
      close cIndexes;

      exception
         when OpenOutputFailed then
            ShowOpenError;
            if bAllTables then
               Raise;
            end if;

   end; -- CreateIndex

   procedure CreateTable(s_dir varchar2,
                        s_owner varchar2, 
                        s_table varchar2, 
                        gen_drop boolean) is
   begin
      dbms_output.enable(2000);
      GenCreateScript(s_dir, s_owner, s_table, gen_drop );
      CreateCheckConst(s_dir, s_owner, s_table, gen_drop );
      CreatePk(s_dir, s_owner, s_table, gen_drop );
      CreateFk(s_dir, s_owner, s_table, gen_drop );
      CreateIndex(s_dir, s_owner, s_table, gen_drop );
      CreateUniqConst(s_dir, s_owner, s_table, gen_drop );
   end;

end gen_tab_struct;

/
