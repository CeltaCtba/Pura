CREATE OR REPLACE FUNCTION comp.create_visualizer_filter_attributes(db_visualizer_p comp.t_db_visualizer)
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
									from 	comp.filter_attribute 
									where 	id_visualizer = db_visualizer_p.id);

if (qtd_comp_attribute > 0) then
for rec in
	select 	*
	from	comp.detail_attribute
	where 	id_visualizer = db_visualizer_p.id
	and		id_comp_attribute not in (	select 	id_comp_attribute 
									from 	comp.filter_attribute 
									where 	id_visualizer = db_visualizer_p.id)
loop
		
	insert into comp.filter_attribute 	(id,id_comp_attribute,id_domain_value_type,id_expression_label,nr_order,id_visualizer)
	values								(nextval('comp.filter_attribute_seq'),rec.id_comp_attribute,rec.id_domain_value_type,coalesce(rec.id_expression_label,2),vorder,db_visualizer_p.id);

	vorder := vorder + 1;
end loop;
	
end if;

END;
 $function$
