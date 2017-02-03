CREATE OR REPLACE FUNCTION comp.create_visualizer_attributes_rec_visible(db_visualizer_p comp.t_db_visualizer)
  RETURNS boolean AS
$BODY$
DECLARE
qtd_comp_attribute numeric;
id_system_table_v numeric;
BEGIN

select 	id_system_table
into	id_system_table_v
from	comp.db_visualizer
where   id = db_visualizer_p.id;

if (id_system_table_v is null) then
	return false;
end if;

select 	count(1)
into	qtd_comp_attribute
from	comp.table_attribute ta
where 	ta.id_table = id_system_table_v
and		id not in (select id_table_attribute 
					from	comp.component_attribute ca
					where	ca.id_visualizer = db_visualizer_p.id);

return qtd_comp_attribute > 0 ;

END;
 $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
