CREATE OR REPLACE FUNCTION comp.get_table_name_by_attribute_id(id_table_attribute_p numeric)
 RETURNS character varying
 LANGUAGE plpgsql
AS $function$
DECLARE
name_v character varying;
BEGIN

select 	st.name
into	name_v
from 	comp.table_attribute ta,
	comp.system_table st
where 	st.id = ta.id_table
and	ta.id = id_table_attribute_p;

RETURN name_v;

END;
$function$
