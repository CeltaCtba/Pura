CREATE OR REPLACE FUNCTION comp.before_post_comp_attribute(vacao character varying, obj comp.t_component_attribute)
 RETURNS comp.t_component_attribute
 LANGUAGE plpgsql
AS $function$ 
declare
id_domain_w 	comp.component_attribute.id_domain%type;
ds_sql_w	comp.component_attribute.ds_sql%type;
begin
	if (lower(vacao) = 'a') then
		select 	id_domain, ds_sql
		into	id_domain_w, ds_sql_w
		from	comp.component_attribute
		where 	id = $2.id;
	
		if (((id_domain_w is null) and ($2.id_domain is not null)) or ((ds_sql_w is null) and ($2.ds_sql is not null)))then
			update 	comp.detail_attribute
			set	id_domain_value_type = 51,
				vl_width = 200
			where	id_domain_value_type <> 51
			and	id_comp_attribute = $2.id;
		end if;
	end if;
	return $2;
end;
 $function$
