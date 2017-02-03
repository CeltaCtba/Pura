CREATE OR REPLACE FUNCTION comp.get_module_name(id_module_p numeric)
 RETURNS character varying
 LANGUAGE plpgsql
AS $function$
DECLARE
v_name character varying ;
BEGIN
select coalesce(comp.get_expression_text(id_expression_title),'')
into 	v_name
from	comp.system_module
where	id = id_module_p;



RETURN v_name;

END;
$function$
