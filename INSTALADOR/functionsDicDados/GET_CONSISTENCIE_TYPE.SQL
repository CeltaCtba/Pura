CREATE OR REPLACE FUNCTION comp.get_consistencie_type(id_consistencie_p numeric)
 RETURNS character varying
 LANGUAGE plpgsql
AS $function$
declare
consistencie_type numeric;
begin

BEGIN
select 	id_domain_value_type 
into 	consistencie_type
from 	comp.consistencies where id = id_consistencie_p;

if(consistencie_type = 124) then-- abort
	return comp.get_expression_text(449);
else -- info
	return comp.get_expression_text(450);
end if;
END;

END;
$function$
