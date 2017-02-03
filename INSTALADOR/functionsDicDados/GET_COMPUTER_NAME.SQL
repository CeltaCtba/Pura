CREATE OR REPLACE FUNCTION comp.get_computer_name(id_computer_p numeric)
 RETURNS character varying
 LANGUAGE plpgsql
AS $function$
DECLARE
name_v character varying;
BEGIN

select 	coalesce(name,'')
into	name_v
from 	comp.computer
where 	id = id_computer_p;

RETURN name_v;

END;
$function$
