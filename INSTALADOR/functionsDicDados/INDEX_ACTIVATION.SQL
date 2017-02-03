CREATE OR REPLACE FUNCTION comp.index_activation(id_system_table_p numeric, id_table_index_p numeric)
  RETURNS boolean AS
$BODY$
DECLARE
qtd numeric;

BEGIN

select 	count(1)
into 	qtd
from 	comp.table_index ia 
where 	ia.id_table = id_system_table_p
and	ia.id = id_table_index_p;

RETURN qtd > 0;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
