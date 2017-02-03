CREATE OR REPLACE FUNCTION comp.gera_manipulacao_dados_tabela(nometabela character varying)
  RETURNS text AS
$BODY$

declare
--Constantes
vprefixo_type 		constant 	character varying := 't_';
vprefixo_function 	constant 	character varying := 'dic_';
vfim_proc			constant 	character varying := ' end; ' || chr(13) || ' $body$ ' || chr(13) || ' language plpgsql volatile cost 100; ';

--Variaveis
rec 					record;
vtexto_sql				text 	:= '';
vcontador_auxiliar		integer := 0;
vrestricao_where		text 	:= '';
vid_tabela				numeric := 0;
vtxt_beforepost			text 	:= '';
vtxt_afterpost			text 	:= '';
vschema_fixo 		 	character varying;
vschema_select			character varying;
begin

execute 'show geramanip.schema_name' into vschema_select;
vschema_fixo := vschema_select;

execute 'drop type if exists ' || vschema_fixo || '.' || vprefixo_type || lower($1) || ' cascade';

vtexto_sql := 'create type ' || vschema_fixo || '.' || vprefixo_type || lower($1) || ' as (';

for rec in
	select 	lower(ta.name) attname, 
			lower(comp.get_expression_text(dv.id_expression)) as atttype,
			coalesce(ta.vl_attribute_size,0) as attsize,
			coalesce(ta.vl_decimal_size,0) as attdec_size
	from	comp.table_attribute ta,
			comp.system_table st,
			comp.domain_value dv,
			comp.database_schema ds
	where	ta.id_table = st.id
	and		ta.id_domain_value_type = dv.id
	and		st.id_database_schema = ds.id
	and		lower(st.name) = lower($1)
	and		lower(ds.name) = vschema_select
	and		lower(ta.name) not in ('dt_creation','nm_creation_user','dt_alter','nm_alter_user')	
	order 	by ta.id
loop
	vtexto_sql := vtexto_sql || rec.attname || ' ' || rec.atttype;
	if (rec.attsize <> 0) then
		vtexto_sql := vtexto_sql || '(' || rec.attsize;

		if (rec.attdec_size <> 0) then
			vtexto_sql := vtexto_sql || ',' || rec.attdec_size;			
		end if;
		vtexto_sql := vtexto_sql || ')';
	end if;
	vtexto_sql := vtexto_sql || ',' || chr(13);
end loop;

vtexto_sql := substring(vtexto_sql from 1 for (length(vtexto_sql)-2)) || ')';

execute vtexto_sql;

--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXX--XXXXXXXX--XXXXXXXX--XXX| Passo 2 - Inicio - Decodifica |XXX--XXXXXXXX--XXXXXXXX--XXXXXXX 
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
vtexto_sql := 	'create or replace function ' || vschema_fixo || '.' || vprefixo_function || 'decodifica_' || lower($1)  || '(lista_p character varying[], valida_p boolean default false) ' || chr(13) ||
				' returns ' 	|| vschema_fixo || '.' 	|| vprefixo_type || lower($1) || ' as '   || chr(13) ||
				' $body$ ' 		|| chr(13) ||
				' declare ' 	|| chr(13) ||
				' vresult ' 	|| vschema_fixo || '.' 	|| vprefixo_type 		|| lower($1) 	  ||';'|| chr(13) ||
				' subtxt 		character varying := ' 	|| quote_literal('') 	|| ';' || chr(13) ||
				' vattname 		character varying := ' 	|| quote_literal('') 	|| ';' || chr(13) ||
				' vattcontent 	character varying := ' 	|| quote_literal('') 	|| ';' || chr(13) ||
				' vpos 			integer; ' 	|| chr(13)  ||
				' vid_visualizer numeric; '	|| chr(13)  ||
				' begin ' 					|| chr(13)  ||
				' for subtxt in ' 			|| chr(13)  ||
				' select unnest($1) '	|| chr(13)  ||
				' order by 1 '				|| chr(13)  ||
				' loop '					|| chr(13)  ||
				' vpos := position(' || quote_literal('=') || ' in subtxt); ' 				|| chr(13) ||
				' vattname := lower(substring(subtxt from 1 for vpos-1));'					|| chr(13) ||
				' vattcontent := substring(subtxt from (vpos+1) for length(subtxt)-1);'		|| chr(13) ||
				' if (lower(vattname) = lower(' || quote_literal('#id_visualizer') || ')) then ' || chr(13) ||
				'    vid_visualizer := vattcontent;	'										|| chr(13) ||
				' end if; '																	|| chr(13) ||
				' if (vattcontent = ' || quote_literal('null') || ') then ' 				|| chr(13) ||
				'    vattcontent := null;	'												|| chr(13) ||
				' end if; '																	|| chr(13);
			
vcontador_auxiliar := 0;
for rec in
	select 	lower(ta.name) attname, 
			lower(comp.get_expression_text(dv.id_expression)) as atttype,
			ta.fl_not_null as flag_not_null
	from	comp.table_attribute ta,
			comp.system_table st,
			comp.domain_value dv,
			comp.database_schema ds
	where	ta.id_table = st.id
	and		ta.id_domain_value_type = dv.id
	and		st.id_database_schema = ds.id
	and		lower(st.name) = lower($1)
	and		lower(ds.name) = vschema_select
	and		lower(ta.name) not in ('dt_creation','nm_creation_user','dt_alter','nm_alter_user')	
	order 	by ta.id
loop
	vcontador_auxiliar := vcontador_auxiliar + 1;
	if (vcontador_auxiliar = 1) then
		vtexto_sql := vtexto_sql || ' if ';
	else
		vtexto_sql := vtexto_sql || ' elsif ';	
	end if;

	vtexto_sql := vtexto_sql	|| ' (vattname = ' 	|| quote_literal(rec.attname) || ') then' || chr(13)
								|| ' vresult.' 		|| rec.attname || ' := ';

	vtexto_sql := vtexto_sql 	|| ' cast(vattcontent as ' || rec.atttype || ');' || chr(13);		
	
	if (rec.flag_not_null) then
		vtexto_sql := vtexto_sql	|| 	' if ((vattname = ' 	|| quote_literal(rec.attname) || ') and ' ||
										' (vattcontent is null) and ($2 is true)) then '	|| chr(13);
		vtexto_sql := vtexto_sql	|| 	' perform comp.consist(12,';
		
		vtexto_sql := vtexto_sql	|| 	'(select coalesce(comp.get_expression_text(da.id_expression_label),vattname) ';
		vtexto_sql := vtexto_sql	|| 	'from comp.component_attribute ca ';
		vtexto_sql := vtexto_sql	|| 	'join comp.db_visualizer db on (ca.id_visualizer = db.id) ';
		vtexto_sql := vtexto_sql	|| 	'join comp.system_table st on ( db.id_system_table = st.id ) ';
		vtexto_sql := vtexto_sql	|| 	'join comp.table_attribute ta on (ta.id_table = st.id and ta.id = ca.id_table_attribute ) ';
		vtexto_sql := vtexto_sql	|| 	'left join comp.detail_attribute da on (da.id_comp_attribute = ca.id)  ';
		vtexto_sql := vtexto_sql	|| 	'where db.id = vid_visualizer ';
		vtexto_sql := vtexto_sql	|| 	'and lower(st.name) = lower(' || quote_literal($1) || ') ';
		vtexto_sql := vtexto_sql	|| 	'and lower(ta.name) = lower(vattname) ';
		vtexto_sql := vtexto_sql	|| 	'limit 1 )); ' 	|| chr(13);
		vtexto_sql := vtexto_sql	|| 	' end if; ' 	|| chr(13);
	
	end if;
end loop;
vtexto_sql := vtexto_sql || ' end if; '		|| chr(13) 	||
							' end loop; '	|| chr(13) 	||
							' return vresult; ' 		|| chr(13) || vfim_proc;

execute vtexto_sql;
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXX--XXXXXXXX--XXXXXXXX--XXXX| Passo 2 - Fim - Decodifica |XXX--XXXXXXXX--XXXXXXXX--XXXXXXXXXX 
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXX--XXXXXXXX--XXXXXXXX--XXXXX| Passo 2 - Inicio - Insere |XXXXX--XXXXXXXX--XXXXXXXX--XXXXXXXX 
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

vtexto_sql := 	'create or replace function ' || vschema_fixo || '.' || vprefixo_function || 'insere_' || lower($1)  	|| '(obj_p '  || 
				' ' 			|| vschema_fixo || '.' 	|| vprefixo_type || lower($1) || ') ' 	|| chr(13) ||				
				' returns character varying as ' 		||  chr(13) ||
				
				' $body$ ' 		|| chr(13) 	||
				' declare ' 	|| chr(13) 	||
				' vresult ' 	|| vschema_fixo || '.' 	|| vprefixo_type 		|| lower($1) 	  ||';'|| chr(13) 	||
				' rec 			record;' 	 || chr(13) ||
				' vstr_fields 	character varying := ' 	|| quote_literal('') 	|| ';' || chr(13) ||
				' vstr_values 	character varying := ' 	|| quote_literal('') 	|| ';' || chr(13) ||
				' begin ' 					|| chr(13)  ||				
				' for rec in ' 			|| chr(13)  ||
				' select lower(a.attname) as attname '		|| chr(13)  ||
				' from pg_catalog.pg_attribute a '	|| chr(13)  ||
				' where a.attrelid = '	|| quote_literal(vschema_fixo || '.' 	|| vprefixo_type  	|| lower($1)) || '::regclass ' || chr(13)	||
				' and a.attnum > 0   ' 	|| chr(13)  ||
				' and a.attisdropped = false   ' 	|| chr(13)  ||				
				' loop '							|| chr(13);
				
vcontador_auxiliar := 0;
for rec in
	select 	lower(ta.name) attname, 
			lower(comp.get_expression_text(dv.id_expression)) as atttype
	from	comp.table_attribute ta,
			comp.system_table st,
			comp.domain_value dv,
			comp.database_schema ds
	where	ta.id_table = st.id
	and		ta.id_domain_value_type = dv.id
	and		st.id_database_schema = ds.id
	and		lower(st.name) = lower($1)
	and		lower(ds.name) = vschema_select
	and		lower(ta.name) not in ('dt_creation','nm_creation_user','dt_alter','nm_alter_user')	
	order 	by ta.id
loop
	vcontador_auxiliar := vcontador_auxiliar + 1;
	if (vcontador_auxiliar = 1) then
		vtexto_sql := vtexto_sql || ' if ';
	else
		vtexto_sql := vtexto_sql || ' elsif ';	
	end if;

	vtexto_sql := vtexto_sql 	|| ' ((rec.attname = ' || quote_literal(rec.attname) || ') and ($1.' || rec.attname || ' is not null)) then' || chr(13)
								|| ' vstr_fields := vstr_fields || lower(rec.attname) || ' || quote_literal(',') 		|| ';' || chr(13)
								|| ' vstr_values := vstr_values || ';

	if ((rec.atttype = 'varchar') or (rec.atttype = 'text') or (rec.atttype = 'timestamp') or (rec.atttype = 'timestamp without time zone') or (rec.atttype = 'date') or (rec.atttype = 'bytea')) then
		if ((rec.atttype = 'varchar') or (rec.atttype = 'text')) then
			vtexto_sql := vtexto_sql || ' quote_literal(replace(cast($1.' 	|| rec.attname ||  ' as text),'	|| quote_literal('#') || ',' || quote_literal('#') || ')) || ' || quote_literal(',') || ';' || chr(13);		
		else
			vtexto_sql := vtexto_sql || ' quote_literal(cast($1.' 	|| rec.attname ||  ' as ' 	|| rec.atttype || ')) || ' || quote_literal(',') || ';' || chr(13);	
		end if;
	else 
		vtexto_sql := vtexto_sql || ' cast($1.' || rec.attname || ' as ' || rec.atttype 	|| ') || ' || quote_literal(',') || ';' || chr(13);	
	end if;
end loop;
vtexto_sql := vtexto_sql || ' end if; '		|| chr(13);
vtexto_sql := vtexto_sql || ' end loop; '	|| chr(13);
vtexto_sql := vtexto_sql || ' begin '		|| chr(13);
vtexto_sql := vtexto_sql || ' execute ' 	|| quote_literal('Insert into ' || vschema_select || '.' 	|| lower($1) || '(');
vtexto_sql := vtexto_sql || ' || substring(vstr_fields from 1 for (length(vstr_fields)-1)) || ' 	|| quote_literal(') values (') 	|| chr(13);
vtexto_sql := vtexto_sql || ' || substring(vstr_values from 1 for (length(vstr_values)-1)) || ' 	|| quote_literal(')') || ';' 	|| chr(13);
vtexto_sql := vtexto_sql || ' return ' || quote_literal('ok') || ';'	|| chr(13);
vtexto_sql := vtexto_sql || ' exception when others then '	|| chr(13);
vtexto_sql := vtexto_sql || ' return sqlerrm; '		|| chr(13);
vtexto_sql := vtexto_sql || ' end; '	|| chr(13) 	|| vfim_proc;

execute vtexto_sql;

--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXX--XXXXXXXX--XXXXXXXX--XXXXXX| Passo 2 - Fim - Insere |XXXXX--XXXXXXXX--XXXXXXXX--XXXXXXXXXX 
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXX--XXXXXXXX--XXXXXXXX--XXX| Passo 2 - Inicio - Atualiza |XXXXX--XXXXXXXX--XXXXXXXX--XXXXXXXX 
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

vtexto_sql := 	'create or replace function ' || vschema_fixo || '.' || vprefixo_function || 'atualiza_' || lower($1) 	|| '(obj_p '  || 
				' ' 			|| vschema_fixo || '.' 	|| vprefixo_type || lower($1) || ', lista_p character varying[]) ' 	|| chr(13) ||				
				' returns character varying as ' 		||  chr(13) ||
				
				' $body$ ' 		|| chr(13) 	||
				' declare ' 	|| chr(13) 	||
				' vresult ' 	|| vschema_fixo || '.' 	|| vprefixo_type 		|| lower($1) 	||';'|| chr(13) ||
				' rec 				record;' 	 || chr(13) ||
				' vexist			boolean;' 	 || chr(13) ||
				' vstr_fields 		character varying := ' 	|| quote_literal('') 		|| ';' 	|| chr(13) ||
				' vstr_values 		character varying := ' 	|| quote_literal('') 		|| ';' 	|| chr(13) ||
				' vstr_where_values character varying := ' 	|| quote_literal('where ') 	|| ';' 	|| chr(13) ||
				' begin ' 					|| chr(13)  ||				
				' for rec in ' 			|| chr(13)  ||
				' select lower(a.attname) as attname, ' 			|| chr(13) 	||
				' case when c.constraint_type is not null then ' 	|| quote_literal('s') || 
				' else ' || quote_literal('n') || ' end as key ' 	|| chr(13) 	||
				' from pg_catalog.pg_attribute a ' 					|| chr(13) 	||
				' left outer join information_schema.constraint_column_usage b '		|| chr(13) 	||
				' on (lower(b.column_name) = lower(a.attname) '	   	|| chr(13) 	||
				' and lower(b.table_schema) = ' || quote_literal(lower(vschema_select)) 	|| chr(13) 	||
				' and lower(b.table_name) = ' 	|| quote_literal(lower($1)) || ')'		|| chr(13) 	||
				' left outer join information_schema.table_constraints c on '		|| chr(13) 	||
				' (c.constraint_schema = b.table_schema '		|| chr(13) 	||
				'  and c.constraint_name = b.constraint_name '		|| chr(13) 	||
				'  and lower(c.constraint_type) = ' || quote_literal('primary key') || ')'	|| chr(13) 	||
				' where a.attrelid = ' 	|| quote_literal(lower(vschema_fixo) || '.' || vprefixo_type || lower($1)) || '::regclass' || chr(13) ||
				' and a.attnum > 0 ' 	|| chr(13) 	||
				' and a.attisdropped = false ' 		|| chr(13) ||
				' group by 1,2 ' 		|| chr(13) ||
				' order by 2 desc ' 	|| chr(13) ||
				' loop ' || chr(13);

vcontador_auxiliar := 0;
for rec in
	select 	lower(ta.name) attname, 
			lower(comp.get_expression_text(dv.id_expression)) as atttype
	from	comp.table_attribute ta,
			comp.system_table st,
			comp.domain_value dv,
			comp.database_schema ds
	where	ta.id_table = st.id
	and		ta.id_domain_value_type = dv.id
	and		st.id_database_schema = ds.id
	and		lower(st.name) = lower($1)
	and		lower(ds.name) = vschema_select
	and		lower(ta.name) not in ('dt_creation','nm_creation_user','dt_alter','nm_alter_user')
	order 	by ta.id
loop
	vcontador_auxiliar := vcontador_auxiliar + 1;
	if (vcontador_auxiliar = 1) then
		vtexto_sql := vtexto_sql || ' if ';
	else
		vtexto_sql := vtexto_sql || ' elsif ';	
	end if;

	vtexto_sql := vtexto_sql 	|| ' (rec.attname = ' || quote_literal(rec.attname) || ') then ' || chr(13);
	vtexto_sql := vtexto_sql 	|| ' if ((position(rec.attname in lower(cast($2 as character varying))) > 0) or ';
	
	if ((rec.atttype = 'varchar') or (rec.atttype = 'text')) then
		vtexto_sql := vtexto_sql 	|| '(coalesce($1.' 	|| rec.attname || ','''') <> '''')) then ' || chr(13);
	elsif ((rec.atttype = 'numeric') or (rec.atttype = 'integer') or (rec.atttype = 'smallint') or (rec.atttype = 'bigint')) then
		vtexto_sql := vtexto_sql 	|| '(coalesce($1.' 	|| rec.attname || ',0) <> 0)) then ' || chr(13);
	else
		vtexto_sql := vtexto_sql 	|| '($1.' 	|| rec.attname || ' is not null)) then ' || chr(13);	
	end if;
	
	vtexto_sql := vtexto_sql 	|| ' if (rec.key = ' 	|| quote_literal('s') 			|| ') then' || chr(13);
	vtexto_sql := vtexto_sql 	|| ' if ($1.' 	|| rec.attname || ' is not null) then' || chr(13);
	vtexto_sql := vtexto_sql 	|| ' vstr_where_values := vstr_where_values || rec.attname || ' || quote_literal('=') || ' || ';

	if ((rec.atttype = 'varchar') or (rec.atttype = 'text') or (rec.atttype = 'timestamp') or (rec.atttype = 'timestamp without time zone') or (rec.atttype = 'date') or (rec.atttype = 'bytea')) then
		if ((rec.atttype = 'varchar') or (rec.atttype = 'text')) then
			vtexto_sql := vtexto_sql || ' quote_literal(replace(cast($1.' 	|| rec.attname ||  ' as text),'	|| quote_literal('#') || ',' || quote_literal('#') || ')) || ' || quote_literal(' and ') || ';' || chr(13);
		else
			vtexto_sql := vtexto_sql || ' quote_literal(cast($1.' 	|| rec.attname ||  ' as ' 	|| rec.atttype || ')) || ' || quote_literal(' and ') || ';' || chr(13);
		end if;
	else 
		vtexto_sql := vtexto_sql || ' cast($1.' 	|| rec.attname ||  ' as ' 	|| rec.atttype || ') || ' 	|| quote_literal(' and ') || ';' || chr(13);
	end if;
	
	vtexto_sql := vtexto_sql 	|| ' else ' || chr(13);
	vtexto_sql := vtexto_sql 	|| ' vstr_where_values := vstr_where_values || rec.attname || ' || quote_literal('=null and ') || ' ;' || chr(13);
	vtexto_sql := vtexto_sql 	|| ' end if; ' || chr(13);
	vtexto_sql := vtexto_sql 	|| ' else ' || chr(13);
	vtexto_sql := vtexto_sql 	|| ' if ($1.' 	|| rec.attname || ' is not null) then' || chr(13);
	vtexto_sql := vtexto_sql 	|| ' vstr_values := vstr_values || rec.attname || ' || quote_literal('=') || ' || ';
	
	if ((rec.atttype = 'varchar') or (rec.atttype = 'text') or (rec.atttype = 'timestamp') or (rec.atttype = 'timestamp without time zone') or (rec.atttype = 'date') or (rec.atttype = 'bytea')) then
		if ((rec.atttype = 'varchar') or (rec.atttype = 'text')) then
			vtexto_sql := vtexto_sql || ' quote_literal(replace(cast($1.' 	|| rec.attname ||  ' as text),'	|| quote_literal('#') || ',' || quote_literal('#') || ')) || ' || quote_literal(',') || ';' || chr(13);
		else			
			vtexto_sql := vtexto_sql || ' quote_literal(cast($1.' 	|| rec.attname ||  ' as ' 	|| rec.atttype || ')) || ' || quote_literal(',') || ';' || chr(13);
		end if;
	else 
		vtexto_sql := vtexto_sql || ' cast($1.' 	|| rec.attname ||  ' as ' 	|| rec.atttype || ') || ' 	|| quote_literal(',') || ';' || chr(13);
	end if;
	vtexto_sql := vtexto_sql 	|| ' else ' || chr(13);
	vtexto_sql := vtexto_sql 	|| ' vstr_values := vstr_values || rec.attname || ' || quote_literal('=null,') || ' ;' || chr(13);
	vtexto_sql := vtexto_sql 	|| ' end if; ' || chr(13);
	vtexto_sql := vtexto_sql 	|| ' end if; ' || chr(13);
	vtexto_sql := vtexto_sql 	|| ' end if; ' || chr(13);
end loop;

vtexto_sql := vtexto_sql || ' end if; ' 	|| chr(13);	
vtexto_sql := vtexto_sql || ' end loop; ' 	|| chr(13);
vtexto_sql := vtexto_sql || ' begin ' 		|| chr(13);
vtexto_sql := vtexto_sql || ' execute ' 	|| quote_literal('select case when count(1) > 0 then true else false end as vexist ' || 
			'from ' || vschema_select || '.' 	|| lower($1) || ' ') || ' || substring(vstr_where_values from 1 for (length(vstr_where_values)-5)) ' ||
			' into vexist' || ';' 	|| chr(13) ;
vtexto_sql := vtexto_sql || ' if (vexist) then ' 	|| chr(13);
vtexto_sql := vtexto_sql || ' execute ' 			|| quote_literal('Update ' || vschema_select || '.'	|| lower($1) || ' set ');
vtexto_sql := vtexto_sql || ' || substring(vstr_values from 1 for (length(vstr_values)-1)) ' 	|| chr(13);
vtexto_sql := vtexto_sql || ' || '' '' || substring(vstr_where_values from 1 for (length(vstr_where_values)-5));' 				|| chr(13);
vtexto_sql := vtexto_sql || ' return ' || quote_literal('ok') || ';'	|| chr(13);
vtexto_sql := vtexto_sql || ' else'				|| chr(13);
vtexto_sql := vtexto_sql || ' return ' || quote_literal('Registro inexistente.') || ';'	|| chr(13);
vtexto_sql := vtexto_sql || ' end if;'			|| chr(13);
vtexto_sql := vtexto_sql || ' exception when others then '	|| chr(13);
vtexto_sql := vtexto_sql || ' return sqlerrm; '		|| chr(13);
vtexto_sql := vtexto_sql || ' end; '	|| chr(13) 	|| vfim_proc;

execute vtexto_sql;
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXX--XXXXXXXX--XXXXXXXX--XXXXX| Passo 2 - Fim - Atualiza |XXXXX--XXXXXXXX--XXXXXXXX--XXXXXXXXX 
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXX--XXXXXXXX--XXXXXXXX--XXXXX| Passo 2 - Inicio - Deleta |XXXXX--XXXXXXXX--XXXXXXXX--XXXXXXXX 
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

vtexto_sql := 	'create or replace function ' || vschema_fixo || '.' || vprefixo_function || 'deleta_' || lower($1) 	|| '(obj_p '  || 
				' ' 			|| vschema_fixo || '.' 	|| vprefixo_type || lower($1) || ') ' 	|| chr(13) ||				
				' returns character varying as ' 		||  chr(13) ||
				
				' $body$ ' 		|| chr(13) 	||
				' declare ' 	|| chr(13) 	||
				' vresult ' 	|| vschema_fixo || '.' 	|| vprefixo_type 		|| lower($1) 	||';'|| chr(13) ||
				' rec 				record;' 	 || chr(13) ||
				' vexist			boolean;' 	 || chr(13) ||
				' vstr_where_values character varying := ' 	|| quote_literal('where ') 	|| ';' 	|| chr(13) ||
				' begin ' 					|| chr(13)  ||				
				' for rec in ' 			|| chr(13)  ||
				' select lower(a.attname) as attname, ' 			|| chr(13) 	||
				' case when c.constraint_type is not null then ' 	|| quote_literal('s') || 
				' else ' || quote_literal('n') || ' end as key ' 	|| chr(13) 	||
				' from pg_catalog.pg_attribute a ' 					|| chr(13) 	||
				' join information_schema.constraint_column_usage b '		|| chr(13) 	||
				' on (lower(b.column_name) = lower(a.attname) '	   	|| chr(13) 	||
				' and lower(b.table_schema) = ' || quote_literal(lower(vschema_select)) 	|| chr(13) 	||
				' and lower(b.table_name) = ' 	|| quote_literal(lower($1)) || ')'		|| chr(13) 	||
				' join information_schema.table_constraints c on '		|| chr(13) 	||
				' (c.constraint_schema = b.table_schema '		|| chr(13) 	||
				'  and c.constraint_name = b.constraint_name '		|| chr(13) 	||
				'  and lower(c.constraint_type) = ' || quote_literal('primary key') || ')'	|| chr(13) 	||
				' where a.attrelid = ' 	|| quote_literal(lower(vschema_fixo) || '.' || vprefixo_type || lower($1)) || '::regclass' || chr(13) ||
				' and b.constraint_name is not null'|| chr(13) ||
				' and a.attnum > 0 ' 	|| chr(13) 	||
				' and a.attisdropped = false ' 		|| chr(13) ||
				' group by 1,2 ' 		|| chr(13) ||
				' order by 2 desc ' 	|| chr(13) ||
				' loop ' || chr(13);
				
vcontador_auxiliar := 0;
for rec in
	select 	lower(ta.name) attname, 
			lower(comp.get_expression_text(dv.id_expression)) as atttype
	from	comp.table_attribute ta,
			comp.system_table st,
			comp.domain_value dv,
			comp.integrity_attribute ia,
			comp.integrity i,
			comp.database_schema ds
	where	ta.id_table = st.id
	and		ta.id_domain_value_type = dv.id
	and		ta.id = ia.id_table_attribute_origin
	and		i.id = ia.id_integrity
	and		st.id_database_schema = ds.id
	and		i.id_domain_value_type = 9
	and		lower(st.name) = lower($1)
	and		lower(ds.name) = vschema_select
	and		lower(ta.name) not in ('dt_creation','nm_creation_user','dt_alter','nm_alter_user')	
	order 	by ta.id
loop
	vcontador_auxiliar := vcontador_auxiliar + 1;
	if (vcontador_auxiliar = 1) then
		vtexto_sql := vtexto_sql || ' if ';
	else
		vtexto_sql := vtexto_sql || ' elsif ';	
	end if;

	vtexto_sql := vtexto_sql 	|| ' (rec.attname = ' 	|| quote_literal(rec.attname) 	|| ') then' || chr(13);
	vtexto_sql := vtexto_sql 	|| ' vstr_where_values := vstr_where_values || rec.attname || ' || quote_literal('=') || ' || ';

	if ((rec.atttype = 'varchar') or (rec.atttype = 'text') or (rec.atttype = 'timestamp') or (rec.atttype = 'timestamp without time zone') or (rec.atttype = 'date') or (rec.atttype = 'bytea')) then
		vtexto_sql := vtexto_sql || ' quote_literal(cast($1.' 	|| rec.attname ||  ' as ' 	|| rec.atttype || ')) || ' || quote_literal(' and ') || ';' || chr(13);
	else 
		vtexto_sql := vtexto_sql || ' cast($1.' 	|| rec.attname ||  ' as ' 	|| rec.atttype || ') || ' 	|| quote_literal(' and ') || ';' || chr(13);
	end if;
	
end loop;

if (vcontador_auxiliar = 0) then
	raise exception using message = 'A tabela ' || $1 || ' não possui uma integridade do tipo PK. Abortando...';
end if;

vtexto_sql := vtexto_sql || ' end if; ' || chr(13);
vtexto_sql := vtexto_sql || ' end loop; ' 	|| chr(13);
vtexto_sql := vtexto_sql || ' begin ' 		|| chr(13);
vtexto_sql := vtexto_sql || ' execute ' 	|| quote_literal('select case when count(1) > 0 then true else false end as vexist ' || 
			' from ' || vschema_select || '.' 	|| lower($1) || ' ') || ' || substring(vstr_where_values from 1 for (length(vstr_where_values)-5)) ' ||
			' into vexist' || ';' 	|| chr(13) ;
vtexto_sql := vtexto_sql || ' if (vexist) then ' || chr(13);
vtexto_sql := vtexto_sql || ' execute ' 		|| quote_literal('Delete from ' || vschema_select || '.'	|| lower($1) || ' ');
vtexto_sql := vtexto_sql || ' || substring(vstr_where_values from 1 for (length(vstr_where_values)-5));' || chr(13);
vtexto_sql := vtexto_sql || ' return ' || quote_literal('ok') || ';'	|| chr(13);
vtexto_sql := vtexto_sql || ' else'				|| chr(13);
vtexto_sql := vtexto_sql || ' return ' || quote_literal('Registro inexistente.') || ';'	|| chr(13);
vtexto_sql := vtexto_sql || ' end if;'			|| chr(13);
vtexto_sql := vtexto_sql || ' exception when others then '	|| chr(13);
vtexto_sql := vtexto_sql || ' return sqlerrm; '		|| chr(13);
vtexto_sql := vtexto_sql || ' end; '	|| chr(13) 	|| vfim_proc;


execute vtexto_sql;
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXX--XXXXXXXX--XXXXXXXX--XXXXXX| Passo 2 - Fim - Deleta |XXXXXX--XXXXXXXX--XXXXXXXX--XXXXXXXXX 
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--XXXXXXXX--XXXXXXXX--XXXXXXXX--XXXX| Passo 2 - Inicio - Manipula |XXXX--XXXXXXXX--XXXXXXXX--XXXXXXXX 
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

select 	ta.id
into	vid_tabela
from	comp.system_table ta,
		comp.database_schema ds
where	lower(ta.name) = lower($1)
and		lower(ds.name) = lower(vschema_select)
and		ds.id = ta.id_database_schema;

vtexto_sql := 	'create or replace function ' || vschema_fixo || '.' || vprefixo_function || 'manipula_' || lower($1) || 
				'(acao_p character varying, lista_p character varying[]) returns '  || 
				' ' 			|| vschema_fixo || '.' 	|| vprefixo_type 	|| lower($1) 	|| ' as ' 	|| chr(13) ||				
				' $body$ ' 		|| chr(13) 	||
				' declare ' 	|| chr(13) 	||
				' vregistro ' 	|| vschema_fixo || '.' 			|| vprefixo_type 	 || lower($1) 		||';'|| chr(13) ||
				' vcompletou		character varying;'			|| chr(13)	||
				' begin ' 										|| chr(13)	||				
				' vregistro := ' 		|| vschema_fixo || '.' 	|| vprefixo_function || 'decodifica_' 	|| lower($1) 	||'($2,true);' || chr(13);

	--lendo os eventos da manipulacao / beforepost
for rec in	
	select 	lower(so.name) object_name,
			lower(ds.name) schema_name,
			e.id_domain_value_type event_type,
			me.nr_order,
			so.ds_object
	from	comp.manipulation_event me,
			comp.system_object so,
			comp.event e,
			comp.database_schema ds
	where	me.id_object_manipulation = so.id
	and		e.id = me.id_event
	and		ds.id = so.id_database_schema
	and		me.id_table = vid_tabela
	and		me.fl_active is true
	order by 3
loop
	if (rec.event_type = 45) then --beforepost
		vtxt_beforepost := ' vregistro := ' || rec.schema_name || '.' || rec.object_name || '($1,vregistro);' || chr(13);
	elsif (rec.event_type = 46) then --afterpost
		vtxt_afterpost 	:= ' vregistro := ' || rec.schema_name || '.' || rec.object_name || '($1,vregistro);' || chr(13);	
	end if;
end loop;

	if (vtxt_beforepost <> '' ) then
		vtexto_sql := vtexto_sql || vtxt_beforepost || chr(13);
	end if;
	
	vtexto_sql := vtexto_sql || ' if (comp.check_consistencies('||quote_literal($1)||') > 0) then ' || chr(13);
	vtexto_sql := vtexto_sql || '	return vregistro;' 	|| chr(13);
	vtexto_sql := vtexto_sql || ' end if;' 				|| chr(13);

	vtexto_sql := vtexto_sql || ' if (lower($1) = ' 	|| quote_literal('d') 	|| ') then ' || chr(13);
	vtexto_sql := vtexto_sql || ' 	vcompletou := ' 	|| vschema_fixo || '.' 	|| vprefixo_function || 'deleta_'	|| lower($1) 	||'(vregistro);' || chr(13);


	vtexto_sql := vtexto_sql || ' elsif (lower($1) = '	|| quote_literal('i') 	|| ') then ' || chr(13) ;
	vtexto_sql := vtexto_sql || ' 	vcompletou := ' || vschema_fixo || '.' 	|| vprefixo_function || 'insere_' 	|| lower($1) 	||'(vregistro);' || chr(13);

	vtexto_sql := vtexto_sql || ' elsif (lower($1) = '	|| quote_literal('a') 	|| ') then ' || chr(13) ;
	vtexto_sql := vtexto_sql || ' 	vcompletou := ' || vschema_fixo || '.' 	|| vprefixo_function || 'atualiza_'	|| lower($1) 	||'(vregistro,$2);' || chr(13);
	vtexto_sql := vtexto_sql || ' end if; ' 		|| chr(13);

	if (vtxt_afterpost <> '' ) then
		vtexto_sql := vtexto_sql || vtxt_afterpost || chr(13);	
	end if;

	vtexto_sql := vtexto_sql || ' if (vcompletou <> '|| quote_literal('ok') 		|| ') then ' || chr(13) ;
	vtexto_sql := vtexto_sql || ' 	perform comp.consist(37,comp.retira_acentos(vcompletou));' 	|| chr(13) ;
	vtexto_sql := vtexto_sql || ' end if; ' 		|| chr(13);

	vtexto_sql := vtexto_sql || ' return vregistro;' || chr(13) ;
	vtexto_sql := vtexto_sql || vfim_proc;

execute vtexto_sql;
return '';

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
