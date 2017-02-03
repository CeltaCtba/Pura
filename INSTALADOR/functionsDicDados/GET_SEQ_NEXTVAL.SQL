CREATE OR REPLACE FUNCTION comp.get_seq_nextval(vsequence_name character varying, vstep integer, OUT result_value integer)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
BEGIN
	IF ($2 = 0) THEN
		EXECUTE 'SELECT LAST_VALUE FROM ' || VSEQUENCE_NAME INTO $3;
	ELSE
		EXECUTE 'SELECT NEXTVAL(''' || VSEQUENCE_NAME || ''')' INTO $3;
	END IF;
END;
$function$
