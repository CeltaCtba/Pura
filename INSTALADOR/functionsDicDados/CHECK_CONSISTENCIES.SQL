CREATE OR REPLACE FUNCTION comp.check_consistencies(IN tablename character varying, OUT count integer)
  RETURNS integer AS
$BODY$
begin

	select 	count(1)
	into	$2
	from	COMP.CONSISTENCIES_SESSION cs
	join		comp.consistencies c on (c.id = cs.id_consistencie)
	left join	comp.system_table st on (st.id = c.id_table and lower(st.name) = lower($1))
	where	cs.SESSION = substring(cast(inet_client_addr() as character varying) from 1 for 20)
	and	c.id_domain_value_type = 124;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
