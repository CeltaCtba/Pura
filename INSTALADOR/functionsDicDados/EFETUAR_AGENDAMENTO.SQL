CREATE OR REPLACE FUNCTION comp.efetuar_agendamento(id_schedule_p numeric, dt_execucao timestamp without time zone)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
dt_start_time_v time;
dt_character character varying;
dt_current_date timestamp;
BEGIN

select	dt_start_time
into 	dt_start_time_v
from	data.schedule
where	id = id_schedule_p;

if(dt_start_time_v is not null) then
	dt_current_date := dt_execucao;
	dt_character :=  EXTRACT(DAY from dt_current_date);
	dt_character :=  dt_character||'/'||EXTRACT(MONTH from dt_current_date);
	dt_character :=  dt_character||'/'||EXTRACT(YEAR from dt_current_date);
	
	dt_character :=  dt_character||' '||EXTRACT(HOUR from dt_start_time_v);
	dt_character :=  dt_character||':'||EXTRACT(MINUTE from dt_start_time_v);
	dt_character :=  dt_character||':00';

	dt_current_date := to_timestamp(dt_character, 'DD/MM/YYYY HH24:MI:SS');
	if (dt_current_date > current_timestamp) then
		insert into data.schedule_process (id,id_schedule,dt_start) values ((select data.get_sequence_nextval('SCHEDULE_PROCESS_SEQ' ,1)),id_schedule_p,dt_current_date );
	else
		insert into data.schedule_process (id,id_schedule,dt_start) values ((select data.get_sequence_nextval('SCHEDULE_PROCESS_SEQ' ,1)),id_schedule_p,dt_current_date + INTERVAL '1 DAYS');
	end if;
end if;



END;
$function$
