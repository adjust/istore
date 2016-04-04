----functions----
CREATE OR REPLACE FUNCTION sum_up(istore, integer)
 RETURNS bigint
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$istore_sum_up$function$;
----
CREATE OR REPLACE FUNCTION sum_up(bigistore, integer)
 RETURNS bigint
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$bigistore_sum_up$function$;
