CREATE OR REPLACE FUNCTION comp.create_visualizer_attributes_rec(db_visualizer_p comp.t_db_visualizer)
  RETURNS void AS
$BODY$
DECLARE
qtd_comp_attribute 	numeric;
rec 			record;
vid			numeric;
BEGIN

for rec in
	select 	ta.id
	from	comp.table_attribute ta
	where 	ta.id_table =  db_visualizer_p.id_system_table
	and 	lower(ta.name) not in ('dt_creation','dt_alter','nm_creation_user','nm_alter_user')
	and	ta.id not in 
		(select id_table_attribute 
		from	comp.component_attribute ca
		where	ca.id_visualizer = db_visualizer_p.id)
loop
	vid := nextval('comp.component_attribute_seq');
	insert into comp.component_attribute 	(id,id_visualizer,id_table_attribute)
	values					(vid,db_visualizer_p.id,rec.id);

end loop;	

END;
 $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
