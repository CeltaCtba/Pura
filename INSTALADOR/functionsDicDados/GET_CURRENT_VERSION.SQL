CREATE OR REPLACE FUNCTION comp.get_current_version(id_application_p numeric)
 RETURNS numeric
 LANGUAGE plpgsql
AS $function$
DECLARE

id_version_w  numeric(13,4);

BEGIN

SELECT  max(id )
INTO  id_version_w 
FROM  COMP.version
where id_application = $1;


return id_version_w;

END;
$function$
