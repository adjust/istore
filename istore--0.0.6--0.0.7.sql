----functions----
CREATE OR REPLACE FUNCTION istore_seed(integer, integer, bigint)
 RETURNS istore
 LANGUAGE c
 IMMUTABLE
AS '$libdir/istore.so', $function$istore_seed$function$;
