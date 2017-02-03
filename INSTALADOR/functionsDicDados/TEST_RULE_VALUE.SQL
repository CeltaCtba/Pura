CREATE OR REPLACE FUNCTION comp.test_rule_value(entry character varying, id_rule numeric, user_id integer, profile_id integer, estab_id integer, OUT value boolean)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
declare
vatt_type 		character varying;
vdomain_value 	comp.rule.id_domain_value_comparison%type;
vdomain_type 	comp.rule.id_domain_value_value%type;
vactive_rule	boolean;
vsql 			text;
begin
	
	if ($2 is null) then
		raise exception using message := comp.get_expression_text(343);		
	else
		select	coalesce(fl_active,false)
		into	vactive_rule
		from	comp.rule
		where	id = $2;
		
		if not vactive_rule then
			raise exception using message := comp.get_expression_text(343);		
		end if;
	end if;
	
	select 	coalesce(lower(comp.get_expression_text(dv.id_expression)),''), coalesce(r.id_domain_value_comparison,0), coalesce(r.id_domain_value_value,0)
	into	vatt_type, vdomain_value, vdomain_type
	from	comp.domain_value dv,
			comp.rule r
	where	dv.id = r.id_domain_value_value
	and		r.id = 	coalesce($2,0);
	
	if (vatt_type = '') then
		raise exception using message := comp.get_expression_text(344);		
	end if;

	begin
		vsql := 'select cast(' || $1 || ' as ' || vatt_type || ')';
		execute vsql into $1;
	exception when others then
		raise exception using message := comp.get_macro_text(338,cast('{' || cast(coalesce($1,'') as character varying) || ',' || vsql || ',' || sqlerrm || '}' as character varying[]));		
	end;

	select 	rv.valor
	into	$6
	from	comp.rule_value rv
	where	rv.id_rule = $2
	and		rv.id_system_user = coalesce($3,0);
	
	if ($6 is null) then
		select 	rv.valor
		into	$6
		from	comp.rule_value rv
		where	rv.id_rule = $2
		and		rv.id_profile = coalesce($4,0);
		
		if ($6 is null) then
			select 	rv.valor
			into	$6
			from	comp.rule_value rv
			where	rv.id_rule = $2
			and		rv.id_establishment = coalesce($5,0);

			if ($6 is null) then
				select 	rv.valor
				into	$6
				from	comp.rule_value rv
				where	rv.id_rule = $2
				and		rv.id_system_user is null
				and		rv.id_profile is null
				and		rv.id_establishment is null;				
			end if;
		end if;
	end if;
	
	begin
		vsql := 'select cast(' || $6 || ' as ' || vatt_type || ')';
		execute vsql into $6;
	exception when others then
		raise exception using message := comp.get_macro_text(338,cast('{' || cast(coalesce($6,'') as character varying) || ',' || vsql || ',' || sqlerrm || '}' as character varying[]));		
	end;

	$6 := false;
	if (vdomain_value = 117) then 		--117 igual
		if ($1 = $6) then
			$6 := true;
		end if;
	elsif (vdomain_value = 116) then 	--116 menor
		if ($1 < $6) then
			$6 := true;
		end if;
	elsif (vdomain_value = 115) then 	--115 maior
		if ($1 > $6) then
			$6 := true;
		end if;		
	end if;
	
	return;
end;
$function$
