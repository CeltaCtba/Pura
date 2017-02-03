CREATE OR REPLACE FUNCTION comp.get_selected_questions_options(id_question_p numeric)
  RETURNS numeric AS
$BODY$
DECLARE
retorno numeric;
BEGIN

select 	coalesce(max(coalesce(qo.id_domain_value_option,qs.id_questions_options)),0)
into	retorno
from	comp.questions_options qo
join	comp.questions_session qs on qo.id = qs.id_questions_options
where	qo.id_question = id_question_p
and	qs.session = substring(cast(inet_client_addr() as character varying) from 1 for 20);


RETURN retorno;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
