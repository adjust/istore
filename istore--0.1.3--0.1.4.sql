----functions----
CREATE OR REPLACE FUNCTION bigistore_avl_finalfn(internal)
 RETURNS bigistore
 LANGUAGE c
 IMMUTABLE
AS 'istore', $function$bigistore_avl_finalfn$function$;
----
CREATE OR REPLACE FUNCTION bigistore_avl_transfn(internal, integer, bigint)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE
AS 'istore', $function$bigistore_avl_transfn$function$;
----
CREATE OR REPLACE FUNCTION istore_avl_finalfn(internal)
 RETURNS istore
 LANGUAGE c
 IMMUTABLE
AS 'istore', $function$istore_avl_finalfn$function$;
----
CREATE OR REPLACE FUNCTION istore_avl_transfn(internal, integer, integer)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE
AS 'istore', $function$istore_avl_transfn$function$;
----aggregates----
  CREATE AGGREGATE isagg(key integer, value bigint) (
    SFUNC = bigistore_avl_transfn,
  STYPE = internal,
  FINALFUNC = bigistore_avl_finalfn
  );

----
  CREATE AGGREGATE isagg(key integer, value integer) (
    SFUNC = istore_avl_transfn,
  STYPE = internal,
  FINALFUNC = istore_avl_finalfn
  );
