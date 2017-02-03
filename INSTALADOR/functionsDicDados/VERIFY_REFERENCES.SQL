create or replace function comp.verify_references(id_application_p numeric, id_object_p numeric, ds_object_p text)
 returns void
 language plpgsql
as $function$
declare
	rec record;
	existe_v boolean;
begin
	for rec in
		select 	distinct upper(so.name) as name_v,
			so.id as id_v
		from 	comp.system_object so
		where 	so.id_domain_value_type in (13,32)
		and 	so.id_application = $1
	loop
		if ((position(rec.name_v in upper($3))>0) and ($2 <> rec.id_v)) then
			
			select 	case when sor.id is not null then true else false end as flag
			into	existe_v 
			from 	comp.system_object_reference sor
			where	sor.id_object_origin = $2
			and	sor.id_object_destiny = rec.id_v;

			existe_v := coalesce(existe_v,false);

			if not existe_v then				
				insert into comp.system_object_reference
				(id_object_origin,id_object_destiny) 
				values 
				($2,rec.id_v);
			end if;
		end if;
	end loop;
end;
$function$
