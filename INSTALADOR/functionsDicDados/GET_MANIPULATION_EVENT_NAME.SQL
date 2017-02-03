CREATE OR REPLACE FUNCTION comp.get_manipulation_event_name(id_manipulation_event_p numeric)
  RETURNS character varying AS
$BODY$
DECLARE
v_name character varying ;
BEGIN
select  comp.get_expression_text(dv.id_expression)||' - '||st.name
into 	v_name
from 	comp.manipulation_event me
join	comp.system_table st on st.id = me.id_table
join	comp.event e on e.id = me.id_event
join	comp.domain_value dv on dv.id = e.id_domain_value_type
where 	me.id = id_manipulation_event_p;


RETURN v_name;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
