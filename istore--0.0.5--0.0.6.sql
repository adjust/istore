----functions----
CREATE OR REPLACE FUNCTION istore_array_add(integer[], bigint[])
 RETURNS istore
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/istore.so', $function$istore_array_add$function$;
