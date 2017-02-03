CREATE OR REPLACE FUNCTION comp.get_system_object_schema_name(id_system_object_p numeric)
 RETURNS character varying
 LANGUAGE plpgsql
AS $function$
DECLARE
name_v character varying;
BEGIN

select 	coalesce(ds.name,'')
into	name_v
from 	comp.system_object so
join 	comp.database_schema ds on so.id_database_schema = ds.id
where 	so.id = id_system_object_p;

RETURN name_v;

END;
$function$
