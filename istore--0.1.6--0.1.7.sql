----functions----
CREATE OR REPLACE FUNCTION clamp_above(bigistore, integer)
 RETURNS bigistore
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$bigistore_clamp_above$function$;
----
CREATE OR REPLACE FUNCTION clamp_below(bigistore, integer)
 RETURNS bigistore
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$bigistore_clamp_below$function$;
----
CREATE OR REPLACE FUNCTION clamp_above(istore, integer)
 RETURNS istore
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$istore_clamp_above$function$;
----
CREATE OR REPLACE FUNCTION clamp_below(istore, integer)
 RETURNS istore
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$istore_clamp_below$function$;
