CREATE OR REPLACE FUNCTION comp.getfiledata(lobjid oid)
 RETURNS bytea
 LANGUAGE plpgsql
 STABLE STRICT
AS $function$
DECLARE
  fd int4;
  imgsize int4;
  INV_READ int4 := 262144;
  SEEK_SET int4 := 0;
  SEEK_END int4 := 2;
BEGIN
  SELECT lo_open(lobjid, INV_READ) INTO fd;
  PERFORM lo_lseek(fd, 0, SEEK_END);
  SELECT lo_tell(fd) INTO imgsize;
  PERFORM lo_lseek(fd, 0, SEEK_SET);
  RETURN loread(fd, imgsize);
END;
$function$
