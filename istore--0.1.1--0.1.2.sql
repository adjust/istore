----functions----
CREATE OR REPLACE FUNCTION istore_sum_transfn(internal, bigistore)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE
AS 'istore', $function$bigistore_sum_transfn$function$;
----
CREATE OR REPLACE FUNCTION istore_sum_finalfn(internal)
 RETURNS bigistore
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$istore_sum_finalfn$function$;
----
CREATE OR REPLACE FUNCTION istore_sum_transfn(internal, istore)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE
AS 'istore', $function$istore_sum_transfn$function$;
----aggregates----
DROP AGGREGATE IF EXISTS sum (bigistore);
CREATE AGGREGATE sum(bigistore) (
  SFUNC = public.istore_sum_transfn,
  STYPE = internal,
  FINALFUNC = istore_sum_finalfn
);


----
DROP AGGREGATE IF EXISTS sum (istore);
CREATE AGGREGATE sum(istore) (
  SFUNC = public.istore_sum_transfn,
  STYPE = internal,
  FINALFUNC = istore_sum_finalfn
);

----functions----
DROP FUNCTION IF EXISTS istore_agg_finalfn(internal);
DROP FUNCTION IF EXISTS bigistore_agg_finalfn(internal);
