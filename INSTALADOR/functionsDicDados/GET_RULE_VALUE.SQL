CREATE OR REPLACE FUNCTION comp.get_rule_value(IN rule_id numeric, IN user_id numeric, IN profile_id numeric, IN estab_id numeric, IN computer_id numeric, OUT value character varying)
  RETURNS character varying AS
$BODY$
declare
vatt_type 		character varying;
vdomain_vl 		comp.rule.id_domain_value_comparison%type;
vdomain_type 	comp.rule.id_domain_value_value%type;
vdefault_vl	comp.rule.vl_default%type;
vactive_rule	boolean;
vsql 			text;
begin
	
	if ($1 is null) then
		raise exception using message := comp.get_expression_text(343);		
	else
		select	coalesce(fl_active,false)
		into	vactive_rule
		from	comp.rule
		where	id = $1;
		
		if not vactive_rule then
			raise exception using message := comp.get_expression_text(343);		
		end if;
	end if;
	
	select 	coalesce(lower(comp.get_expression_text(dv.id_expression)),''), 
		coalesce(r.id_domain_value_comparison,0), 
		coalesce(r.id_domain_value_value,0),
		coalesce(r.vl_default,'')
	into	vatt_type, vdomain_vl, vdomain_type, vdefault_vl
	from	comp.domain_value dv,
			comp.rule r
	where	dv.id = r.id_domain_value_value
	and		r.id = 	coalesce($1,0);
	
	if (vatt_type = '') then
		raise exception using message := comp.get_expression_text(344);		
	end if;

	
	if($6 is null) then
	
		select 	rv.vl_value
		into	$6
		from	comp.rule_value rv
		where	rv.id_rule = $1
		and		rv.id_computer = (select	id 	from comp.computer 	where 	nr_identifier  = coalesce($5,0));
	end if;
	
	if($6 is null) then
		select 	rv.vl_value
		into	$6
		from	comp.rule_value rv
		where	rv.id_rule = $1
		and		rv.id_system_user = coalesce($2,0);
	end if;
	
	if ($6 is null) then
		select 	rv.vl_value
		into	$6
		from	comp.rule_value rv
		where	rv.id_rule = $1
		and		rv.id_profile = coalesce($3,0);
	end if;
	
	if ($6 is null) then
		select  rv.vl_value
		into	$6
		from	comp.rule_value rv
		where	rv.id_rule = $1
		and		rv.id_establishment = coalesce($4,0);
	end if;
	
	if ($6 is null) then
		$6 := vdefault_vl;
	end if;
	
	if ($6 = 'SYSTEM_LOCAL_PATH') then
		$6 := comp.GET_SESSION_PARAMETER('SYSTEM_LOCAL_PATH');
	else
		if ($6 <> '') then
			begin
				vsql := 'select cast(' || $6 || ' as ' || vatt_type || ')';
				execute vsql into $6;
			exception when others then
				raise exception using message := comp.get_macro_text(338,cast('{' || cast($1 as character varying) || ',' || vsql || ',' || sqlerrm || '}' as character varying[]));		
			end;
		end if;
	end if;
	
	return;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
