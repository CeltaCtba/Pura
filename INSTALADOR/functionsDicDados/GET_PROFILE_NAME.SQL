CREATE OR REPLACE FUNCTION comp.get_profile_name(id_profile_p numeric)
 RETURNS character varying
 LANGUAGE plpgsql
AS $function$
DECLARE
v_name character varying ;
BEGIN
select coalesce(name,'')
into 	v_name
from	comp.profile
where	id = id_profile_p;

RETURN v_name;

END;
$function$
