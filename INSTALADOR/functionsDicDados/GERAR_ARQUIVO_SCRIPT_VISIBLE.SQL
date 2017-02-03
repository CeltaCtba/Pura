CREATE OR REPLACE FUNCTION comp.gerar_arquivo_script_visible(SIGNED_SCRIPT_p comp.t_SIGNED_SCRIPT)
  RETURNS boolean AS
$BODY$
BEGIN

return SIGNED_SCRIPT_p.id is not null and SIGNED_SCRIPT_p.DT_LIBERACAO is not null;

END;
 $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
