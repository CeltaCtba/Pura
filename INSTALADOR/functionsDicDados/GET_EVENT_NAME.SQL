CREATE OR REPLACE FUNCTION comp.get_event_name(id_event_p numeric)
 RETURNS character varying
 LANGUAGE plpgsql
AS $function$
DECLARE
name_v character varying;
BEGIN

select 	coalesce(comp.get_domain_value_text(e.id_domain_value_type),'')
into	name_v
from 	comp.event e
where 	e.id = $1;

RETURN name_v;

END;
$function$
