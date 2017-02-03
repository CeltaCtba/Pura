CREATE OR REPLACE FUNCTION comp.beforepost_SIGNED_SCRIPT(vacao character varying, obj comp.t_SIGNED_SCRIPT)
  RETURNS comp.t_SIGNED_SCRIPT AS
$BODY$ 
declare

begin
	if(obj.DT_LIBERACAO is not null)then
		perform comp.consist(59); 
	end if;
	
	return $2;

end;
 $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
