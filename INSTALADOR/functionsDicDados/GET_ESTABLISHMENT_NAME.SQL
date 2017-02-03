CREATE OR REPLACE FUNCTION comp.get_establishment_name(id_establishment_p numeric)
 RETURNS character varying
 LANGUAGE plpgsql
AS $function$
DECLARE
v_name character varying ;
BEGIN
select coalesce(name,'')
into 	v_name
from	comp.establishment
where	id = id_establishment_p;

RETURN v_name;

END;
$function$
