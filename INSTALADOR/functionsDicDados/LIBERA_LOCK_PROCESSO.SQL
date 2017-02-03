CREATE OR REPLACE FUNCTION comp.libera_lock_processo(nm_processo_p character varying, consiste_sessao_p boolean DEFAULT true)
  RETURNS void AS
$BODY$
DECLARE

BEGIN
if (consiste_sessao_p) then
	delete from comp.lock 
	where upper(lock_name) = upper(nm_processo_p) 
	and (session = substring(cast(inet_client_addr() as character varying) from 1 for 20) 
	or session = '');
else
	delete from comp.lock where upper(lock_name) = upper(nm_processo_p);
end if;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
