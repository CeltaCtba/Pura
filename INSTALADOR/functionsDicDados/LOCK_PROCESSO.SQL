CREATE OR REPLACE FUNCTION comp.lock_processo(
    nm_processo_p character varying,
    consiste_sessao_p boolean DEFAULT true)
  RETURNS void AS
$BODY$
DECLARE

BEGIN
if (consiste_sessao_p) then
	insert into comp.lock (lock_name,session) values (upper(nm_processo_p),'');
	insert into comp.lock (lock_name,session) values (upper(nm_processo_p),substring(cast(inet_client_addr() as character varying) from 1 for 20));
else
	insert into comp.lock (lock_name,session) values (upper(nm_processo_p),'');
end if;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
