----functions----
CREATE OR REPLACE FUNCTION add(istore, istore)
 RETURNS istore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$istore_add$function$;
----
CREATE OR REPLACE FUNCTION gin_extract_bigistore_key(internal, internal)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$gin_extract_bigistore_key$function$;
----
CREATE OR REPLACE FUNCTION accumulate(istore, integer)
 RETURNS istore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$istore_accumulate$function$;
----
CREATE OR REPLACE FUNCTION accumulate(istore)
 RETURNS istore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$istore_accumulate$function$;
----
CREATE OR REPLACE FUNCTION fill_gaps(istore, integer, integer DEFAULT 0)
 RETURNS istore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$istore_fill_gaps$function$;
----
CREATE OR REPLACE FUNCTION istore(integer[], integer[])
 RETURNS istore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$istore_array_add$function$;
----
CREATE OR REPLACE FUNCTION sum_up(istore, integer)
 RETURNS bigint
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$istore_sum_up$function$;
----
CREATE OR REPLACE FUNCTION sum_up(istore)
 RETURNS bigint
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$istore_sum_up$function$;
----
CREATE OR REPLACE FUNCTION istore(integer[])
 RETURNS istore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$istore_from_intarray$function$;
----
CREATE OR REPLACE FUNCTION divide(istore, integer)
 RETURNS istore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$istore_divide_integer$function$;
----
CREATE OR REPLACE FUNCTION divide(istore, istore)
 RETURNS istore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$istore_divide$function$;
----
CREATE OR REPLACE FUNCTION multiply(istore, integer)
 RETURNS istore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$istore_multiply_integer$function$;
----
CREATE OR REPLACE FUNCTION multiply(istore, istore)
 RETURNS istore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$istore_multiply$function$;
----
CREATE OR REPLACE FUNCTION subtract(istore, integer)
 RETURNS istore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$istore_subtract_integer$function$;
----
CREATE OR REPLACE FUNCTION subtract(istore, istore)
 RETURNS istore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$istore_subtract$function$;
----
CREATE OR REPLACE FUNCTION add(istore, integer)
 RETURNS istore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$istore_add_integer$function$;
----
CREATE OR REPLACE FUNCTION compact(istore)
 RETURNS istore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$istore_compact$function$;
----
CREATE OR REPLACE FUNCTION each("is" istore, OUT key integer, OUT value integer)
 RETURNS SETOF record
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$istore_each$function$;
----
CREATE OR REPLACE FUNCTION fetchval(istore, integer)
 RETURNS integer
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$istore_fetchval$function$;
----
CREATE OR REPLACE FUNCTION exist(istore, integer)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$istore_exist$function$;
----
CREATE OR REPLACE FUNCTION istore_max_transfn(internal, bigistore)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE
AS 'istore', $function$bigistore_max_transfn$function$;
----
CREATE OR REPLACE FUNCTION istore_min_transfn(internal, bigistore)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE
AS 'istore', $function$bigistore_min_transfn$function$;
----
CREATE OR REPLACE FUNCTION istore_sum_transfn(internal, bigistore)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE
AS 'istore', $function$bigistore_sum_transfn$function$;
----
CREATE OR REPLACE FUNCTION istore_to_json(bigistore)
 RETURNS json
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$bigistore_to_json$function$;
----
CREATE OR REPLACE FUNCTION svals(bigistore)
 RETURNS SETOF bigint
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$bigistore_svals$function$;
----
CREATE OR REPLACE FUNCTION skeys(bigistore)
 RETURNS SETOF integer
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$bigistore_skeys$function$;
----
CREATE OR REPLACE FUNCTION avals(bigistore)
 RETURNS bigint[]
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$bigistore_avals$function$;
----
CREATE OR REPLACE FUNCTION akeys(bigistore)
 RETURNS integer[]
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$bigistore_akeys$function$;
----
CREATE OR REPLACE FUNCTION istore_val_smaller(bigistore, bigistore)
 RETURNS bigistore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$bigistore_val_smaller$function$;
----
CREATE OR REPLACE FUNCTION istore_val_larger(bigistore, bigistore)
 RETURNS bigistore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$bigistore_val_larger$function$;
----
CREATE OR REPLACE FUNCTION istore_seed(integer, integer, bigint)
 RETURNS bigistore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$bigistore_seed$function$;
----
CREATE OR REPLACE FUNCTION accumulate(bigistore, integer)
 RETURNS bigistore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$bigistore_accumulate$function$;
----
CREATE OR REPLACE FUNCTION accumulate(bigistore)
 RETURNS bigistore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$bigistore_accumulate$function$;
----
CREATE OR REPLACE FUNCTION fill_gaps(bigistore, integer, bigint DEFAULT 0)
 RETURNS bigistore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$bigistore_fill_gaps$function$;
----
CREATE OR REPLACE FUNCTION istore(integer[], bigint[])
 RETURNS bigistore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$bigistore_array_add$function$;
----
CREATE OR REPLACE FUNCTION bigistore(integer[], bigint[])
 RETURNS bigistore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$bigistore_array_add$function$;
----
CREATE OR REPLACE FUNCTION bigistore(integer[], integer[])
 RETURNS bigistore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$bigistore_array_add$function$;
----
CREATE OR REPLACE FUNCTION sum_up(bigistore, integer)
 RETURNS bigint
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$bigistore_sum_up$function$;
----
CREATE OR REPLACE FUNCTION sum_up(bigistore)
 RETURNS bigint
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$bigistore_sum_up$function$;
----
CREATE OR REPLACE FUNCTION bigistore(integer[])
 RETURNS bigistore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$bigistore_from_intarray$function$;
----
CREATE OR REPLACE FUNCTION divide(bigistore, bigint)
 RETURNS bigistore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$bigistore_divide_integer$function$;
----
CREATE OR REPLACE FUNCTION divide(bigistore, bigistore)
 RETURNS bigistore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$bigistore_divide$function$;
----
CREATE OR REPLACE FUNCTION multiply(bigistore, bigint)
 RETURNS bigistore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$bigistore_multiply_integer$function$;
----
CREATE OR REPLACE FUNCTION multiply(bigistore, bigistore)
 RETURNS bigistore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$bigistore_multiply$function$;
----
CREATE OR REPLACE FUNCTION subtract(bigistore, bigint)
 RETURNS bigistore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$bigistore_subtract_integer$function$;
----
CREATE OR REPLACE FUNCTION subtract(bigistore, bigistore)
 RETURNS bigistore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$bigistore_subtract$function$;
----
CREATE OR REPLACE FUNCTION add(bigistore, bigint)
 RETURNS bigistore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$bigistore_add_integer$function$;
----
CREATE OR REPLACE FUNCTION add(bigistore, bigistore)
 RETURNS bigistore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$bigistore_add$function$;
----
CREATE OR REPLACE FUNCTION compact(bigistore)
 RETURNS bigistore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$bigistore_compact$function$;
----
CREATE OR REPLACE FUNCTION each("is" bigistore, OUT key integer, OUT value bigint)
 RETURNS SETOF record
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$bigistore_each$function$;
----
CREATE OR REPLACE FUNCTION fetchval(bigistore, integer)
 RETURNS bigint
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$bigistore_fetchval$function$;
----
CREATE OR REPLACE FUNCTION exist(bigistore, integer)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$bigistore_exist$function$;
----
CREATE OR REPLACE FUNCTION gin_consistent_istore_key(internal, smallint, internal, integer, internal, internal)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$gin_consistent_istore_key$function$;
----
CREATE OR REPLACE FUNCTION gin_extract_istore_key_query(internal, internal, smallint, internal, internal)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$gin_extract_istore_key_query$function$;
----
CREATE OR REPLACE FUNCTION gin_extract_istore_key(internal, internal)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$gin_extract_istore_key$function$;
----
CREATE OR REPLACE FUNCTION bigistore_agg_finalfn(internal)
 RETURNS bigistore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$bigistore_agg_finalfn_pairs$function$;
----
CREATE OR REPLACE FUNCTION istore_to_json(istore)
 RETURNS json
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$istore_to_json$function$;
----
CREATE OR REPLACE FUNCTION istore_agg_finalfn_pairs(internal)
 RETURNS istore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$istore_agg_finalfn_pairs$function$;
----
CREATE OR REPLACE FUNCTION istore_max_transfn(internal, istore)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE
AS 'istore', $function$istore_max_transfn$function$;
----
CREATE OR REPLACE FUNCTION istore_min_transfn(internal, istore)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE
AS 'istore', $function$istore_min_transfn$function$;
----
CREATE OR REPLACE FUNCTION istore_sum_transfn(internal, istore)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE
AS 'istore', $function$istore_sum_transfn$function$;
----
CREATE OR REPLACE FUNCTION svals(istore)
 RETURNS SETOF integer
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$istore_svals$function$;
----
CREATE OR REPLACE FUNCTION skeys(istore)
 RETURNS SETOF integer
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$istore_skeys$function$;
----
CREATE OR REPLACE FUNCTION avals(istore)
 RETURNS integer[]
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$istore_avals$function$;
----
CREATE OR REPLACE FUNCTION akeys(istore)
 RETURNS integer[]
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$istore_akeys$function$;
----
CREATE OR REPLACE FUNCTION istore_val_smaller(istore, istore)
 RETURNS istore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$istore_val_smaller$function$;
----
CREATE OR REPLACE FUNCTION istore_val_larger(istore, istore)
 RETURNS istore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$istore_val_larger$function$;
----
CREATE OR REPLACE FUNCTION istore_seed(integer, integer, integer)
 RETURNS istore
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$istore_seed$function$;
----
CREATE OR REPLACE FUNCTION istore_min_combine(internal, internal)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE
AS 'istore', $function$istore_min_combine$function$;
----
CREATE OR REPLACE FUNCTION istore_max_combine(internal, internal)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE
AS 'istore', $function$istore_max_combine$function$;
----
CREATE OR REPLACE FUNCTION istore_sum_combine(internal, internal)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE
AS 'istore', $function$istore_sum_combine$function$;
----
CREATE OR REPLACE FUNCTION istore_deserial(bytea, internal)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$istore_deserial$function$;
----
CREATE OR REPLACE FUNCTION istore_serial(internal)
 RETURNS bytea
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS 'istore', $function$istore_serial$function$;
