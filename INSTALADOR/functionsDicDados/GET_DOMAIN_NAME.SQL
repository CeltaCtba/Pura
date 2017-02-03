CREATE OR REPLACE FUNCTION comp.get_domain_name(id_domain_p numeric)
 RETURNS character varying
 LANGUAGE plpgsql
AS $function$
DECLARE
name_v character varying;
BEGIN

select 	coalesce(comp.get_expression_text(d.id_expression),'')
into	name_v
from 	comp.domain d
where 	d.id = $1;

RETURN name_v;

END;
$function$
