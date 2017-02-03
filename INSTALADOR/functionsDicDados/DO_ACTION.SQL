CREATE OR REPLACE FUNCTION comp.do_action(ds_action_p character varying,ds_parameters  character varying default null)
  RETURNS void AS
$BODY$
declare
nr_order_p numeric;
id_action_p numeric;
begin

select	coalesce(max(nr_order),0) +1
into 	nr_order_p
from 	comp.system_action_session
where 	session = substring(cast(inet_client_addr() as character varying) from 1 for 20);
	
select	id
into	id_action_p	
from 	comp.system_action
where	upper(name) = upper(ds_action_p);

BEGIN
	INSERT INTO COMP.system_action_session(SESSION,id_action,parameters,nr_order) VALUES (substring(cast(inet_client_addr() as character varying) from 1 for 20),id_action_p,ds_parameters,nr_order_p);		
END;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
