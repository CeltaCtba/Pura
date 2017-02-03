CREATE OR REPLACE FUNCTION comp.get_application_name(id_application_p numeric)
 RETURNS character varying
 LANGUAGE plpgsql
AS $function$
DECLARE
name_v character varying;

BEGIN

select 		coalesce(comp.get_expression_text(coalesce(max(id_expression),0)),'') 
into		name_v
from 		comp.application
where		id = id_application_p;

RETURN name_v;

END;
$function$
