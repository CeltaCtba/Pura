CREATE OR REPLACE FUNCTION comp.sync(system_table_p comp.t_system_table)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
declare
qtd numeric;
BEGIN

delete from comp.log_synchronizer;

PERFORM comp.sync_database_structure();

select 	count(1)
into   	qtd
from   	comp.log_synchronizer
where 	level = 0;

if (qtd = 0) then
	PERFORM comp.consist(15);
else
	PERFORM comp.consist(16);
end if;
END;
 $function$
