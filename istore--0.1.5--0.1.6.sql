----functions----
CREATE OR REPLACE FUNCTION max_key(istore)
 RETURNS integer
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$istore_max_key$function$;
----
CREATE OR REPLACE FUNCTION min_key(istore)
 RETURNS integer
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$istore_min_key$function$;
----
CREATE OR REPLACE FUNCTION max_key(bigistore)
 RETURNS integer
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$bigistore_max_key$function$;
----
CREATE OR REPLACE FUNCTION min_key(bigistore)
 RETURNS integer
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$bigistore_min_key$function$;
