CREATE OR REPLACE FUNCTION comp.db_visualizer_activation(id_system_module_p numeric, id_visualizer_p numeric)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
DECLARE
qtd numeric;

BEGIN

select 	count(1)
into 	qtd
from	comp.folder f
join	comp.folder_child fc on f.id = fc.id_folder
where	fc.id_visualizer = id_visualizer_p
and		f.id_module = id_system_module_p;



RETURN qtd > 0;

END;
$function$
