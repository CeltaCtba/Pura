CREATE OR REPLACE FUNCTION comp.get_system_object_name(id_system_object_p numeric)
 RETURNS character varying
 LANGUAGE plpgsql
AS $function$
DECLARE
name_v character varying;
BEGIN

select 	coalesce(name,'')
into	name_v
from 	comp.system_object
where 	id = id_system_object_p;

RETURN name_v;

END;
$function$
