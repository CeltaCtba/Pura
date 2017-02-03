CREATE OR REPLACE FUNCTION comp.gerar_arquivo_script_texto(SIGNED_SCRIPT_p comp.t_SIGNED_SCRIPT)
  RETURNS text AS
$BODY$
declare
retorno text ;
BEGIN
	retorno := 'ID='||SIGNED_SCRIPT_p.id||chr(13)||chr(10);
	retorno := retorno || 'DT_LIBERACAO='||SIGNED_SCRIPT_p.DT_LIBERACAO||chr(13)||chr(10);
	retorno := retorno || 'NM_LIBERACAO_USER='||SIGNED_SCRIPT_p.NM_LIBERACAO_USER||chr(13)||chr(10);
	retorno := retorno || 'CNPJ_CLIENTE='||coalesce(SIGNED_SCRIPT_p.CNPJ_CLIENTE,'')||chr(13)||chr(10);
	retorno := retorno || 'DS_SCRIPT='||SIGNED_SCRIPT_p.DS_SCRIPT||chr(13)||chr(10)||'FIM';
return retorno;
END;
 $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
