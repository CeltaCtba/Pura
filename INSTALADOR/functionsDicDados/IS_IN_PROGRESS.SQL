CREATE OR REPLACE FUNCTION comp.is_in_progress(in vfunction_name character varying, out vresult boolean )
  RETURNS boolean AS
$BODY$
declare
vcount integer;
BEGIN
	select 	count(1)
	into	vcount
	from 	pg_stat_activity
	where 	position(lower($1) in lower(query))>0
	and	lower(state) = 'active';

	if vcount > 1 then
		$2 := true;
	else
		$2 := false;
	end if;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
