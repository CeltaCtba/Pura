CREATE OR REPLACE FUNCTION comp.get_session_parameter(ds_key_p character varying)
  RETURNS character varying AS
$BODY$
declare
retorno character varying;
begin

select 	coalesce(max(value),'')
into	retorno
from	comp.parameters_session
where	upper(key) = ds_key_p
and     session = substring(cast(inet_client_addr() as character varying) from 1 for 20);

return retorno;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
