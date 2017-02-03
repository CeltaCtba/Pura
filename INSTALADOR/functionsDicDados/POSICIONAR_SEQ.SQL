CREATE OR REPLACE FUNCTION comp.posicionar_seq(vsequence_name character varying, vvalue integer)
 RETURNS bigint
 LANGUAGE plpgsql
AS $function$
declare
vresult bigint;
begin

	if ($2 <= 0) then
		$2 = 0;
	end if;
	select setval($1,$2,true) into vresult;
	return vresult;

end;
$function$
