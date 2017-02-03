CREATE OR REPLACE FUNCTION comp.integrity_activation(id_system_table_p numeric, id_integrity_p numeric)
  RETURNS boolean AS
$BODY$
DECLARE
qtd numeric;

BEGIN

select 	count(1)
into 	qtd
from 	comp.integrity_attribute ia 
join	comp.table_attribute ta on ta.id = ia.id_table_attribute_origin
where 	ia.id_integrity = id_integrity_p
and		ta.id_table = id_system_table_p;

RETURN qtd > 0;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
