CREATE OR REPLACE FUNCTION comp.get_file_export_name(id_file_export_p numeric)
  RETURNS character varying AS
$BODY$
DECLARE
v_name character varying ;
BEGIN
select 	coalesce(comp.get_Expression_text(id_expression_name),'')
into 	v_name
from	comp.file_Export
where	id = id_file_export_p;

RETURN v_name;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
