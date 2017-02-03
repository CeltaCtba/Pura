CREATE OR REPLACE FUNCTION comp.export_file_name_treater(filename_p character varying, usermac_p character varying, ie64bit boolean DEFAULT false)
  RETURNS character varying AS
$BODY$
DECLARE
VRESULT character varying := '';
w_qt0909 integer := 0;
v_fl_pserv_ini boolean;
v_modelo_sat character varying;

BEGIN
	VRESULT	:= filename_p;
	
	if (upper(filename_p) in ('BEMAMFD_0909.DLL','BEMAMFD2_0909.DLL','BEMAMFD3_0909.DLL','BEMAFI32_0909.DLL',
					'BEMAMFD.DLL','BEMAMFD2.DLL','BEMAMFD3.DLL','BEMAFI32.DLL')) then
		
		SELECT	count(*)
		into 	w_qt0909
		FROM   	data.inicfg
		WHERE  	upper(CHAVEINI) = 'CONVENIO0909'
		AND    	VALORINI = 'SIM'
		AND    	upper(USERMAC) = upper(usermac_p);
	
		if (w_qt0909 > 0) then
			if (position('_0909' in filename_p) > 0) then
				VRESUlt := replace(filename_p,'_0909','' )	;
			else
				VResult := '';
			end if;
		else
			if (position('_0909' in filename_p) > 0) then
				VResult := '';
			else
				VResult := filename_p;
			end if;
			
		end if;
	
	end if;
	if (upper(filename_p) in ('PSERV.INI','C50032.INI')) then
		select 	coalesce(fl_pserv_ini,true)
		into 	v_fl_pserv_ini
		from	data.parametro;
	
		if(not v_fl_pserv_ini) then
			VRESULT := '';
		end if;
	end if;
	if (upper(filename_p) = 'SAT.DLL' )then
		VRESULT := '';
	end if;
	if (upper(filename_p) in ('BEMASAT.DLL','DLLSAT.DLL')) then
		VRESULT := 'SAT.dll';
		
		SELECT	coalesce(max(VALORINI),'')
		into 	v_modelo_sat
		FROM   	data.inicfg
		WHERE  	upper(CHAVEINI) = 'MODELOSAT'
		AND    	upper(USERMAC) = upper(usermac_p);
		
		if ((v_modelo_sat = 'DIMEP' and upper(filename_p) = 'BEMASAT.DLL')
			or (v_modelo_sat = 'BEMATECH' and upper(filename_p) = 'DLLSAT.DLL') 
			or v_modelo_sat = '') then
			VRESULT := '';
		
		end if;
		
	end if;
	
	if (upper(filename_p) in ('LIBEAY32.DLL','LIBICONV.DLL','LIBINTL.DLL','LIBPQ.DLL','LIBXML2.DLL','LIBXSLT.DLL','SSLEAY32.DLL','ZLIB1.DLL',
		'LIBEAY32_32B.DLL','LIBICONV_32B.DLL','LIBINTL_32B.DLL','LIBPQ_32B.DLL','LIBXML2_32B.DLL','LIBXSLT_32B.DLL','SSLEAY32_32B.DLL','ZLIB1_32B.DLL'))then
		if (ie64Bit) then
			if (position('_32b' in filename_p) > 0) then
				VResult := '';
			else
				VRESUlt := filename_p;				
			end if;
		else
			if (position('_32b' in filename_p) > 0) then
				VRESUlt := replace(filename_p,'_32b','');
			else
				VResult := '';
			end if;
			
		end if;
	end if;
	
	RETURN VRESULT;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
