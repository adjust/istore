----functions----
CREATE OR REPLACE FUNCTION concat(istore, istore)
 RETURNS istore
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$istore_concat$function$;
----
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
CREATE OR REPLACE FUNCTION delete(bigistore, bigistore)
 RETURNS bigistore
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$bigistore_delete_istore$function$;
----
CREATE OR REPLACE FUNCTION exists_any(bigistore, integer[])
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$bigistore_exists_any$function$;
----
CREATE OR REPLACE FUNCTION exists_all(bigistore, integer[])
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$bigistore_exists_all$function$;
----
CREATE OR REPLACE FUNCTION delete(bigistore, integer[])
 RETURNS bigistore
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$bigistore_delete_array$function$;
----
CREATE OR REPLACE FUNCTION delete(bigistore, integer)
 RETURNS bigistore
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$bigistore_delete$function$;
----
CREATE OR REPLACE FUNCTION slice_array(bigistore, integer[])
 RETURNS integer[]
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$bigistore_slice_to_array$function$;
----
CREATE OR REPLACE FUNCTION slice(bigistore, integer[])
 RETURNS bigistore
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$bigistore_slice$function$;
----
CREATE OR REPLACE FUNCTION istore_to_matrix(bigistore)
 RETURNS integer[]
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$bigistore_to_matrix$function$;
----
CREATE OR REPLACE FUNCTION istore_to_array(bigistore)
 RETURNS integer[]
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$bigistore_to_array$function$;
----
CREATE OR REPLACE FUNCTION concat(bigistore, bigistore)
 RETURNS bigistore
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$bigistore_concat$function$;
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
----
CREATE OR REPLACE FUNCTION delete(istore, istore)
 RETURNS istore
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$istore_delete_istore$function$;
----
CREATE OR REPLACE FUNCTION exists_any(istore, integer[])
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$istore_exists_any$function$;
----
CREATE OR REPLACE FUNCTION exists_all(istore, integer[])
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$istore_exists_all$function$;
----
CREATE OR REPLACE FUNCTION delete(istore, integer[])
 RETURNS istore
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$istore_delete_array$function$;
----
CREATE OR REPLACE FUNCTION delete(istore, integer)
 RETURNS istore
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$istore_delete$function$;
----
CREATE OR REPLACE FUNCTION slice_array(istore, integer[])
 RETURNS integer[]
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$istore_slice_to_array$function$;
----
CREATE OR REPLACE FUNCTION slice(istore, integer[])
 RETURNS istore
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$istore_slice$function$;
----
CREATE OR REPLACE FUNCTION istore_to_matrix(istore)
 RETURNS integer[]
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$istore_to_matrix$function$;
----
CREATE OR REPLACE FUNCTION istore_to_array(istore)
 RETURNS integer[]
 LANGUAGE c
 IMMUTABLE STRICT
AS 'istore', $function$istore_to_array$function$;
----operators----
CREATE OPERATOR ?& (
  PROCEDURE = exists_all,
  LEFTARG = bigistore,
  RIGHTARG = _int4
);

----
CREATE OPERATOR %# (
  PROCEDURE = istore_to_matrix,
  RIGHTARG = bigistore
);

----
CREATE OPERATOR %% (
  PROCEDURE = istore_to_array,
  RIGHTARG = bigistore
);

----
CREATE OPERATOR -> (
  PROCEDURE = slice_array,
  LEFTARG = bigistore,
  RIGHTARG = _int4
);

----
CREATE OPERATOR -> (
  PROCEDURE = slice_array,
  LEFTARG = istore,
  RIGHTARG = _int4
);

----
CREATE OPERATOR || (
  PROCEDURE = concat,
  LEFTARG = bigistore,
  RIGHTARG = bigistore
);

----
CREATE OPERATOR ?| (
  PROCEDURE = exists_any,
  LEFTARG = bigistore,
  RIGHTARG = _int4
);

----
CREATE OPERATOR %# (
  PROCEDURE = istore_to_matrix,
  RIGHTARG = istore
);

----
CREATE OPERATOR %% (
  PROCEDURE = istore_to_array,
  RIGHTARG = istore
);

----
CREATE OPERATOR || (
  PROCEDURE = concat,
  LEFTARG = istore,
  RIGHTARG = istore
);

----
CREATE OPERATOR ?| (
  PROCEDURE = exists_any,
  LEFTARG = istore,
  RIGHTARG = _int4
);

----
CREATE OPERATOR ?& (
  PROCEDURE = exists_all,
  LEFTARG = istore,
  RIGHTARG = _int4
);
