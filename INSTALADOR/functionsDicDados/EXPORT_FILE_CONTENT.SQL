CREATE OR REPLACE FUNCTION comp.export_file_content(filename_p character varying)
  RETURNS text AS
$BODY$
DECLARE
VRESULT text := null;

BEGIN

	if (upper(filename_p) in (upper('pserv.ini'),upper('c50032.ini'))) then
		if (upper(filename_p) = upper('pserv.ini')) then
			select 	max(pserv_ini)
			into	VRESULT
			from 	data.parametro;
		else
			select 	max(c50032_ini)
			into	VRESULT
			from 	data.parametro;		
		end if;
		
	end if;

	RETURN VRESULT;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
