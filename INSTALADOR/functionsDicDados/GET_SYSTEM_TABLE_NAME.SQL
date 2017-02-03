CREATE OR REPLACE FUNCTION comp.get_system_table_name(id_system_table_p numeric)
 RETURNS character varying
 LANGUAGE plpgsql
AS $function$
DECLARE
name_v character varying;
BEGIN

select 	coalesce(name,'')
into	name_v
from 	comp.system_table
where 	id = id_system_table_p;

RETURN name_v;

END;
$function$
