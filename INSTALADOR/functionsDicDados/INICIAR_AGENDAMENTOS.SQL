CREATE OR REPLACE FUNCTION comp.iniciar_agendamentos()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE

regitro_v record;
qt_registro_v numeric;

BEGIN

for regitro_v in 
select	id,
		dt_start_time,
		id_domain_value_process
from 	data.schedule
loop
	select	count(1)
	into	qt_registro_v
	from	data.schedule_process sp
	where 	id_schedule = regitro_v.id
	and		sp.id not in (select	id_schedule_process
				      from	data.schedule_executed_process);
						
	if	(qt_registro_v = 0)	then
			perform comp.efetuar_agendamento(regitro_v.id,cast(current_timestamp as timestamp without time zone ));
	end if;
end loop;		



END;
$function$
