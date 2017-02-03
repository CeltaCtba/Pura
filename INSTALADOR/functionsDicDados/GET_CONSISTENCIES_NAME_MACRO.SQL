CREATE OR REPLACE FUNCTION comp.get_consistencies_name_macro(id_consistencie_p numeric, expression_list character varying[])
 RETURNS character varying
 LANGUAGE plpgsql
AS $function$
DECLARE
v_name character varying ;
BEGIN
Select	comp.get_macro_text(c.id_expression_message,expression_list) as message
into	v_name
from	comp.consistencies c
where 	c.id = id_consistencie_p;

RETURN v_name;

END;
$function$
