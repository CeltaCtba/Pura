CREATE OR REPLACE FUNCTION comp.system_object_params_refresh()
  RETURNS void AS
$BODY$
	DECLARE
	REC RECORD;

	BEGIN
			
		FOR REC IN
			SELECT 	id AS ID_OBJECT_P, name, ds_object AS ds_object_p
			FROM	comp.system_object 
			WHERE	ID_DOMAIN_VALUE_TYPE = 13
			and	upper(name) not like 'DIC_%'
		LOOP		
			perform comp.create_object_params(rec.id_object_p, rec.name, rec.ds_object_p);
		END LOOP;
		
	END;
	$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
