CREATE OR REPLACE FUNCTION comp.get_grid_attribute_order(id_grid_attribute_p numeric, id_user_p numeric)
 RETURNS numeric
 LANGUAGE plpgsql
AS $function$
DECLARE
v_nr_order numeric ;
BEGIN
select 	coalesce(max(nr_order),0)
into 	v_nr_order
from	comp.grid_order
where	id_user = id_user_p
and		id_grid_attribute = id_grid_attribute_p;


RETURN v_nr_order;

END;
$function$
