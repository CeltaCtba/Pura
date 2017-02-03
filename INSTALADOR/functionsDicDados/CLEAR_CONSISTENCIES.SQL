CREATE OR REPLACE FUNCTION comp.clear_consistencies()
  RETURNS void AS
$BODY$
begin

BEGIN
	delete from COMP.CONSISTENCIES_SESSION where SESSION = substring(cast(inet_client_addr() as character varying) from 1 for 20);
	delete from COMP.QUESTIONS_SESSION where SESSION = substring(cast(inet_client_addr() as character varying) from 1 for 20);
	delete from COMP.SYSTEM_ACTION_SESSION where SESSION = substring(cast(inet_client_addr() as character varying) from 1 for 20);
EXCEPTION WHEN OTHERS THEN
	RAISE EXCEPTION USING MESSAGE = INITCAP(SQLERRM);
END;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
