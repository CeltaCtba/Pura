CREATE OR REPLACE FUNCTION comp.get_object_param_name(id_param_p numeric)
 RETURNS character varying
 LANGUAGE plpgsql
AS $function$
DECLARE
name_v character varying;
BEGIN

select 	coalesce(name,'')
into	name_v
from 	comp.object_param
where 	id = $1;

RETURN name_v;

END;
$function$
