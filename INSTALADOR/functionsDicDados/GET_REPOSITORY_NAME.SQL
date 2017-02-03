CREATE OR REPLACE FUNCTION comp.get_repository_name(id_repository_p numeric)
  RETURNS character varying AS
$BODY$
DECLARE
v_name character varying ;
BEGIN
select  name || coalesce(' - '||version,'')
into 	v_name
from	comp.repository
where	id = id_repository_p;

RETURN v_name;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
