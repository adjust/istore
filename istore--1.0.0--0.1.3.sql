----functions----
CREATE OR REPLACE FUNCTION add(istore, istore)
 RETURNS istore
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$istore_add$function$;
----
CREATE OR REPLACE FUNCTION accumulate(istore, integer)
 RETURNS istore
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$istore_accumulate$function$;
----
CREATE OR REPLACE FUNCTION accumulate(istore)
 RETURNS istore
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$istore_accumulate$function$;
----
CREATE OR REPLACE FUNCTION fill_gaps(istore, integer, integer DEFAULT 0)
 RETURNS istore
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$istore_fill_gaps$function$;
----
CREATE OR REPLACE FUNCTION istore(integer[], integer[])
 RETURNS istore
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$istore_array_add$function$;
----
CREATE OR REPLACE FUNCTION sum_up(istore, integer)
 RETURNS bigint
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$istore_sum_up$function$;
----
CREATE OR REPLACE FUNCTION sum_up(istore)
 RETURNS bigint
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$istore_sum_up$function$;
----
CREATE OR REPLACE FUNCTION istore(integer[])
 RETURNS istore
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$istore_from_intarray$function$;
----
CREATE OR REPLACE FUNCTION divide(istore, integer)
 RETURNS istore
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$istore_divide_integer$function$;
----
CREATE OR REPLACE FUNCTION divide(istore, istore)
 RETURNS istore
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$istore_divide$function$;
----
CREATE OR REPLACE FUNCTION multiply(istore, integer)
 RETURNS istore
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$istore_multiply_integer$function$;
----
CREATE OR REPLACE FUNCTION multiply(istore, istore)
 RETURNS istore
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$istore_multiply$function$;
----
CREATE OR REPLACE FUNCTION subtract(istore, integer)
 RETURNS istore
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$istore_subtract_integer$function$;
----
CREATE OR REPLACE FUNCTION subtract(istore, istore)
 RETURNS istore
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$istore_subtract$function$;
----
CREATE OR REPLACE FUNCTION add(istore, integer)
 RETURNS istore
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$istore_add_integer$function$;
----
CREATE OR REPLACE FUNCTION compact(istore)
 RETURNS istore
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$istore_compact$function$;
----
CREATE OR REPLACE FUNCTION each("is" istore, OUT key integer, OUT value integer)
 RETURNS SETOF record
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$istore_each$function$;
----
CREATE OR REPLACE FUNCTION fetchval(istore, integer)
 RETURNS integer
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$istore_fetchval$function$;
----
CREATE OR REPLACE FUNCTION exist(istore, integer)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$istore_exist$function$;
----
CREATE OR REPLACE FUNCTION bigistore_agg_finalfn(internal)
 RETURNS bigistore
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$bigistore_agg_finalfn_pairs$function$;
----
CREATE OR REPLACE FUNCTION istore_to_json(istore)
 RETURNS json
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$istore_to_json$function$;
----
CREATE OR REPLACE FUNCTION istore_agg_finalfn_pairs(internal)
 RETURNS istore
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$istore_agg_finalfn_pairs$function$;
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
----
CREATE OR REPLACE FUNCTION svals(istore)
 RETURNS SETOF integer
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$istore_svals$function$;
----
CREATE OR REPLACE FUNCTION skeys(istore)
 RETURNS SETOF integer
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$istore_skeys$function$;
----
CREATE OR REPLACE FUNCTION avals(istore)
 RETURNS integer[]
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$istore_avals$function$;
----
CREATE OR REPLACE FUNCTION akeys(istore)
 RETURNS integer[]
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$istore_akeys$function$;
----
CREATE OR REPLACE FUNCTION istore_val_smaller(istore, istore)
 RETURNS istore
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$istore_val_smaller$function$;
----
CREATE OR REPLACE FUNCTION istore_val_larger(istore, istore)
 RETURNS istore
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$istore_val_larger$function$;
----
CREATE OR REPLACE FUNCTION istore_seed(integer, integer, integer)
 RETURNS istore
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$istore_seed$function$;

DROP AGGREGATE SUM(istore);
CREATE AGGREGATE SUM (
    sfunc = istore_sum_transfn,
    basetype = istore,
    stype = internal,
    finalfunc = bigistore_agg_finalfn
);

DROP AGGREGATE MIN(istore);
CREATE AGGREGATE MIN (
    sfunc = istore_min_transfn,
    basetype = istore,
    stype = internal,
    finalfunc = istore_agg_finalfn_pairs
);

DROP AGGREGATE MAX(istore);
CREATE AGGREGATE MAX (
    sfunc = istore_max_transfn,
    basetype = istore,
    stype = internal,
    finalfunc = istore_agg_finalfn_pairs
);

DROP AGGREGATE SUM(bigistore);
CREATE AGGREGATE SUM (
    sfunc = istore_sum_transfn,
    basetype = bigistore,
    stype = internal,
    finalfunc = bigistore_agg_finalfn
);

DROP AGGREGATE MIN(bigistore);
CREATE AGGREGATE MIN (
    sfunc = istore_min_transfn,
    basetype = bigistore,
    stype = internal,
    finalfunc = bigistore_agg_finalfn
);

DROP AGGREGATE MAX(bigistore);
CREATE AGGREGATE MAX (
    sfunc = istore_max_transfn,
    basetype = bigistore,
    stype = internal,
    finalfunc = bigistore_agg_finalfn
);

----
DROP FUNCTION IF EXISTS istore_agg_combine(internal, internal);
----
DROP FUNCTION IF EXISTS istore_deserial(bytea, internal);
----
DROP FUNCTION IF EXISTS istore_serial(internal);
