CREATE OR REPLACE FUNCTION comp.get_folder_title(id_folder_p numeric)
 RETURNS character varying
 LANGUAGE plpgsql
AS $function$
DECLARE
name_v character varying;
BEGIN

select 	coalesce(comp.get_expression_text(f.id_expression_title),'')
into	name_v
from 	comp.folder f
where 	id = id_folder_p;

RETURN name_v;

END;
$function$
