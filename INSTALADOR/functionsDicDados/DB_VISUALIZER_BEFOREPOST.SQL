CREATE OR REPLACE FUNCTION comp.db_visualizer_beforepost(vacao character varying, obj comp.t_db_visualizer)
 RETURNS comp.t_db_visualizer
 LANGUAGE plpgsql
AS $function$
DECLARE

BEGIN


RETURN obj;

END;
$function$
