----functions----
CREATE OR REPLACE FUNCTION istore_agg_finalfn(internal)
 RETURNS bigistore
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$istore_agg_finalfn$function$;
----
CREATE OR REPLACE FUNCTION bigistore_agg_finalfn(internal)
 RETURNS bigistore
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$bigistore_agg_finalfn$function$;

----aggregates----
  DROP AGGREGATE IF EXISTS max (bigistore);
    CREATE AGGREGATE max(bigistore) (
    SFUNC = public.istore_val_larger,
  STYPE = bigistore
  );


----
  DROP AGGREGATE IF EXISTS min (bigistore);
    CREATE AGGREGATE min(bigistore) (
    SFUNC = public.istore_val_smaller,
  STYPE = bigistore
  );

----
  DROP AGGREGATE IF EXISTS sum (bigistore);
    CREATE AGGREGATE sum(bigistore) (
    SFUNC = array_agg_transfn,
  STYPE = internal,
  FINALFUNC = bigistore_agg_finalfn
  );

----
  DROP AGGREGATE IF EXISTS max (istore);
    CREATE AGGREGATE max(istore) (
    SFUNC = public.istore_val_larger,
  STYPE = istore
  );


----
  DROP AGGREGATE IF EXISTS min (istore);
    CREATE AGGREGATE min(istore) (
    SFUNC = public.istore_val_smaller,
  STYPE = istore
  );


----
  DROP AGGREGATE IF EXISTS sum (istore);
    CREATE AGGREGATE sum(istore) (
    SFUNC = array_agg_transfn,
  STYPE = internal,
  FINALFUNC = istore_agg_finalfn
  );

----
DROP FUNCTION IF EXISTS istore_max_transfn(internal, bigistore);
----
DROP FUNCTION IF EXISTS istore_min_transfn(internal, bigistore);
----
DROP FUNCTION IF EXISTS istore_sum_transfn(internal, bigistore);
----
DROP FUNCTION IF EXISTS istore_agg_finalfn_pairs(internal);
----
DROP FUNCTION IF EXISTS istore_max_transfn(internal, istore);
----
DROP FUNCTION IF EXISTS istore_min_transfn(internal, istore);
----
DROP FUNCTION IF EXISTS istore_sum_transfn(internal, istore);
