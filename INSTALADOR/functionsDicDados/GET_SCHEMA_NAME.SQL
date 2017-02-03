CREATE OR REPLACE FUNCTION comp.get_schema_name(id_database_schema_p numeric)
 RETURNS character varying
 LANGUAGE plpgsql
AS $function$
DECLARE
name_v character varying;

BEGIN

select 		coalesce(max(name),'') 
into		name_v
from 		comp.database_schema
where		id = id_database_schema_p;

RETURN name_v;

END;
$function$
