CREATE OR REPLACE FUNCTION comp.is_number(prm_str text)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_return BOOLEAN;
BEGIN
  IF regexp_matches(prm_str,E'^-*[[:digit:]]+\.?[[:digit:]]+$') is not null 
  THEN
     v_return = TRUE;
  ELSE
    v_return = FALSE;
  END IF;
  RETURN v_return;     
END;
$function$
