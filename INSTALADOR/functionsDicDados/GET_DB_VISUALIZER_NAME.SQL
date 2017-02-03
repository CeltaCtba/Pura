CREATE OR REPLACE FUNCTION comp.get_db_visualizer_name(id_visualizer_p numeric)
 RETURNS character varying
 LANGUAGE plpgsql
AS $function$
DECLARE
name_v character varying;
BEGIN

select 	coalesce(comp.get_expression_text(v.id_expression_title),'')
into	name_v
from 	comp.db_visualizer v
where 	id = id_visualizer_p;

RETURN name_v;

END;
$function$
