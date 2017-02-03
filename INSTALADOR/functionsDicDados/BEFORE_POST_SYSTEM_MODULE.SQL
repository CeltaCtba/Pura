CREATE OR REPLACE FUNCTION comp.before_post_system_module(vacao character varying, obj comp.t_system_module)
  RETURNS comp.t_system_module AS
$BODY$ 
declare
vmaster_user	boolean;
begin
	select	coalesce(u.fl_desenv_user,false)
	into 	vmaster_user	
	from	comp.system_user u
	where 	u.id = cast(comp.get_context_variable('id_user') as numeric);

	if (not vmaster_user) then
		perform comp.consist(35); 
	end if;

	return $2;
end;
 $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
