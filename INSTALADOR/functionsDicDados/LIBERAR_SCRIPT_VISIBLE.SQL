CREATE OR REPLACE FUNCTION comp.liberar_script_visible(SIGNED_SCRIPT_p comp.t_SIGNED_SCRIPT)
  RETURNS boolean AS
$BODY$
DECLARE
qt_user numeric;
BEGIN

select count(id)
into qt_user
from comp.system_user
where fl_desenv_user
and  id = cast(comp.get_context_variable('ID_USER') as numeric);

return qt_user > 0 and SIGNED_SCRIPT_p.id is not null and SIGNED_SCRIPT_p.DT_LIBERACAO is null;

END;
 $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
