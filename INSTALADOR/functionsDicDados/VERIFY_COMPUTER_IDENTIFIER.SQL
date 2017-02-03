CREATE OR REPLACE FUNCTION comp.verify_computer_identifier(computer_name_p character varying, nr_identifier_p numeric)
 RETURNS void
 LANGUAGE plpgsql
AS $function$ 
declare
qtd numeric;
begin
	select 	count(1)
	into	qtd
	from	comp.computer
	where	nr_identifier = nr_identifier_p;

	if(qtd = 0) then
		insert into comp.computer (id,name,nr_identifier) values (NEXTVAL('COMP.COMPUTER_SEQ'),computer_name_p,nr_identifier_p);
	end if;
	
end;
 $function$
