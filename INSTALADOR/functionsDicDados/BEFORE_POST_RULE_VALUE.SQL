CREATE OR REPLACE FUNCTION comp.before_post_rule_value(vacao character varying, obj comp.t_rule_value)
  RETURNS comp.t_rule_value AS
$BODY$ 
declare
vatt_type character varying;
begin
	if (($2.id_profile is null) and ($2.id_establishment is null) and ($2.id_system_user is null) and ($2.id_computer is null)) then
		perform comp.consist(13);
	end if;

	select 	comp.get_expression_text(dv.id_expression)
	into	vatt_type
	from	comp.domain_value dv,
		comp.rule r
	where 	r.id = $2.id_rule
	and	r.id_domain_value_value = dv.id;

	begin
		execute 'select cast(' || $2.vl_value || ' as ' || vatt_type || ')';
	exception
	when others then
		perform comp.consist(14);
	end;

	return $2;
end;
 $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
