CREATE OR REPLACE FUNCTION comp.get_system_action_name(id_action_p numeric)
  RETURNS character varying AS
$BODY$
DECLARE
name_v character varying;
BEGIN

select 	coalesce(name,'')
into	name_v
from 	comp.system_action
where 	id = id_action_p;

RETURN name_v;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
