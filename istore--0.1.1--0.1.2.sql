----functions----
CREATE OR REPLACE FUNCTION istore_agg_finalfn(internal)
 RETURNS istore
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$istore_agg_finalfn_pairs$function$;

CREATE OR REPLACE FUNCTION bigistore_agg_finalfn(internal)
 RETURNS bigistore
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$bigistore_agg_finalfn_pairs$function$;

CREATE OR REPLACE FUNCTION istore_max_transfn(internal, bigistore)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE
AS 'istore', $function$bigistore_max_transfn$function$;

----
CREATE OR REPLACE FUNCTION istore_min_transfn(internal, bigistore)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE
AS 'istore', $function$bigistore_min_transfn$function$;

----
CREATE OR REPLACE FUNCTION istore_sum_transfn(internal, bigistore)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE
AS 'istore', $function$bigistore_sum_transfn$function$;

----
CREATE OR REPLACE FUNCTION istore_max_transfn(internal, istore)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE
AS 'istore', $function$istore_max_transfn$function$;

----
CREATE OR REPLACE FUNCTION istore_min_transfn(internal, istore)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE
AS 'istore', $function$istore_min_transfn$function$;

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
  FINALFUNC = bigistore_agg_finalfn
);

----
DROP AGGREGATE IF EXISTS sum (istore);
CREATE AGGREGATE sum(istore) (
  SFUNC = public.istore_sum_transfn,
  STYPE = internal,
  FINALFUNC = bigistore_agg_finalfn
);

----
DROP AGGREGATE IF EXISTS MIN (istore);
CREATE AGGREGATE MIN (
    sfunc = istore_min_transfn,
    basetype = istore,
    stype = internal,
    finalfunc = istore_agg_finalfn
);

----
DROP AGGREGATE IF EXISTS MAX (istore);
CREATE AGGREGATE MAX (
    sfunc = istore_max_transfn,
    basetype = istore,
    stype = internal,
    finalfunc = istore_agg_finalfn
);

----
DROP AGGREGATE IF EXISTS MIN (bigistore);
CREATE AGGREGATE MIN (
    sfunc = istore_min_transfn,
    basetype = bigistore,
    stype = internal,
    finalfunc = bigistore_agg_finalfn
);

----
DROP AGGREGATE IF EXISTS MAX (bigistore);
CREATE AGGREGATE MAX (
    sfunc = istore_max_transfn,
    basetype = bigistore,
    stype = internal,
    finalfunc = bigistore_agg_finalfn
);
