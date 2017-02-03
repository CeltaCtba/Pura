CREATE OR REPLACE FUNCTION comp.get_consistencie_text(id_consistencie_p numeric)
  RETURNS character varying AS
$BODY$
DECLARE
v_name character varying ;
BEGIN
Select	case when cs.vl_text is not null
	then
		comp.get_macro_text(c.id_expression_message,cast('{'||cs.vl_text||'}' as character varying[]))
	else
		comp.get_expression_text(c.id_expression_message) 	
	end as message
into	v_name
from	comp.consistencies_session cs,
	comp.consistencies c
where 	cs.id_consistencie = c.id
and	cs.id = id_consistencie_p;

RETURN v_name;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
