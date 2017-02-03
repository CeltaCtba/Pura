CREATE OR REPLACE FUNCTION comp.create_modules_profile_enabled(obj comp.t_profile)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
declare
qtd numeric;
begin

select 	count(1)
into	qtd
from	comp.system_module m
where	id not in (select id_module
		from	comp.system_module_profile smp	
		where	id_profile = obj.id);
return qtd > 0;		

end;
$function$
