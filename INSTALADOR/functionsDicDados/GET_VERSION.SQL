CREATE OR REPLACE FUNCTION comp.get_version(dt_alter_p date)
 RETURNS numeric
 LANGUAGE plpgsql
AS $function$
DECLARE

id_version_w 	numeric(10,0);
	
BEGIN
	
SELECT 	id 
INTO 	id_version_w 
FROM 	COMP.version
WHERE 	$1 between dt_initial and dt_generation;

return id_version_w;
	
END;
$function$
