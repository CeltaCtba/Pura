CREATE OR REPLACE FUNCTION comp.get_rule_val(rule_id numeric)
 RETURNS character varying
 LANGUAGE plpgsql
AS $function$
declare
vretorno character varying;
begin



select value 
into  vretorno
from comp.get_rule_value(rule_id, cast(comp.get_context_variable('ID_USER') as numeric),
cast( comp.get_context_variable('ID_PROFILE')as numeric),
cast(comp.get_context_variable('ID_ESTABLISHMENT')as numeric),
cast(comp.get_context_variable('PRISMA_ID')as numeric));


return vretorno;

end;
$function$
