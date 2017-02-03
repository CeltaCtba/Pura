CREATE OR REPLACE FUNCTION comp.create_object_param(obj comp.t_system_object)
  RETURNS void AS
$BODY$
begin
	if ((obj.id_domain_value_type = 13) and (coalesce(obj.fl_generated,false) = false)) then
		perform comp.create_object_params(obj.id, obj.name, obj.ds_object);
	end if;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
