CREATE OR REPLACE FUNCTION comp.file_export_activation(id_visualizer_p numeric, id_file_export_p numeric)
  RETURNS boolean AS
$BODY$
DECLARE
qtd numeric;

BEGIN

select 	count(1)
into 	qtd
from	comp.db_button b
join	comp.file_export fe on b.id_file_export = fe.id
where	fe.id =  id_file_export_p
and	b.id_visualizer = id_visualizer_p;

RETURN qtd > 0;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
