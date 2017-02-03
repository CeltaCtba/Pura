CREATE OR REPLACE FUNCTION comp.create_visualizer_grid_attributes_enable(db_visualizer_p comp.t_db_visualizer)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
DECLARE
qtd_comp_attribute numeric;
BEGIN

select 	count(1)
into	qtd_comp_attribute
from	comp.detail_attribute
where 	id_visualizer = db_visualizer_p.id
and		id_comp_attribute not in (	select 	id_comp_attribute 
									from 	comp.grid_attribute 
									where 	id_visualizer = db_visualizer_p.id);


return qtd_comp_attribute > 0 ;


END;
 $function$
