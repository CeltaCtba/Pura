CREATE OR REPLACE FUNCTION comp.create_modules_profile(obj comp.t_profile)
  RETURNS void AS
$BODY$
declare
begin

insert  into comp.system_module_profile  (id,id_module,id_profile)
select 	data.get_sequence_nextval('COMP.SYSTEM_MODULE_PROFILE_SEQ',1),id,obj.id
from	comp.system_module m
where	id not in (select id_module
		from	comp.system_module_profile smp	
		where	id_profile = obj.id);

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
