CREATE OR REPLACE FUNCTION comp.get_table_attribute_name(id_table_attribute_p numeric)
 RETURNS character varying
 LANGUAGE plpgsql
AS $function$
DECLARE
name_v character varying;
BEGIN

select 	coalesce(name,'')
into	name_v
from 	comp.table_attribute
where 	id = id_table_attribute_p;

RETURN name_v;

END;
$function$
