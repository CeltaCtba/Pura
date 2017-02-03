CREATE OR REPLACE FUNCTION comp.get_question_name(id_question_p numeric)
 RETURNS character varying
 LANGUAGE plpgsql
AS $function$
DECLARE
v_name character varying ;
BEGIN
select coalesce(comp.get_expression_text(id_expression_question),'')
into 	v_name
from	comp.questions
where	id = id_question_p;

RETURN v_name;

END;
$function$
