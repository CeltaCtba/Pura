CREATE OR REPLACE FUNCTION comp.get_db_button_name(id_db_button_p numeric)
 RETURNS character varying
 LANGUAGE plpgsql
AS $function$
DECLARE
v_name character varying ;
BEGIN
select coalesce(comp.get_expression_text(id_expression_name),'')
into 	v_name
from	comp.db_button
where	id = id_db_button_p;

RETURN v_name;

END;
$function$
