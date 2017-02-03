CREATE OR REPLACE FUNCTION comp.get_comp_attribute_name(id_comp_attribute_p numeric)
  RETURNS character varying AS
$BODY$
DECLARE
name_v character varying;
registro_v record;
BEGIN

select 		coalesce(max(ta.name),'') 
into		name_v
from		comp.component_attribute ca
join		comp.table_attribute ta on ca.id_table_attribute = ta.id
where		ca.id = id_comp_attribute_p;

if (name_v = '') then
	
	for registro_v in 
	select	comp.get_comp_attribute_name(id_comp_attribute) as name
	from 	comp.attribute_event_dispacher
	where	id_comp_attribute_dest = id_comp_attribute_p
	loop
		if(name_v = '') then
			name_v := '('||registro_v.name;
		else
			name_v := name_v ||','||registro_v.name;
		end if;
	end loop;
	if( name_v = '') then
		name_v := '(';
	end if;
	name_v := name_v ||')';
	
	select 	so.name||name_v
	into	name_v
	from	comp.system_object so
	join	comp.component_attribute ca on so.id = ca.id_system_object
	where	ca.id = id_comp_attribute_p;
	
end if;

RETURN name_v;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
