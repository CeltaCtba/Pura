CREATE OR REPLACE FUNCTION comp.get_system_user_name(id_system_user_p numeric)
 RETURNS character varying
 LANGUAGE plpgsql
AS $function$
DECLARE
name_v character varying;
BEGIN

select 	coalesce(name,'')
into	name_v
from 	comp.system_user
where 	id = $1;

RETURN name_v;

END;
$function$
