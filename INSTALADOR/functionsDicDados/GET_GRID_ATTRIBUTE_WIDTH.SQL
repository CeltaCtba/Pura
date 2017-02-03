CREATE OR REPLACE FUNCTION comp.get_grid_attribute_width(id_grid_attribute_p numeric, id_user_p numeric)
 RETURNS numeric
 LANGUAGE plpgsql
AS $function$
DECLARE
v_vl_width numeric ;
BEGIN
select 	coalesce(max(vl_width),(select vl_width from comp.grid_attribute where id = id_grid_attribute_p ))
into 	v_vl_width
from	comp.grid_order
where	id_user = id_user_p
and		id_grid_attribute = id_grid_attribute_p;


RETURN v_vl_width;

END;
$function$
