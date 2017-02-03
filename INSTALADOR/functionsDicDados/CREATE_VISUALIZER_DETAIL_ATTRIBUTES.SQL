CREATE OR REPLACE FUNCTION comp.create_visualizer_detail_attributes(db_visualizer_p comp.t_db_visualizer)
  RETURNS void AS
$BODY$
DECLARE
qt_comp_att numeric;
rec 		record;
vid			numeric;
vorder		numeric = 10;
vidtype		numeric;
videxplab	numeric;
vwidth		numeric;
BEGIN

select 	count(1)
into	qt_comp_att
from	comp.component_attribute
where 	id_visualizer = db_visualizer_p.id
and		id not in (	select 	id_comp_attribute 
					from 	comp.detail_attribute 
					where 	id_visualizer = db_visualizer_p.id);

if (qt_comp_att > 0) then
for rec in
	select 		ca.id, ta.id_domain_value_type, ta.name, ca.id_domain
	from		comp.component_attribute ca
	left join 	comp.table_attribute ta on ca.id_table_attribute = ta.id
	where 		ca.id_visualizer = db_visualizer_p.id
	and			ca.id not in (	select 	id_comp_attribute 
								from 	comp.detail_attribute 
								where 	id_visualizer = db_visualizer_p.id)
loop
	vid := nextval('comp.detail_attribute_seq');
	
	select 	da.id_expression_label, da.vl_width
	into	videxplab, vwidth
	from 	comp.detail_attribute da,
			comp.component_attribute ca,
			comp.table_attribute ta
	where	da.id_comp_attribute = ca.id
	and		ca.id_table_attribute = ta.id
	and		lower(ta.name) = lower(rec.name)
	and		da.id_expression_label <> 2
	order	by da.id desc
	limit 	1;
	
	if (videxplab is null) then
		select 	e.id
		into	videxplab
		from 	comp.expression e
		where	lower(comp.retira_acentos(e.ds_por)) = lower(rec.name);
	end if;
	
	videxplab 	:= coalesce(videxplab,2);
	vwidth		:= coalesce(vwidth,80);
	
	if (rec.id_domain_value_type = 21) then
		vidtype := 54;
	elsif (rec.id_domain_value_type = 5) then
		vidtype := 53;	
	elsif (rec.id_domain is not null) then
		vidtype := 51;	
	else
		vidtype := 52;	
	end if;
	
	insert into comp.detail_attribute 	(id,id_comp_attribute,id_domain_value_type,vl_width,nr_order,fl_break_line,id_expression_label,id_visualizer)
	values					(vid,rec.id,vidtype,vwidth,vorder,false,videxplab,db_visualizer_p.id);

	vorder := vorder + 10;
end loop;
	
end if;

END;
 $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
