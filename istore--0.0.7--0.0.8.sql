----functions----
CREATE OR REPLACE FUNCTION gin_consistent_istore_key(internal, smallint, internal, integer, internal, internal)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/istore.so', $function$gin_consistent_istore_key$function$;
----
CREATE OR REPLACE FUNCTION gin_extract_istore_key_query(internal, internal, smallint, internal, internal)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/istore.so', $function$gin_extract_istore_key_query$function$;
----
CREATE OR REPLACE FUNCTION gin_extract_istore_key(internal, internal)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/istore.so', $function$gin_extract_istore_key$function$;
