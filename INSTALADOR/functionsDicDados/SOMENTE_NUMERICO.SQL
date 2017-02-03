CREATE OR REPLACE FUNCTION comp.somente_numerico(ecampo character varying)
 RETURNS character varying
 LANGUAGE plpgsql
AS $function$

declare
tamanho integer;
i integer;
j integer;
campo character varying;
aux character varying;
v_numeros VARCHAR(10) := '0123456789';

BEGIN
   if (trim(ecampo) = '') then
      return null;
      exit;
   end if;

   i := 1;
   campo := '';
   tamanho := character_length(ecampo);

   while (i <= tamanho)
   loop
      aux := substring(ecampo, i, 1);
      j := 1;

   	  while (j <= 10)
      loop
         if (aux = substring(v_numeros, j, 1)) then
           campo := campo || aux;
         end if;

         j := j + 1;
      end loop;

      i := i + 1;
   end loop;

   return campo;
END;
$function$
