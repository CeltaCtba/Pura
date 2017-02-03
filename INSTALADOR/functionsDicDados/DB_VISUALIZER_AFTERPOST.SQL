CREATE OR REPLACE FUNCTION comp.db_visualizer_afterpost(vacao character varying,obj comp.t_db_visualizer)
  RETURNS comp.t_db_visualizer AS
$BODY$
DECLARE

BEGIN
if (comp.get_selected_questions_options(4) = 4)then
	execute comp.create_visualizer_attributes_rec(obj);
end if;

RETURN obj;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
