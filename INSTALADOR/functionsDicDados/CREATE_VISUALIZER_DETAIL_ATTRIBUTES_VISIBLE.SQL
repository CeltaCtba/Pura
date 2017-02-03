CREATE OR REPLACE FUNCTION comp.create_visualizer_detail_attributes_visible(db_visualizer_p comp.t_db_visualizer)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
DECLARE
qtd_comp_attribute numeric;
id_system_table_v numeric;
BEGIN

select	id_system_table
into	id_system_table_v
from	comp.db_visualizer
where 	id = db_visualizer_p.id;

select 	count(1)
into	qtd_comp_attribute
from	comp.component_attribute;

return 	qtd_comp_attribute > 0 and id_system_table_v is not null;


END;
 $function$
