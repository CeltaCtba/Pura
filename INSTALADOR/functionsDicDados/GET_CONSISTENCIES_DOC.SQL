CREATE OR REPLACE FUNCTION comp.get_consistencies_doc(id_consistencie_p numeric)
 RETURNS character varying
 LANGUAGE plpgsql
AS $function$
DECLARE
v_name character varying ;
BEGIN
Select	comp.get_expression_text(c.id_expression_documentation) as message
into	v_name
from	comp.consistencies c
where 	c.id = id_consistencie_p;

RETURN v_name;

END;
$function$
