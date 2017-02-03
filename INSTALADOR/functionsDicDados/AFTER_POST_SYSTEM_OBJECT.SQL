CREATE OR REPLACE FUNCTION comp.after_post_system_object(vacao character varying, obj comp.t_system_object)
  RETURNS comp.t_system_object AS
$BODY$ 
declare
begin
	if (lower($1) <> 'd') then
		if not (obj.id_domain_value_type in (37,41)) then
			if (coalesce(obj.fl_generated,false) = false) then
				perform comp.create_object_params($2.id, $2.name, $2.ds_object);
				perform comp.verify_references($2.id_application, $2.id, $2.ds_object);
			end if;	
		end if;
	end if;

	return $2;
end;
 $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
