CREATE OR REPLACE FUNCTION comp.liberar_script(SIGNED_SCRIPT_p comp.t_SIGNED_SCRIPT)
  RETURNS void AS
$BODY$

BEGIN

update comp.SIGNED_SCRIPT
set 	dt_liberacao = current_date,
NM_LIBERACAO_USER = (select name from comp.system_user where id =  cast(comp.get_context_variable('ID_USER') as numeric))
where id = SIGNED_SCRIPT_p.id;

END;
 $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
