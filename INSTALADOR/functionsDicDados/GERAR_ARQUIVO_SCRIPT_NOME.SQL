CREATE OR REPLACE FUNCTION comp.gerar_arquivo_script_nome(SIGNED_SCRIPT_p comp.t_SIGNED_SCRIPT)
  RETURNS character varying AS
$BODY$
declare 
retorno character varying ;
BEGIN
	retorno := 'Script_'||cast(SIGNED_SCRIPT_p.id as character varying )||'_'|| SIGNED_SCRIPT_p.NM_LIBERACAO_USER;
	if (SIGNED_SCRIPT_p.CNPJ_CLIENTE is not null) then
		retorno := retorno ||'_'||SIGNED_SCRIPT_p.CNPJ_CLIENTE ;
	end if;
	return retorno;
END;
 $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
