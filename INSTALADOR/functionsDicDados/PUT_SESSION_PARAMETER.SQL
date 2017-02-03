CREATE OR REPLACE FUNCTION comp.put_session_parameter(ds_key_p character varying, ds_param_p character varying)
  RETURNS void AS
$BODY$

begin

	begin
		insert into comp.parameters_session (id,key,value,session) 
		values (comp.get_seq_nextval('COMP.PARAMETERS_SESSION_SEQ',1),ds_key_p,ds_param_p,substring(cast(inet_client_addr() as character varying) from 1 for 20));
	exception
		when others then begin
		update	comp.parameters_session 
		set		value = ds_param_p
		where	key = ds_key_p
		and		session = substring(cast(inet_client_addr() as character varying) from 1 for 20);
		end;
	end;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
