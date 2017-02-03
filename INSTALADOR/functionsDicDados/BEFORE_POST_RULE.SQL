CREATE OR REPLACE FUNCTION comp.before_post_rule(vacao character varying, obj comp.t_rule)
  RETURNS comp.t_rule AS
$BODY$ 
declare
vmaster_user	boolean;
begin
	select	coalesce(u.fl_desenv_user,false)
	into 	vmaster_user	
	from	comp.system_user u
	where 	u.id = cast(comp.get_context_variable('id_user') as numeric);

	if (not vmaster_user) then
		perform comp.consist(34); 
	end if;

	return $2;
end;
 $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
