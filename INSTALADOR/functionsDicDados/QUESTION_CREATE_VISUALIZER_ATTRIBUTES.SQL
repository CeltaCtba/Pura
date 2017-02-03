CREATE OR REPLACE FUNCTION  comp.question_create_visualizer_attributes(vacao character varying,obj comp.t_db_visualizer)
  RETURNS boolean AS
$BODY$
DECLARE
qtd numeric;
BEGIN
if (vacao in ('I','A') and obj.id_system_table is not null) then
	select 	count(1)
	into	qtd
	from	comp.table_attribute ta
	where 	ta.id_table =  obj.id_system_table
	and		id not in (select id_table_attribute 
					from	comp.component_attribute ca
					where	ca.id_visualizer = obj.id);
	return qtd > 0;
end if;

return false;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
