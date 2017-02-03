CREATE OR REPLACE FUNCTION comp.get_expression_text(id_expression numeric, id_language numeric DEFAULT 1)
  RETURNS character varying AS
$BODY$
DECLARE
TEXT_W 			VARCHAR(4000) := '';
BEGIN

--IF ($2 = 1) THEN
	SELECT	A.DS_POR
	INTO	TEXT_W
	FROM	COMP.EXPRESSION A
	WHERE	1=1
	AND 	A.ID = $1;
--END IF;

RETURN TEXT_W;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
