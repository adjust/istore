----functions----
CREATE OR REPLACE FUNCTION accumulate(istore, integer)
 RETURNS istore
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/istore.so', $function$istore_accumulate$function$;
----
CREATE OR REPLACE FUNCTION accumulate(istore)
 RETURNS istore
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/istore.so', $function$istore_accumulate$function$;
