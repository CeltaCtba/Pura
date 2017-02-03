CREATE OR REPLACE FUNCTION comp.create_visualizer_grid_attributes(db_visualizer_p comp.t_db_visualizer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
qtd_comp_attribute numeric;
rec 		record;
vid			numeric;
vorder		numeric = 1;
BEGIN

select 	count(1)
into	qtd_comp_attribute
from	comp.detail_attribute
where 	id_visualizer = db_visualizer_p.id
and		id_comp_attribute not in (	select 	id_comp_attribute 
									from 	comp.grid_attribute 
									where 	id_visualizer = db_visualizer_p.id);

if (qtd_comp_attribute > 0) then
for rec in
	select 	*
	from	comp.detail_attribute
	where 	id_visualizer = db_visualizer_p.id
	and		id_comp_attribute not in (	select 	id_comp_attribute 
									from 	comp.grid_attribute 
									where 	id_visualizer = db_visualizer_p.id)
loop
		
	insert into comp.grid_attribute 	(id,id_comp_attribute,vl_width,id_expression_label,id_visualizer)
	values								(nextval('comp.grid_attribute_seq'),rec.id_comp_attribute,100,coalesce(rec.id_expression_label,2),db_visualizer_p.id);

	vorder := vorder + 1;
end loop;
	
end if;

END;
 $function$
