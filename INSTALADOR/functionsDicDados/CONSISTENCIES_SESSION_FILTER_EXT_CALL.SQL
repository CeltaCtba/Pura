CREATE OR REPLACE FUNCTION comp.consistencies_session_filter_ext_call(id_p numeric)
  RETURNS boolean AS
$BODY$ 
 declare 
 qtd numeric;
 begin 
 
 select count(1)
 into   qtd
 from	comp.consistencies_session
 where 	id = id_p
 and	session = substring(cast(inet_client_addr() as character varying) from 1 for 20);
 
 return qtd > 0;
 
 
 end; 
 $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
