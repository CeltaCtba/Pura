CREATE OR REPLACE FUNCTION comp.get_domain_value_text(id_domain_value numeric)
 RETURNS character varying
 LANGUAGE plpgsql
AS $function$
DECLARE
TEXT_W 			VARCHAR(4000) := '';
BEGIN


SELECT	comp.get_expression_text(id_expression,1)
INTO	TEXT_W
FROM	COMP.domain_value a
WHERE	1=1
AND 	A.ID = id_domain_value;


RETURN TEXT_W;

END;
$function$
