CREATE OR REPLACE FUNCTION comp.get_user_name(id_user_p numeric)
 RETURNS character varying
 LANGUAGE plpgsql
AS $function$
DECLARE
v_name character varying ;
BEGIN
select coalesce(name,'')
into 	v_name
from	comp.system_user
where	id = id_user_p;

RETURN v_name;

END;
$function$
