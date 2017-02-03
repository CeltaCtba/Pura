CREATE OR REPLACE FUNCTION comp.before_post_system_object(vacao character varying, obj comp.t_system_object)
  RETURNS comp.t_system_object AS
$BODY$ 
declare
vexists 	boolean = false;
vexecute 	boolean = false;

begin	
	if (lower($1) <> 'd') then
		if (($2.id_domain_value_type = 37) and (position('FOR EACH' in upper($2.ds_object))=0)) then
			perform comp.consist(17);
		end if;
	
		select 	case when count(1) > 0 then true else false end as flag
		into	vexists
		from	comp.system_object
		where	lower(name) = lower($2.name)
		and	id_database_schema = $2.id_database_schema
		and	id_domain_value_type = $2.id_domain_value_type
		and	id <> $2.id;
		
		if (vexists) then
			perform comp.consist(28);		
		end if;

		if (obj.id_domain_value_type in (37,41)) then
			if (lower(vacao) = 'i') then
				vexecute := true;
			end if;
		else 
			vexecute := true;
		end if;

		if (vexecute) then
			begin
				execute $2.ds_object;
			exception 
			when others then
				perform comp.consist(37,comp.retira_acentos(sqlerrm));
			end;			
		end if;
	end if;
	return $2;
end;
 $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
