----functions----
CREATE OR REPLACE FUNCTION bigistore_length(bigistore)
 RETURNS integer
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$bigistore_length$function$;
----
CREATE OR REPLACE FUNCTION istore_length(bigistore)
 RETURNS integer
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$bigistore_length$function$;
----
CREATE OR REPLACE FUNCTION istore_length(istore)
 RETURNS integer
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$istore_length$function$;
