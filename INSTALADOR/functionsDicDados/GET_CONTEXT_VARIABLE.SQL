CREATE OR REPLACE FUNCTION comp.get_context_variable(variable_name character varying)
 RETURNS character varying
 LANGUAGE plpgsql
AS $function$
DECLARE
VTEXT VARCHAR := '';
BEGIN
	BEGIN
		EXECUTE 'show context.' || lower(variable_name) INTO VTEXT;
		RETURN VTEXT;
	EXCEPTION WHEN OTHERS THEN
		RETURN NULL;
	END;
END;
$function$
