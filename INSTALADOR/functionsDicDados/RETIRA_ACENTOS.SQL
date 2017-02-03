CREATE OR REPLACE FUNCTION comp.retira_acentos(ptexto character varying)
  RETURNS character varying AS
$BODY$
DECLARE
V_COM_ACENTO varchar(229) := 'ÁÀÂÃÄבאגדהÉÈÊËיטךכÍÌÎÏםלמןÓÒÔÕÖףעפץצÚÙÛÜתשûüÇח"';
V_SEM_ACENTO VARCHAR(229) := 'AAAAAaaaaaEEEEeeeeIIIIiiiiOOOOOoooooUUUUuuuuCc ';
V_LOOP_1 INTEGER := 1;
V_LOOP_2 INTEGER := 1;
V_TEXTO_A VARCHAR(1) := '';
V_TEXTO_B character varying := '';

BEGIN
	if(ptexto = null) then
		return null;
	end if;
  V_LOOP_1 = 1;
  /* INICIAR O LOOP NO TEXTO PRINCIPAL ------------ */
  while (V_LOOP_1 <= char_length($1)) 
  loop
    V_TEXTO_A = '';
    V_TEXTO_A = substring(pTexto from V_LOOP_1 for 1);
    V_LOOP_2 = 1;
    /* INICIAR O LOOP NO TEXTO COM ACENTO --------- */
    while (V_LOOP_2 <= char_length(V_COM_ACENTO))
    loop
      if (V_TEXTO_A = substring(V_COM_ACENTO from V_LOOP_2 for 1)) then
        V_TEXTO_A = substring(V_SEM_ACENTO from V_LOOP_2 for 1);
      end if;
      V_LOOP_2 = V_LOOP_2 + 1;
    end loop;
    V_TEXTO_B = V_TEXTO_B || V_TEXTO_A;
    V_LOOP_1 = V_LOOP_1 + 1;
  end loop;
return V_TEXTO_B;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
