CREATE OR REPLACE FUNCTION comp.lock_processo_timeout(nm_processo_p character varying, consiste_sessao_p boolean default true)
  RETURNS void AS
$BODY$
DECLARE
	vTempoSegundo integer;
	vContagemTempo integer;
	vContinua boolean;
	vSaiuLaco boolean;

BEGIN
	vTempoSegundo := cast(comp.get_rule_val(18) as integer);
	
	vContagemTempo := 0;
	vContinua := True;
	vSaiuLaco := False;
	
	while vContinua 
	loop
		begin
			if (consiste_sessao_p) then
				insert into comp.lock (lock_name,session) values (upper(nm_processo_p),'');
				insert into comp.lock (lock_name,session) values (upper(nm_processo_p),substring(cast(inet_client_addr() as character varying) from 1 for 20));
			else
				insert into comp.lock (lock_name,session) values (upper(nm_processo_p),'');
			end if;
			vSaiuLaco := true;
		exception
			when others then begin
				vSaiuLaco := false;
			end;
		end;
		
		if vSaiuLaco then
			vContinua := False;
		else
			perform pg_sleep(0.5); 	-- dormindo por 500ms
			
			vContagemTempo := vContagemTempo + 1;
			if vContagemTempo >= vTempoSegundo*2 then
				vContinua := False;
			end if;					
		end if;			
	end loop;
	
	if not vSaiuLaco then
		perform comp.libera_lock_processo($1,$2);
		raise exception using message = 'Exit';	
	end if;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
