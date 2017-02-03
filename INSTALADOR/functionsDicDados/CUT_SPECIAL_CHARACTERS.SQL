CREATE OR REPLACE FUNCTION comp.cut_special_characters(text_p text)
  RETURNS text AS
$BODY$  
 Select trim(translate($1,  
 ''':',  
 ''   
  ));  
 $BODY$
  LANGUAGE sql VOLATILE
  COST 100;
