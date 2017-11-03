select i.TABLE_NAME, i.index_name, ic.column_position, ic.column_name from dba_indexes i, dba_ind_columns ic 
	WHERE i.TABLE_NAME = 'PS_CO_STATUS_EMAIL'
      	and i.index_name=ic.index_name
        	order by i.table_name