CREATE OR REPLACE FUNCTION comp.get_module_external_call_name(id_module_external_call_p numeric)
 RETURNS character varying
 LANGUAGE plpgsql
AS $function$
DECLARE
v_name character varying ;
BEGIN
select coalesce(comp.get_expression_text(id_expression_name),'')
into 	v_name
from	comp.module_external_call
where	id = id_module_external_call_p;



RETURN v_name;

END;
$function$
