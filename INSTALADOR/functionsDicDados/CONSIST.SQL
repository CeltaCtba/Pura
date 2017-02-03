CREATE OR REPLACE FUNCTION comp.consist(id_consistencie numeric, vl_text character varying DEFAULT ''''::character varying)
  RETURNS void AS
$BODY$
declare
TEXT_W 	text := '''';
begin

BEGIN
	IF (COALESCE($2,'''') <> '''') THEN
		INSERT INTO COMP.CONSISTENCIES_SESSION(SESSION,ID_CONSISTENCIE,VL_TEXT) VALUES (substring(cast(inet_client_addr() as character varying) from 1 for 20),$1,substring($2 from 1 for 400));
	ELSE
		INSERT INTO COMP.CONSISTENCIES_SESSION(SESSION,ID_CONSISTENCIE) VALUES (substring(cast(inet_client_addr() as character varying) from 1 for 20),$1);
	END IF;
EXCEPTION WHEN OTHERS THEN
	RAISE EXCEPTION USING MESSAGE = INITCAP(SQLERRM);
END;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
